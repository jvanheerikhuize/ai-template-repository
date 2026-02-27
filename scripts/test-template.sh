#!/usr/bin/env bash
# =============================================================================
# test-template.sh — Validate the AI Template Repository structure
# =============================================================================
# Usage:
#   ./scripts/test-template.sh            # Run all tests
#   ./scripts/test-template.sh --verbose  # Show extra detail
#
# Requirements: bash >= 4.0
# Optional:     python3 with pyyaml  (for YAML validation + schema checks)
#               yq >= 4.0            (fallback YAML parser)
#
# Exit codes: 0 = all passed, 1 = one or more failed
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

VERBOSE=false
[[ "${1:-}" == "--verbose" ]] && VERBOSE=true

# ── Counters and colour helpers ───────────────────────────────────────────────
PASS=0; FAIL=0; WARN=0; SKIP=0
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; NC='\033[0m'

pass()    { PASS=$((PASS+1));  printf "  ${GREEN}✓${NC} %s\n" "$1"; }
fail()    { FAIL=$((FAIL+1));  printf "  ${RED}✗${NC} %s\n" "$1"; }
warn()    { WARN=$((WARN+1));  printf "  ${YELLOW}!${NC} %s\n" "$1"; }
skip()    { SKIP=$((SKIP+1));  printf "  ${YELLOW}–${NC} %s (skipped)\n" "$1"; }
section() { printf "\n${CYAN}── %s ──${NC}\n" "$1"; }
detail()  { $VERBOSE && printf "    → %s\n" "$1" || true; }

# ── YAML parser detection ─────────────────────────────────────────────────────
YAML_PARSER=""
if python3 -c "import yaml" 2>/dev/null; then
  YAML_PARSER="python3"
  detail "YAML parser: python3 + pyyaml"
elif command -v yq >/dev/null 2>&1; then
  YAML_PARSER="yq"
  detail "YAML parser: yq"
else
  detail "YAML parser: none (YAML-dependent tests will be skipped)"
fi

# ── YAML helpers ──────────────────────────────────────────────────────────────

# validate_yaml FILE — returns 0 if valid, 1 if invalid, 2 if parser unavailable
validate_yaml() {
  case "$YAML_PARSER" in
    python3)
      python3 - "$1" <<'PY'
import yaml, sys
try:
    yaml.safe_load(open(sys.argv[1]))
except Exception as e:
    print(e, file=sys.stderr); sys.exit(1)
PY
      ;;
    yq) yq eval '.' "$1" >/dev/null 2>&1 ;;
    *)  return 2 ;;
  esac
}

# yaml_get FILE DOT.KEY — prints scalar value or empty string
yaml_get() {
  case "$YAML_PARSER" in
    python3)
      python3 - "$1" "$2" <<'PY'
import yaml, sys
data = yaml.safe_load(open(sys.argv[1]))
for k in sys.argv[2].split('.'):
    data = data.get(k) if isinstance(data, dict) else None
print('' if data is None else str(data))
PY
      ;;
    yq) yq eval ".$2" "$1" 2>/dev/null | grep -v "^null$" ;;
    *)  echo "" ;;
  esac
}

# yaml_count FILE DOT.KEY — prints length of the array at KEY
yaml_count() {
  case "$YAML_PARSER" in
    python3)
      python3 - "$1" "$2" <<'PY'
import yaml, sys
data = yaml.safe_load(open(sys.argv[1]))
for k in sys.argv[2].split('.'):
    data = data.get(k, []) if isinstance(data, dict) else []
print(len(data) if isinstance(data, list) else 0)
PY
      ;;
    yq) yq eval ".$2 | length" "$1" 2>/dev/null ;;
    *)  echo "0" ;;
  esac
}

# yaml_list FILE DOT.KEY — prints each item on a new line
yaml_list() {
  case "$YAML_PARSER" in
    python3)
      python3 - "$1" "$2" <<'PY'
import yaml, sys
data = yaml.safe_load(open(sys.argv[1]))
for k in sys.argv[2].split('.'):
    data = data.get(k, []) if isinstance(data, dict) else []
for item in (data if isinstance(data, list) else []):
    print(item)
PY
      ;;
    yq) yq eval ".$2[]" "$1" 2>/dev/null ;;
  esac
}

