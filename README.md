# GRaCe-GRC Documentation Hub

Architecture, flows and decisions for the GRaCe-GRC platform.

## Start here
| Section | What's in it |
|---|---|
| [Architecture](architecture/README.md) | System context, containers, deployment |
| [Systems](systems/) | One page per initiative, with components and key flows |
| [Flows](flows/README.md) | End-to-end sequence and data-flow diagrams |
| [ADRs](adr/README.md) | Architecture Decision Records |
| [Glossary](glossary.md) | GRC and platform terms |

## Systems
- [Federated Regulatory Control Mapping System](systems/control-mapping/README.md)
- [Continuous Compliance Monitoring and Automated Audit Evidence System](systems/continuous-compliance/README.md)
- [Risk Assessment Compliance Scoring and Reporting Platform](systems/risk-reporting/README.md)

## Conventions
- Diagrams are written in **Mermaid** inside Markdown, so GitHub renders them and changes are reviewable in pull requests.
- Architecture views follow the **C4 model**: context → containers → components.
- Significant decisions get an ADR (copy `adr/0000-template.md`).
- **This repository is public.** Keep hostnames, IPs, network topology, secrets flows and anything else that helps an attacker out of it.

## License
Content in this repository is licensed under [CC BY 4.0](LICENSE).
