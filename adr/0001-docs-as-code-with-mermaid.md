# 0001. Docs as code with Markdown and Mermaid

- **Status:** Accepted
- **Date:** 2026-10-20
- **Initiative:** Platform

## Context
Architecture and flow diagrams need to stay current and be reviewed like code.

## Decision
Keep documentation in this repository as Markdown, with diagrams in Mermaid, structured with the C4 model.

## Consequences
- Diagrams render on GitHub and changes show up in pull request diffs.
- Mermaid's layout control is limited; complex diagrams may need draw.io files (`.drawio`) committed alongside an exported `.svg`.

## Alternatives considered
- Image-only diagrams (PNG): can't be diffed or reviewed.
- External wiki: separate from pull request review and history.
