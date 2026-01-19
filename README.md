# Enterprise Spec-Based Development Template

A language-agnostic repository template for **Specification-Driven Development (SDD)** with automated Claude Code integration.

## Overview

This template provides a structured approach to software development where features are formally specified before implementation. It includes:

- Formal specification templates and JSON schemas
- Automated workflow for spec ingestion and implementation
- Integration with Claude Code CLI for AI-assisted development
- Enterprise-ready CI/CD pipelines
- Comprehensive documentation and contribution guidelines

## Quick Start

### 1. Use This Template

Click "Use this template" on GitHub or clone and reinitialize:

```bash
git clone https://github.com/jvanheerikhuize/spec-driven-development-template.git my-project
cd my-project
rm -rf .git && git init
```

### 2. Configure Secrets

Add these secrets to your GitHub repository:

| Secret | Description |
|--------|-------------|
| `ANTHROPIC_API_KEY` | API key for Claude Code CLI |

### 3. Customize

1. Update `CODEOWNERS` with your team structure
2. Modify `specs.config.yaml` settings
3. Adjust workflow triggers in `.github/workflows/spec-ingestion.yml`

## Repository Structure

```
├── .ai/                            # AI Context System
│   ├── CONTEXT.md                 # Master context (AI starts here)
│   ├── config.yaml                # AI behavior configuration
│   ├── specs/
│   │   └── SPEC.md               # Product specification template
│   ├── architecture/
│   │   ├── ARCHITECTURE.md       # System architecture
│   │   └── PATTERNS.md           # Code patterns & conventions
│   ├── decisions/                 # Architecture Decision Records
│   └── prompts/                   # Reusable prompt templates
│
├── specs/                          # Implementation Specifications
│   ├── features/                   # Feature specs (YAML)
│   │   └── _template.yaml         # Feature template
│   ├── api/                        # API specs (OpenAPI 3.1)
│   │   └── _template.openapi.yaml # OpenAPI template
│   └── schemas/                    # JSON schemas
│       └── feature-spec.schema.json
│
├── scripts/
│   └── ingest-spec.sh             # Spec processing script
│
├── .github/
│   ├── workflows/
│   │   ├── spec-ingestion.yml     # Main automation workflow
│   │   └── validate-specs.yml     # Spec validation
│   ├── ISSUE_TEMPLATE/            # Issue templates
│   ├── pull_request_template.md
│   └── CODEOWNERS
│
├── .claude/                        # Claude Code configuration
│   ├── settings.json
│   └── CLAUDE.md                  # Project instructions for Claude
│
├── docs/
│   └── spec-based-development.md  # SDD guide
│
├── specs.config.yaml              # Central spec registry
├── CONTRIBUTING.md
└── README.md
```

## How It Works

### The Spec-Based Development Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    SPECIFICATION PHASE                          │
├─────────────────────────────────────────────────────────────────┤
│  1. Create spec from template                                   │
│  2. Define acceptance criteria (Given/When/Then)                │
│  3. Submit for review                                           │
│  4. Iterate until approved                                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   IMPLEMENTATION PHASE                          │
├─────────────────────────────────────────────────────────────────┤
│  Option A: Automated via Claude Code                            │
│  • Add to specs.config.yaml with auto_implement: true           │
│  • Workflow detects and processes approved specs                │
│  • Creates feature branch and PR automatically                  │
│                                                                 │
│  Option B: Manual Implementation                                │
│  • Create feature branch: spec/FEAT-XXXX                        │
│  • Implement all acceptance criteria                            │
│  • Write tests, submit PR                                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     REVIEW & MERGE                              │
├─────────────────────────────────────────────────────────────────┤
│  • Code review by team                                          │
│  • All acceptance criteria verified                             │
│  • Tests passing                                                │
│  • Merge and update spec status to 'implemented'                │
└─────────────────────────────────────────────────────────────────┘
```

### Triggering Implementation

The spec ingestion workflow can be triggered in multiple ways:

| Trigger | Description |
|---------|-------------|
| **Push to main** | Processes new/changed specs in `specs/` directory |
| **Manual dispatch** | Run via GitHub Actions UI with specific spec file |
| **Scheduled** | Processes approved specs from config (Mon-Fri 9 AM UTC) |
| **PR approval** | Processes specs when PRs are approved |
| **Config-based** | Specs in `specs.config.yaml` with `auto_implement: true` |

### Local Development

Process specs locally using the ingestion script:

```bash
# Process a single spec
./scripts/ingest-spec.sh specs/features/FEAT-0001.yaml

# Validate without implementing
./scripts/ingest-spec.sh --validate specs/features/FEAT-0001.yaml

# Process all approved specs from config
./scripts/ingest-spec.sh --config

# Dry run (preview what would happen)
DRY_RUN=true ./scripts/ingest-spec.sh specs/features/FEAT-0001.yaml
```

## Writing Specifications

### Feature Spec Example

```yaml
metadata:
  id: "FEAT-0001"
  title: "User Authentication"
  version: "1.0.0"
  status: "draft"
  priority: "high"

