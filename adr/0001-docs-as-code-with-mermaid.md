# 0001. Docs as code with Markdown and Mermaid

- **Status:** Accepted
- **Date:** 2026-10-21
- **Initiative:** Platform

## Context
Architecture, flow and data model diagrams need to stay current, be reviewed like code,
and also be available as image files for slides and documents.

## Decision
- Keep documentation as Markdown in this repository.
- Write every diagram in Mermaid. The `.mmd` file under `assets/diagrams/` is the source of truth.
- Generate SVG and PNG from the `.mmd` with `scripts/build-diagrams.sh`, which also refreshes the Mermaid embedded in the Markdown pages.
- Keep each original figure as `*.original.png` for reference.

## Consequences
- Diagrams render on GitHub and changes show up in pull request diffs.
- Mermaid's automatic layout differs from the hand-drawn originals; the originals stay available.
- Contributors need Node.js to regenerate images (`npx @mermaid-js/mermaid-cli`).

## Alternatives considered
- Image-only diagrams: can't be diffed or reviewed.
- draw.io: precise layout, but diffs are hard to review and it needs a separate tool.
