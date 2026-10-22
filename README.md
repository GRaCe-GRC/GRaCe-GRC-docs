# GRaCe-GRC Documentation Hub

Architecture, processing flows, data model and decisions for the GRaCe-GRC platform.

## Start here
| Section | What's in it |
|---|---|
| [Solution architecture](architecture/README.md) | How the three projects fit together |
| [Roadmap](architecture/roadmap.md) | Phased timeline and the solution at the end of each phase |
| [End-to-end trace](architecture/end-to-end-trace.md) | One requirement followed through all three projects |
| [Data model](data-model/README.md) | Simplified and complete data models |
| [Repositories](architecture/repositories.md) | Which repository holds each component |
| [ADRs](adr/README.md) | Architecture Decision Records |
| [Glossary](glossary.md) | GRC and platform terms |

## Systems
| Project | Architecture, processing flow and data model |
|---|---|
| 1 | [Federated Regulatory Control Mapping System](systems/control-mapping/README.md) |
| 2 | [Continuous Compliance Monitoring and Automated Audit Evidence System](systems/continuous-compliance/README.md) |
| 3 | [Risk Assessment Compliance Scoring and Reporting Platform](systems/risk-reporting/README.md) |

## Diagrams
Every diagram lives in [`assets/diagrams/`](assets/diagrams/) in four forms:

| File | Purpose |
|---|---|
| `*.mmd` | Mermaid source: **the file you edit** |
| `*.svg`, `*.png` | Rendered from the `.mmd` by `scripts/build-diagrams.sh` |
| `*.original.png` | The original figure, kept for reference |

Markdown pages embed the Mermaid so GitHub renders it. After editing a `.mmd`, run
`scripts/build-diagrams.sh` to regenerate the SVG and PNG and update the embedded copies.

> **This repository is public.** Keep hostnames, account IDs, network details and secrets flows out of it.

## License
Content in this repository is licensed under [CC BY 4.0](LICENSE).