has_frontmatter() { head -1 "$1" | grep -q "^---$"; }

# =============================================================================
section "1. Required Files"
# =============================================================================
REQUIRED=(
  ".ai/README.md"                     ".ai/DIRECTIVES.md"
  ".ai/CONTEXT.md"                    ".ai/config.yaml"
  ".ai/architecture/ARCHITECTURE.md"  ".ai/architecture/PATTERNS.md"
  ".ai/decisions/INDEX.yaml"          ".ai/decisions/README.md"
  ".ai/decisions/template.md"         ".ai/memory/README.md"
  ".ai/memory/SESSION_LOG.yaml"       ".ai/memory/LEARNINGS.yaml"
  ".ai/memory/TRACEABILITY.yaml"      ".ai/memory/AUTHORIZATIONS.yaml"
  ".ai/specs/SPEC.md"                 "specs.config.yaml"
  "scripts/ingest-spec.sh"            "scripts/Invoke-SpecIngestion.ps1"
  ".claude/CLAUDE.md"                 ".markdownlint.yaml"
)
for f in "${REQUIRED[@]}"; do
  [[ -f "$f" ]] && pass "exists: $f" || fail "missing: $f"
done

# =============================================================================
section "2. YAML Syntax Validity"
# =============================================================================
YAML_FILES=(
  ".ai/config.yaml"               ".ai/decisions/INDEX.yaml"
  ".ai/memory/SESSION_LOG.yaml"   ".ai/memory/LEARNINGS.yaml"
  ".ai/memory/TRACEABILITY.yaml"  ".ai/memory/AUTHORIZATIONS.yaml"
  "specs.config.yaml"
)
for f in "${YAML_FILES[@]}"; do
  [[ ! -f "$f" ]] && { fail "cannot validate (missing): $f"; continue; }
  [[ -z "$YAML_PARSER" ]] && { skip "yaml syntax: $f"; continue; }
  validate_yaml "$f" && pass "valid yaml: $f" || fail "invalid yaml: $f"
done

# =============================================================================
section "3. YAML Frontmatter"
# =============================================================================
FRONTMATTER_REQUIRED=(
  ".ai/README.md"                     ".ai/DIRECTIVES.md"
  ".ai/CONTEXT.md"                    ".ai/architecture/ARCHITECTURE.md"
  ".ai/architecture/PATTERNS.md"      ".ai/decisions/template.md"
)
for f in "${FRONTMATTER_REQUIRED[@]}"; do
  [[ ! -f "$f" ]] && { fail "cannot check (missing): $f"; continue; }
  has_frontmatter "$f" && pass "has frontmatter: $f" || fail "missing frontmatter: $f"
done

# =============================================================================
section "4. Cross-Reference Integrity"
# =============================================================================

# config.yaml entry_points all point to existing files
if [[ -f ".ai/config.yaml" ]]; then
  if [[ "$YAML_PARSER" == "python3" ]]; then
    while IFS= read -r p; do
      [[ -z "$p" ]] && continue
      [[ -f "$p" || -d "$p" ]] \
        && pass "config entry_point: $p" \
        || fail "config entry_point missing: $p"
    done < <(yaml_list ".ai/config.yaml" "context.entry_points")
  else
    skip "config.yaml entry_points check (YAML parser unavailable)"
  fi
fi

# DIRECTIVES.md §0 session-init file references
for f in ".ai/CONTEXT.md" ".ai/memory/SESSION_LOG.yaml" \
         ".ai/memory/LEARNINGS.yaml" ".ai/memory/TRACEABILITY.yaml" \
         ".ai/decisions/INDEX.yaml"; do
  [[ -f "$f" ]] && pass "DIRECTIVES §0 ref: $f" || fail "DIRECTIVES §0 ref missing: $f"
done

# decisions/README.md references INDEX.yaml
if [[ -f ".ai/decisions/README.md" ]]; then
  grep -q "INDEX\.yaml" ".ai/decisions/README.md" \
    && pass "decisions/README.md links to INDEX.yaml" \
    || fail "decisions/README.md does not reference INDEX.yaml"
fi

