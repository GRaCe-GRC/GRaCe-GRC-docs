# 0003. Repositories are components; GitHub Projects are initiatives

- **Status:** Accepted
- **Date:** 2026-10-23
- **Initiative:** Platform

## Context
The platform is delivered as three projects (initiatives) that share components: the admin
console serves all three, and later projects build on the services and APIs of earlier ones. If a
repository belonged to one project, shared components would need an owner project and work for
the other projects would be tracked in the wrong place.

## Decision
- A **repository is a component**. It is not owned by a project, and any project can use it.
- A **GitHub Project is an initiative**: the GRaCe-GRC Roadmap (epics) and one board per project.
  Issues from any repository can be on any project board.
- Epics and stories live in the `.github` repository (`GRC-<n>`) and in this repository for
  documentation (`DOCS-<n>`). Stories are sub-issues of epics.
- Issues are labelled `project-1`, `project-2`, `project-3` or `platform` (shared work).
- The [repository catalog](../architecture/repositories.md) maps each architecture component to its
  repository.

## Consequences
- Shared components have one home, and each project's work stays visible on its own board.
- A repository can have issues on several boards, so labels and boards must be kept accurate.
- Repository names describe the component, not the project.

## Alternatives considered
- Repositories owned by a project: shared components would need an arbitrary owner, and
  cross-project work would be hard to follow.
- One repository per project (monorepo per initiative): shared components would be duplicated or
  depend on another project's repository.
