# Architecture Decision Records (ADRs)

This directory contains Architecture Decision Records — lightweight documents that capture **why** significant decisions were made, not just what was done.

> **AI Assistants**: You are required to create an ADR here whenever you make a decision that falls under the [trigger conditions](#when-to-create-an-adr) below. Do not skip this step.

---

## Format

Each ADR is a single Markdown file with YAML frontmatter. The frontmatter is the machine-readable index; the body is the human-readable record. There is no separate index file — tooling can discover ADRs by globbing `ADR-*.md` and parsing frontmatter.

```text
ADR-NNN-kebab-case-title.md
```

Examples:

- `ADR-001-add-ai-directives-system.md`
- `ADR-002-use-postgres-over-mysql.md`

---

## When to Create an ADR

Create an ADR for any decision that is:

- **Architectural** — affects the overall structure, patterns, or design of the system
- **Hard to reverse** — would be costly or disruptive to undo later
- **Non-obvious** — future contributors (human or AI) would reasonably ask "why did we do it this way?"
- **Cross-cutting** — affects more than one module, layer, or team
- **Technology choices** — introducing or replacing a dependency, tool, or framework
- **Security-relevant** — changes to auth, secrets handling, data access, or trust boundaries

You do **not** need an ADR for:

- Routine bug fixes
- Style or formatting changes
- Obvious, easily-reversed implementation details

---

## How to Create an ADR

1. Copy `template.md` and name it `ADR-NNN-short-title.md`
2. Use the next sequential number by checking the highest existing `ADR-NNN-*.md` file
3. Fill in all frontmatter fields and all body sections — leave none blank
4. Set `status: proposed` initially; update to `accepted` once the decision is confirmed

---

## ADR Lifecycle

```text
proposed → accepted → (deprecated | superseded)
```

| Status | Meaning |
|--------|---------|
| `proposed` | Decision is under consideration |
| `accepted` | Decision has been made and is active |
| `deprecated` | No longer relevant; kept for history |
| `superseded` | Replaced by a newer ADR — set `superseded_by` to the new ID |

---

## Frontmatter Reference

Each ADR file begins with a YAML frontmatter block that serves as the machine-readable record:

```yaml
---
id: "ADR-001"
title: "Short Title"
status: proposed          # proposed | accepted | deprecated | superseded
date: "YYYY-MM-DD"
decision_makers: []       # names of humans/AI involved
superseded_by: null       # e.g. "ADR-005", or null
---
```

Tooling integration: parse frontmatter with standard libraries (`js-yaml`, `python-frontmatter`, `yq`) or grep/awk. No secondary index file is required or maintained.
