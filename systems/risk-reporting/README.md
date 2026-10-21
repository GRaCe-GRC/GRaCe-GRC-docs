# Risk Assessment Compliance Scoring and Reporting Platform

**Initiative:** Risk & Reporting

## Purpose
_One paragraph: what problem this system solves and for whom._

## Scope
- In scope: _..._
- Out of scope: _..._

## Components
```mermaid
flowchart LR
    bus{{Event bus}} --> scoring[Scoring engine]
    register[Risk register] --> scoring
    scoring --> scores[(Scores)]
    scores --> reports[Report generator]
    reports --> exports[PDF / dashboard exports]
```

## Key flows
- [Compliance scoring and reporting](../../flows/scoring-and-reporting.md)

## Interfaces
| Interface | Direction | Description |
|---|---|---|
| _REST /api/..._ | inbound | _..._ |
| _event ..._ | outbound | _..._ |

## Related
- [Containers](../../architecture/02-containers.md)
- ADRs: _link relevant ADRs_
