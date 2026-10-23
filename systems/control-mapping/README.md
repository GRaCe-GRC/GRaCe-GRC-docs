# Project 1: Federated Regulatory Control Mapping System

Acquires regulatory files, uses retrieval-augmented generation (RAG) and an LLM to propose controls and control mappings, routes every proposal through expert review, and publishes approved results as OSCAL catalogs.

## Architecture

**Figure 10.1: Proposed high-level software architecture**

<!-- mermaid-source: assets/diagrams/control-mapping/fig-10-1-architecture.mmd -->
```mermaid
---
title: Federated Regulatory Control Mapping System
---
flowchart TB
  reviewers["Compliance<br/>Reviewers"]:::ext
  regulators["Regulatory<br/>Regulatory entities"]:::ext

  subgraph P["Project scope"]
    subgraph UI["User interface layer"]
      ui["Admin console UI<br/>Review and approval"]:::ui
    end
    sqs[["Event queue (Amazon SQS)<br/>Asynchronous events between services"]]:::queue
    subgraph SVC["Service layer"]
      acs["Admin console service<br/>Review workflows"]:::svc
      ing["Regulatory ingestion<br/>service"]:::svc
      eng["Regulatory engine<br/>RAG and LLM mapping"]:::eng
      cat["Catalog service<br/>OSCAL publishing"]:::svc
    end
    subgraph API["Inner API layer"]
      capi["Control API<br/>Controls"]:::api
      mapi["Control mapping API<br/>Mappings"]:::api
      rapi["Regulatory API<br/>Regulatory files"]:::api
      catapi["Catalog API<br/>Catalogs"]:::api
    end
    subgraph SOR["System of records"]
      cdb[("Controls database<br/>Controls and control mappings")]:::db
      rdb[("Regulatory<br/>database")]:::db
      s3["S3 bucket<br/>Files"]:::db
      catdb[("Catalog database<br/>Catalog metadata")]:::db
    end
  end

  published["Published catalogs<br/>OSCAL catalog API"]:::ext
  extorgs["External<br/>organizations"]:::ext

  reviewers --> ui
  ui --> acs
  regulators --> ing
  ing --> sqs
  eng <--> sqs
  cat <--> sqs
  acs --> capi
  acs --> mapi
  ing --> rapi
  ing --> s3
  eng --> capi
  eng --> mapi
  eng --> rapi
  eng --> s3
  cat --> catapi
  cat --> s3
  cat --> published
  extorgs --> cat
  capi <--> cdb
  mapi <--> cdb
  rapi <--> rdb
  catapi <--> catdb

  classDef ext fill:#eef0f3,stroke:#6b7280,color:#111827
  classDef ui fill:#ffffff,stroke:#8fa8e0,color:#111827
  classDef svc fill:#ffffff,stroke:#7cc19c,color:#111827
  classDef eng fill:#ffffff,stroke:#6d4fc2,stroke-width:2px,color:#111827
  classDef queue fill:#fff3d6,stroke:#c98a1b,color:#111827
  classDef api fill:#ffffff,stroke:#b4a3dd,color:#111827
  classDef db fill:#ffffff,stroke:#9aa3b2,color:#111827

  style UI fill:#eef3fc,stroke:#c6d4f2,color:#374151
  style SVC fill:#eef7f1,stroke:#c4e3d0,color:#374151
  style API fill:#f4f0fb,stroke:#d9cff0,color:#374151
  style SOR fill:#f1f3f6,stroke:#d4d8df,color:#374151
  style P fill:#f8fafc,stroke:#8a94a6,stroke-dasharray:6 4,color:#374151
```
<!-- /mermaid-source -->

Files: [SVG](../../assets/diagrams/control-mapping/fig-10-1-architecture.svg) · [PNG](../../assets/diagrams/control-mapping/fig-10-1-architecture.png) · [Original](../../assets/diagrams/control-mapping/fig-10-1-architecture.original.png) · [Mermaid source](../../assets/diagrams/control-mapping/fig-10-1-architecture.mmd)

## Processing flow

**Figure 10.2: Proposed processing flow**

