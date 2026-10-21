# Project 3: Risk Assessment Compliance Scoring and Reporting Platform

Receives completed assessments from Project 2, scores risk and compliance with a versioned methodology, opens remediations and verifies fixes by requesting re-assessment from Project 2, and publishes approved reports as OSCAL assessment results and POA&M.

## Architecture

**Figure 12.1: Proposed high-level software architecture**

<!-- mermaid-source: assets/diagrams/risk-reporting/fig-12-1-architecture.mmd -->
```mermaid
---
title: Risk Assessment Compliance Scoring and Reporting Platform
---
flowchart TB
  reviewers["Compliance<br/>Reviewers"]:::ext
  p2events["Project 2<br/>Assessment events"]:::ext
  p2svc["Project 2<br/>Assessment service"]:::ext
  p1svc["Project 1<br/>Catalog service"]:::ext

  subgraph P["Project scope"]
    subgraph UI["User interface layer"]
      ui["Admin console UI<br/>Dashboard, remediation, reports"]:::ui
    end
    bus[["Event messaging (Amazon SNS and SQS)<br/>Assessment, score, and remediation events"]]:::queue
    subgraph SVC["Service layer"]
      acs["Admin console service<br/>Methodology, review, reports"]:::svc
      asvc["Assessment<br/>service"]:::svc
      score["Score engine<br/>Risk scoring"]:::eng
      rem["Remediation service<br/>AI-suggested actions"]:::svc
      rep["Report service<br/>AI-drafted summaries"]:::svc
    end
    subgraph API["Inner API layer"]
      aapi["Assessment API<br/>Assessment results"]:::api
      sapi["Score API<br/>Scores, methodology"]:::api
      rapi["Remediation API<br/>Remediations"]:::api
      repapi["Report API<br/>Report metadata"]:::api
    end
    subgraph SOR["System of records"]
      adb[("Assessment<br/>database")]:::db
      sdb[("Score<br/>database")]:::db
      rdb[("Remediation<br/>database")]:::db
      repdb[("Report<br/>database")]:::db
      s3["S3 bucket<br/>Report files"]:::db
    end
  end

  published["Published reports<br/>Auditors, management"]:::ext
  authorities["Regulatory<br/>authorities"]:::ext

  reviewers --> ui
  ui --> acs
  acs --> score
  acs --> rem
  acs --> rep
  p2events <--> bus
  asvc <--> bus
  score <--> bus
  rem <--> bus
  rep <--> bus
  p2svc --> asvc
  p1svc --> asvc
  score --> asvc
  rem --> asvc
  asvc --> aapi
  score --> sapi
  rem --> rapi
  rep --> repapi
  rep --> s3
  rep --> published
  rep --> authorities
  aapi <--> adb
  sapi <--> sdb
  rapi <--> rdb
  repapi <--> repdb

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

Files: [SVG](../../assets/diagrams/risk-reporting/fig-12-1-architecture.svg) · [PNG](../../assets/diagrams/risk-reporting/fig-12-1-architecture.png) · [Original](../../assets/diagrams/risk-reporting/fig-12-1-architecture.original.png) · [Mermaid source](../../assets/diagrams/risk-reporting/fig-12-1-architecture.mmd)

## Processing flow

**Figure 12.2: Proposed processing flow**

<!-- mermaid-source: assets/diagrams/risk-reporting/fig-12-2-processing-flow.mmd -->
```mermaid
---
title: "Risk Assessment Compliance Scoring and Reporting Platform: processing flow"
config:
  flowchart:
    wrappingWidth: 420