# memory/README.md exists and references all four memory yaml files
if [[ -f ".ai/memory/README.md" ]]; then
  for mf in "SESSION_LOG.yaml" "LEARNINGS.yaml" "TRACEABILITY.yaml" "AUTHORIZATIONS.yaml"; do
    grep -q "$mf" ".ai/memory/README.md" \
      && pass "memory/README.md references $mf" \
      || fail "memory/README.md does not reference $mf"
  done
fi

# =============================================================================
section "5. Schema Consistency"
# =============================================================================

if [[ -z "$YAML_PARSER" ]]; then
  skip "all schema checks (YAML parser unavailable)"
else
  # decisions/INDEX.yaml: next_adr_id == count(decisions) + 1
  if [[ -f ".ai/decisions/INDEX.yaml" ]]; then
    nid=$(yaml_get ".ai/decisions/INDEX.yaml" "next_adr_id")
    cnt=$(yaml_count ".ai/decisions/INDEX.yaml" "decisions")
    exp=$((cnt + 1))
    [[ "$nid" == "$exp" ]] \
      && pass "INDEX.yaml: next_adr_id=$nid with $cnt decisions" \
      || fail "INDEX.yaml: next_adr_id=$nid, expected $exp ($cnt decisions + 1)"
  fi

  # TRACEABILITY.yaml: next_tr_id == count(traces) + 1
  if [[ -f ".ai/memory/TRACEABILITY.yaml" ]]; then
    nid=$(yaml_get ".ai/memory/TRACEABILITY.yaml" "next_tr_id")
    cnt=$(yaml_count ".ai/memory/TRACEABILITY.yaml" "traces")
    exp=$((cnt + 1))
    [[ "$nid" == "$exp" ]] \
      && pass "TRACEABILITY.yaml: next_tr_id=$nid with $cnt traces" \
      || fail "TRACEABILITY.yaml: next_tr_id=$nid, expected $exp ($cnt traces + 1)"
  fi

  # AUTHORIZATIONS.yaml: next_auth_id == count(learned_authorizations) + 1
  if [[ -f ".ai/memory/AUTHORIZATIONS.yaml" ]]; then
    nid=$(yaml_get ".ai/memory/AUTHORIZATIONS.yaml" "next_auth_id")
    cnt=$(yaml_count ".ai/memory/AUTHORIZATIONS.yaml" "learned_authorizations")
    exp=$((cnt + 1))
    [[ "$nid" == "$exp" ]] \
      && pass "AUTHORIZATIONS.yaml: next_auth_id=$nid with $cnt learned" \
      || fail "AUTHORIZATIONS.yaml: next_auth_id=$nid, expected $exp ($cnt learned + 1)"
  fi

  # LEARNINGS.yaml: next_learning_id == count(learnings) + 1
  if [[ -f ".ai/memory/LEARNINGS.yaml" ]]; then
    nid=$(yaml_get ".ai/memory/LEARNINGS.yaml" "next_learning_id")
    cnt=$(yaml_count ".ai/memory/LEARNINGS.yaml" "learnings")
    exp=$((cnt + 1))
    [[ "$nid" == "$exp" ]] \
      && pass "LEARNINGS.yaml: next_learning_id=$nid with $cnt learnings" \
      || fail "LEARNINGS.yaml: next_learning_id=$nid, expected $exp ($cnt learnings + 1)"
  fi

  # SESSION_LOG.yaml: at least one session logged
  if [[ -f ".ai/memory/SESSION_LOG.yaml" ]]; then
    cnt=$(yaml_count ".ai/memory/SESSION_LOG.yaml" "sessions")
    [[ "$cnt" -gt 0 ]] \
      && pass "SESSION_LOG.yaml: $cnt session(s) logged" \
      || warn "SESSION_LOG.yaml: no sessions logged yet"
  fi
fi

