# Project 2: Continuous Compliance Monitoring and Automated Audit Evidence System

Ingests the OSCAL catalogs published by Project 1, configures a test and connectors for each control, collects evidence automatically from sources such as GitHub, Splunk, Datadog and AWS, validates it against each control, and publishes OSCAL assessment results.

## Architecture

**Figure 11.1: Proposed high-level software architecture**

<!-- mermaid-source: assets/diagrams/continuous-compliance/fig-11-1-architecture.mmd -->
```mermaid
---
title: Continuous Compliance Monitoring and Automated Audit Evidence System
---
flowchart TB
  reviewers["Compliance<br/>Reviewers"]:::ext
  p1["Project 1<br/>Catalog service"]:::ext

  subgraph P["Project scope"]
    subgraph UI["User interface layer"]
      ui["Admin console UI<br/>Configuration and review"]:::ui
    end
    bus[["Event messaging (Amazon SNS and SQS)<br/>Topics fan out events to subscriber queues"]]:::queue
    subgraph SVC["Service layer"]
      acs["Admin console service<br/>Configuration, review"]:::svc
      val["Assessment validation<br/>engine (AI-assisted)"]:::eng
      eveng["Evidence engine<br/>AI-assisted collection"]:::eng
      cing["Catalog ingestion<br/>service"]:::svc
      ccs["Control config<br/>service"]:::svc
      cons["Connector<br/>service"]:::svc
      asvc["Assessment<br/>service"]:::svc
      ecs["Evidence collection<br/>service"]:::svc
    end
    subgraph API["Inner API layer"]
      ccapi["Control config API<br/>Control configs"]:::api
      conapi["Connector API<br/>Connectors"]:::api
      aapi["Assessment API<br/>Assessments"]:::api
      eapi["Evidence API<br/>Evidence metadata"]:::api
    end
    subgraph SOR["System of records"]
      ccdb[("Control config<br/>database")]:::db
      condb[("Connector<br/>database")]:::db
      adb[("Assessment<br/>database")]:::db
      edb[("Evidence<br/>database")]:::db
      s3["S3 bucket<br/>Evidence files"]:::db
    end
  end

  sources["Evidence sources<br/>GitHub, Splunk,<br/>Datadog, AWS"]:::ext
  published["Published assessments<br/>OSCAL results API"]:::ext

  reviewers --> ui
  ui --> acs
  acs --> ccs
  acs --> cons
  acs --> asvc
  val <--> bus
  eveng <--> bus
  asvc --> bus
  ecs --> bus
  val --> asvc
  val --> ecs
  eveng --> ecs
  eveng <--> sources
  eveng --> s3
  p1 --> cing
  cing --> ccapi
  ccs --> ccapi
  cons --> conapi
  asvc --> aapi
  asvc --> published
  ecs --> eapi
  ccapi <--> ccdb
  conapi <--> condb
  aapi <--> adb
  eapi <--> edb

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

Files: [SVG](../../assets/diagrams/continuous-compliance/fig-11-1-architecture.svg) · [PNG](../../assets/diagrams/continuous-compliance/fig-11-1-architecture.png) · [Original](../../assets/diagrams/continuous-compliance/fig-11-1-architecture.original.png) · [Mermaid source](../../assets/diagrams/continuous-compliance/fig-11-1-architecture.mmd)

## Processing flow

**Figure 11.2: Proposed processing flow**

<!-- mermaid-source: assets/diagrams/continuous-compliance/fig-11-2-processing-flow.mmd -->
```mermaid
---
title: "Continuous Compliance Monitoring and Automated Audit Evidence System: processing flow"
config:
  flowchart:
    wrappingWidth: 420
