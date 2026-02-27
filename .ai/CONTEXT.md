---
document_type: project-context
version: "1.0"
status: active
last_updated: "2026-02-27"
owner: "🚨 INIT REQUIRED"
---

# Project Context

> **For AI Assistants**: This is the master context file. Start here for a complete understanding of the project.
> Sections marked **🚨 INIT REQUIRED** must be replaced with your project's actual information when this template is used for a real project.

<!--
  AI PROCESSING INSTRUCTIONS:
  1. Read this file first to understand project scope
  2. Follow links to detailed documents as needed
  3. Check config.yaml for behavior preferences
  4. Respect patterns in architecture/PATTERNS.md
-->

## Quick Reference

| Document | Purpose | When to Read |
|----------|---------|--------------|
| [DIRECTIVES.md](DIRECTIVES.md) | Mandatory AI rules | **Always — before anything else** |
| [memory/AUTHORIZATIONS.yaml](memory/AUTHORIZATIONS.yaml) | What the AI is/isn't allowed to do | Before any gated action |
| [memory/SESSION_LOG.yaml](memory/SESSION_LOG.yaml) | Session history | Start of every session |
| [memory/LEARNINGS.yaml](memory/LEARNINGS.yaml) | Accumulated project knowledge | Before touching existing code |
| [memory/TRACEABILITY.yaml](memory/TRACEABILITY.yaml) | Request → code audit trail | When implementing or investigating |
| [SPEC.md](specs/SPEC.md) | Product requirements | Understanding WHAT to build |
| [ARCHITECTURE.md](architecture/ARCHITECTURE.md) | System design | Understanding HOW it's built |
| [PATTERNS.md](architecture/PATTERNS.md) | Code conventions | Writing or reviewing code |
| [decisions/](decisions/) | ADRs | Understanding WHY decisions were made |

---

## 1. Project Summary

### Identity
- **Name**: AI Template Repository
- **Type**: Template repository
- **Stage**: Production

### One-Liner
> A language-agnostic, platform-agnostic GitHub repository template that enables spec-based development with built-in AI coding assistant governance, persistent memory, and traceability.

### Tech Stack
| Layer | Technology |
|-------|------------|
| Tooling scripts | Bash (Unix/macOS), PowerShell (Windows) |
| Spec format | YAML (feature specs + OpenAPI for APIs) |
| Spec schema validation | JSON Schema |
| Documentation | Markdown |
| CI / Automation | GitHub Actions |
| AI governance | `.ai/` directory (DIRECTIVES, AUTHORIZATIONS, memory) |
| Application code | **None** — this template is language-agnostic; `src/` is created by the consumer |

> **🚨 INIT REQUIRED**: Replace the tech stack table above with your project's actual stack when you use this template for a real project.

---

## 2. Current State

### Active Work
- [x] AI governance system: DIRECTIVES, AUTHORIZATIONS, SESSION_LOG, LEARNINGS, TRACEABILITY
- [x] Template-sync runbook added
- [x] AI-agnostic and platform-agnostic restructure
- [x] `.ai/` context files populated from placeholder templates (2026-02-26)
- [x] All `.ai/` Markdown files converted to YAML frontmatter format (2026-02-26)
- [x] DIRECTIVES.md rewritten in AI-native structure with RFC 2119 language (2026-02-26)
- [x] `.ai/` directory unified — consistent naming, entry points, cross-references (2026-02-26)
- [x] Internal test suite added: `scripts/test-template.sh` + `scripts/Test-Template.ps1` (2026-02-27)

> **🚨 INIT REQUIRED**: Replace the active work list above with your current sprint/iteration tasks.

### Recent Changes
- 2026-02-27: Added internal test suite (`test-template.sh` + `Test-Template.ps1`) with 8 validation suites; updated DIRECTIVES §9; session documentation cleanup
- 2026-02-26: Unified `.ai/` directory — YAML frontmatter on all MD files, consistent cross-references, rewrote DIRECTIVES.md in AI-native format (RFC 2119, §0–§9, ASCII auth flowchart)
- 2026-02-26: Populated `.ai/` context files — replaced template placeholders with real project context; converted memory files to YAML

> **🚨 INIT REQUIRED**: Replace the recent changes list with your project's actual change history.

