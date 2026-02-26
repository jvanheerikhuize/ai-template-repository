# AI Memory System

This directory is the AI's persistent memory for this project. It serves two purposes:

1. **Persistent memory** — knowledge accumulated across sessions that would otherwise be lost
2. **End-to-end traceability** — a complete audit trail from user request to deployed code

> **AI Assistants**: You are required to read and update these files as specified. See [DIRECTIVES.md](../DIRECTIVES.md) §3b for the mandatory rules.

---

## Files

| File | Format | Purpose | Read | Write |
|------|--------|---------|------|-------|
| [AUTHORIZATIONS.yaml](AUTHORIZATIONS.yaml) | YAML | Base rules + learned action permissions | Before every gated action | When a new authorization is learned |
| [SESSION_LOG.yaml](SESSION_LOG.yaml) | YAML | Chronological log of every AI session | Start of session | End of session |
| [LEARNINGS.yaml](LEARNINGS.yaml) | YAML | Accumulated project knowledge and gotchas | Start of session | When something non-obvious is discovered |
| [TRACEABILITY.yaml](TRACEABILITY.yaml) | YAML | Matrix linking requests → specs → ADRs → code → PRs | When implementing | When any link in the chain is established |

All files use YAML 1.2 and are parseable by `yq`, Python `yaml`, and `grep`.

### Parsing Examples

```bash
# Get the most recent session summary
yq '.sessions[-1].summary' .ai/memory/SESSION_LOG.yaml

# List all active learnings
yq '.learnings[] | select(.status == "active") | .title' .ai/memory/LEARNINGS.yaml

# Find a trace by id
yq '.traces[] | select(.id == "TR-001")' .ai/memory/TRACEABILITY.yaml

# Check what is never allowed
yq '.base_rules.never_allowed[].rule' .ai/memory/AUTHORIZATIONS.yaml
```

---

## When to Update Each File

### SESSION_LOG.yaml
- **Read**: At the start of every session to understand what was done previously and any open items
- **Write**: At the end of every session — append a new entry to the `sessions` array; never edit past entries

### LEARNINGS.yaml
- **Read**: Before touching any existing code
- **Write**: When you discover something non-obvious — a gotcha, an undocumented constraint, a pattern that diverges from expected, or domain knowledge that took investigation

### TRACEABILITY.yaml
- **Read**: When starting work on a request, to check if related work exists
- **Write**: When any traceability link is established:
  - A user request is received
  - A spec is created or referenced
  - An ADR is created
  - Code is changed (files + commit/PR reference)
  - A PR is opened or merged

---

## Traceability Chain

Every unit of work should be traceable end-to-end:

```
User Request
    │
    ▼
Spec (specs/features/*.yaml)
    │
    ▼
ADR (if architectural decision made)
    │
    ▼
Implementation (files changed)
    │
    ▼
PR / Commit
    │
    ▼
TRACEABILITY.yaml entry (the permanent record)
```

A row in TRACEABILITY.yaml is the single source of truth for this chain.
