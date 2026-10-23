# Repositories

Where the code for each architecture component lives. Every repository is in the
[GRaCe-GRC organization](https://github.com/GRaCe-GRC).

## Repositories are components
A repository is a component, not part of a project. Any project can use a repository, and its
work is tracked on that project's board. Stories live in the
[`.github`](https://github.com/GRaCe-GRC/.github/issues) repository and are referenced as
`GRC-<n>`; each repository also has its own prefix for its own issues.

Build, run and test instructions are in each repository's README. Every repository runs CI
through the shared [reusable workflows](https://github.com/GRaCe-GRC/.github/blob/main/.github/workflows/README.md).

## Project 1: Federated Regulatory Control Mapping System

| Component | Repository | Layer | Stack | Issue prefix |
|---|---|---|---|---|
| Admin console UI | [admin-console-ui](https://github.com/GRaCe-GRC/admin-console-ui) | User interface | Angular | `ACUI-` |
| Regulatory ingestion service | [regulatory-ingestion-service](https://github.com/GRaCe-GRC/regulatory-ingestion-service) | Service | Spring Boot | `RIS-` |
| Regulatory engine | [regulatory-engine](https://github.com/GRaCe-GRC/regulatory-engine) | Service | Spring Boot | `RE-` |
| Catalog service | [catalog-service](https://github.com/GRaCe-GRC/catalog-service) | Service | Spring Boot | `CATS-` |
| Admin console service | [admin-console-service](https://github.com/GRaCe-GRC/admin-console-service) | Service | Spring Boot | `ACS-` |
| Control API | [control-api](https://github.com/GRaCe-GRC/control-api) | Inner API | Spring Boot | `CTLA-` |
| Control mapping API | [control-mapping-api](https://github.com/GRaCe-GRC/control-mapping-api) | Inner API | Spring Boot | `CMA-` |
| Regulatory API | [regulatory-api](https://github.com/GRaCe-GRC/regulatory-api) | Inner API | Spring Boot | `RA-` |
| Catalog API | [catalog-api](https://github.com/GRaCe-GRC/catalog-api) | Inner API | Spring Boot | `CATA-` |

The diagrams show an admin console UI and an admin console service in every project. They are
delivered as one shared `admin-console-ui` and one shared `admin-console-service`, used by all
three projects.

## Projects 2 and 3
No repositories yet. They are added here when their setup stories are done; the admin console
repositories above are shared with them.

## Organization repositories

| Repository | Purpose | Issue prefix |
|---|---|---|
| [.github](https://github.com/GRaCe-GRC/.github) | Organization profile, community health files, issue and PR templates, reusable workflows; epics and stories | `GRC-` |
| [GRaCe-GRC-docs](https://github.com/GRaCe-GRC/GRaCe-GRC-docs) | This documentation hub | `DOCS-` |
| [GRaCe-GRC-sandbox](https://github.com/GRaCe-GRC/GRaCe-GRC-sandbox) | Local development environment (Docker Compose) | `SBX-` |

## Local environment
[GRaCe-GRC-sandbox](https://github.com/GRaCe-GRC/GRaCe-GRC-sandbox) runs the environment on your machine
with Docker Compose: today the PostgreSQL databases, and the services as they are added. It does not
include Amazon SQS, SNS or S3 yet. See its
[README](https://github.com/GRaCe-GRC/GRaCe-GRC-sandbox#readme) to start it.

## Related
- [Solution architecture](README.md)
- [Project 1 architecture](../systems/control-mapping/README.md#architecture)
