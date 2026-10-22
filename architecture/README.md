# Solution architecture

GRaCe-GRC is delivered as three projects that build on each other:

1. **Federated Regulatory Control Mapping System** turns regulatory files into reviewed controls, control mappings and OSCAL catalogs.
2. **Continuous Compliance Monitoring and Automated Audit Evidence System** turns those catalogs into configured tests, automated evidence collection and OSCAL assessment results.
3. **Risk Assessment Compliance Scoring and Reporting Platform** turns assessment results into risk scores, remediations with closed-loop verification, approved reports and OSCAL POA&M.

Each project follows the same layering: user interface, event messaging, service layer,
inner APIs and system of records. Each project owns its own databases; projects exchange
data only through internal service APIs and events, referring to each other's entities by ID.

## Complete solution

**Figure 12.3: Complete solution, Projects 1, 2 and 3**

<!-- mermaid-source: assets/diagrams/solution/fig-12-3-complete-solution.mmd -->
```mermaid
---
title: "Complete solution: Projects 1, 2 and 3"
---
flowchart LR
  regulators["Regulatory<br/>entities"]:::ext
  sources["Evidence<br/>sources"]:::ext
  authorities["Regulatory<br/>authorities"]:::ext
  extorgs["External<br/>organizations"]:::ext
  auditors2["Auditors and<br/>GRC tools"]:::ext
  auditors3["Auditors and<br/>management"]:::ext

  subgraph P1["Project 1 · Federated Regulatory Control Mapping System"]
    direction TB
    subgraph P1UI["User interface layer"]
      p1ui["Admin console UI (reviewers)"]:::ui
    end
    p1q[["Event messaging (SNS and SQS)"]]:::queue
    subgraph P1SVC["Service layer"]
      p1ing["Regulatory ingestion service"]:::svc
      p1eng["Regulatory engine (AI-assisted)"]:::eng
      p1cat["Catalog service"]:::svc
      p1acs["Admin console service"]:::svc
    end
    subgraph P1SOR["Inner APIs and system of records"]
      p1sor["4 APIs, 3 databases, S3 bucket"]:::db
    end
    subgraph P1PUBI["Published interface"]
      p1pub["Published catalogs API (OSCAL)"]:::api
    end
    P1UI ~~~ p1q ~~~ P1SVC ~~~ P1SOR ~~~ P1PUBI
  end

  subgraph P2["Project 2 · Continuous Compliance Monitoring and Automated Audit Evidence System"]
    direction TB
    subgraph P2UI["User interface layer"]
      p2ui["Admin console UI (reviewers)"]:::ui
    end
    p2q[["Event messaging (SNS and SQS)"]]:::queue
    subgraph P2SVC["Service layer"]
      p2cing["Catalog ingestion service"]:::svc
      p2cc["Control config and connector services"]:::svc
      p2as["Assessment service"]:::svc
      p2ecs["Evidence collection service"]:::svc
      p2ee["Evidence engine (AI-assisted)"]:::eng
      p2val["Assessment validation engine"]:::eng
      p2acs["Admin console service"]:::svc
    end
    subgraph P2SOR["Inner APIs and system of records"]
      p2sor["4 APIs, 4 databases, S3 bucket"]:::db
    end
    subgraph P2PUBI["Published interface"]
      p2pub["Published assessments API (OSCAL)"]:::api
    end
    P2UI ~~~ p2q ~~~ P2SVC ~~~ P2SOR ~~~ P2PUBI
  end

  subgraph P3["Project 3 · Risk Assessment Compliance Scoring and Reporting Platform"]
    direction TB
    subgraph P3UI["User interface layer"]
      p3ui["Admin console UI (reviewers)"]:::ui
    end
    p3q[["Event messaging (SNS and SQS)"]]:::queue
    subgraph P3SVC["Service layer"]
      p3as["Assessment service"]:::svc
      p3score["Score engine"]:::eng
      p3rem["Remediation service (AI-assisted)"]:::svc
      p3rep["Report service (AI-assisted)"]:::svc
      p3acs["Admin console service"]:::svc
    end
    subgraph P3SOR["Inner APIs and system of records"]
      p3sor["4 APIs, 4 databases, S3 bucket"]:::db
    end
    subgraph P3PUBI["Published interface"]
      p3pub["Published reports API (OSCAL)"]:::api
    end
    P3UI ~~~ p3q ~~~ P3SVC ~~~ P3SOR ~~~ P3PUBI
  end

  regulators -->|"Regulatory ingestion service"| P1
  P1 ==>|"Catalog service → Catalog ingestion service<br/>(internal API)"| P2
  P2 ==>|"Assessment service → Assessment service<br/>(AssessmentCompleted)"| P3
  P1 ==>|"Catalog service → Assessment service<br/>(risk context)"| P3
  P3 -.->|"Remediation service → Assessment service<br/>closed-loop verification (added in Project 3)"| P2
  P2 <-->|"Evidence engine"| sources
  P3 -->|"Report service"| authorities
  P1 -->|"Published catalogs API"| extorgs
  P2 -->|"Published assessments API"| auditors2
  P3 -->|"Published reports API"| auditors3
  linkStyle 13,14,15 stroke:#2563a8,stroke-width:2px
  linkStyle 16 stroke:#b5472e,stroke-width:2px

  classDef ext fill:#eef0f3,stroke:#6b7280,color:#111827
  classDef ui fill:#ffffff,stroke:#8fa8e0,color:#111827
  classDef svc fill:#ffffff,stroke:#7cc19c,color:#111827
  classDef eng fill:#ffffff,stroke:#6d4fc2,stroke-width:2px,color:#111827
  classDef queue fill:#fff3d6,stroke:#c98a1b,color:#111827
  classDef api fill:#ffffff,stroke:#b4a3dd,color:#111827
  classDef db fill:#ffffff,stroke:#9aa3b2,color:#111827

  style P1UI fill:#eef3fc,stroke:#c6d4f2,color:#374151
  style P1SVC fill:#eef7f1,stroke:#c4e3d0,color:#374151
  style P1SOR fill:#f1f3f6,stroke:#d4d8df,color:#374151
  style P1PUBI fill:#f4f0fb,stroke:#d9cff0,color:#374151
  style P2UI fill:#eef3fc,stroke:#c6d4f2,color:#374151
  style P2SVC fill:#eef7f1,stroke:#c4e3d0,color:#374151
  style P2SOR fill:#f1f3f6,stroke:#d4d8df,color:#374151
  style P2PUBI fill:#f4f0fb,stroke:#d9cff0,color:#374151
  style P3UI fill:#eef3fc,stroke:#c6d4f2,color:#374151
  style P3SVC fill:#eef7f1,stroke:#c4e3d0,color:#374151
  style P3SOR fill:#f1f3f6,stroke:#d4d8df,color:#374151
  style P3PUBI fill:#f4f0fb,stroke:#d9cff0,color:#374151
  style P1 fill:#f8fafc,stroke:#8a94a6,stroke-dasharray:6 4,color:#374151
  style P2 fill:#f8fafc,stroke:#8a94a6,stroke-dasharray:6 4,color:#374151
  style P3 fill:#f8fafc,stroke:#8a94a6,stroke-dasharray:6 4,color:#374151
```
<!-- /mermaid-source -->

