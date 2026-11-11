# Documentação APS3 - Entidade Reserva do FabLab

## 1. Diagrama C4 (Nível 3)

### Descrição
Este diagrama descreve a estrutura interna da **API de Sensores e Atuadores** (desenvolvida em Node.js), sua interação com a camada de dados MySQL e o controle dos dispositivos físicos instalados nos ambientes.

### Explicação dos Componentes
* **Controlador de Segurança:** Atua na camada de borda/autenticação da API, garantindo a validação de permissões no banco de dados e repassando requisições validadas para a camada de serviço.
* **Service - Regras de Controles:** Núcleo de regras de negócio. Responsável por consultar a situação atual dos dispositivos no MySQL e enviar comandos de programação e configuração aos componentes físicos.
* **Banco de Dados MySQL:** Responsável pela persistência de permissões, perfis de acesso, logs e estados dos dispositivos.
* **Sensores e Atuadores:** 
  * **Atuador:** Dispositivo de saída acionado pela API (ex.: travas eletrônicas, retransmissores de energia, ar-condicionado).
  * **Sensor:** Dispositivo de entrada parametrizado pela API (ex.: sensores de presença, temperatura e luminosidade).

---

## 2. Diagrama de Sequência

### Descrição
O diagrama de sequência especifica a troca de mensagens síncronas e assíncronas entre as partes envolvidas durante o processo de reserva de um ambiente por um docente.

### DTOs

Abaixo estão especificadas as estruturas de dados transmitidas entre as camadas durante o fluxo do Diagrama de Sequência:

### 🔹 `disponivelDto`
Objeto retornado pelo `Repository` para o `Service` informando o status de checagem do ambiente:
```json
{
  "disponivel": true,
  "id_sala": 1
}
```

### 🔹 `reservadoDto`
Payload de sucesso emitido após a persistência da reserva no banco de dados e retornado com status **HTTP 200**:
```json
{
  "status_code": 200,
  "reservado": true,
  "id_professor": 1,
  "id_sala": 1,
  "data_reserva": "2026-11-10",
  "horario_reserva": "19:00"
}
```

### 🔹 `falhaReservaDto`
Payload de exceção/falha retornado ao cliente com status **HTTP 400** quando a sala não está disponível:
```json
{
  "status_code": 400,
  "reservado": false,
  "alerta": "Sala não disponível nesta data e horário"
}
```

### Passo a Passo do Fluxo
1. **Requisição:** O `Professor` aciona a interface no `APP`, que faz uma chamada `POST /app/reserva` para a camada `Service`.
2. **Checagem:** O `Service` consulta o `Repository` para verificar se o recurso está disponível no horário solicitado.
3. **Decisão Alternativa (`alt / else`):**
   * **Caminho de Sucesso (`disponivel = true`):**
     * O `Repository` efetiva o registro (`reservado = true`).
     * A notificação é registrada na mensageria via **RabbitMQ** (`reserva = ok`).
     * O `Service` devolve status **HTTP 200** para o aplicativo.
     * O aplicativo notifica o usuário com um alerta de sucesso.
     * O `Service` agenda assincronamente a inicialização dos **Equipamentos** da sala.
   * **Caminho de Falha (`disponivel = false`):**
     * O `Service` interrompe o fluxo e retorna **HTTP 400** contendo o payload de erro (`falhaReservaDto`).
     * O `APP` exibe a mensagem de falha ao professor.

---

## 3. Diagrama de Atividades com Raias

### Descrição
Este diagrama reorganiza o fluxo de controle sob a perspectiva procedimental, dividindo o processo em **raias** que deixam claras as responsabilidades de cada ator ou subsistema.

### Responsabilidade das Raias
* **Raia Professor:** Início do processo (`nó inicial`) e consumo do resultado final (`nós terminais`).
* **Raia APP:** Mediação de interface, serialização dos dados HTTP e exibição de alertas.
* **Raia Service:** Orquestração do fluxo, tomada de decisão condicional (`disponível?`) e encadeamento dos efeitos colaterais.
* **Raia Repository:** Execução de operações de leitura e gravação no banco de dados.
* **Raia RabbitMQ:** Publicação de eventos para integração orientada a eventos.
* **Raia Equipamentos:** Agendamento de rotinas de hardware nos ambientes reservados.

---

## 4. Diagrama de Transição de Estados

### Descrição
Mapeia o ciclo de vida rigoroso da entidade de domínio **Reserva**, especificando os estados, subestados concorrentes/compostos, gatilhos, condições de guarda e ações de efeito.

### Estrutura Formal dos Estados
* **Estado Inicial (`[*]`):** Transição inicial para a situação `Solicitada`.
* **Subestado Composto (`EmAnalise`):** Agrupa a verificação interna de regras de negócio.
  * O subestado interno inicia em `ChecandoDisponibilidade`.
  * Avalia as guardas `[disponivel == true]` ou `[disponivel == false]`, bifurcando a análise interna entre `Aprovada` ou `Recusada`.
* **Sintaxe Formal de Transição (`Gatilho [Guarda] / Ação`):**
  * **Transição de Sucesso:**  
    `confirmarReserva [disponivel == true] / alertarUsuarioSucesso()` transiciona de `EmAnalise` para `SalaReservada`.
  * **Transição de Falha:**  
    `rejeitarReserva [disponivel == false] / alertarUsuarioFalha()` transiciona de `EmAnalise` para `SolicitationCancelada`.
* **Estados Terminais (`[*]`):** Os estados finais `SalaReservada` e `SolicitationCancelada` concluem o ciclo de vida da entidade.

---

## 5. ADR
### Descrição
Está contida no architecture/ e define a esoclha de node.js para ser utilizado na api dos sensores e atuadores.