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
| TR-001 | Populate all `.ai/` and `.claude/` template placeholder files with real project context | — | — | `.ai/CONTEXT.md`, `.ai/DIRECTIVES.md`, `.ai/architecture/ARCHITECTURE.md`, `.ai/memory/SESSION_LOG.md`, `.ai/memory/LEARNINGS.md`, `.ai/memory/TRACEABILITY.md`, `.ai/architecture/PATTERNS.md` | — | Implemented |

---

**Next TR ID: 002**

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
