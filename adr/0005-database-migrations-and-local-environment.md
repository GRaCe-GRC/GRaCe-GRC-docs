# 0005. Database, migrations and local environment

- **Status:** Accepted
- **Date:** 2026-10-22
- **Initiative:** Platform

## Context
The first feature stores regulatory authorities, so the platform needs a database engine, a way
to create and change schemas, table naming rules, and a place to run everything on a developer's
machine. The data model already uses PostgreSQL types (`uuid`, `jsonb`, arrays). Automated tests
need infrastructure that is not in place yet.

## Decision
- **PostgreSQL** for every database.
- **Each inner API owns its database.** Only that API connects to it; everything else goes
  through the API. The API creates and changes its schema with **Flyway**: versioned SQL files
  (`V1__create_authorities.sql`, ...) in the API's repository, applied in order on startup.
- **Table names are plural without a prefix** (`authorities`, `frameworks`, `files`,
  `requirements`); foreign keys are the singular name plus `_id`.
- **GRaCe-GRC-sandbox** runs the local environment with Docker Compose: the databases and, as
  they are added, the services. It creates databases and users only; tables come from each API's
  migrations. It does not include Amazon SQS, SNS or S3 yet.
- **Automated testing is deferred.** Changes are verified manually against the sandbox, and each
  pull request lists the steps. No Testcontainers and no in-memory database (H2).

## Consequences
- Schema changes are reviewed like code and applied the same way everywhere.
- A database can be rebuilt from scratch by resetting the sandbox and starting its API.
- Services that need a database cannot start without the sandbox running locally.
- Without automated tests, regressions are caught only by manual checks until testing is added.
- Follow-up: add automated tests; add SQS, SNS and S3 (for example LocalStack) to the sandbox.

## Alternatives considered
- Hibernate `ddl-auto=update`: no history, cannot rename or drop columns, schemas drift.
- `schema.sql` on startup: no versioning; the first change after data exists becomes manual.
- Liquibase: equivalent capability, but XML/YAML changelogs instead of plain SQL.
- Testcontainers or H2 for tests: not used now; H2 also differs from PostgreSQL on `uuid`, `jsonb` and arrays.
- A shared database for all services: couples services to each other's schemas.
