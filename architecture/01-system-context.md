# System context

Who uses GRaCe-GRC and which external systems it talks to.

```mermaid
flowchart LR
    admin([GRC Administrator])
    owner([Control Owner])
    auditor([Auditor])

    subgraph grace[GRaCe-GRC Platform]
        console[Admin Console]
        platform[GRC Services]
    end

    frameworks[(Regulatory frameworks<br/>ISO 27001, SOC 2, NIST...)]
    sources[(Evidence sources<br/>cloud, CI/CD, ticketing, IAM)]
    idp[(Identity provider)]

    admin --> console
    owner --> console
    auditor --> console
    console --> platform
    platform --> frameworks
    platform --> sources
    console --> idp
```

## Actors
- **GRC Administrator**: manages frameworks, controls and mappings.
- **Control Owner**: owns controls and responds to failures.
- **Auditor**: reviews evidence and reports.

## Open questions
- Which frameworks are in scope for the first release?
- Which evidence sources come first?