---
flowchart TB
  subgraph S1[" "]
    direction LR
    s1["<b>1. Receive completed assessments</b><br/><i>Assessment service</i><br/>Consumes AssessmentCompleted, retrieves the results from the Project 2 Assessment service, and adds risk context from Project 1."]:::stdom
    s1i0["Queue: AssessmentCompleted (Project 2)"]:::q
    s1i0 --> s1
    s1i1["Project 2: Assessment service (internal)"]:::ext
    s1i1 --> s1
    s1i2["Project 1: Catalog service, risk context"]:::ext
    s1i2 --> s1
    s1o0["Queue: AssessmentReceived"]:::q
    s1 --> s1o0
  end
  subgraph S2[" "]
    direction LR
    s2["<b>2. Calculate risk and compliance scores</b><br/><i>Score engine</i><br/>Runs on AssessmentReceived, on a schedule, or on request. Scores findings by likelihood, impact, severity, and control effectiveness."]:::steng
    s2i0["Queue: AssessmentReceived"]:::q
    s2i0 --> s2
    s2i1["Scheduler or Admin console"]:::ext
    s2i1 --> s2
    s2o0["Score API: COMPLETE, methodology version"]:::api
    s2 --> s2o0
    s2o1["Queue: ScoreCompleted"]:::q
    s2 --> s2o1
  end
  subgraph S3[" "]
    direction LR
    s3["<b>3. Create remediations</b><br/><i>Remediation service</i><br/>Consumes ScoreCompleted and opens a remediation for each non-compliant finding, prioritized by score. AI suggests actions."]:::stdom
    s3i0["Queue: ScoreCompleted"]:::q
    s3i0 --> s3
    s3o0["Remediation API: OPEN remediations"]:::api
    s3 --> s3o0
    s3o1["Queue: RemediationUpdated"]:::q
    s3 --> s3o1
  end
  subgraph S4[" "]
    direction LR
    s4["<b>4. Act on remediations</b><br/><i>Compliance reviewers in the Admin console</i><br/>Reviewers assign and update remediations, then mark each as RESOLVED or RISK_ACCEPTED, with a justification on record."]:::strev
    s4i0["Admin console UI: reviewers"]:::api
    s4i0 --> s4
    s4o0["Remediation API: status updates"]:::api
    s4 --> s4o0
    s4o1["Queue: RemediationUpdated"]:::q
    s4 --> s4o1
  end
  subgraph S5[" "]
    direction LR
    s5["<b>5. Verify the fix with Project 2</b><br/><i>Remediation service</i><br/>For each RESOLVED remediation, asks Project 2 to re-assess the control. A passing result marks it VERIFIED; a failing result reopens it."]:::stdom
    s5i0["Queue: AssessmentCompleted (Project 2)"]:::q
    s5i0 --> s5
    s5o0["Queue: ReassessmentRequested (to Project 2)"]:::q
    s5 --> s5o0
    s5o1["Remediation API: VERIFIED or REOPENED"]:::api
    s5 --> s5o1
  end
  subgraph S6[" "]
    direction LR
    s6["<b>6. Generate a report</b><br/><i>Report service</i><br/>Builds a report at any time from the latest COMPLETE score and current remediation status, showing PENDING items as such. AI drafts a summary."]:::stdom
    s6i0["Queue: ScoreCompleted, RemediationUpdated"]:::q
    s6i0 --> s6
    s6i1["Scheduler or Admin console"]:::ext
    s6i1 --> s6
    s6o0["Report API: DRAFT"]:::api
    s6 --> s6o0
  end
  subgraph S7[" "]
    direction LR
    s7["<b>7. Approve the report</b><br/><i>Authorized approver in the Admin console</i><br/>An authorized person reviews the draft and approves it. Approved reports cannot be edited; changes create a new version."]:::strev
    s7i0["Admin console UI: approver"]:::api
    s7i0 --> s7
    s7o0["Report API: APPROVED"]:::api
    s7 --> s7o0
  end
  subgraph S8[" "]
    direction LR
    s8["<b>8. Publish and submit</b><br/><i>Report service</i><br/>Stores the report in S3 with a hash, publishes it in OSCAL formats, and submits it to regulatory authorities where supported."]:::stdom
    s8o0["S3: report files (write-once)"]:::api
    s8 --> s8o0
    s8o1["Published reports: OSCAL results, POA&amp;M"]:::ext
    s8 --> s8o1
    s8o2["Regulatory authorities: authorized submission"]:::ext
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

