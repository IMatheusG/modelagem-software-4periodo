Diagrama de Sequência (DTO)
disponivelDto = {
    "disponivel": True,
    "id_sala": 1
}

reservadoDto = {
    "status_code": 200,
    "reservado": True,
    "id_professor": 1,
    "id_sala": 1,
    "data_reserva": "2026-11-10",
    "horario_reserva": "19:00"
}

falhaReservaDto = {
    "status_code": 400,
    "reservado": False,
    "alerta": "Sala não disponível nesta data e horário"
}


📄 Artefato 3: Diagrama de Transição de Estados (State Machine / DaC)
Objetivo: Mapear o ciclo de vida rigoroso da entidade de domínio principal (ex.: Reserva, OrdemServico, LoteResiduo, VeiculoAGV).
Requisitos Técnicos:
Utilizar sintaxe Mermaid (stateDiagram-v2) ou PlantUML.
Mapear o estado inicial (*), subestados e pelo menos um estado terminal.
Aplicar a sintaxe formal de transição em pelo menos duas setas:

oDeEfeito()
Gatilho [Condic¸​a˜oDeGuarda] / Ac¸​a˜oDeEfeito()

Incluir em pelo menos um estado os compartimentos de ações internas (entry /, do / ou exit /).


📄 Artefato 5: Registro de Decisão Arquitetural (ADR 0001)
Objetivo: Documentar e justificar a escolha de uma decisão de infraestrutura ou padrão da funcionalidade.
Estrutura Obrigatória da ADR (Formato Nygard):
Título: ADR 0001 — [Nome da Decisão]
Status: [Aprovado / Proposto]
Contexto: Qual o problema técnico ou de negócio a ser resolvido?
Decisão: Qual tecnologia, protocolo ou padrão foi adotado e por quê?
Consequências: Quais são as vantagens geradas e os débitos/riscos aceitos?