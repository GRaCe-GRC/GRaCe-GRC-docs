# Continuous Compliance Monitoring and Automated Audit Evidence System

**Initiative:** Continuous Compliance

## Purpose
_One paragraph: what problem this system solves and for whom._

## Scope
- In scope: _..._
- Out of scope: _..._

## Components
```mermaid
flowchart LR
    scheduler[Check scheduler] --> runners[Check runners]
    runners --> connectors[Source connectors]
    runners --> results[(Check results)]
    connectors --> collector[Evidence collector]
    collector --> store[(Evidence store)]
    results -->|events| bus{{Event bus}}
```

## Key flows
- [Automated evidence collection](../../flows/evidence-collection.md)

## Interfaces
| Interface | Direction | Description |
|---|---|---|
| _REST /api/..._ | inbound | _..._ |
| _event ..._ | outbound | _..._ |

## Related
- [Containers](../../architecture/02-containers.md)
- ADRs: _link relevant ADRs_
