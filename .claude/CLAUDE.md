# Claude Code Project Instructions

This document provides context and guidelines for Claude Code when working with this repository.

## Project Overview

This is a **language-agnostic template repository** designed for **spec-based development**. Features are implemented based on formal specifications rather than ad-hoc requests.

## Repository Structure

```
├── specs/                    # All specifications
│   ├── features/            # Feature specifications (YAML)
│   ├── api/                 # API specifications (OpenAPI)
│   └── schemas/             # JSON schemas for validation
├── scripts/                  # Automation scripts
│   └── ingest-spec.sh       # Spec processing script
├── .github/
│   ├── workflows/           # CI/CD workflows
│   │   └── spec-ingestion.yml
│   └── ISSUE_TEMPLATE/      # Issue templates
├── docs/                     # Documentation
├── specs.config.yaml         # Central spec registry
└── .claude/                  # Claude Code configuration
```

## Spec-Based Development Workflow

1. **Specification First**: All features start with a formal spec in `specs/features/`
2. **Review & Approval**: Specs go through review before implementation
3. **Automated Implementation**: Approved specs trigger Claude Code implementation
4. **PR Creation**: Implementation creates a PR for human review

## When Implementing Specs

### DO:
- Read and understand the entire spec before coding
- Implement ALL acceptance criteria
- Follow existing patterns in the codebase
- Create appropriate tests for each acceptance criterion
- Keep implementations minimal and focused on the spec
- Document any decisions made when spec is ambiguous

### DON'T:
- Add features not in the spec
- Over-engineer solutions
- Skip acceptance criteria
- Ignore existing code patterns
- Make breaking changes without spec approval

## Spec File Formats

### Feature Specs (`specs/features/*.yaml`)
- Follow the schema in `specs/schemas/feature-spec.schema.json`
- Must include: metadata, description, acceptance_criteria
- Use Gherkin-style (Given/When/Then) for acceptance criteria

### API Specs (`specs/api/*.yaml`)
- Follow OpenAPI 3.1 specification
- Include complete request/response schemas
- Document error responses

## Code Conventions

Since this is language-agnostic, follow these general principles:

1. **Match existing style** - If code exists, match its patterns
2. **Standard tooling** - Use language-standard formatters/linters
3. **Clear naming** - Self-documenting names over comments
4. **Test coverage** - Tests for all acceptance criteria
5. **Minimal changes** - Only change what the spec requires

## Testing Requirements

For each acceptance criterion in a spec:
1. Create at least one test case
2. Cover the happy path (Given/When/Then)
3. Cover edge cases if specified
4. Cover error cases if specified

## Commit Messages

Follow conventional commits format:
```
feat(FEAT-0001): Brief description

- Implemented acceptance criteria AC-001, AC-002
- Added tests for all criteria

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Working with specs.config.yaml

The central configuration tracks all specs:
- Check `specifications` array for pending work
- Respect `status` field (only implement `approved` specs)
- Update status to `implemented` after completion

## Important Files to Read

Before implementing any spec, read:
1. The spec file itself (thoroughly)
2. `specs.config.yaml` for context
3. Related existing code
4. Existing tests for patterns
