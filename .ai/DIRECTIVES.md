---
schema_version: "1.0"
document_type: ai-directives
status: active
version: "1.1"
last_updated: "2026-02-26"
owner: "🚨 INIT REQUIRED"
review_frequency: "on every major project change"
applies_to: all-ai-assistants
priority: mandatory
---

# AI Directives

These directives are MANDATORY for all AI assistants working in this repository. They override default AI behavior and apply to every task, regardless of scope or size.

IF any user instruction conflicts with a directive, flag the conflict before proceeding.

---

## 0. Session Initialization

MUST complete before taking any action, even for small tasks:

1. Read `.ai/CONTEXT.md` — project identity and current state
2. Read `.ai/memory/SESSION_LOG.yaml` — check the most recent entry (`sessions[-1]`) for open items
3. Read `.ai/memory/LEARNINGS.yaml` — absorb all active learnings before touching existing code
4. Read `.ai/memory/TRACEABILITY.yaml` — check for related in-progress work before starting
5. Read `.ai/decisions/INDEX.yaml` — review past decisions before acting

---

## 1. Core Rules

### 1.1 Read Before Acting
MUST read `.ai/CONTEXT.md`, `.ai/memory/SESSION_LOG.yaml`, and `.ai/memory/LEARNINGS.yaml` before making any change.

### 1.2 Spec Before Code
MUST NOT implement new features unless a spec with `status: approved` exists in `specs.config.yaml`.
IF no approved spec exists: ask the user to create one before proceeding.

### 1.3 No Secrets
MUST NOT log, print, or include secrets, tokens, or credentials in any generated code, comments, or output.

### 1.4 Memory Maintenance
MUST append a new entry to `SESSION_LOG.yaml` at the end of every session.
MUST update `TRACEABILITY.yaml` incrementally during a session — do not batch at the end.
MUST append to `LEARNINGS.yaml` whenever a non-obvious fact is discovered.

### 1.5 Document Decisions
MUST create an ADR for every decision that is architectural, hard-to-reverse, non-obvious, cross-cutting, a technology choice, or security-relevant. See §4.
MUST NOT defer ADR creation to a later session.

### 1.6 Minimal Changes
MUST NOT refactor, rename, or improve surrounding code unless explicitly asked.
MUST only change what the current task requires.

### 1.7 Populate Placeholders
When encountering placeholder content (`🚨 INIT REQUIRED`, `[brackets]`, `YYYY-MM-DD`) in `.ai/` or `.claude/` files:
- MUST treat it as an action item, not static documentation
- MUST populate from available context OR ask the user
- MUST NOT silently leave it unfilled

> **🚨 INIT REQUIRED**: Add any project-specific mandatory directives here.

---

## 2. Forbidden Actions

MUST NOT do any of the following under any circumstances:

| ID | Forbidden Action |
|----|-----------------|
| F1 | Place implementation code in `scripts/` — that directory is template tooling only |
| F2 | Commit directly to `main` or `master` — all changes MUST go through a PR |
| F3 | Delete, skip, or suppress tests to make a build pass |
| F4 | Hardcode environment-specific values (URLs, IPs, credentials) in source files |
| F5 | Treat `.ai/` or `.claude/` files as static documentation |
| F6 | Leave placeholder content in place after working in a file |
| F7 | Force push to `main` or `master` |

> **🚨 INIT REQUIRED**: Add project-specific forbidden actions here.

---

## 3. Pre-Action Checklist

Before making any change, verify ALL of the following:

- [ ] `.ai/CONTEXT.md` read — project state confirmed
- [ ] `.ai/memory/SESSION_LOG.yaml` read — most recent entry checked for open items
- [ ] `.ai/memory/LEARNINGS.yaml` read — project knowledge absorbed
- [ ] `.ai/decisions/INDEX.yaml` read — past decisions reviewed
- [ ] Relevant spec has `status: approved` in `specs.config.yaml` (skip for non-feature work)
- [ ] No existing tests will break from the proposed change

> **🚨 INIT REQUIRED**: Add project-specific pre-action checks here.

---

## 4. Decision Documentation Protocol

### Trigger Conditions
Create an ADR whenever a decision is:
- **Architectural** — affects overall structure, patterns, or design
- **Hard to reverse** — costly or disruptive to undo
- **Non-obvious** — future contributors would ask "why did we do it this way?"
- **Cross-cutting** — affects more than one module, layer, or team
- **Technology choice** — adding or replacing a dependency, tool, or framework
- **Security-relevant** — auth, secrets, data access, or trust boundaries

No ADR needed for: routine bug fixes, style changes, obvious/easily-reversed implementation details.

