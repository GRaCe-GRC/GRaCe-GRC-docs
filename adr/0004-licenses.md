# 0004. Apache-2.0 for code, CC BY 4.0 for documentation

- **Status:** Accepted
- **Date:** 2026-10-23
- **Initiative:** Platform

## Context
All GRaCe-GRC repositories are public. Code and documentation need clear licences so others can
use, change and contribute to them, and so contributions are accepted under known terms.

## Decision
- **Code repositories** are licensed under the **Apache License 2.0**, with a `LICENSE` file and a
  `NOTICE` file in the repository root. Maven projects also declare the licence in `pom.xml`.
- **Documentation** in this repository is licensed under **Creative Commons Attribution 4.0
  International (CC BY 4.0)**.
- New repositories are created with the matching licence from the start.

## Consequences
- Apache-2.0 includes an explicit patent grant and is compatible with the libraries the
  services use (Spring, Angular).
- Anyone redistributing the code keeps the `NOTICE` file; anyone reusing the documentation gives
  attribution.
- Third-party code and assets added to a repository must have licences compatible with these.

## Alternatives considered
- MIT for code: simpler, but no explicit patent grant.
- One licence for everything: software licences fit documentation poorly, and CC licences are not
  meant for software.
