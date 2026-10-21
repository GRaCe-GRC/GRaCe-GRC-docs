# Data model

Each project owns its own databases. Links between projects are identifiers (marked **REF**),
read through the owning project's internal service API, not foreign keys.

## Simplified data model

**Figure 14.1: Simplified data model**

<!-- mermaid-source: assets/diagrams/data-model/fig-14-1-simplified-data-model.mmd -->
```mermaid
---
title: "Simplified data model (attributes are illustrative; dotted lines = references across projects by ID)"
---
erDiagram

  regulatory_authority {
    uuid id PK
    varchar name
    varchar jurisdiction
  }
  regulatory_framework {
    uuid id PK
    uuid authority_id FK
    varchar name
    varchar citation
  }
  regulatory_file {
    uuid id PK
    uuid framework_id FK
    varchar version
    date effective_date
  }
  regulatory_requirement {
    uuid id PK
    uuid file_id FK
    varchar provision_ref
    text text
  }
  catalog {
    uuid id PK
    varchar version
    enum status
    text oscal_file_uri
  }
  control {
    uuid id PK
    varchar oscal_control_id
    int version
    enum status
  }
  control_mapping {
    uuid id PK
    uuid requirement_id FK
    uuid control_id FK
    uuid risk_id FK
    enum status
  }
  risk {
    uuid id PK
    varchar name
    enum category
    smallint likelihood
    smallint impact
  }
  control_configuration {
    uuid id PK
    varchar control_id "REF"
    int version
    jsonb test_procedure
    enum status
  }
  connector {
    uuid id PK
    enum type
    text endpoint
    varchar secret_ref
    enum status
  }
  assessment {
    uuid id PK
    enum trigger
    timestamp started_at
    enum status
  }
  assessment_result {
    uuid id PK
    uuid assessment_id FK
    uuid config_id FK
    enum result
    enum status
  }
  evidence {
    uuid id PK
    uuid result_id FK
    uuid connector_id FK
    text s3_uri
    char(64) sha256
    enum status
  }
  scoring_methodology {
    uuid id PK
    varchar version
    jsonb weights
    date effective_date
  }
  score {
    uuid id PK
    uuid methodology_id FK
    decimal overall_score
    enum status
  }
  finding {
    uuid id PK
    uuid result_id "REF"
    uuid risk_id "REF"
    boolean compliant
    enum severity
  }
  remediation {
    uuid id PK
    uuid finding_id FK
    uuid verified_by "REF"
    enum status
  }
  report {
    uuid id PK
    uuid score_id FK
    int version
    enum status
    char(64) sha256
  }
  submission {
    uuid id PK
    uuid report_id FK
    uuid authority_id "REF"
    enum status
    timestamp submitted_at
  }

  regulatory_authority ||--o{ regulatory_framework : ""
  regulatory_framework ||--o{ regulatory_file : ""
  regulatory_file ||--o{ regulatory_requirement : ""
  regulatory_requirement ||--o{ control_mapping : ""
  control ||--o{ control_mapping : ""
  risk ||--o{ control_mapping : ""
  catalog }o--o{ control : "join table"
  control_configuration }o--o{ connector : "join table"
  control_configuration ||--o{ assessment_result : ""
  assessment ||--o{ assessment_result : ""
  assessment_result ||--o{ evidence : ""
  connector ||--o{ evidence : ""
  scoring_methodology ||--o{ score : ""
  score }o--o{ finding : "join table"
  score ||--o{ report : ""
  report ||--o{ submission : ""
  finding ||--o{ remediation : ""
  report }o--o{ remediation : "join table"
  control ||..o{ control_configuration : "ref across projects"
  assessment_result ||..o{ finding : "ref across projects"
  risk ||..o{ finding : "ref across projects"
  regulatory_authority ||..o{ submission : "ref across projects"
  assessment_result ||..o{ remediation : "closed-loop verification"
```
<!-- /mermaid-source -->

Files: [SVG](../assets/diagrams/data-model/fig-14-1-simplified-data-model.svg) · [PNG](../assets/diagrams/data-model/fig-14-1-simplified-data-model.png) · [Original](../assets/diagrams/data-model/fig-14-1-simplified-data-model.original.png) · [Mermaid source](../assets/diagrams/data-model/fig-14-1-simplified-data-model.mmd)

## Complete data model

The full model is large, so it is linked rather than embedded:

**Complete data model, Projects 1, 2 and 3**

![Complete data model, Projects 1, 2 and 3](../assets/diagrams/data-model/data-model-complete.svg)

Files: [SVG](../assets/diagrams/data-model/data-model-complete.svg) · [PNG](../assets/diagrams/data-model/data-model-complete.png) · [Original](../assets/diagrams/data-model/data-model-complete.original.png) · [Mermaid source](../assets/diagrams/data-model/data-model-complete.mmd)

Per project:
- [Figure 14.2: Project 1](../systems/control-mapping/README.md#data-model)
- [Figure 14.3: Project 2](../systems/continuous-compliance/README.md#data-model)
- [Figure 14.4: Project 3](../systems/risk-reporting/README.md#data-model)

Self-referencing links: `regulatory_file.supersedes_file_id`, `regulatory_requirement.parent_requirement_id`,
`control.parent_control_id` (control enhancements), `control_group.parent_group_id`, `catalog.previous_catalog_id`.