<!-- mermaid-source: assets/diagrams/control-mapping/fig-10-2-processing-flow.mmd -->
```mermaid
---
title: "Federated Regulatory Control Mapping System: processing flow"
config:
  flowchart:
    wrappingWidth: 420
---
flowchart TB
  subgraph S1[" "]
    direction LR
    s1["<b>1. Acquire regulatory files</b><br/><i>Regulatory ingestion service</i><br/>Retrieves files from regulatory sources on a schedule, or receives files that regulatory entities publish to its API."]:::sting
    s1b0["Regulatory entities (pull or push)"]:::ext
    s1 <--> s1b0
  end
  subgraph S2[" "]
    direction LR
    s2["<b>2. Store the file and announce it</b><br/><i>Regulatory ingestion service</i><br/>Saves file metadata through the Regulatory API, stores the original file in S3, and publishes a RegulationIngested event."]:::sting
    s2o0["Regulatory API: file metadata"]:::api
    s2 --> s2o0
    s2o1["S3: original regulatory file"]:::api
    s2 --> s2o1
    s2o2["Queue: RegulationIngested"]:::q
    s2 --> s2o2
  end
  subgraph S3[" "]
    direction LR
    s3["<b>3. Propose controls with RAG and AI</b><br/><i>Regulatory engine</i><br/>Consumes the event, retrieves related text with RAG, and uses an LLM to draft controls and control mappings in PENDING status."]:::steng
    s3i0["Queue: RegulationIngested"]:::q
    s3i0 --> s3
    s3o0["Control API: PENDING controls"]:::api
    s3 --> s3o0
    s3o1["Control mapping API: PENDING mappings"]:::api
    s3 --> s3o1
  end
  subgraph S4[" "]
    direction LR
    s4["<b>4. Expert review</b><br/><i>Compliance reviewers in the Admin console</i><br/>Reviewers examine each proposed control and control mapping and approve or deny it. Denied items are kept for the audit trail."]:::strev
    s4i0["Admin console UI: reviewers"]:::api
    s4i0 --> s4
    s4o0["Control API: APPROVED or REJECTED"]:::api
    s4 --> s4o0
    s4o1["Control mapping API: APPROVED or REJECTED"]:::api
    s4 --> s4o1
  end
  subgraph S5[" "]
    direction LR
    s5["<b>5. Signal that review is complete</b><br/><i>Regulatory engine</i><br/>Once every proposed item for the regulatory file has a decision, the engine publishes a ReviewCompleted event."]:::steng
    s5o0["Queue: ReviewCompleted"]:::q
    s5 --> s5o0
  end
  subgraph S6[" "]
    direction LR
    s6["<b>6. Publish the OSCAL catalog</b><br/><i>Catalog service</i><br/>Consumes the event, saves catalog metadata through the Catalog API, uploads the OSCAL file to S3, and adds it to Published catalogs."]:::stcat
    s6i0["Queue: ReviewCompleted"]:::q
    s6i0 --> s6
    s6o0["Catalog API: catalog metadata"]:::api
    s6 --> s6o0
    s6o1["S3: OSCAL catalog file"]:::api
    s6 --> s6o1
    s6o2["Published catalogs: OSCAL catalog API"]:::ext
    s6 --> s6o2
  end
  S1 --> S2
  S2 --> S3
  S3 --> S4
  S4 --> S5
  S5 --> S6
  style S1 fill:transparent,stroke:transparent
  style S2 fill:transparent,stroke:transparent
  style S3 fill:transparent,stroke:transparent
  style S4 fill:transparent,stroke:transparent
  style S5 fill:transparent,stroke:transparent
  style S6 fill:transparent,stroke:transparent
  classDef sting fill:#ffffff,stroke:#0f7b5f,stroke-width:2px,color:#111827,text-align:left
  classDef steng fill:#ffffff,stroke:#6d4fc2,stroke-width:2px,color:#111827,text-align:left
  classDef strev fill:#ffffff,stroke:#b5472e,stroke-width:2px,color:#111827,text-align:left
  classDef stcat fill:#ffffff,stroke:#2563a8,stroke-width:2px,color:#111827,text-align:left
  classDef stdom fill:#ffffff,stroke:#0f7b5f,stroke-width:2px,color:#111827,text-align:left
  classDef stext fill:#ffffff,stroke:#6b7280,stroke-width:2px,color:#111827,text-align:left
  classDef q fill:#fff3d6,stroke:#c98a1b,color:#111827
  classDef api fill:#ffffff,stroke:#b4a3dd,color:#374151
  classDef ext fill:#eef0f3,stroke:#6b7280,color:#374151
```
<!-- /mermaid-source -->

Files: [SVG](../../assets/diagrams/control-mapping/fig-10-2-processing-flow.svg) · [PNG](../../assets/diagrams/control-mapping/fig-10-2-processing-flow.png) · [Original](../../assets/diagrams/control-mapping/fig-10-2-processing-flow.original.png) · [Mermaid source](../../assets/diagrams/control-mapping/fig-10-2-processing-flow.mmd)

## Data model

**Figure 14.2: Complete data model, Project 1**