Files: [SVG](../../assets/diagrams/risk-reporting/fig-12-2-processing-flow.svg) · [PNG](../../assets/diagrams/risk-reporting/fig-12-2-processing-flow.png) · [Original](../../assets/diagrams/risk-reporting/fig-12-2-processing-flow.original.png) · [Mermaid source](../../assets/diagrams/risk-reporting/fig-12-2-processing-flow.mmd)

## Data model

**Figure 14.4: Complete data model, Project 3**

<!-- mermaid-source: assets/diagrams/risk-reporting/fig-14-4-data-model.mmd -->
```mermaid
---
title: "Complete data model, Project 3: Risk Assessment Compliance Scoring and Reporting Platform"
---
erDiagram

  scoring_methodology {
    uuid id PK
    varchar name
    varchar version
    text formula
    jsonb weights
    jsonb rating_thresholds
    enum status
    date effective_from
    uuid approved_by
  }
  score {
    uuid id PK
    uuid methodology_id FK
    uuid assessment_ref "REF"
    enum trigger_type
    decimal overall_score
    decimal compliance_pct
    enum risk_rating
    enum status
    timestamp computed_at
  }
  finding_score {
    uuid score_id PK,FK
    uuid finding_id PK,FK
    decimal risk_score
    int priority_rank
  }
  finding {
    uuid id PK
    uuid assessment_ref "REF"
    uuid result_ref "REF"
    varchar control_ref "REF"
    uuid risk_ref "REF"
    uuid oscal_finding_uuid
    boolean compliant
    enum severity
    smallint likelihood
    smallint impact
    decimal control_effectiveness
    timestamp imported_at
  }
  report {
    uuid id PK
    uuid score_id FK
    uuid framework_ref "REF"
    varchar title
    int version
    enum report_type
    date period_start
    date period_end
    text ai_summary
    enum status
    uuid approved_by
    timestamp approved_at
    text s3_uri
    char(64) sha256
    text signature
    text oscal_results_uri
    text oscal_poam_uri
    timestamp generated_at
  }
  report_remediation {
    uuid report_id PK,FK
    uuid remediation_id PK,FK
    enum status_at_generation
  }
  remediation {
    uuid id PK
    uuid finding_id FK
    uuid oscal_poam_item_uuid
    varchar title
    text description
    text ai_suggested_action
    varchar owner
    enum priority
    date due_date
    enum status
    text risk_acceptance_justification
    timestamp resolved_at
    uuid verification_assessment_ref "REF"
    timestamp verified_at
  }
  submission {
    uuid id PK
    uuid report_id FK
    uuid authority_ref "REF"
    enum channel
    uuid submitted_by
    timestamp submitted_at
    enum status
    varchar receipt_reference
  }

  scoring_methodology ||--o{ score : "computes"
  score ||--o{ finding_score : "scores"
  finding ||--o{ finding_score : "scored in"
  score ||--o{ report : "basis for"
  report ||--o{ report_remediation : "lists"
  remediation ||--o{ report_remediation : "listed in"
  finding ||--o{ remediation : "remediated by"
  report ||--o{ submission : "submitted as"
```
<!-- /mermaid-source -->

Files: [SVG](../../assets/diagrams/risk-reporting/fig-14-4-data-model.svg) · [PNG](../../assets/diagrams/risk-reporting/fig-14-4-data-model.png) · [Original](../../assets/diagrams/risk-reporting/fig-14-4-data-model.original.png) · [Mermaid source](../../assets/diagrams/risk-reporting/fig-14-4-data-model.mmd)

## Related
- [Solution architecture](../../architecture/README.md)
- [Simplified data model](../../data-model/README.md)
- [Roadmap](../../architecture/roadmap.md)