### Known Issues
- **Initialization gap**: Any fields marked "🚨 INIT REQUIRED" have not yet been filled in — owner/team contacts, project-specific domain rules. Fill in when this template is used for a real project.
- **Template skipping (mitigated)**: AI assistants historically skip `.ai/` files when content looks like boilerplate. Mitigated by populating all files with real content and using YAML frontmatter. See [LEARNINGS.yaml](memory/LEARNINGS.yaml) L-001.

---

## 3. Key Concepts

### Domain Model
This template has no runtime domain model. It is a repository scaffold.

The key conceptual entities are:

```
[Spec File] ──triggers──▶ [Ingestion Script] ──creates──▶ [GitHub Issue / PR]
     │                                                            │
     │                                                            ▼
     └──registered in──▶ [specs.config.yaml]          [AI Implementation]
                                                                  │
                                                                  ▼
                                                        [.ai/memory/ updated]
```

### Bounded Contexts
| Context | Responsibility | Key Files |
|---------|---------------|-----------|
| AI Governance | Rules, memory, authorization for AI assistants | `.ai/DIRECTIVES.md`, `.ai/memory/` |
| Spec Management | Defining, tracking, and ingesting feature specs | `specs/`, `specs.config.yaml` |
| Automation | GitHub Actions CI, spec ingestion workflows | `.github/workflows/`, `scripts/` |
| Documentation | Developer guides and runbooks | `docs/` |

> **🚨 INIT REQUIRED**: Replace the bounded contexts with your project's actual domains.

### Critical Paths
1. **Spec → Implementation**: Author spec YAML → `ingest-spec.sh` → AI reads spec → implements in `src/` → PR created → human review
2. **AI session start**: Read DIRECTIVES → Read SESSION_LOG → Read LEARNINGS → Read CONTEXT → proceed with task
3. **AI session end**: Update SESSION_LOG → Update TRACEABILITY → Update LEARNINGS if needed

---

## 4. Codebase Navigation

### Entry Points
| Purpose | Location |
|---------|----------|
| AI rules (read first) | `.ai/DIRECTIVES.md` |
| AI session memory | `.ai/memory/SESSION_LOG.yaml` |
| Spec registry | `specs.config.yaml` |
| Spec ingestion (Unix) | `scripts/ingest-spec.sh` |
| Spec ingestion (Windows) | `scripts/Invoke-SpecIngestion.ps1` |
| User-facing docs | `README.md` |
| Feature specs | `specs/features/` |
| API specs | `specs/api/` |
| Runbooks | `docs/runbooks/` |

> **🚨 INIT REQUIRED**: Add your project's actual entry points (e.g., `src/index.ts`, `src/main.py`) once `src/` is created.

### Key Files
```
.ai/
├── DIRECTIVES.md         # Non-negotiable AI rules — always read first
├── CONTEXT.md            # This file — project overview
├── config.yaml           # AI behaviour preferences
├── specs/SPEC.md         # Product spec guide (template — fill in per project)
├── architecture/
│   ├── ARCHITECTURE.md   # System architecture
│   └── PATTERNS.md       # Code patterns and conventions
├── decisions/
│   ├── INDEX.yaml        # ADR index (machine-parseable)
│   └── ADR-NNN-*.md      # Individual decision records
└── memory/
    ├── AUTHORIZATIONS.yaml # Persistent authorization policy
    ├── SESSION_LOG.yaml  # Per-session history
    ├── LEARNINGS.yaml    # Accumulated project knowledge
    └── TRACEABILITY.yaml # Request → code audit trail

scripts/
├── ingest-spec.sh                # Spec ingestion (Bash/Unix)
└── Invoke-SpecIngestion.ps1      # Spec ingestion (PowerShell/Windows)

specs/
├── features/             # Feature specs (YAML)
├── api/                  # API specs (OpenAPI)
└── schemas/              # JSON Schema for spec validation

docs/
└── runbooks/             # Operational procedures
```

### Module Map
```
[specs/features/*.yaml]
        │
        ▼
[scripts/ingest-spec.sh]  ──────▶  [GitHub Actions]
        │                                  │
        ▼                                  ▼
[specs.config.yaml]             [AI reads spec + .ai/ context]
                                           │
                                           ▼
                                  [src/ implementation]
                                           │
                                           ▼
                                  [PR + .ai/memory/ update]
```