Files: [SVG](../assets/diagrams/solution/fig-12-3-complete-solution.svg) · [PNG](../assets/diagrams/solution/fig-12-3-complete-solution.png) · [Original](../assets/diagrams/solution/fig-12-3-complete-solution.original.png) · [Mermaid source](../assets/diagrams/solution/fig-12-3-complete-solution.mmd)

## Projects 1 and 2 combined

**Figure 11.3: Projects 1 and 2 combined**

<!-- mermaid-source: assets/diagrams/solution/fig-11-3-projects-1-2-combined.mmd -->
```mermaid
---
title: "Projects 1 and 2 combined"
---
flowchart LR
  regulators["Regulatory<br/>Regulatory entities"]:::ext
  reviewers["Compliance<br/>Reviewers"]:::ext
  pubcat["Published<br/>catalogs API"]:::api
  extorgs["External<br/>organizations"]:::ext
  pubassess["Published assessments<br/>Auditors, GRC tools"]:::ext
  sources["Evidence sources<br/>GitHub, Splunk,<br/>Datadog, AWS"]:::ext

  subgraph P1["Project 1 · Federated Regulatory Control Mapping System"]
    direction TB
    subgraph P1UI["User interface layer"]
      p1ui["Admin console UI"]:::ui
    end
    p1q[["Event queue (Amazon SQS)"]]:::queue
    subgraph P1SVC["Service layer"]
      p1ing["Regulatory ingestion service"]:::svc
      p1eng["Regulatory engine (AI)"]:::eng
      p1cat["Catalog service"]:::svc
      p1acs["Admin console service"]:::svc
    end
    subgraph P1API["Inner API layer"]
      p1a1["Control API"]:::api
      p1a2["Control mapping API"]:::api
      p1a3["Regulatory API"]:::api
      p1a4["Catalog API"]:::api
    end
    subgraph P1SOR["System of records"]
      p1d1[("Controls database")]:::db
      p1d2[("Regulatory database")]:::db
      p1d3[("Catalog database")]:::db
      p1d4["S3 bucket"]:::db
    end
    P1UI ~~~ p1q ~~~ P1SVC ~~~ P1API ~~~ P1SOR
  end

  subgraph P2["Project 2 · Continuous Compliance Monitoring and Automated Audit Evidence System"]
    direction TB
    subgraph P2UI["User interface layer"]
      p2ui["Admin console UI"]:::ui
    end
    p2q[["Event messaging (Amazon SNS and SQS)"]]:::queue
    subgraph P2SVC["Service layer"]
      p2cing["Catalog ingestion service"]:::svc
      p2ccs["Control config service"]:::svc
      p2con["Connector service"]:::svc
      p2as["Assessment service"]:::svc
      p2ecs["Evidence collection service"]:::svc
      p2ee["Evidence engine (AI)"]:::eng
      p2acs["Admin console service"]:::svc
      p2val["Assessment validation engine"]:::eng
    end
    subgraph P2API["Inner API layer"]
      p2a1["Control config API"]:::api
      p2a2["Connector API"]:::api
      p2a3["Assessment API"]:::api
      p2a4["Evidence API"]:::api
    end
    subgraph P2SOR["System of records"]
      p2d1[("Control config database")]:::db
      p2d2[("Connector database")]:::db
      p2d3[("Assessment database")]:::db
      p2d4[("Evidence database")]:::db
      p2d5["S3 bucket"]:::db
    end
    P2UI ~~~ p2q ~~~ P2SVC ~~~ P2API ~~~ P2SOR
  end

  reviewers --> P1
  reviewers --> P2
  regulators -->|"to Regulatory ingestion service"| P1
  P1 ==>|"Catalog service → Catalog ingestion service"| P2
  P1 -->|"Catalog service"| pubcat
  extorgs --> pubcat
  P2 -->|"Assessment service"| pubassess
  P2 <-->|"Evidence engine (AI)"| sources
  linkStyle 11 stroke:#2563a8,stroke-width:2px

  classDef ext fill:#eef0f3,stroke:#6b7280,color:#111827
  classDef ui fill:#ffffff,stroke:#8fa8e0,color:#111827
  classDef svc fill:#ffffff,stroke:#7cc19c,color:#111827
  classDef eng fill:#ffffff,stroke:#6d4fc2,stroke-width:2px,color:#111827
  classDef queue fill:#fff3d6,stroke:#c98a1b,color:#111827
  classDef api fill:#ffffff,stroke:#b4a3dd,color:#111827
  classDef db fill:#ffffff,stroke:#9aa3b2,color:#111827

  style P1UI fill:#eef3fc,stroke:#c6d4f2,color:#374151
  style P1SVC fill:#eef7f1,stroke:#c4e3d0,color:#374151
  style P1API fill:#f4f0fb,stroke:#d9cff0,color:#374151
  style P1SOR fill:#f1f3f6,stroke:#d4d8df,color:#374151
  style P2UI fill:#eef3fc,stroke:#c6d4f2,color:#374151
  style P2SVC fill:#eef7f1,stroke:#c4e3d0,color:#374151
  style P2API fill:#f4f0fb,stroke:#d9cff0,color:#374151
  style P2SOR fill:#f1f3f6,stroke:#d4d8df,color:#374151
  style P1 fill:#f8fafc,stroke:#8a94a6,stroke-dasharray:6 4,color:#374151
  style P2 fill:#f8fafc,stroke:#8a94a6,stroke-dasharray:6 4,color:#374151
```
<!-- /mermaid-source -->

Files: [SVG](../assets/diagrams/solution/fig-11-3-projects-1-2-combined.svg) · [PNG](../assets/diagrams/solution/fig-11-3-projects-1-2-combined.png) · [Original](../assets/diagrams/solution/fig-11-3-projects-1-2-combined.original.png) · [Mermaid source](../assets/diagrams/solution/fig-11-3-projects-1-2-combined.mmd)

## Per-project architecture
- [Project 1 architecture](../systems/control-mapping/README.md#architecture)
- [Project 2 architecture](../systems/continuous-compliance/README.md#architecture)
- [Project 3 architecture](../systems/risk-reporting/README.md#architecture)

## Repositories
The repository for each component is listed in [Repositories](repositories.md).
