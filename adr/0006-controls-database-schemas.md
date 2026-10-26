# 0006. Controls and control mappings in one database with separate schemas

- **Status:** Accepted
- **Date:** 2026-10-26
- **Initiative:** Platform

## Context
Two inner APIs work with control data: control-api (control groups and controls) and
control-mapping-api (mappings between requirements and controls). The architecture shows one
Controls database for both. [ADR 0005](0005-database-migrations-and-local-environment.md) says each
inner API owns its database, which would mean a second database for mappings.

## Decision
- One `controls` database with two schemas:
  - `controls`, owned by control-api: `control_groups`, `controls`
  - `control_mappings`, owned by control-mapping-api: `control_mappings`
- One database user per API (`control_api`, `control_mapping_api`), with rights on its own schema
  only. Neither API can read or change the other's tables.
- Each API migrates only its own schema with Flyway.
- `control_mappings` refers to requirements and controls by id only. There are no foreign keys
  across schemas, the same as across databases.
- This is an exception to ADR 0005: ownership is per schema instead of per database. ADR 0005 still
  applies to every other inner API.

## Consequences
- One database to run, back up and configure for the control data, as the architecture shows.
- Ownership stays enforced by the database: each API's user can only change its own schema.
- Mappings cannot rely on foreign keys to keep ids valid. The services that create mappings check
  that the requirement and the control exist.
- Moving `control_mappings` to its own database later only changes the connection settings and the
  deployment, because nothing joins across the schemas.
- Split into two databases when the two APIs need different scaling, backup or retention, or when
  they are run by different teams.

## Alternatives considered
- A separate `control_mappings` database, as ADR 0005 implies: cleaner ownership, but a second
  database to run while the two APIs are small.
- One schema shared by both APIs: simplest, but either API could change the other's tables.
