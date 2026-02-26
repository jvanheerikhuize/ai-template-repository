# AI Directives

> **MANDATORY**: All AI assistants working in this repository **MUST** read and comply with every directive in this file. These rules override default AI behavior and take effect for every task, regardless of scope.

<!--
  AI PROCESSING INSTRUCTIONS:
  - Load this file on every session before taking any action
  - These directives are non-negotiable
  - If a user instruction conflicts with a directive, flag the conflict before proceeding
-->

---

## 1. Core Directives

1. **Read before acting** — Before making any change, read `.ai/CONTEXT.md`, `.ai/memory/SESSION_LOG.md`, and `.ai/memory/LEARNINGS.md`. Do not skip this even for "small" tasks.
2. **Spec before code** — Do not implement new features unless the spec status is `approved` in `specs.config.yaml`. If no spec exists, ask the user to create one before proceeding.
3. **Never expose secrets** — Do not log, print, or include secrets, tokens, or credentials anywhere in generated code or output.
4. **Update memory** — At the end of every session, append to `SESSION_LOG.md`. During a session, update `TRACEABILITY.md` incrementally. Never skip memory updates.
5. **Document decisions** — Create an ADR for every architectural, hard-to-reverse, or non-obvious decision. Do not defer this to a later session.
6. **Minimal changes** — Only change what is required by the current task. Do not refactor, rename, or "improve" surrounding code unless explicitly asked.
7. **Populate, don't ignore** — When you encounter a file in `.ai/` or `.claude/` with placeholder content (marked with `🚨 INIT REQUIRED`, `[brackets]`, or `YYYY-MM-DD`), treat those as action items. Populate them from available context or ask the user. Never silently leave them unfilled.

> **🚨 INIT REQUIRED**: Add any project-specific mandatory directives below when this template is used for a real project.

---

## 2. Forbidden Actions

Actions that must **never** be taken, under any circumstances:

- Do NOT place implementation code in `scripts/` — that directory contains template repo tooling only (spec ingestion scripts). All AI-generated application code must go in `src/`.
- Do NOT commit directly to `main` or `master` — all changes must go through a PR.
- Do NOT remove or bypass tests to make a build pass — fix the underlying issue instead.
- Do NOT hardcode environment-specific values (URLs, IPs, credentials) in source files.
- Do NOT treat `.ai/` or `.claude/` files as static documentation — they are live, AI-maintained context files and must be kept current.
- Do NOT leave placeholder content (`[brackets]`, `YYYY-MM-DD`, `🚨 INIT REQUIRED`) in place after working in a file — either fill it in or ask the user what to put there.

> **🚨 INIT REQUIRED**: Add project-specific forbidden actions here.

---

## 3. Required Checks Before Acting

Before making **any** change, verify all of the following:

- [ ] Read `.ai/CONTEXT.md` to confirm current project state
- [ ] Read `.ai/memory/SESSION_LOG.md` — check most recent entry for open items
- [ ] Read `.ai/memory/LEARNINGS.md` — absorb project knowledge before touching existing code
- [ ] Check `.ai/decisions/INDEX.md` to understand past decisions before acting
- [ ] Confirm the relevant spec is `approved` in `specs.config.yaml` (for feature work)
- [ ] Verify no existing test will break from the proposed change

> **🚨 INIT REQUIRED**: Add project-specific pre-action checks here.

---

## 3a. Decision Documentation (Required)

Whenever you make a decision that is **architectural, hard to reverse, non-obvious, cross-cutting, a technology choice, or security-relevant**, you **MUST**:

1. Create a new ADR file at `.ai/decisions/ADR-NNN-short-title.md` using [template.md](.ai/decisions/template.md) as the base
2. Use the next sequential number from [INDEX.md](.ai/decisions/INDEX.md)
3. Set status to `Accepted` (since the decision has already been made)
4. Add a row to [INDEX.md](.ai/decisions/INDEX.md) immediately
5. Update "Next ADR number" in INDEX.md

See [.ai/decisions/README.md](.ai/decisions/README.md) for the full trigger list and naming conventions.

**Do not defer this step.** Create the ADR in the same session as the decision.

---

## 3b. Memory Maintenance (Required)

The `.ai/memory/` directory is your persistent memory. You **MUST** maintain it as follows:

### At the start of every session
1. Read [SESSION_LOG.yaml](.ai/memory/SESSION_LOG.yaml) — check the most recent entry for open items and recent state
2. Read [LEARNINGS.yaml](.ai/memory/LEARNINGS.yaml) — absorb accumulated project knowledge before acting
3. Read [TRACEABILITY.yaml](.ai/memory/TRACEABILITY.yaml) — check if related work exists before starting

