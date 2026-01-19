# Enterprise Spec-Based Development Template

A language-agnostic repository template for **Specification-Driven Development (SDD)** with automated Claude Code integration.

## Overview

This template provides a structured approach to software development where features are formally specified before implementation. It includes:

- Formal specification templates and JSON schemas
- Automated workflow for spec ingestion and AI-assisted implementation
- Integration with Claude Code CLI for intelligent code generation
- Enterprise-ready CI/CD pipelines with GitHub Actions
- Comprehensive integrations (Microsoft Teams, Azure DevOps, Slack, and more)
- Operational runbooks and incident response procedures
- Rich GitHub issue and PR templates

## Quick Start

### 1. Use This Template

Click "Use this template" on GitHub or clone and reinitialize:

```bash
git clone https://github.com/jvanheerikhuize/spec-driven-development-template.git my-project
cd my-project
rm -rf .git && git init
```

### 2. Configure Secrets

Add these secrets to your GitHub repository (Settings → Secrets → Actions):

| Secret | Required | Description |
|--------|----------|-------------|
| `ANTHROPIC_API_KEY` | Yes | API key for Claude Code CLI |
| `TEAMS_WEBHOOK_URL` | No | Microsoft Teams incoming webhook |
| `AZURE_DEVOPS_PAT` | No | Azure DevOps Personal Access Token |
| `SLACK_WEBHOOK_URL` | No | Slack incoming webhook |

See [Integrations Guide](docs/integrations.md) for the complete secrets reference.

### 3. Customize

1. Update `CODEOWNERS` with your team structure
2. Configure integrations in `specs.config.yaml`
3. Adjust workflow triggers in `.github/workflows/spec-ingestion.yml`
4. Review and customize issue templates in `.github/ISSUE_TEMPLATE/`

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
│   │   ├── validate-specs.yml     # Spec validation
│   │   └── notify-integrations.yml # Reusable notification workflow
│   ├── ISSUE_TEMPLATE/            # Issue templates (6 templates)
│   │   ├── bug-report.yaml
│   │   ├── feature-request.yaml
│   │   ├── spec-review.yaml
│   │   ├── incident-report.yaml
│   │   ├── documentation.yaml
│   │   └── integration-request.yaml
│   ├── pull_request_template.md
│   └── CODEOWNERS
│
├── .claude/                        # Claude Code configuration
│   ├── settings.json
│   └── CLAUDE.md                  # Project instructions for Claude
│
├── docs/
│   ├── spec-based-development.md  # SDD guide with rationale
│   ├── integrations.md            # Integration setup guide
│   └── runbooks/                  # Operational runbooks
│       ├── incident-response.md
│       ├── spec-ingestion-failure.md
│       ├── workflow-troubleshooting.md
│       └── integration-issues.md
│
├── specs.config.yaml              # Central spec registry & integrations
├── CONTRIBUTING.md
├── SECURITY.md
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

## Notification Events

Integrations can subscribe to these events:

| Event | Description |
|-------|-------------|
| `spec_created` | New specification file added |
| `spec_approved` | Specification status changed to approved |
| `implementation_started` | AI implementation workflow began |
| `implementation_completed` | Implementation finished successfully |
| `implementation_failed` | Implementation encountered an error |
| `pr_created` | Pull request was created |
| `pr_merged` | Pull request was merged |
| `validation_failed` | Schema validation failed |

## Integrations

This template supports extensive integrations with enterprise tools. Configure them in `specs.config.yaml`.

### Microsoft Ecosystem

#### Microsoft Teams

Send notifications to Teams channels with Adaptive Cards support:

```yaml
integrations:
  teams:
    enabled: true
    webhook_url: ""  # Or use TEAMS_WEBHOOK_URL secret
    notify_on:
      - "spec_approved"
      - "implementation_started"
      - "implementation_completed"
      - "implementation_failed"
    use_adaptive_cards: true
```

**Setup:**
1. In Teams, go to your channel → `...` → Connectors
2. Add "Incoming Webhook" and copy the URL
3. Add `TEAMS_WEBHOOK_URL` to GitHub Secrets

#### Azure DevOps

Sync specifications with Azure DevOps work items:

```yaml
integrations:
  azure_devops:
    enabled: true
    organization: "your-org"
    project: "your-project"
    work_item_type: "User Story"
    area_path: "your-project\\Team"
    iteration_path: "your-project\\Sprint 1"
```