# =============================================================================
section "6. No Stale .md Memory References"
# =============================================================================
# Doc files that should use .yaml for memory file references
# (YAML memory files themselves keep historical .md records — excluded here)
DOC_FILES=(
  ".ai/README.md"               ".ai/DIRECTIVES.md"
  ".ai/CONTEXT.md"              ".ai/architecture/ARCHITECTURE.md"
  ".ai/architecture/PATTERNS.md" ".ai/decisions/README.md"
  ".ai/decisions/template.md"   ".ai/memory/README.md"
  ".ai/config.yaml"             ".claude/CLAUDE.md"
)
STALE_PATTERNS=(
  "SESSION_LOG\.md"   "LEARNINGS\.md"
  "TRACEABILITY\.md"  "AUTHORIZATIONS\.md"
  "decisions/INDEX\.md"
)
for pat in "${STALE_PATTERNS[@]}"; do
  found=false
  for f in "${DOC_FILES[@]}"; do
    [[ ! -f "$f" ]] && continue
    if grep -q "$pat" "$f" 2>/dev/null; then
      fail "stale ref '$pat' in: $f"
      if $VERBOSE; then
        grep -n "$pat" "$f" | while IFS= read -r line; do detail "$line"; done
      fi
      found=true
    fi
  done
  $found || pass "no stale ref: $pat"
done

# =============================================================================
section "7. ADR Files (if any)"
# =============================================================================
mapfile -t adr_files < <(find .ai/decisions -name "ADR-[0-9]*.md" 2>/dev/null | sort || true)
if [[ ${#adr_files[@]} -eq 0 ]]; then
  skip "no ADR files found (expected for a fresh template)"
else
  for adr in "${adr_files[@]}"; do
    name=$(basename "$adr")
    has_frontmatter "$adr" \
      && pass "frontmatter present: $name" \
      || fail "missing frontmatter: $name"
    for field in id title status date; do
      grep -q "^${field}:" <(head -15 "$adr") \
        && pass "field '$field': $name" \
        || fail "missing field '$field': $name"
    done
    status=$(grep "^status:" <(head -15 "$adr") | head -1 \
             | sed 's/^status:[[:space:]]*//' | tr -d '"' | tr -d "'" | xargs)
    case "$status" in
      proposed|accepted|deprecated|superseded)
        pass "valid status ($status): $name" ;;
      *)
        fail "invalid status '$status': $name" ;;
    esac
    # Check ADR is registered in INDEX.yaml
    if [[ -f ".ai/decisions/INDEX.yaml" && "$YAML_PARSER" == "python3" ]]; then
      adr_id=$(grep "^id:" <(head -15 "$adr") | head -1 \
               | sed 's/^id:[[:space:]]*//' | tr -d '"' | tr -d "'" | xargs)
      in_index=$(python3 - ".ai/decisions/INDEX.yaml" "$adr_id" <<'PY'
import yaml, sys
data = yaml.safe_load(open(sys.argv[1]))
ids = [str(d.get('id', '')) for d in data.get('decisions', [])]
print('yes' if sys.argv[2] in ids else 'no')
PY
)
      [[ "$in_index" == "yes" ]] \
        && pass "registered in INDEX.yaml: $name ($adr_id)" \
        || fail "not in INDEX.yaml: $name (id=$adr_id)"
    fi
  done
fi

# =============================================================================
section "8. Feature Spec Files (if any)"
# =============================================================================
mapfile -t spec_files < <(find specs/features -name "*.yaml" 2>/dev/null | sort || true)
if [[ ${#spec_files[@]} -eq 0 ]]; then
  skip "no feature specs found (expected for a fresh template)"
else
  for spec in "${spec_files[@]}"; do
    [[ -z "$YAML_PARSER" ]] && { skip "yaml syntax: $spec"; continue; }
    validate_yaml "$spec" \
      && pass "valid yaml: $spec" \
      || fail "invalid yaml: $spec"
  done
fi

# =============================================================================
printf "\n${CYAN}── Summary ──${NC}\n"
printf "  ${GREEN}✓ Passed :${NC}  %d\n" "$PASS"
printf "  ${RED}✗ Failed :${NC}  %d\n" "$FAIL"
printf "  ${YELLOW}! Warned :${NC}  %d\n" "$WARN"
printf "  ${YELLOW}– Skipped:${NC}  %d\n" "$SKIP"
echo ""

if [[ $FAIL -gt 0 ]]; then
  printf "${RED}FAILED${NC} — %d test(s) failed.\n" "$FAIL"
  exit 1
else
  printf "${GREEN}PASSED${NC} — all tests passed.\n"
  exit 0
fi
