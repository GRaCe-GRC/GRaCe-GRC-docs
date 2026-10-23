# 0002. Shared admin console across projects

- **Status:** Accepted
- **Date:** 2026-10-23
- **Initiative:** Platform

## Context
Figures 10.1, 11.1 and 12.1 each show an **Admin console UI** and an **Admin console service**
inside their project, so the diagrams contain three admin consoles. Reviewers and administrators
work across all three projects, and the consoles share layout, navigation, sign-in and most of
their behaviour.

## Decision
- Deliver the admin consoles of all projects as **one** `admin-console-ui` (Angular) and **one**
  `admin-console-service` (Spring Boot), each with a section or module per project.
- `admin-console-service` is shaped around the screens of the console (user experience), not
  around a project's domain. It reaches each project's data only through that project's service
  APIs, as any other service does.
- The figures keep one console per project: they show what each project needs from the console,
  not how it is deployed.

## Consequences
- One application to build, secure, deploy and keep consistent for all users.
- A change for one project can affect the others; each project's section must stay separate in
  the code.
- Project 2 and Project 3 add their sections to the existing repositories instead of new ones.

## Alternatives considered
- One admin console per project, as drawn: three copies of the same shell, sign-in and
  navigation, and users switching between three applications.
- One console UI with a backend per project: a single UI, but three services with the same
  cross-cutting concerns.