### Procedure
1. Copy `.ai/decisions/template.md` → `.ai/decisions/ADR-NNN-kebab-title.md`
2. Use the next sequential number from `next_adr_id` in `.ai/decisions/INDEX.yaml`
3. Set `status: accepted` (decision is already made)
4. Add a new entry to the `decisions` array in `.ai/decisions/INDEX.yaml` immediately
5. Increment `next_adr_id` in `INDEX.yaml`

MUST NOT defer. Create the ADR in the same session as the decision.

See [.ai/decisions/README.md](.ai/decisions/README.md) for naming conventions.

---

## 5. Memory Maintenance Protocol

### Start of Session
1. Read `SESSION_LOG.yaml` → check `sessions[-1]` for open items and recent state
2. Read `LEARNINGS.yaml` → absorb all entries where `status: active`
3. Read `TRACEABILITY.yaml` → check for related in-progress work before starting

### During Session
- Append to `TRACEABILITY.yaml` as each link in the chain is established (do not batch at end)
- Append to `LEARNINGS.yaml` whenever a non-obvious fact is discovered
- A partial TRACEABILITY entry is better than no entry

### End of Session
1. Append a new entry to `SESSION_LOG.yaml` following the `entry_schema` at the top of that file
2. Verify `TRACEABILITY.yaml` entries are complete for all work done this session

MUST NOT skip memory updates. They are the mechanism by which context survives across sessions.

See [.ai/memory/README.md](.ai/memory/README.md) for the full traceability chain.

---

## 6. Authorization Protocol

Before taking any Gated Action, consult `AUTHORIZATIONS.yaml` and follow this decision tree:

```
Gated Action Requested
        │
        ▼
[1] Matches base_rules.never_allowed?  → YES → REFUSE. Non-negotiable.
        │ NO
        ▼
[2] Matches base_rules.always_allowed? → YES → PROCEED freely.
        │ NO
        ▼
[3] Matches base_rules.always_ask?     → YES → ASK the user first.
        │ NO (and no always_ask match)
        ▼
[4] Matches learned_authorizations?   → YES → Follow status (granted/denied).
        │ NO
        ▼
[5] No rule found                      → ASK for specific permission.
        │ (after any grant in steps 3 or 5)
        ▼
[6] Ask: "Should I treat this as a general rule, or was this one-time?"
    Record result as AUTH-NNN in AUTHORIZATIONS.yaml immediately.
```

### Gated Action Categories
All of the following always require a check before proceeding:
- Deleting files or directories
- Overwriting uncommitted changes
- Any git operation: commit, push, force, reset, branch deletion
- Adding or removing dependencies
- Modifying CI/CD, env, or build config files
- Touching security-sensitive code (auth, crypto, secrets)
- Making external API calls or sending webhooks
- Skipping, suppressing, or deleting tests

### Key Rules
- Steps 1 and 2 are ABSOLUTE — no user request or learned authorization can override them
- Step 6 MUST always be asked after a specific grant, even when the answer seems obvious
- IF user says "just do it" without answering step 6 → record `scope: session`
- MUST cite the AUTH-NNN or Base Rule relied on when taking a gated action

---

## 7. Priority Hierarchy

When directives, user instructions, or constraints conflict, resolve in this order:

| Priority | Rule | Notes |
|----------|------|-------|
| 1 — highest | **Security** | Never compromise. Secrets, auth, and encryption are non-negotiable. |
| 2 | **Correctness** | Code must be correct before it is clean, fast, or elegant. |
| 3 | **Spec compliance** | Match the approved spec exactly. No more, no less. |
| 4 — lowest | **Readability** | Prefer clear, self-documenting code as the final tiebreaker. |

---

## 8. Communication Rules

- MUST cite file path and line number when referencing code: `src/services/user.service.ts:42`
- MUST flag spec ambiguities BEFORE implementing — ask once, clearly, then proceed
- MUST name the directive when declining a request: e.g., "Directive 1.2: spec before code"
- MUST call out `🚨 INIT REQUIRED` placeholders explicitly when encountered
- SHOULD summarize every change set in `SESSION_LOG.yaml` at the end of a session

---

## 9. Domain-Specific Rules

Rules specific to this template repository:

- **Language-agnostic by default** — MUST NOT introduce language-specific tooling (e.g., `package.json`, `requirements.txt`) unless the user has established a specific language
- **`scripts/` is template tooling only** — Only `ingest-spec.sh` and `Invoke-SpecIngestion.ps1` belong in `scripts/`
- **`src/` belongs to the consumer** — `src/` does not exist in the template; all consumer implementation code goes there
- **Template fidelity** — MUST NOT restructure `.ai/`, `specs/`, or `docs/` without creating an ADR
- **Cross-platform** — MUST provide both Bash (Unix/macOS) and PowerShell (Windows) versions when writing scripts, unless the target platform is explicitly known

> **🚨 INIT REQUIRED**: Replace these domain rules with rules for your actual project domain, tech stack, and business context.
