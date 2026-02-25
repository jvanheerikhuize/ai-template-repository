# Traceability Matrix

End-to-end audit trail linking every user request to the spec, architectural decisions, code changes, and PR that fulfilled it.

> **AI Assistants**: Update this file whenever any link in the chain is established — do not wait until the work is complete. A partial row is better than no row.

---

## How to Add a Row

Use the next sequential TR-NNN ID. Fill in what you know; leave unknowns as `—`.

```markdown
| TR-NNN | [Brief request title] | [Spec file or —] | [ADR-NNN or —] | [Files changed] | [PR # or commit or —] | [Status] |
```

**Status values**: `In Progress` | `Implemented` | `Merged` | `Superseded` | `Abandoned`

---

## Matrix

| ID | Request | Spec | ADR | Key Files Changed | PR / Commit | Status |
|----|---------|------|-----|-------------------|-------------|--------|
| TR-001 | Add mandatory AI directives file to `.ai/` folder | — | [ADR-001](../decisions/ADR-001-add-ai-directives-system.md) | `.ai/DIRECTIVES.md`, `.ai/config.yaml`, `.ai/CONTEXT.md`, `.claude/CLAUDE.md` | — | Implemented |
| TR-002 | Make decisions system work in fresh clones; auto-document decisions | — | [ADR-001](../decisions/ADR-001-add-ai-directives-system.md) | `.ai/decisions/README.md`, `.ai/decisions/INDEX.md`, `.ai/decisions/ADR-001-*.md`, `.claude/CLAUDE.md` | — | Implemented |
| TR-003 | Add persistent memory and end-to-end traceability to `.ai/` | — | [ADR-002](../decisions/ADR-002-add-ai-memory-system.md) | `.ai/memory/README.md`, `.ai/memory/SESSION_LOG.md`, `.ai/memory/LEARNINGS.md`, `.ai/memory/TRACEABILITY.md` | — | Implemented |
| TR-004 | Add persistent authorization registry with base rules and learned authorizations | — | [ADR-003](../decisions/ADR-003-add-authorization-registry.md) | `.ai/memory/AUTHORIZATIONS.md`, `.ai/DIRECTIVES.md` (§3c), `.ai/config.yaml`, `.ai/CONTEXT.md`, `.ai/memory/README.md` | — | Implemented |

---

**Next TR ID: 005**

---

## How to Read This Table

- **ID**: Unique trace identifier. Reference this in commit messages, PRs, and session logs.
- **Request**: The original user request or issue that initiated the work.
- **Spec**: The feature spec that formalises the request (link to `specs/features/*.yaml`).
- **ADR**: Any architectural decision made during implementation (link to `.ai/decisions/ADR-NNN-*.md`).
- **Key Files Changed**: The most significant files modified — not exhaustive, but enough to find the change.
- **PR / Commit**: The Git reference that delivered the change.
- **Status**: Current state of this trace.

## Cross-References

- Full decision rationale: [.ai/decisions/INDEX.md](../decisions/INDEX.md)
- Session-by-session history: [SESSION_LOG.md](SESSION_LOG.md)
- Accumulated knowledge: [LEARNINGS.md](LEARNINGS.md)
