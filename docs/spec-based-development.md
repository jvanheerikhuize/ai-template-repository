# Spec-Based Development Guide

This guide explains how to use the specification-driven development workflow in this repository.

## Overview

Spec-Based Development (SBD) is a methodology where features are fully specified before implementation begins. This approach:

- Ensures clarity of requirements before coding
- Enables automated implementation via AI tools
- Creates documentation as a natural byproduct
- Reduces rework and miscommunication

## The Spec Lifecycle

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  DRAFT   │───▶│  REVIEW  │───▶│ APPROVED │───▶│IMPLEMENTED│───▶│DEPRECATED│
└──────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘
     │               │               │               │
     │               │               │               │
  Writing        Feedback       Ready for        Code           Replaced
  spec           & revisions    implementation   complete       or removed
```

### Status Definitions

| Status | Description |
|--------|-------------|
| `draft` | Spec is being written, not ready for review |
| `review` | Spec is complete and awaiting feedback |
| `approved` | Spec has been approved for implementation |
| `implemented` | Feature has been implemented and merged |
| `deprecated` | Spec is no longer relevant or superseded |

## Creating a Specification

### Step 1: Create the Spec File

```bash
# Copy the template
cp specs/features/_template.yaml specs/features/FEAT-0001-my-feature.yaml
```

### Step 2: Fill in Metadata

```yaml
metadata:
  id: "FEAT-0001"
  title: "User Authentication via OAuth"
  version: "1.0.0"
  status: "draft"
  priority: "high"
  author: "your-name"
  created_at: "2024-01-15"
  tags:
    - authentication
    - security
```

### Step 3: Define the Problem

```yaml
description:
  summary: |
    Add OAuth 2.0 authentication to allow users to sign in
    with their Google or GitHub accounts.

  problem_statement: |
    Currently, users must create and remember yet another password.
    This creates friction during signup and security risks from
    password reuse.

  proposed_solution: |
    Implement OAuth 2.0 flows for Google and GitHub, allowing
    users to authenticate with existing accounts.
```

### Step 4: Write Acceptance Criteria

Use the Gherkin format (Given/When/Then):

```yaml
acceptance_criteria:
  - id: "AC-001"
    given: "A user is on the login page"
    when: "They click 'Sign in with Google'"
    then: "They are redirected to Google's OAuth consent screen"

  - id: "AC-002"
    given: "A user completes Google OAuth consent"
    when: "They are redirected back to the application"
    then: "A new account is created with their Google email"
    and:
      - "They are automatically logged in"
      - "They see the dashboard"
```

### Step 5: Add Technical Requirements

```yaml
technical_requirements:
  constraints:
    - "Must support both Google and GitHub OAuth"
    - "Must handle OAuth errors gracefully"

  security:
    - "OAuth tokens must be stored securely"
    - "PKCE flow must be used for added security"

  performance:
    response_time_ms: 3000  # OAuth flow can be slow
```

## Spec Review Process

### Submitting for Review

1. Change status to `review`
2. Open a Pull Request
3. Tag reviewers (architecture team)

### Review Checklist

Reviewers check for:

- [ ] Clear, testable acceptance criteria
- [ ] Complete technical requirements
- [ ] No scope creep
- [ ] Feasible implementation
- [ ] Security considerations addressed
- [ ] Dependencies identified

### Approval

Once approved:
1. Status changes to `approved`
2. Spec is added to `specs.config.yaml`
3. Implementation can begin

## Implementation Methods

### Method 1: Automated (Claude Code)

For specs registered in `specs.config.yaml`:

```yaml
specifications:
  - id: "FEAT-0001"
    file: "specs/features/FEAT-0001-oauth.yaml"
    status: "approved"
    auto_implement: true
```

The GitHub Actions workflow will:
1. Detect the approved spec
2. Run Claude Code CLI
3. Create a feature branch
4. Open a PR with implementation

### Method 2: Manual Processing

Run the ingestion script locally:

```bash
# Process a single spec
./scripts/ingest-spec.sh specs/features/FEAT-0001-oauth.yaml

# Validate only (no implementation)
./scripts/ingest-spec.sh --validate specs/features/FEAT-0001-oauth.yaml

# Process all approved specs from config
./scripts/ingest-spec.sh --config
```

### Method 3: Manual Implementation

1. Create feature branch: `git checkout -b spec/FEAT-0001`
2. Implement each acceptance criterion
3. Write tests for each criterion
4. Submit PR referencing the spec

## Best Practices

### Writing Good Specs

1. **Be specific**: Avoid vague terms like "fast" or "user-friendly"
2. **Be complete**: Include error cases and edge cases
3. **Be testable**: Each criterion should be verifiable
4. **Be minimal**: Don't over-specify implementation details

### Acceptance Criteria Tips

**DO:**
```yaml
- id: "AC-001"
  given: "A user enters an invalid email format"
  when: "They submit the form"
  then: "An error message 'Please enter a valid email' appears below the field"
```

**DON'T:**
```yaml
- id: "AC-001"
  given: "Bad input"
  when: "Submit"
  then: "Show error"  # Too vague!
```

### Managing Spec Changes

If requirements change after approval:

1. Create a new spec version (increment `version`)
2. Document what changed and why
3. Re-submit for review if changes are significant

## Troubleshooting

### Spec Validation Fails

```bash
# Check YAML syntax
yq e '.' specs/features/your-spec.yaml

# Validate against schema
./scripts/ingest-spec.sh --validate specs/features/your-spec.yaml
```

### Implementation Doesn't Match Spec

- Review the acceptance criteria for ambiguity
- Check if all criteria are present in tests
- File an issue referencing specific criteria

### Workflow Not Triggering

Check:
1. Is the spec status `approved`?
2. Is `auto_implement: true` in config?
3. Is `ANTHROPIC_API_KEY` secret set?

## FAQ

**Q: Can I implement without a spec?**
A: For small fixes, yes. For features, always start with a spec.

**Q: How detailed should specs be?**
A: Detailed enough that implementation is unambiguous, but not so detailed that it prescribes implementation.

**Q: Who approves specs?**
A: The architecture team or designated reviewers in CODEOWNERS.

**Q: Can specs be changed after implementation?**
A: Yes, create a new version for enhancements or changes.
