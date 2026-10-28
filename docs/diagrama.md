```mermaid
flowchart TD
    subgraph Professor
        direction TB
        start(( )) --> req[Solicitar sala\ndata e horário]
        alt_choice[Escolher outro\nhorário ou sala] --> req
        conf[Receber aviso\nde confirmação]
    end

    subgraph Smart_Campus [Smart Campus]
        direction TB
        rec_req[Receber pedido\nde agendamento] --> check{Sala livre?}
        check -- NÃO --> alt_choice
        check -- SIM --> res[Reservar sala\ncria agendamento]
        res --> send_cmd[Enviar comando\nligar no horário]
    end

    subgraph Grade_horaria [Grade horária]
        direction TB
        grade[Fornecer grade\nde aulas e salas]
    end

    subgraph Equipamentos
        direction TB
        rcv_cmd[Receber comando\ne agendar início] --> wait[Início agendado\naguarda o horário]
        wait --> end_node(( ))
    end

    req --> rec_req
    grade --> check
    res --> conf
    send_cmd --> rcv_cmd