### During a session
- Append to [TRACEABILITY.yaml](.ai/memory/TRACEABILITY.yaml) as each link in the chain is established (do not batch at the end)
- Append to [LEARNINGS.yaml](.ai/memory/LEARNINGS.yaml) whenever you discover something non-obvious

### At the end of every session
1. Append a new entry to [SESSION_LOG.yaml](.ai/memory/SESSION_LOG.yaml) following the `entry_schema` at the top of that file
2. Verify TRACEABILITY.yaml entries are complete for all work done this session

See [.ai/memory/README.md](.ai/memory/README.md) for the full traceability chain and update triggers.

**Do not skip memory updates.** They are the mechanism by which context survives across sessions.

---

## 3c. Authorization Check (Required Before Gated Actions)

Before taking any **Gated Action** (see category list below), you **MUST** consult [AUTHORIZATIONS.yaml](.ai/memory/AUTHORIZATIONS.yaml) and follow its Decision Protocol exactly.

### Gated Action Categories (always require a check)
- Deleting files or directories
- Overwriting uncommitted changes
- Any git operation: commit, push, force, reset, branch deletion
- Adding or removing dependencies
- Modifying CI/CD, env, or build config files
- Touching security-sensitive code (auth, crypto, secrets)
- Making external API calls or sending webhooks
- Skipping, suppressing, or deleting tests

### The Decision Protocol (abbreviated)
1. **Check Base Rules → Never Allowed** — if matched, refuse. Non-negotiable.
2. **Check Base Rules → Always Allowed** — if matched, proceed freely.
3. **Check Learned Authorizations** — if a matching AUTH-NNN exists, follow its status (granted/denied).
4. **No rule found → Ask** for specific permission.
5. **After a grant → Ask the generalization follow-up**:
   > "You've approved [specific action]. Should I treat this as a general rule for [action category], or was this a one-time exception?"
   Accept: "General rule" | "One-time only" | "Only for [narrower scope]"
6. **Record the result** as a new AUTH-NNN row in [AUTHORIZATIONS.md](.ai/memory/AUTHORIZATIONS.md) immediately.

### Key Rules
- Steps 1 and 2 are absolute — learned authorizations and in-session user requests cannot override them.
- Step 5 must **always** be asked after a specific grant, even when it feels obvious.
- If a user says "just do it" without answering step 5, record `scope=session` (expires at end of session, not persisted).
- Always cite the AUTH-NNN or Base Rule you relied on when taking a gated action.

See [AUTHORIZATIONS.yaml](.ai/memory/AUTHORIZATIONS.yaml) for the full decision tree, category definitions, and the Learned Authorizations table.

---

## 4. Priority Hierarchy

When directives, user instructions, or constraints conflict, resolve them in this order:

1. **Security** — Never compromise security for any other goal. Secrets, auth, and encryption are non-negotiable.
2. **Correctness** — Code must be correct before it is clean, fast, or elegant.
3. **Spec compliance** — Match the approved spec exactly; implement no more and no less.
4. **Readability** — Prefer clear, self-documenting code as the final tiebreaker.

---

## 5. Communication Rules

How the AI must communicate with the team:

- Always cite the file path and line number when referencing specific code (e.g., `src/services/user.service.ts:42`)
- Flag ambiguities in specs **before** implementing, not after — ask once, clearly, then proceed
- Summarize every change set at the end of a session in SESSION_LOG.md
- When declining a request due to a directive, name the directive (e.g., "Directive 2: spec before code") and explain the conflict
- When a placeholder (`🚨 INIT REQUIRED`) is encountered, call it out explicitly and either fill it from context or ask the user

---

## 6. Domain-Specific Rules

Rules that apply specifically to this template repository:

- **Language-agnostic by default** — Do not introduce language-specific tooling, configs, or assumptions (e.g., `package.json`, `requirements.txt`) unless the user has established a specific language for their project
- **`scripts/` is template tooling only** — `ingest-spec.sh` and `Invoke-SpecIngestion.ps1` are the only files that belong in `scripts/`. Do not add application code there.
- **`src/` belongs to the consumer** — The `src/` directory does not exist in the template. When a consumer project is set up, all implementation code goes there.
- **Template fidelity** — The `.ai/`, `specs/`, and `docs/` directory structures are intentional. Do not restructure them without creating an ADR.
- **Cross-platform awareness** — When writing scripts or commands, provide both Bash (Unix/macOS) and PowerShell (Windows) versions unless the target platform is explicitly known.

> **🚨 INIT REQUIRED**: Replace the domain-specific rules above with rules that apply to your actual project domain, tech stack, and business context when using this template for a real project.

---

## Document Metadata

| Field | Value |
|-------|-------|
| Version | 1.0 |
| Last Updated | 2026-02-26 |
| Owner | 🚨 INIT REQUIRED — set when template is used for a real project |
| Review Frequency | On every major project change |
