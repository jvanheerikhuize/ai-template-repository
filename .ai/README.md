---
document_type: directory-index
version: "1.1"
last_updated: "2026-02-26"
---

# .ai/ — AI Governance Directory

Persistent context, rules, and memory for AI assistants. All files are live operational data — **not static documentation**. Keep them current.

## Session Initialization (read in order)

| # | File | Format | Purpose |
|---|------|--------|---------|
| 1 | [DIRECTIVES.md](DIRECTIVES.md) | MD + YAML | Mandatory rules — defines all AI behavior |
| 2 | [CONTEXT.md](CONTEXT.md) | MD + YAML | Project identity, state, and navigation |
| 3 | [memory/SESSION_LOG.yaml](memory/SESSION_LOG.yaml) | YAML | Last session's open items and state |
| 4 | [memory/LEARNINGS.yaml](memory/LEARNINGS.yaml) | YAML | Accumulated project knowledge |
| 5 | [memory/TRACEABILITY.yaml](memory/TRACEABILITY.yaml) | YAML | In-progress work and audit trail |
| 6 | [decisions/INDEX.yaml](decisions/INDEX.yaml) | YAML | Past architectural decisions |

## Full File Index

| File | Format | Purpose |
|------|--------|---------|
| `DIRECTIVES.md` | MD + YAML | Non-negotiable AI rules |
| `CONTEXT.md` | MD + YAML | Master project context |
| `config.yaml` | YAML | AI tool integration preferences |
| `specs/SPEC.md` | MD | Product spec guide (template) |
| `architecture/ARCHITECTURE.md` | MD + YAML | System architecture |
| `architecture/PATTERNS.md` | MD + YAML | Code conventions |
| `decisions/INDEX.yaml` | YAML | ADR index (machine-parseable) |
| `decisions/README.md` | MD | ADR process and lifecycle |
| `decisions/template.md` | MD + YAML | Blank ADR template |
| `memory/AUTHORIZATIONS.yaml` | YAML | Gated action policy |
| `memory/SESSION_LOG.yaml` | YAML | Per-session history |
| `memory/LEARNINGS.yaml` | YAML | Accumulated knowledge |
| `memory/TRACEABILITY.yaml` | YAML | Request → commit linkage |
| `memory/README.md` | MD | Memory system guide |

## Tool Entry Points

| Tool | Config File | Reads First |
|------|-------------|-------------|
| Claude Code | `.claude/CLAUDE.md` | `DIRECTIVES.md` → `CONTEXT.md` |
| Cursor | `.cursorrules` | `CONTEXT.md` |
| Copilot | `.github/copilot-instructions.md` | `CONTEXT.md` |
| Any tool | This file | `CONTEXT.md` |
