```mermaid
workspace "Smart Campus - Processo de Agendamento" {

    model {
        professor = person "Professor" "Professor que solicita salas e horários[cite: 1]."
        
        enterprise "Smart Campus Enterprise" {
            smartCampusSystem = softwareSystem "Smart Campus System" "Sistema central de gerenciamento[cite: 1]." {
                agendamentoComponent = component "Módulo de Agendamento" "Recebe pedidos e verifica disponibilidade[cite: 1]."
                automacaoComponent = component "Módulo de Automação" "Envia comandos para ligar equipamentos[cite: 1]."
            }
            
            gradeSystem = softwareSystem "Sistema de Grade Horária" "Fornece a grade de aulas e salas[cite: 1]."
            
            equipamentosSystem = softwareSystem "Sistema de Equipamentos" "Gerencia o início agendado[cite: 1]."
        }

        # Relações de fluxo dinâmico
        professor -> agendamentoComponent "1. Solicitar sala (data e horário)"
        agendamentoComponent -> gradeSystem "2. Consultar grade"
        gradeSystem -> agendamentoComponent "3. Fornecer grade de aulas e salas"
        agendamentoComponent -> professor "4. Escolher outro horário (se ocupado) ou receber confirmação"
        agendamentoComponent -> automacaoComponent "5. Reservar sala e enviar comando"
        automacaoComponent -> equipamentosSystem "6. Receber comando e agendar início"
    }

    views {
        dynamic smartCampusSystem "FluxoAgendamento" "Fluxo dinâmico do processo de agendamento do Smart Campus[cite: 1]." {
            include *
            autoLayout
        }

        styles {
            element "Person" {
                background #08427b
                color #ffffff
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
        }
    }
}
