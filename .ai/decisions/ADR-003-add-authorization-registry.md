# ADR-003: Add Authorization Registry

## Status

Accepted

## Date

2026-02-25

## Context

AI assistants were operating without a persistent, queryable record of what they are and are not authorized to do in this repository. Every session started with implicit defaults, meaning:

- The AI had to ask for permission on every potentially destructive action, even for things previously approved
- There was no way to set hard limits that survived session boundaries
- Approved generalizations ("you can delete any directory") were lost between sessions
- There was no distinction between "never do this regardless of what the user says in-session" and "ask before doing this"

The existing DIRECTIVES.md had a "Forbidden Actions" section, but it was a static template with no mechanism for the AI to learn and persist new authorizations discovered during work.

## Decision

We will introduce `.ai/memory/AUTHORIZATIONS.md` as a two-layer authorization registry:

**Layer 1: Base Rules** (user-configured, static)
- `Never Allowed` — absolute prohibitions the AI must refuse even if asked in-session
- `Always Allowed` — actions the AI may take freely without confirmation
- `Always Ask` — actions that must be confirmed every time regardless of learned authorizations

**Layer 2: Learned Authorizations** (AI-accumulated, dynamic)
- A table of AUTH-NNN entries appended by the AI during sessions
- Each entry records: action category, scope (specific/general/session), status (granted/denied), date, session, and origin

**The Decision Protocol** governs every Gated Action:
1. Check Never Allowed → refuse if matched (non-negotiable)
2. Check Always Allowed → proceed if matched
3. Check Learned Authorizations → follow the matching entry
4. No rule found → ask for specific permission
5. After a grant → ask the generalization follow-up: "General rule or one-time exception?"
6. Record the result as AUTH-NNN immediately

**Gated Action Categories** (13 defined):
`delete-files`, `delete-directories`, `overwrite-uncommitted`, `git-commit`, `git-push`, `git-force`, `git-branch-delete`, `dependency-add`, `dependency-remove`, `config-modify`, `security-sensitive`, `external-call`, `test-bypass`

DIRECTIVES.md §3c was added to enforce this protocol as a mandatory directive.

## Consequences

### Positive
- Hard limits survive sessions — a "never" rule set by the project owner cannot be overridden by in-session requests
- Approved generalizations persist — the AI stops asking the same question repeatedly once the user has answered it
- The generalization follow-up actively builds policy over time rather than requiring the user to pre-define everything
- AUTH-NNN IDs provide an audit trail for every authorization
- The two-layer design gives project owners control over policy while letting the AI learn within those bounds

### Negative
- The AI must read AUTHORIZATIONS.md before every gated action, adding a file to session startup context
- The learned authorizations table will grow over time and may need pruning
- The system relies on the AI correctly categorizing actions against the 13 defined categories — ambiguous actions may not match cleanly

### Neutral
- Base Rules start with sensible defaults (never force-push main, never commit secrets) which the user can extend
- AUTH-001 was bootstrapped from an action already taken (prompts directory deletion) to seed the learned table

## Alternatives Considered

### Option 1: Expand the "Forbidden Actions" section in DIRECTIVES.md
- **Pros**: No new file; already read at session start
- **Cons**: DIRECTIVES.md is for static rules; it has no mechanism for the AI to append learned authorizations; mixing static and dynamic content degrades both
- **Why rejected**: The learned authorization layer requires a separate, appendable file

### Option 2: Use LEARNINGS.md for authorization notes
- **Pros**: One fewer file
- **Cons**: LEARNINGS.md is free-form knowledge; authorizations need structured, queryable entries with explicit status (granted/denied) and scope; free-form text cannot be reliably checked against the decision protocol
- **Why rejected**: Authorizations require a table with defined fields, not prose notes

### Option 3: Require user to pre-configure all authorizations before first session
- **Pros**: Simpler protocol (no in-session learning)
- **Cons**: Users cannot anticipate every action an AI might take; pre-configuration is burdensome and will be incomplete
- **Why rejected**: The on-the-go learning with generalization follow-up is the core value of this system

## References

- [AUTHORIZATIONS.md](../memory/AUTHORIZATIONS.md)
- [DIRECTIVES.md §3c](../DIRECTIVES.md) — mandatory authorization check protocol
- [ADR-002](ADR-002-add-ai-memory-system.md) — memory system this builds on
