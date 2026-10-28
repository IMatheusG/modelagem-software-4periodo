workspace "Smart Campus - Processo de Agendamento" {

    model {
        professor = person "Professor" "Professor que solicita salas e horários."
        
        enterprise "Smart Campus Enterprise" {
            smartCampusSystem = softwareSystem "Smart Campus System" "Sistema central de gerenciamento." {
                agendamentoComponent = component "Módulo de Agendamento" "Recebe pedidos e verifica disponibilidade."
                automacaoComponent = component "Módulo de Automação" "Envia comandos para ligar equipamentos."
            }
            
            gradeSystem = softwareSystem "Sistema de Grade Horária" "Fornece a grade de aulas e salas."
            
            equipamentosSystem = softwareSystem "Sistema de Equipamentos" "Gerencia o início agendado."
        }

        # Relações de fluxo dinâmico
        professor -> agendamentoComponent "1. Solicitar sala (data e horário)"
        agendamentoComponent -> gradeSystem "2. Consultar grade"
        gradeSystem -> agendamentoComponent "3. Fornecer grade de aulas e salas"
        agendamentoComponent -> professor "4. Escolher outro horário ou receber confirmação"
        agendamentoComponent -> automacaoComponent "5. Reservar sala e enviar comando"
        automacaoComponent -> equipamentosSystem "6. Receber comando e agendar início"
    }

    views {
        dynamic smartCampusSystem "FluxoAgendamento" "Fluxo dinâmico do processo de agendamento do Smart Campus." {
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