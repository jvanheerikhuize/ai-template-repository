# System Architecture

> **For AI Assistants**: This document defines HOW the system is built. For WHAT it does, see `../specs/SPEC.md`. For WHY decisions were made, see `../decisions/`.
>
> **Note**: This file currently describes the **template repository's own architecture**. When you use this template for a real project, replace this content with your project's actual system architecture.

## Document Info

| Field | Value |
|-------|-------|
| Version | 1.0.0 |
| Status | Active |
| Last Updated | 2026-02-26 |
| Owner | 🚨 INIT REQUIRED — set when template is used for a real project |

---

## 1. Architecture Overview

### 1.1 System Context

This repository is a **documentation and tooling scaffold** — it has no runtime application components. Its "system" is the developer workflow it enables.

```
┌─────────────────────────────────────────────────────────────┐
│                     Developer Environment                    │
├─────────────────────────────────────────────────────────────┤
│  IDE + AI Assistant (Claude Code / Copilot / Cursor / etc.) │
└──────────────────────────┬──────────────────────────────────┘
                           │  reads .ai/ context
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                  AI Template Repository                      │
│                                                              │
│  .ai/          specs/       scripts/      .github/           │
│  (governance)  (spec files) (ingestion)   (CI workflows)     │
└──────────────────────────┬──────────────────────────────────┘
                           │  spec approved → ingest
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                      GitHub                                  │
│  Issues / PRs / Actions                                      │
└──────────────────────────┬──────────────────────────────────┘
                           │  AI implements spec
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                  src/  (consumer creates)                    │
│  All implementation code lives here                          │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Architecture Style

| Aspect | Choice | Rationale |
|--------|--------|-----------|
| Overall Style | Documentation + Tooling scaffold | No runtime app; enables spec-driven development |
| Automation | GitHub Actions | Platform-native CI, no additional infrastructure |
| Scripting | Bash + PowerShell | Cross-platform (Unix + Windows) |
| Spec format | YAML + OpenAPI | Human-readable, widely supported, schema-validatable |
| AI governance | Flat Markdown files | Universal — readable by any AI tool without special plugins |

---

## 2. Component Architecture

### 2.1 Component Overview

```
ai-template-repository/
│
├── .ai/                    AI Governance Layer
│   ├── DIRECTIVES.md       Non-negotiable AI rules
│   ├── CONTEXT.md          Project context (master reference)
│   ├── config.yaml         AI behaviour preferences
│   ├── specs/SPEC.md       Product spec guide (template)
│   ├── architecture/       Technical documentation
│   ├── decisions/          Architecture Decision Records (ADRs)
│   └── memory/             AI persistent memory
│       ├── SESSION_LOG.md  Per-session history
│       ├── LEARNINGS.md    Accumulated knowledge
│       ├── TRACEABILITY.md Request → code audit trail
│       └── AUTHORIZATIONS.md Persistent authorization policy
│
├── specs/                  Specification Storage
│   ├── features/           Feature specs (YAML, validated by JSON schema)
│   ├── api/                API specs (OpenAPI 3.1)
│   └── schemas/            JSON Schema validators
│
├── scripts/                Ingestion Tooling (template-only)
│   ├── ingest-spec.sh      Bash spec ingestion script
│   └── Invoke-SpecIngestion.ps1  PowerShell spec ingestion script
│
├── .github/
│   ├── workflows/          GitHub Actions CI
│   └── ISSUE_TEMPLATE/     Issue templates
│
├── docs/
│   └── runbooks/           Operational procedures
│
├── specs.config.yaml       Central spec registry
└── .claude/CLAUDE.md       Claude Code entry point
```

### 2.2 Component Responsibilities

| Component | Purpose | Key Files |
|-----------|---------|-----------|
| AI Governance (`.ai/`) | Provides persistent context, rules, memory, and traceability for AI assistants | `DIRECTIVES.md`, `CONTEXT.md`, `memory/` |
| Spec Storage (`specs/`) | Houses formal feature and API specifications | `features/*.yaml`, `api/*.yaml` |
| Ingestion Scripts (`scripts/`) | CLI tools to process a spec file and create a GitHub issue/PR | `ingest-spec.sh`, `Invoke-SpecIngestion.ps1` |
| CI Workflows (`.github/`) | Automates spec validation, implementation, and PR creation | `.github/workflows/` |
| Spec Registry (`specs.config.yaml`) | Central index of all specs with status tracking | `specs.config.yaml` |

---

## 3. Data Architecture

### 3.1 Data Flow — Spec Lifecycle

```
[Author writes spec YAML]
        │
        ▼
[specs/features/FEAT-NNN-name.yaml]
        │
        ├── registered in specs.config.yaml (status: draft → review → approved)
        │
        ▼
[scripts/ingest-spec.sh  OR  GitHub Actions]
        │
        ├── validates against specs/schemas/feature-spec.schema.json
        ├── creates GitHub Issue
        └── triggers AI implementation session
                │
                ▼
        [AI reads .ai/CONTEXT.md + spec]
                │
                ├── implements in src/
                ├── writes tests
                ├── updates .ai/memory/ (SESSION_LOG, TRACEABILITY, LEARNINGS)
                └── creates PR
                        │
                        ▼
                [Human review → merge]
                        │
                        ▼
                [specs.config.yaml status → implemented]
```

### 3.2 Memory / State

There is no database. The system's "state" is maintained in:

| Store | Location | Contents |
|-------|----------|----------|
| Spec registry | `specs.config.yaml` | Status of all specs |
| AI session memory | `.ai/memory/SESSION_LOG.md` | History of AI sessions |
| Accumulated knowledge | `.ai/memory/LEARNINGS.md` | Discovered gotchas and patterns |
| Audit trail | `.ai/memory/TRACEABILITY.md` | Request → code linkage |
| Authorization policy | `.ai/memory/AUTHORIZATIONS.md` | Granted/denied AI action permissions |
| Architecture decisions | `.ai/decisions/ADR-NNN-*.md` | Why decisions were made |

---

## 4. Integration Architecture

### 4.1 External Integrations

| System | Purpose | Protocol | Config |
|--------|---------|----------|--------|
| GitHub | Issue/PR creation, CI | GitHub API via `gh` CLI | `GITHUB_TOKEN` |
| Claude Code | AI implementation | Claude API | `ANTHROPIC_API_KEY` |
| Optional: Slack, Teams, Jira, Linear, etc. | Notifications / issue sync | Webhooks / REST | See `specs.config.yaml integrations` section |

### 4.2 GitHub Actions Workflows

> **🚨 INIT REQUIRED**: Document actual workflows once `.github/workflows/` is populated for your project.

### 4.3 AI Tool Integration

The `.ai/` directory is designed to be read by any AI coding assistant:

| Tool | Entry Point | Notes |
|------|------------|-------|
| Claude Code | `.claude/CLAUDE.md` | Points to `.ai/DIRECTIVES.md` and `.ai/CONTEXT.md` |
| Cursor | `.cursorrules` | Can import `.ai/CONTEXT.md` |
| Copilot | `.github/copilot-instructions.md` | Reference `.ai/CONTEXT.md` |
| Aider | `--read .ai/CONTEXT.md` | Pass as context flag |
| Any tool | `.ai/CONTEXT.md` | Universal entry point |

---

## 5. Infrastructure Architecture

This template has no deployed infrastructure. When a consumer project adds infrastructure, document it here.

> **🚨 INIT REQUIRED**: Add deployment diagrams, cloud provider details, environment strategy, and scaling approach when your project has infrastructure.

---

## 6. Security Architecture

### 6.1 Secrets Handling
- No secrets are stored in this repository
- `ANTHROPIC_API_KEY` and `GITHUB_TOKEN` are provided via environment variables or GitHub Actions secrets
- `.env*` files are excluded from context loading in `config.yaml`

### 6.2 Authorization Model
- AI actions requiring elevated permissions follow the protocol in `.ai/memory/AUTHORIZATIONS.md`
- Three-tier policy: Never Allowed → Always Allowed → Learned Authorizations → Ask
- Force pushes and direct commits to `main` are permanently forbidden (Base Rules)

> **🚨 INIT REQUIRED**: Add your project's full security architecture (authentication, authorization, encryption, compliance) here.

---

## 7. Observability

This template has no runtime services and therefore no monitoring stack. The "observability" layer is the AI memory system:

- **Session history**: `.ai/memory/SESSION_LOG.md`
- **Change audit**: `.ai/memory/TRACEABILITY.md`
- **Knowledge base**: `.ai/memory/LEARNINGS.md`

> **🚨 INIT REQUIRED**: Add monitoring stack, logging standards, and alerting strategy when your project has runtime services.

---

## 8. Development Standards

### 8.1 Spec Authoring
- Feature specs live in `specs/features/` and follow `specs/schemas/feature-spec.schema.json`
- API specs live in `specs/api/` and follow OpenAPI 3.1
- All specs must have at least one acceptance criterion (Gherkin-style Given/When/Then)
- Specs must be `approved` in `specs.config.yaml` before implementation begins

### 8.2 Script Standards
- Scripts in `scripts/` must have both Bash (`ingest-spec.sh`) and PowerShell (`Invoke-SpecIngestion.ps1`) equivalents
- Scripts must be cross-platform safe (no Unix-only assumptions in PowerShell; no Windows-only assumptions in Bash)
- No application logic in `scripts/` — only template tooling

### 8.3 Documentation Standards
- All `.ai/` files must be kept current; do not let them go stale
- ADRs are append-only — never edit a published ADR, create a superseding one instead
- Session logs are append-only — never edit past entries

---

## 9. Appendix

### A. Architecture Decision Records

See `../decisions/` for all ADRs. Next ADR: 001.

### B. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2026-02-26 | Claude Sonnet 4.6 | Initial population from template placeholder |
