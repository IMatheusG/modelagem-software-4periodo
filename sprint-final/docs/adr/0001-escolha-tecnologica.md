# ADR 0001: Adoção de Mensageria Assíncrona (RabbitMQ) e Cache Distribuído (Redis) para Desacoplamento entre Controle de Acesso Biométrico e Automação Energética

## Status

Aceito

## Contexto

No domínio do **Smart Campus UniSenai**, o controle de acesso biométrico aos laboratórios está diretamente integrado à governança de eficiência energética. O mesmo evento físico que comprova a identidade e a permissão de um usuário em um `Ambiente` dispara a abertura de uma `Sessão de Uso` (`Modo Operacional`), comanda o acionamento imediato da iluminação e bancadas, controla a janela de tolerância de 15 minutos para desligamento do ar-condicionado (`Perfil Energético`), realiza pré-condicionamento via grade horária (`Política de Agendamento`) e monitora anomalias de consumo sem ocupação (`Alerta de Desperdício`).

Em uma topologia puramente síncrona, a validação biométrica na porta do laboratório ficaria acoplada à disponibilidade e latência dos atuadores IoT, de consultas pesadas ao banco relacional (`PostgreSQL`) e do serviço externo de notificações por e-mail. Além disso, manter o contador de ocupação ativa e os temporizadores de 15 minutos em memória local criaria um Ponto Único de Falha (SPOF), violando os invariantes de segurança e disponibilidade operacional do campus.

## Decisão

Decidimos adotar uma arquitetura orientada a eventos e resiliente a falhas composta por:

1. **RabbitMQ como Message Broker Assíncrono:** Desacoplar o `Serviço de Orquestração de Acesso e Energia` do `Worker de Automação e Alertas`. Eventos de domínio (`OccupancyEvent`, `WasteAlert`) e registros pendentes de auditoria (`AccessLogPendente`) são publicados via protocolo AMQP. Falhas em integrações externas (como indisponibilidade do `Serviço Externo de E-mail`) são tratadas por filas de retentativa com *backoff* exponencial e *Dead Letter Queue* (`dlq.notificacoes`).
2. **Redis como Cache Distribuído de Estado e Timers:** Externalizar o estado em tempo real de ocupação de cada `Ambiente` (`Vazio`, `Ocupado`, `Pré-condicionado`), a contagem atômica de usuários presentes na `Sessão de Uso`, o agendamento da janela de tolerância de 15 minutos do ar-condicionado e o cache de *fallback* de permissões críticas para suportar *timeouts* superiores a 3 segundos no `Banco de Dados Principal` (PostgreSQL).

## Consequências Positivas

- **Baixa Latência no Acesso Físico:** A resposta ao `Leitor Biométrico` ocorre em milissegundos, sem aguardar o acionamento físico dos dispositivos IoT ou o envio de e-mails.
- **Resiliência e Tolerância a Falhas (Chaos Engineering):** Estouros de *timeout* (> 3s) no PostgreSQL são mitigados por *Circuit Breaker* e *fallback* no Redis com persistência assíncrona eventual via RabbitMQ; falhas no serviço de e-mail não interrompem a automação energética.
- **Eliminação de SPOF e Escalabilidade Horizontal:** Múltiplas instâncias do orquestrador e dos *workers* podem operar simultaneamente compartilhando estado consistente no Redis e balanceando consumo de filas no RabbitMQ.
- **Extensibilidade Orientada a Eventos:** Novos módulos (painéis analíticos de demanda do campus, auditoria avançada) podem consumir eventos de ocupação e desperdício sem modificar o núcleo de validação biométrica.

## Consequências Negativas (Trade-offs)

- **Maior Complexidade Operacional e de Infraestrutura:** A equipe precisa provisionar, monitorar e manter instâncias de RabbitMQ e Redis além do banco relacional PostgreSQL.
- **Consistência Eventual nos Efeitos Colaterais:** Existe uma janela assíncrona de alguns milissegundos entre a liberação da porta e o acionamento dos atuadores IoT ou a gravação de logs enfileirados em modo degradado.
- **Necessidade de Idempotência nos Consumidores:** O `Worker de Automação e Alertas` deve implementar chaves de idempotência para evitar comandos repetidos aos atuadores em caso de reentrega de mensagens pelo RabbitMQ.
