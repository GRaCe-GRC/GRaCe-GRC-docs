# Roadmap

Three overlapping phases over 36 months. Each project starts while the previous one is in its pilot stage.

**Figure 13.1: Proposed timeline**

<!-- mermaid-source: assets/diagrams/solution/fig-13-1-timeline.mmd -->
```mermaid
---
title: "Proposed timeline (M0 = start of work; January 2027 used as a placeholder start date)"
---
gantt
  dateFormat YYYY-MM-DD
  axisFormat %b %Y
  tickInterval 3month
  todayMarker off

  section Phase 1 · Project 1
  Federated Regulatory Control Mapping (M0–M12)        :p1, 2027-01-01, 2028-01-01
  Data model, OSCAL schemas, first frameworks          :2027-01-01, 2027-04-01
  Ingestion service and AI mapping engine              :2027-03-01, 2027-08-01
  Expert review workflow, Published catalogs API       :2027-06-01, 2027-11-01
  Partner pilots and open catalog release              :2027-09-01, 2028-01-01
  M12 · Reviewed OSCAL catalogs published              :milestone, m1, 2028-01-01, 0d

  section Phase 2 · Project 2
  Continuous Compliance Monitoring (M9–M27)            :p2, 2027-10-01, 2029-04-01
  Control configuration and connector framework        :2027-10-01, 2028-03-01
  Evidence engine and validation engine                :2028-01-01, 2028-09-01
  Pilots in independent technical environments         :2028-07-01, 2029-01-01
  Connector specs, OSCAL assessment results            :2028-11-01, 2029-04-01
  M27 · Assessment results published                   :milestone, m2, 2029-04-01, 0d

  section Phase 3 · Project 3
  Risk Scoring and Reporting (M24–M36)                 :p3, 2029-01-01, 2030-01-01
  Scoring methodology and Score engine                 :2029-01-01, 2029-05-01
  Remediation and closed-loop verification             :2029-03-01, 2029-08-01
  Report approval, OSCAL POA&M publishing              :2029-05-01, 2029-10-01
  Auditor pilots, documentation, release               :2029-08-01, 2030-01-01
  M36 · Complete solution released                     :milestone, m3, 2030-01-01, 0d
```
<!-- /mermaid-source -->

Files: [SVG](../assets/diagrams/solution/fig-13-1-timeline.svg) · [PNG](../assets/diagrams/solution/fig-13-1-timeline.png) · [Original](../assets/diagrams/solution/fig-13-1-timeline.original.png) · [Mermaid source](../assets/diagrams/solution/fig-13-1-timeline.mmd)

> Months are counted from the start of the work. The Mermaid version uses January 2027 as a placeholder start date; set real dates on the Roadmap project.

| Phase | Project | Months | Milestone |
|---|---|---|---|
| 1 | Federated Regulatory Control Mapping System | M0–M12 | M12: reviewed OSCAL catalogs published |
| 2 | Continuous Compliance Monitoring and Automated Audit Evidence System | M9–M27 | M27: assessment results published |
| 3 | Risk Assessment Compliance Scoring and Reporting Platform | M24–M36 | M36: complete solution released |

## Solution at the end of each phase
| Figure | End of phase | Diagram |
|---|---|---|
| 13.2 | Phase 1 | [Project 1 architecture](../systems/control-mapping/README.md#architecture) |
| 13.3 | Phase 2 | [Projects 1 and 2 combined](README.md#projects-1-and-2-combined) |
| 13.4 | Phase 3 | [Complete solution](README.md#complete-solution) |