---
flowchart TB
  subgraph S1[" "]
    direction LR
    s1["<b>1. Ingest the published catalog</b><br/><i>Catalog ingestion service</i><br/>Retrieves each approved OSCAL catalog from the Project 1 Catalog service, through an internal API, when a new version is published."]:::stcat
    s1i0["Project 1: Catalog service (internal)"]:::ext
    s1i0 --> s1
  end
  subgraph S2[" "]
    direction LR
    s2["<b>2. Create control configurations</b><br/><i>Catalog ingestion service</i><br/>Creates a configuration for each control in the catalog through the Control config API, in PENDING status."]:::stcat
    s2o0["Control config API: PENDING configs"]:::api
    s2 --> s2o0
  end
  subgraph S3[" "]
    direction LR
    s3["<b>3. Configure controls and connectors</b><br/><i>Compliance reviewers in the Admin console</i><br/>Reviewers select the connector each control needs. If it is PENDING, they provide its settings. The control config then becomes ACTIVE."]:::strev
    s3i0["Admin console UI: reviewers"]:::api
    s3i0 --> s3
    s3o0["Connector API: connector settings"]:::api
    s3 --> s3o0
    s3o1["Secrets Manager: connector credentials"]:::api
    s3 --> s3o1
    s3o2["Control config API: ACTIVE configs"]:::api
    s3 --> s3o2
  end
  subgraph S4[" "]
    direction LR
    s4["<b>4. Start an assessment</b><br/><i>Assessment service</i><br/>A schedule or a reviewer starts a run. The service creates assessments for ACTIVE configs and publishes AssessmentCreated."]:::stdom
    s4i0["Scheduler or Admin console"]:::ext
    s4i0 --> s4
    s4o0["Assessment API: IN_PROGRESS"]:::api
    s4 --> s4o0
    s4o1["Queue: AssessmentCreated"]:::q
    s4 --> s4o1
  end
  subgraph S5[" "]
    direction LR
    s5["<b>5. Create evidence requests</b><br/><i>Evidence collection service</i><br/>Consumes the event, creates evidence entities (metadata) in REQUESTED status, and publishes EvidenceRequested."]:::stdom
    s5i0["Queue: AssessmentCreated"]:::q
    s5i0 --> s5
    s5o0["Evidence API: REQUESTED"]:::api
    s5 --> s5o0
    s5o1["Queue: EvidenceRequested"]:::q
    s5 --> s5o1
  end
  subgraph S6[" "]
    direction LR
    s6["<b>6. Collect the evidence</b><br/><i>Evidence engine (AI-assisted)</i><br/>Uses connectors to retrieve evidence; AI helps with unstructured sources. Files go to S3 with a hash and statuses become COLLECTED."]:::steng
    s6i0["Queue: EvidenceRequested"]:::q
    s6i0 --> s6
    s6b0["GitHub, Splunk, Datadog, AWS"]:::ext
    s6 <--> s6b0
    s6o0["S3: evidence files with SHA-256 hash"]:::api
    s6 --> s6o0
    s6o1["Queue: CollectionCompleted"]:::q
    s6 --> s6o1
  end
  subgraph S7[" "]
    direction LR
    s7["<b>7. Validate evidence against controls</b><br/><i>Assessment validation engine (AI-assisted)</i><br/>Deterministic rules test evidence against each control's criteria. AI flags ambiguous cases. Results: PASSED, FAILED, PENDING_REVIEW."]:::steng
    s7i0["Queue: CollectionCompleted"]:::q
    s7i0 --> s7
    s7o0["Assessment service: control results"]:::api
    s7 --> s7o0
  end
  subgraph S8[" "]
    direction LR
    s8["<b>8. Review and publish results</b><br/><i>Compliance reviewers and Assessment service</i><br/>Reviewers resolve PENDING_REVIEW items. The completed assessment is published as OSCAL assessment results, and Project 3 is notified."]:::strev
    s8i0["Admin console UI: reviewers"]:::api
    s8i0 --> s8
    s8o0["Assessment API: COMPLETED"]:::api
    s8 --> s8o0
    s8o1["Published assessments: OSCAL results"]:::ext
    s8 --> s8o1
    s8o2["Queue: AssessmentCompleted"]:::q
    s8 --> s8o2
  end
  S1 --> S2
  S2 --> S3
  S3 --> S4
  S4 --> S5
  S5 --> S6
  S6 --> S7
  S7 --> S8
  style S1 fill:transparent,stroke:transparent
  style S2 fill:transparent,stroke:transparent
  style S3 fill:transparent,stroke:transparent
  style S4 fill:transparent,stroke:transparent
  style S5 fill:transparent,stroke:transparent
  style S6 fill:transparent,stroke:transparent
  style S7 fill:transparent,stroke:transparent
  style S8 fill:transparent,stroke:transparent
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

