# ADR-001: Add AI Directives System

## Status

Accepted

## Date

2026-02-25

## Context

This repository is used as a template for AI-assisted development. Multiple AI tools (Claude Code, Copilot, Cursor, Aider, etc.) interact with the codebase. There was no single authoritative file that all AI tools were guaranteed to read first, containing non-negotiable behavioral rules.

The existing `.claude/CLAUDE.md` covered Claude Code specifically, and `.ai/config.yaml` had a `custom_instructions` block, but neither was structured as a mandatory, always-enforced directive layer that:
- Survived cloning and applied to any AI tool
- Could be extended with project-specific rules (forbidden actions, priority hierarchy, domain rules)
- Was clearly separated from guidance/preferences (which can be overridden) vs. hard requirements (which cannot)

## Decision

We will introduce `.ai/DIRECTIVES.md` as a mandatory directives file that:
1. Is loaded before any other context file (first in `config.yaml` `entry_points`)
2. Is referenced first in `CLAUDE.md`, `CONTEXT.md`, and `README.md`
3. Distinguishes hard rules (forbidden actions, required checks) from preferences
4. Has a template structure with six sections: Core Directives, Forbidden Actions, Required Checks, Priority Hierarchy, Communication Rules, Domain-Specific Rules

## Consequences

### Positive
- Any AI tool following the context loading order will encounter and apply directives before acting
- Single place to add new mandatory rules without editing multiple files
- Clear separation between "must follow" (DIRECTIVES.md) and "should follow" (CONTEXT.md, PATTERNS.md)
- Template placeholders make it easy for repository cloners to fill in their own rules

### Negative
- AI tools that ignore context loading order (or don't support it) won't automatically pick up the file — it requires the human to point the tool at it
- Adds one more file that must be kept up to date

### Neutral
- Existing rules in CLAUDE.md and config.yaml are not removed; DIRECTIVES.md is additive

## Alternatives Considered

### Option 1: Expand `custom_instructions` in config.yaml
- **Pros**: No new file; already loaded by some tools
- **Cons**: YAML scalar string is hard to read and edit; no structure for different rule categories; not given priority loading order
- **Why rejected**: Poor ergonomics for growing a rule set over time

### Option 2: Add a `## Mandatory Rules` section to CONTEXT.md
- **Pros**: One fewer file
- **Cons**: CONTEXT.md is already large; rules would be buried; no way to signal "this must be read before everything else"
- **Why rejected**: Directives need to be a distinct, prioritized artifact

## References

- [DIRECTIVES.md](../DIRECTIVES.md)
- [CONTEXT.md](../CONTEXT.md) — Quick Reference table updated
- [config.yaml](../config.yaml) — entry_points updated
- [CLAUDE.md](../../.claude/CLAUDE.md) — Quick Start updated
