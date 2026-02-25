# ADR-002: Add AI Memory System

## Status

Accepted

## Date

2026-02-25

## Context

AI assistants have no built-in memory across sessions. Each new conversation starts from scratch, which means:
- Project-specific gotchas and conventions have to be re-discovered every session
- There is no audit trail linking user requests to the specs, decisions, and code that fulfilled them
- Open items from one session are invisible to the next
- The same mistakes can be repeated across sessions

The existing `.ai/decisions/` ADR system captured *why* architectural decisions were made, but there was no mechanism to capture:
1. *What was done* in each session (session log)
2. *What was learned* about this specific codebase over time (accumulated knowledge)
3. *The full chain* from request to spec to ADR to code to PR (traceability)

## Decision

We will introduce a `.ai/memory/` directory containing three files that together form the AI's persistent memory:

| File | Purpose |
|------|---------|
| `SESSION_LOG.md` | Chronological log of every session: what was requested, what changed, what's open |
| `LEARNINGS.md` | Long-term knowledge store: gotchas, domain facts, anti-patterns, integration notes |
| `TRACEABILITY.md` | End-to-end matrix: request → spec → ADR → key files → PR, with unique TR-NNN IDs |

The traceability chain is:
```
User Request → Spec → ADR → Implementation → PR → TRACEABILITY.md row
```

AI assistants are required (via DIRECTIVES.md §3b) to:
- Read all three files at session start
- Update TRACEABILITY.md incrementally during the session
- Append a SESSION_LOG entry at session end
- Add to LEARNINGS.md when non-obvious knowledge is gained

## Consequences

### Positive
- Context survives across sessions without relying on the AI's built-in memory
- Every change can be traced from its originating request to the PR that delivered it
- Accumulated knowledge prevents re-discovering the same gotchas
- Open items are explicitly carried forward in SESSION_LOG
- TR-NNN IDs provide a stable reference across ADRs, commits, and PRs

### Negative
- Requires discipline from AI assistants to actually maintain the files
- TRACEABILITY.md and SESSION_LOG will grow over time and need periodic archiving
- Context loading at session start now includes three additional files

### Neutral
- The memory files are plain markdown — human-readable and editable by the team
- No tooling or scripts are required; the system is entirely file-based

## Alternatives Considered

### Option 1: Expand the SESSION_LOG into CONTEXT.md
- **Pros**: Fewer files
- **Cons**: CONTEXT.md is a static project overview; mixing it with a live log creates noise and makes both worse
- **Why rejected**: Separation of concerns — static project description vs. dynamic session history

### Option 2: Single combined MEMORY.md
- **Pros**: Simpler — one file to read
- **Cons**: Mixes three distinct concerns (session history, knowledge, traceability) into one file; harder to navigate and update
- **Why rejected**: Each file has different read/write timing and access patterns; combining them degrades all three

### Option 3: External memory tool (e.g., vector DB, notes app)
- **Pros**: Richer search; structured querying
- **Cons**: Requires tooling beyond the repo; breaks the "clone and work" promise of the template
- **Why rejected**: File-based approach keeps the system self-contained and tool-agnostic

## References

- [memory/README.md](../memory/README.md)
- [memory/SESSION_LOG.md](../memory/SESSION_LOG.md)
- [memory/LEARNINGS.md](../memory/LEARNINGS.md)
- [memory/TRACEABILITY.md](../memory/TRACEABILITY.md)
- [DIRECTIVES.md §3b](../DIRECTIVES.md) — mandatory memory maintenance rules
- [ADR-001](ADR-001-add-ai-directives-system.md) — the directives system this builds on