Files: [SVG](../../assets/diagrams/continuous-compliance/fig-11-2-processing-flow.svg) · [PNG](../../assets/diagrams/continuous-compliance/fig-11-2-processing-flow.png) · [Original](../../assets/diagrams/continuous-compliance/fig-11-2-processing-flow.original.png) · [Mermaid source](../../assets/diagrams/continuous-compliance/fig-11-2-processing-flow.mmd)

## Data model

**Figure 14.3: Complete data model, Project 2**

<!-- mermaid-source: assets/diagrams/continuous-compliance/fig-14-3-data-model.mmd -->
```mermaid
---
title: "Complete data model, Project 2: Continuous Compliance Monitoring and Automated Audit Evidence System"
---
erDiagram

  control_configuration {
    uuid id PK
    varchar control_ref "REF"
    uuid catalog_ref "REF"
    varchar catalog_version
    jsonb test_procedure
    jsonb evidence_requirements
    jsonb pass_criteria
    jsonb exception_criteria
    jsonb parameter_values
    varchar frequency
    enum status
    uuid configured_by
    timestamp activated_at
    timestamp created_at
  }
  configuration_connector {
    uuid config_id PK,FK
    uuid connector_id PK,FK
    jsonb query_spec
  }
  connector {
    uuid id PK
    varchar name
    enum connector_type
    text endpoint_url
    enum auth_method
    varchar secret_ref
    varchar access_scope
    enum status
    timestamp last_health_check_at
    timestamp created_at
  }
  assessment {
    uuid id PK
    uuid oscal_uuid
    varchar title
    enum trigger_type
    uuid trigger_ref "REF"
    jsonb scope
    enum status
    timestamp started_at
    timestamp completed_at
    text oscal_results_uri
    char(64) sha256
  }
  assessment_result {
    uuid id PK
    uuid assessment_id FK
    uuid config_id FK
    varchar control_ref "REF"
    uuid oscal_finding_uuid
    enum result
    enum determined_by
    text ai_flag_reason
    uuid reviewer_id
    timestamp reviewed_at
    timestamp evaluated_at
  }
  evidence {
    uuid id PK
    uuid result_id FK
    uuid connector_id FK
    uuid oscal_observation_uuid
    text description
    enum collection_method
    text source_reference
    text s3_uri
    char(64) sha256
    varchar media_type
    bigint size_bytes
    enum status
    text error_message
    timestamp collected_at
  }

  control_configuration ||--o{ configuration_connector : "uses"
  connector ||--o{ configuration_connector : "used by"
  control_configuration ||--o{ assessment_result : "evaluated in"
  assessment ||--o{ assessment_result : "produces"
  assessment_result ||--o{ evidence : "supported by"
  connector ||--o{ evidence : "collects"
```
<!-- /mermaid-source -->

Files: [SVG](../../assets/diagrams/continuous-compliance/fig-14-3-data-model.svg) · [PNG](../../assets/diagrams/continuous-compliance/fig-14-3-data-model.png) · [Original](../../assets/diagrams/continuous-compliance/fig-14-3-data-model.original.png) · [Mermaid source](../../assets/diagrams/continuous-compliance/fig-14-3-data-model.mmd)

## Related
- [Solution architecture](../../architecture/README.md)
- [Simplified data model](../../data-model/README.md)
- [Roadmap](../../architecture/roadmap.md)