<!-- mermaid-source: assets/diagrams/control-mapping/fig-14-2-data-model.mmd -->
```mermaid
---
title: "Complete data model, Project 1: Federated Regulatory Control Mapping System"
---
erDiagram

  authorities {
    uuid id PK
    varchar name UK
    varchar jurisdiction
    timestamptz created_at
    boolean enabled
    varchar created_by
  }
  frameworks {
    uuid id PK
    uuid authority_id FK
    varchar name
    varchar short_name
    varchar citation
    enum framework_type
    varchar sector
    enum status
    date effective_date
    timestamp created_at
  }
  files {
    uuid id PK
    uuid framework_id FK
    uuid supersedes_file_id FK
    varchar title
    text source_url
    enum source_format
    enum acquisition_method
    varchar version_label
    date publication_date
    date effective_date
    text s3_uri
    char(64) sha256
    bigint size_bytes
    uuid oscal_resource_uuid
    enum processing_status
    timestamp ingested_at
  }
  requirements {
    uuid id PK
    uuid file_id FK
    uuid parent_requirement_id FK
    varchar provision_ref
    varchar heading
    text text
    enum requirement_type
    varchar source_anchor
    enum extraction_method
    decimal extraction_confidence
    enum status
    timestamp created_at
  }
  catalog {
    uuid id PK
    uuid previous_catalog_id FK
    uuid oscal_uuid
    varchar title
    varchar version
    varchar oscal_version
    enum status
    timestamp published_at
    timestamp last_modified
    text s3_uri
    char(64) sha256
  }
  catalog_control {
    uuid catalog_id PK,FK
    uuid control_id PK,FK
    int control_version
  }
  catalog_resource {
    uuid catalog_id PK,FK
    uuid file_id PK,FK
    uuid resource_uuid
  }
  control_group {
    uuid id PK
    uuid parent_group_id FK
    varchar oscal_group_id
    varchar title
    varchar class
  }
  control {
    uuid id PK
    uuid group_id FK
    uuid parent_control_id FK
    varchar oscal_control_id
    varchar title
    varchar class
    int version
    text statement_prose
    text guidance_prose
    text objective_prose
    enum[] assessment_methods
    text expected_evidence
    jsonb related_controls
    enum origin
    enum status
    uuid approved_by
    timestamp approved_at
    timestamp created_at
  }
  control_parameter {
    uuid id PK
    uuid control_id FK
    varchar oscal_param_id
    varchar label
    text guidelines
    varchar default_value
    jsonb select_choices
  }
  control_mapping {
    uuid id PK
    uuid requirement_id FK
    uuid control_id FK
    uuid risk_id FK
    enum relationship_type
    enum rationale_type
    text rationale_text
    varchar ai_model
    varchar prompt_version
    decimal confidence_score
    jsonb retrieved_context
    enum status
    uuid reviewer_id
    timestamp reviewed_at
    text review_comment
    timestamp created_at
  }
  risk {
    uuid id PK
    varchar code
    varchar title
    text description
    enum category
    smallint default_likelihood
    smallint default_impact
    enum status
    timestamp created_at
  }

  authorities ||--o{ frameworks : "issues"
  frameworks ||--o{ files : "published as"
  files ||--o{ files : "supersedes"
  files ||--o{ requirements : "contains"
  requirements ||--o{ requirements : "parent of"
  files ||--o{ catalog_resource : "referenced by"
  catalog ||--o{ catalog_resource : "has"
  catalog ||--o{ catalog : "previous version"
  catalog ||--o{ catalog_control : "includes"
  control ||--o{ catalog_control : "included in"
  control_group ||--o{ control_group : "parent of"
  control_group ||--o{ control : "groups"
  control ||--o{ control : "enhancements"
  control ||--o{ control_parameter : "has"
  requirements ||--o{ control_mapping : "mapped by"
  control ||--o{ control_mapping : "maps"
  risk ||--o{ control_mapping : "addressed by"
```
<!-- /mermaid-source -->

Files: [SVG](../../assets/diagrams/control-mapping/fig-14-2-data-model.svg) · [PNG](../../assets/diagrams/control-mapping/fig-14-2-data-model.png) · [Original](../../assets/diagrams/control-mapping/fig-14-2-data-model.original.png) · [Mermaid source](../../assets/diagrams/control-mapping/fig-14-2-data-model.mmd)

## Related
- [Solution architecture](../../architecture/README.md)
- [Repositories](../../architecture/repositories.md): where the code for each component lives
- [Simplified data model](../../data-model/README.md)
- [Roadmap](../../architecture/roadmap.md)