**Required Secrets:** `AZURE_DEVOPS_ORG`, `AZURE_DEVOPS_PROJECT`, `AZURE_DEVOPS_PAT`

#### GitHub Projects

Track specs directly in GitHub Projects (v2):

```yaml
integrations:
  github_projects:
    enabled: true
    project_number: 1
    status_field: "Status"
    status_mappings:
      draft: "Backlog"
      review: "In Review"
      approved: "Ready"
      implemented: "Done"
```

### Communication

| Integration | Description | Secret Required |
|-------------|-------------|-----------------|
| **Microsoft Teams** | Rich Adaptive Cards notifications | `TEAMS_WEBHOOK_URL` |
| **Slack** | Channel notifications with formatting | `SLACK_WEBHOOK_URL` |
| **Discord** | Embedded message notifications | `DISCORD_WEBHOOK_URL` |
| **Email** | SMTP-based email alerts | `SMTP_HOST`, `SMTP_USER`, `SMTP_PASSWORD` |

### Project Management

| Integration | Description | Secrets Required |
|-------------|-------------|------------------|
| **Azure DevOps** | Work item sync, status updates | `AZURE_DEVOPS_*` |
| **GitHub Projects** | Native GitHub project boards | None (uses `GITHUB_TOKEN`) |
| **Linear** | Issue tracking sync | `LINEAR_API_KEY` |
| **Jira** | Atlassian issue sync | `JIRA_*` |

### Incident Management

| Integration | Description | Secret Required |
|-------------|-------------|-----------------|
| **PagerDuty** | Alert on-call on failures | `PAGERDUTY_ROUTING_KEY` |
| **Opsgenie** | Alert management | `OPSGENIE_API_KEY` |

### Observability

| Integration | Description | Secrets Required |
|-------------|-------------|------------------|
| **Datadog** | Metrics and events | `DATADOG_API_KEY`, `DATADOG_APP_KEY` |
| **New Relic** | Custom events | `NEW_RELIC_API_KEY` |
| **Sentry** | Error reporting | `SENTRY_DSN` |

### Custom Webhooks

Send notifications to any HTTP endpoint:

```yaml
integrations:
  webhooks:
    enabled: true
    endpoints:
      - name: "internal-system"
        url: "https://internal.example.com/webhook"
        events: ["implementation_completed"]
        headers:
          Authorization: "Bearer ${WEBHOOK_TOKEN}"
        secret: "${WEBHOOK_SECRET}"  # HMAC signature
```

See [docs/integrations.md](docs/integrations.md) for complete setup instructions.

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

## GitHub Issue Templates

This template includes 6 issue templates for comprehensive project management:

| Template | Purpose |
|----------|---------|
| **Bug Report** | Report bugs with component selection and related spec linking |
| **Feature Request** | Request new features with category and complexity assessment |
| **Spec Review** | Submit specifications for review and approval |
| **Incident Report** | Document production incidents with severity levels |
| **Documentation** | Request documentation improvements or additions |
| **Integration Request** | Request new tool integrations |

## Operational Runbooks

The `docs/runbooks/` directory contains operational procedures:

- [Incident Response](docs/runbooks/incident-response.md) - Production incident handling
- [Spec Ingestion Failure](docs/runbooks/spec-ingestion-failure.md) - Troubleshooting automation failures
- [Workflow Troubleshooting](docs/runbooks/workflow-troubleshooting.md) - Debug GitHub Actions issues
- [Integration Issues](docs/runbooks/integration-issues.md) - Fix integration connectivity
- [Runbook Template](docs/runbooks/_template.md) - Create new runbooks

## GitHub Actions Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `spec-ingestion.yml` | Push, manual, schedule, PR approval | Main spec processing and implementation |
| `validate-specs.yml` | Pull request | Validate spec files before merge |
| `notify-integrations.yml` | Called by other workflows | Reusable notification dispatch |

## Documentation

- [Spec-Based Development Guide](docs/spec-based-development.md) - Detailed workflow guide with rationale
- [Integrations Guide](docs/integrations.md) - Complete integration setup instructions
- [Contributing Guidelines](CONTRIBUTING.md) - How to contribute
- [Security Policy](SECURITY.md) - Reporting vulnerabilities
- [AI Context Guide](.ai/README.md) - AI documentation system
- [Runbooks](docs/runbooks/) - Operational procedures
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
