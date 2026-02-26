# AI Learnings

Accumulated project knowledge built up across sessions. This is the AI's long-term memory about this specific codebase — things that are not obvious from reading files alone.

> **AI Assistants**:
> - **Read** this file before touching any existing code
> - **Write** here when you discover something non-obvious: a gotcha, an undocumented constraint, a pattern that diverges from what you'd expect, or domain knowledge that took investigation to uncover
> - Keep entries concise; link to files/ADRs where relevant
> - Never delete entries — mark outdated ones with `[OUTDATED as of YYYY-MM-DD]` instead

---

## How to Add a Learning

Append under the relevant category. Format:

```markdown
### [Short title]
**Discovered**: YYYY-MM-DD | **Session**: NNN | **Relevant files**: `path/to/file`

[What you learned. Be specific enough that a future AI with no session history can act on this.]
```

---

## Codebase Gotchas

### AI assistants skip `.ai/` files when content looks like template boilerplate
**Discovered**: 2026-02-26 | **Session**: 001 | **Relevant files**: `.ai/CONTEXT.md`, `.ai/DIRECTIVES.md`, `.ai/architecture/ARCHITECTURE.md`

When `.ai/` and `.claude/` files contain placeholder content (`[bracket]` syntax, `YYYY-MM-DD`, example comments), AI assistants treat the files as static documentation templates rather than live context requiring action. They read the files but do not follow the instructions inside them, and they do not update memory files at the end of sessions.

**Fix applied**: Populated all placeholder files with real project context. Added `🚨 INIT REQUIRED` markers for fields that genuinely require project-specific input. Added Directive 7 to DIRECTIVES.md: "When you encounter a file in `.ai/` or `.claude/` with placeholder content, treat those as action items."

**Prevention**: After populating this template for a new project, always fill in or mark every `[bracket]` placeholder before the first AI session. An AI assistant that sees populated, specific content will engage with it; one that sees boilerplate examples will treat it as reference-only.

---

### `scripts/` is off-limits for implementation code
**Discovered**: 2026-02-26 | **Session**: 001 | **Relevant files**: `scripts/ingest-spec.sh`, `scripts/Invoke-SpecIngestion.ps1`, `PATTERNS.md`

The `scripts/` directory contains only template repository tooling (the spec ingestion scripts). It is explicitly NOT a place for AI-generated application code. All implementation code must go in `src/`. This is enforced in both DIRECTIVES.md (Forbidden Actions) and PATTERNS.md (Section 3.1).

---

## Patterns and Conventions

### `🚨 INIT REQUIRED` is the marker for mandatory initialization fields
**Discovered**: 2026-02-26 | **Session**: 001 | **Relevant files**: `.ai/CONTEXT.md`, `.ai/DIRECTIVES.md`, `.ai/architecture/ARCHITECTURE.md`

When populating this template for a real project, search all `.ai/` files for the string `🚨 INIT REQUIRED`. Each occurrence is a field that MUST be filled in with project-specific information. These are not optional — leaving them in place means the AI context system is incomplete.

Common INIT REQUIRED fields: Owner/team contacts, project name, tech stack, active work items, environment variables, external documentation links.

---

### Memory files are append-only (except AUTHORIZATIONS.md)
**Discovered**: 2026-02-26 | **Session**: 001 | **Relevant files**: `.ai/memory/`

`SESSION_LOG.md` and `TRACEABILITY.md` are strictly append-only — never edit past entries. `LEARNINGS.md` entries should not be deleted but can be marked `[OUTDATED as of YYYY-MM-DD]`. Only `AUTHORIZATIONS.md` has rows that can be superseded (by adding a new row with `status=supersedes AUTH-NNN`).

---

## Domain Knowledge

### This template has no runtime application — `src/` is created by consumers
**Discovered**: 2026-02-26 | **Session**: 001 | **Relevant files**: `CLAUDE.md`, `.ai/architecture/ARCHITECTURE.md`

The template repository itself contains no `src/` directory. That directory is created by teams using the template when they start building their actual application. The template's value is entirely in the scaffolding: `.ai/`, `specs/`, `scripts/`, `.github/`. Do not confuse this with a project that has a missing `src/` due to a bug.

---

### The AI governance system (`DIRECTIVES`, `AUTHORIZATIONS`, `memory/`) is designed to survive across AI sessions
**Discovered**: 2026-02-26 | **Session**: 001 | **Relevant files**: `.ai/DIRECTIVES.md`, `.ai/memory/`

The `.ai/memory/` files are the mechanism by which an AI assistant's accumulated knowledge persists even though LLMs have no memory between sessions. When these files are properly maintained, a new AI session can achieve full context in seconds by reading them. When they are not maintained (e.g., because the AI ignored them as "template content"), context resets to zero every session and the AI makes redundant or contradictory decisions.

---

## Anti-Patterns (Do Not Repeat)

### Treating populated `.ai/` files as static documentation
**Discovered**: 2026-02-26 | **Session**: 001

**What happened**: AI assistants reading `.ai/DIRECTIVES.md` and `.ai/CONTEXT.md` treated the placeholder content as "template examples" and did not follow the instructions inside — specifically, did not update `SESSION_LOG.md`, did not create ADRs, did not maintain `TRACEABILITY.md`.

**Why it's wrong**: These are live, operational files for the current project. They are not documentation about how to use the template system; they ARE the template system running.

**Correct behaviour**: Read DIRECTIVES.md at the start of every session. Follow every directive literally. Update memory files before the session ends.

---

## Integration and Environment Notes

### The spec ingestion scripts require `gh` CLI
**Discovered**: 2026-02-26 | **Session**: 001 | **Relevant files**: `scripts/ingest-spec.sh`, `scripts/Invoke-SpecIngestion.ps1`

Both ingestion scripts (`ingest-spec.sh` and `Invoke-SpecIngestion.ps1`) depend on the GitHub CLI (`gh`) being installed and authenticated. If a user reports that ingestion fails, check `gh auth status` first.

---

## Security Notes

*No security-specific notes yet. Add entries here when security-relevant constraints or issues are discovered.*