---

## 5. Development Rules

### Must Follow
1. **All code must have tests** — No exceptions for business logic in `src/`
2. **Use existing patterns** — Check PATTERNS.md before creating new ones
3. **No secrets in code** — Use environment variables
4. **Spec before code** — Features in `src/` require an approved spec in `specs/features/`
5. **Scripts/ is read-only for AI** — Never put AI-generated implementation code in `scripts/`; that directory is template tooling only

### Prefer
1. Composition over inheritance
2. Explicit over implicit
3. Small functions (< 20 lines)
4. Descriptive names over comments

### Avoid
1. God classes/functions
2. Deep nesting (> 3 levels)
3. Magic numbers/strings
4. Mutable global state

---

## 6. Testing Requirements

### Coverage Expectations
| Type | Target | Focus |
|------|--------|-------|
| Unit | 80% | Services, utilities |
| Integration | Key paths | API endpoints |
| E2E | Critical flows | User journeys |

> **🚨 INIT REQUIRED**: Adjust coverage targets and test framework to match your project's tooling.

### Test Locations
```
tests/
├── unit/
├── integration/
└── e2e/
```

---

## 7. Environment Setup

### Prerequisites
```bash
# For using spec ingestion scripts (Unix):
bash >= 4.0
gh (GitHub CLI) >= 2.0

# For PowerShell (Windows):
pwsh >= 7.0
gh (GitHub CLI) >= 2.0
```

> **🚨 INIT REQUIRED**: Add your project's actual prerequisites and setup commands once a language/framework is chosen.

### Environment Variables
| Variable | Required | Description |
|----------|----------|-------------|
| `ANTHROPIC_API_KEY` | For Claude Code | Claude Code authentication |
| `GITHUB_TOKEN` | For CI workflows | GitHub Actions authentication |

> **🚨 INIT REQUIRED**: Add your project's actual environment variables.

---

## 8. AI Assistant Guidelines

### When Generating Code
1. **Read before writing** — Understand existing patterns first
2. **Match style** — Follow PATTERNS.md conventions
3. **Minimal changes** — Don't refactor unrelated code
4. **Include tests** — Generate tests alongside implementation
5. **Update memory** — Append to SESSION_LOG and TRACEABILITY as you go

### When Answering Questions
1. **Reference files** — Point to specific code locations with line numbers
2. **Cite architecture** — Link to relevant ADRs when explaining decisions
3. **Stay current** — Check "Recent Changes" above before answering

### When Debugging
1. **Check known issues** — Review section above first
2. **Check LEARNINGS.yaml** — Past gotchas are documented there
3. **Trace data flow** — Follow the module map
4. **Verify assumptions** — Read actual implementation before suggesting fixes

### Forbidden Actions
- Delete or modify test files without explicit request
- Change security-related code without review
- Modify configuration files without confirmation
- Add dependencies without discussion
- Place implementation code in `scripts/` (template tooling only)

---

## 9. Related Documentation

### Internal
- [specs/](../specs/) — Product specifications
- [architecture/](architecture/) — Technical architecture
- [decisions/](decisions/) — Architecture Decision Records
- [docs/runbooks/](../docs/runbooks/) — Operational procedures

### External
> **🚨 INIT REQUIRED**: Add links to your project's external documentation (design system, API docs, etc.).

---

## 10. Contacts

> **🚨 INIT REQUIRED**: Fill in actual team contacts. This is a required step when initializing a new project from this template.

| Role | Contact | When to Escalate |
|------|---------|-----------------|
| Tech Lead | 🚨 INIT REQUIRED | Architecture decisions |
| Product | 🚨 INIT REQUIRED | Requirement clarifications |
| Security | 🚨 INIT REQUIRED | Security concerns |

---

## Document Maintenance

| Field | Value |
|-------|-------|
| Last Updated | 2026-02-26 |
| Update Frequency | At the start/end of every AI session; after major changes |
| Owner | 🚨 INIT REQUIRED — set when template is used for a real project |

### Update Checklist
When updating this document:
- [ ] Update "Current State" section
- [ ] Review "Key Files" for accuracy
- [ ] Check "Known Issues" is current
- [ ] Verify links are working
