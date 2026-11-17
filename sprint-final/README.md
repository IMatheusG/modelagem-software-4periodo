# Smart Campus UniSenai — Documentação Arquitetural e Resiliência

**Equipe (JavaStrippers):** Henrique Chitolina, Tiago Schimitz, Tiago Henrique, Nicolas Machado, Matheus Thimoteo

**Projeto:** Controle de Acesso Biométrico Integrado à Gestão de Eficiência Energética em Laboratórios

## Estrutura de Pastas do Repositório

```text
docs/
├── architecture/
│   ├── c4-nivel2-containers.mmd
│   ├── c4-nivel2-containers.md
│   ├── diagrama-sequencia-resiliencia.mmd
│   ├── diagrama-sequencia-resiliencia.md
│   ├── diagrama-classes-componentes.mmd
│   └── diagrama-classes-componentes.md
└── adr/
    └── 0001-escolha-tecnologica.md
```

## Passo 4: Checklist de Auditoria Final 

- [x] **Consistência Nomes/Métodos:** Os nomes dos contêineres e serviços no C4 Nível 2 (`Leitor Biométrico`, `API Gateway e IoT Broker`, `Serviço de Orquestração de Acesso e Energia`, `Banco de Dados Principal`, `Cache de Estado e Timers`, `Message Broker`, `Worker de Automação e Alertas`, `Dispositivos IoT`, `Serviço Externo de E-mail`) são idênticos aos participantes do Diagrama de Sequência.
- [x] **Sintaxe Compilável:** Todos os arquivos `.md` e `.mmd` utilizam sintaxe oficial Mermaid (`C4Container`, `sequenceDiagram`, `classDiagram`) validada para renderização nativa no GitHub e no Mermaid Live Editor.
- [x] **Desacoplamento por Interfaces:** O Diagrama de Classes e Componentes (`docs/architecture/diagrama-classes-componentes.mmd`) demonstra explicitamente o uso de interfaces (`IPermissaoRepository`, `IAcessoRepository`, `IEstadoOcupacaoCache`, `IEventoPublisher`, `IDispositivoAtuadorGateway`, `IGradeHorariaProvider`, `INotificacaoService`) e Injeção de Dependência via construtor.
- [x] **Rastreabilidade no Git:** Todos os artefatos estão organizados na estrutura `/docs/architecture/` e `/docs/adr/`.
