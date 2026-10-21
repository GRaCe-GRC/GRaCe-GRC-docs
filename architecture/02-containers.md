# Containers

The deployable pieces of GRaCe-GRC and how they communicate.

```mermaid
flowchart TB
    user([Users]) --> console

    subgraph ui[Admin Console]
        console[Angular SPA]
    end

    console -->|HTTPS / REST| gateway[API Gateway]

    subgraph services[Spring Boot microservices]
        mapping[Control Mapping Service]
        monitoring[Compliance Monitoring Service]
        evidence[Audit Evidence Service]
        risk[Risk & Scoring Service]
        reporting[Reporting Service]
    end

    gateway --> mapping
    gateway --> monitoring
    gateway --> evidence
    gateway --> risk
    gateway --> reporting

    bus{{Event bus}}
    monitoring -->|control.check.completed| bus
    evidence -->|evidence.collected| bus
    bus --> risk
    bus --> reporting

    mapping --> mdb[(Mapping DB)]
    evidence --> store[(Evidence store)]
    risk --> rdb[(Risk DB)]
```

| Container | Technology | Owner initiative |
|---|---|---|
| Admin Console | TypeScript, Angular | All |
| Control Mapping Service | Java, Spring Boot | Control Mapping |
| Compliance Monitoring Service | Java, Spring Boot | Continuous Compliance |
| Audit Evidence Service | Java, Spring Boot | Continuous Compliance |
| Risk & Scoring Service | Java, Spring Boot | Risk & Reporting |
| Reporting Service | Java, Spring Boot | Risk & Reporting |

> Draft: service boundaries, the event bus technology and data stores are still to be decided. Record each decision as an ADR.
