# Passo 2: Engenharia de Chaos e Resiliência no Diagrama de Sequência

## Cenários de Falha Injetados

1. **Timeout > 3 segundos no Banco de Dados Principal (PostgreSQL):**
   - O `Serviço de Orquestração de Acesso e Energia` aplica um *timeout* rígido de 3000ms na consulta de identidade e permissão.
   - Em caso de estouro, aciona fallback no `Cache de Estado e Timers` (Redis). Se a permissão pré-sincronizada existir em cache, libera o acesso e enfileira o registro de auditoria (`AccessLogPendente`) no `Message Broker` (RabbitMQ) para persistência eventual. Caso não exista em cache, aplica *fail-closed* seguro (nega acesso e não energiza equipamentos, respeitando os invariantes do domínio).
2. **Indisponibilidade do Serviço Externo de E-mail:**
   - Caso o `Serviço Externo de E-mail` retorne erro `503` ou *timeout*, o `Worker de Automação e Alertas` não bloqueia o acionamento dos `Dispositivos IoT` e encaminha a notificação para uma fila de retentativas (`retry.notificacoes`) no `Message Broker` com *backoff* exponencial (5s, 15s, 45s) e *Dead Letter Queue* (`dlq.notificacoes`).

## Diagrama de Sequência Resiliente

```mermaid
sequenceDiagram
    autonumber
    actor usuario as Usuário do Campus
    participant leitor_biometrico as Leitor Biométrico
    participant api_gateway as API Gateway e IoT Broker
    participant orquestrador_service as Serviço de Orquestração de Acesso e Energia
    participant database as Banco de Dados Principal
    participant cache_estado as Cache de Estado e Timers
    participant message_broker as Message Broker
    participant energia_worker as Worker de Automação e Alertas
    participant rede_iot as Dispositivos IoT
    participant servico_notificacao as Serviço Externo de E-mail

    usuario->>leitor_biometrico: Apresenta Credencial Biométrica (Facial/Digital)
    leitor_biometrico->>api_gateway: POST /acessos/validar (credencial, ambienteId)
    api_gateway->>orquestrador_service: validarAcesso(credencial, ambienteId)

    Note over orquestrador_service,database: Cenário Chaos 1: Latência/Timeout > 3s no PostgreSQL
    orquestrador_service->>database: SELECT Usuario, Permissao WHERE ambienteId AND horarioAtual

    alt Resposta do Banco <= 3000ms (Fluxo Normal)
        database-->>orquestrador_service: Identidade e Permissão Válidas
        orquestrador_service->>database: INSERT AccessLog (imutável)
        orquestrador_service->>cache_estado: SET Ambiente=Ocupado, SessaoDeUso=Ativa, presentes=1
        orquestrador_service--)message_broker: Publica OccupancyEvent (AmbienteOcupado)
        orquestrador_service-->>api_gateway: 200 OK (Acesso Concedido)
        api_gateway-->>leitor_biometrico: Libera Trava Física
        leitor_biometrico-->>usuario: Porta Liberada
    else Timeout > 3000ms ou Falha no Banco (Fallback Resiliente)
        database--xorquestrador_service: TimeoutException (> 3000ms)
        orquestrador_service->>cache_estado: GET fallback:permissao:{usuarioId}:{ambienteId}
        alt Permissão encontrada no Cache de Fallback
            cache_estado-->>orquestrador_service: Permissão Válida em Cache
            orquestrador_service->>cache_estado: SET Ambiente=Ocupado, SessaoDeUso=Ativa, presentes=1
            orquestrador_service--)message_broker: Enfileira AccessLogPendente (persistência eventual)
            orquestrador_service--)message_broker: Publica OccupancyEvent (AmbienteOcupado)
            orquestrador_service-->>api_gateway: 200 OK (Acesso Concedido - Modo Degradado)
            api_gateway-->>leitor_biometrico: Libera Trava Física
            leitor_biometrico-->>usuario: Porta Liberada
        else Sem Permissão em Cache (Fail-Closed Seguro)
            cache_estado-->>orquestrador_service: Cache Miss
            orquestrador_service-->>api_gateway: 503 / 403 Acesso Negado (Invariante de Segurança)
            api_gateway-->>leitor_biometrico: Mantém Trava Bloqueada
            leitor_biometrico-->>usuario: Acesso Negado (Tente Novamente)
        end
    end

    Note over message_broker,servico_notificacao: Processamento Assíncrono de Energia e Chaos 2 (E-mail Indisponível)
    message_broker--)energia_worker: Consome OccupancyEvent (AmbienteOcupado)
    energia_worker->>rede_iot: MQTT Publish: Ligar Iluminação, Ar-Condicionado e Bancadas
    rede_iot-->>energia_worker: ACK Atuadores Energizados

    energia_worker->>servico_notificacao: POST /send (Notificação de Início de Sessão / Auditoria)
    alt Serviço de E-mail Disponível (200 OK)
        servico_notificacao-->>energia_worker: 200 OK (Notificação Enviada)
    else Serviço Externo de E-mail Indisponível (Timeout / 503)
        servico_notificacao--xenergia_worker: 503 Service Unavailable
        energia_worker--)message_broker: Publica na fila retry.notificacoes (Backoff Exponencial: 5s, 15s, 45s)
        loop Retentativa Assíncrona (até 3 tentativas)
            message_broker--)energia_worker: Reentrega mensagem de notificação
            energia_worker->>servico_notificacao: POST /send (Retentativa)
        end
        Note right of message_broker: Se falhar após 3 tentativas, move para dlq.notificacoes sem afetar energia
    end
```