description:
  summary: |
    Implement user authentication with email/password.

  problem_statement: |
    Users cannot currently access protected resources.

  proposed_solution: |
    Add login/logout functionality with session management.

acceptance_criteria:
  - id: "AC-001"
    given: "A user with valid credentials"
    when: "They submit the login form"
    then: "They are authenticated and redirected to dashboard"

  - id: "AC-002"
    given: "An authenticated user"
    when: "They click logout"
    then: "Their session is ended and they see the login page"
```

See [specs/features/_template.yaml](specs/features/_template.yaml) for the complete template.

### API Spec Example

API specifications follow OpenAPI 3.1 format. See [specs/api/_template.openapi.yaml](specs/api/_template.openapi.yaml).

## Configuration

### specs.config.yaml

Central registry for tracking and configuring specs:

```yaml
settings:
  target_branch: "main"
  require_approval: true
  run_tests: true

specifications:
  - id: "FEAT-0001"
    file: "specs/features/FEAT-0001.yaml"
    status: "approved"
    auto_implement: true  # Enable automated implementation
    priority: "high"
```

### Claude Code Settings

Project-specific Claude Code configuration in `.claude/`:

- `settings.json` - Preferences and behavior settings
- `CLAUDE.md` - Project context and instructions for Claude

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `ANTHROPIC_API_KEY` | Yes | API key for Claude Code |
| `CLAUDE_MODEL` | No | Model to use (default: claude-sonnet-4-20250514) |
| `DRY_RUN` | No | Set to "true" for validation only |
| `VERBOSE` | No | Set to "true" for detailed output |

## Integration Points

### Slack Notifications

Enable in `specs.config.yaml`:

```yaml
integrations:
  slack:
    enabled: true
    channel: "#engineering"
```

Requires `SLACK_WEBHOOK_URL` secret.

### Jira Integration

```yaml
integrations:
  jira:
    enabled: true
    project_key: "PROJ"
```

Requires `JIRA_*` secrets.

## Best Practices

### Writing Good Specs

1. **Be specific** - Avoid vague requirements
2. **Be testable** - Every criterion should be verifiable
3. **Be complete** - Include error cases and edge cases
4. **Be minimal** - Don't over-specify implementation details

### Acceptance Criteria

Use Gherkin format for clarity:

```yaml
- id: "AC-001"
  given: "Specific precondition"
  when: "User performs action"
  then: "Specific, measurable outcome"
```

### Code Implementation

- Match existing codebase patterns
- Implement all acceptance criteria
- Write tests for each criterion
- Don't over-engineer

## AI Context System

The `.ai/` directory provides structured context for AI assistants:

```
.ai/
├── CONTEXT.md          # Start here - project overview & current state
├── config.yaml         # AI behavior preferences
├── specs/SPEC.md       # Product specification (WHAT to build)
├── architecture/
│   ├── ARCHITECTURE.md # System design (HOW it's built)
│   └── PATTERNS.md     # Code conventions (HOW to write code)
├── decisions/          # ADRs (WHY decisions were made)
└── prompts/            # Reusable prompt templates
```

### How AI Tools Use This

| Tool | Entry Point | Auto-loaded |
|------|-------------|-------------|
| Claude Code | `.claude/CLAUDE.md` → `.ai/CONTEXT.md` | Yes |
| GitHub Copilot | `.ai/CONTEXT.md` | Manual |
| Cursor | `.ai/` directory | Indexable |
| Other AI | `.ai/CONTEXT.md` | Manual |

### Key Documents

| Document | Purpose | When to Update |
|----------|---------|----------------|
| `CONTEXT.md` | Current project state | Weekly / after major changes |
| `SPEC.md` | Product requirements | Before new features |
| `ARCHITECTURE.md` | System design | After architectural changes |
| `PATTERNS.md` | Code conventions | When patterns evolve |
| `decisions/*.md` | Decision records | After significant decisions |

## Documentation

- [Spec-Based Development Guide](docs/spec-based-development.md) - Detailed workflow guide
- [Contributing Guidelines](CONTRIBUTING.md) - How to contribute
- [AI Context Guide](.ai/README.md) - AI documentation system
- [Feature Spec Template](specs/features/_template.yaml) - Feature specification format
- [API Spec Template](specs/api/_template.openapi.yaml) - OpenAPI specification format

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author & Contributors

**Created by:** Jerry van Heerikhuize ([@jvanheerikhuize](https://github.com/jvanheerikhuize))

**Contributors:**
- Claude (Anthropic) - AI pair programming assistant

## Acknowledgments

- Built with [Claude Code](https://github.com/anthropics/claude-code) - Anthropic's AI coding assistant
- Inspired by specification-driven development best practices
- OpenAPI templates based on [OpenAPI 3.1 Specification](https://spec.openapis.org/oas/v3.1.0)

---

<p align="center">
  Built for spec-driven development with <a href="https://github.com/anthropics/claude-code">Claude Code</a>
</p>
