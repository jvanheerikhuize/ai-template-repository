# =============================================================================
# Test-Template.ps1 — Validate the AI Template Repository structure (Windows)
# =============================================================================
# Usage:
#   .\scripts\Test-Template.ps1            # Run all tests
#   .\scripts\Test-Template.ps1 -Verbose   # Show extra detail
#
# Requirements: PowerShell >= 7.0 (pwsh)
# Optional:     python3 with pyyaml  (for YAML validation + schema checks)
#               powershell-yaml module  (alternative YAML parser)
#
# Exit codes: 0 = all passed, 1 = one or more failed
# =============================================================================

[CmdletBinding()]
param(
    [switch]$VerboseOutput
)

$ErrorActionPreference = 'Stop'
$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot   = Split-Path -Parent $ScriptDir
Set-Location $RepoRoot

$Pass = 0; $Fail = 0; $Warn = 0; $Skip = 0

function Write-Pass   { param($msg) $script:Pass++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Write-Fail   { param($msg) $script:Fail++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }
function Write-Warn   { param($msg) $script:Warn++; Write-Host "  [WARN] $msg" -ForegroundColor Yellow }
function Write-Skip   { param($msg) $script:Skip++; Write-Host "  [SKIP] $msg (skipped)" -ForegroundColor DarkYellow }
function Write-Section { param($title) Write-Host "`n-- $title --" -ForegroundColor Cyan }
function Write-Detail  { param($msg) if ($VerboseOutput) { Write-Host "    -> $msg" -ForegroundColor DarkGray } }

# ── YAML parser detection ─────────────────────────────────────────────────────
$YamlParser = $null

# Try powershell-yaml module
try {
    Import-Module powershell-yaml -ErrorAction Stop
    $YamlParser = 'psyaml'
    Write-Detail "YAML parser: powershell-yaml module"
} catch {
    # Try python3 + pyyaml
    try {
        $result = python3 -c "import yaml; print('ok')" 2>$null
        if ($result -eq 'ok') {
            $YamlParser = 'python3'
            Write-Detail "YAML parser: python3 + pyyaml"
        }
    } catch {
        Write-Detail "YAML parser: none (YAML-dependent tests will be skipped)"
    }
}

# ── YAML helpers ──────────────────────────────────────────────────────────────

function Test-YamlValid {
    param([string]$File)
    if ($YamlParser -eq 'psyaml') {
        try { ConvertFrom-Yaml (Get-Content $File -Raw) | Out-Null; return $true }
        catch { return $false }
    } elseif ($YamlParser -eq 'python3') {
        $code = "import yaml, sys`ntry:`n    yaml.safe_load(open(sys.argv[1]))`nexcept Exception as e:`n    print(e); sys.exit(1)"
        $rc = python3 -c $code $File 2>$null
        return $LASTEXITCODE -eq 0
    }
    return $null  # parser unavailable
}

function Get-YamlValue {
    param([string]$File, [string]$Key)
    if ($YamlParser -eq 'psyaml') {
        $data = ConvertFrom-Yaml (Get-Content $File -Raw)
        foreach ($k in $Key.Split('.')) { $data = $data[$k] }
        return "$data"
    } elseif ($YamlParser -eq 'python3') {
        $code = @"
import yaml, sys
data = yaml.safe_load(open(sys.argv[1]))
for k in sys.argv[2].split('.'):
    data = data.get(k) if isinstance(data, dict) else None
print('' if data is None else str(data))
"@
        return (python3 -c $code $File $Key 2>$null)
    }
    return ""
}

function Get-YamlCount {
    param([string]$File, [string]$Key)
    if ($YamlParser -eq 'psyaml') {
        $data = ConvertFrom-Yaml (Get-Content $File -Raw)
        foreach ($k in $Key.Split('.')) { $data = $data[$k] }
        return ($data | Measure-Object).Count
    } elseif ($YamlParser -eq 'python3') {
        $code = @"
import yaml, sys
data = yaml.safe_load(open(sys.argv[1]))
for k in sys.argv[2].split('.'):
    data = data.get(k, []) if isinstance(data, dict) else []
print(len(data) if isinstance(data, list) else 0)
"@
        return [int](python3 -c $code $File $Key 2>$null)
    }
    return 0
}

function Get-YamlList {
    param([string]$File, [string]$Key)
    if ($YamlParser -eq 'psyaml') {
        $data = ConvertFrom-Yaml (Get-Content $File -Raw)
        foreach ($k in $Key.Split('.')) { $data = $data[$k] }
        return $data
    } elseif ($YamlParser -eq 'python3') {
        $code = @"
import yaml, sys
data = yaml.safe_load(open(sys.argv[1]))
for k in sys.argv[2].split('.'):
    data = data.get(k, []) if isinstance(data, dict) else []
for item in (data if isinstance(data, list) else []):
    print(item)
"@
        return (python3 -c $code $File $Key 2>$null)
    }
    return @()
}

function Test-Frontmatter {
    param([string]$File)
    return ((Get-Content $File -TotalCount 1) -eq '---')
}

# =============================================================================
Write-Section "1. Required Files"
# =============================================================================
$Required = @(
    '.ai/README.md',                    '.ai/DIRECTIVES.md',
    '.ai/CONTEXT.md',                   '.ai/config.yaml',
    '.ai/architecture/ARCHITECTURE.md', '.ai/architecture/PATTERNS.md',
    '.ai/decisions/INDEX.yaml',         '.ai/decisions/README.md',
    '.ai/decisions/template.md',        '.ai/memory/README.md',
    '.ai/memory/SESSION_LOG.yaml',      '.ai/memory/LEARNINGS.yaml',
    '.ai/memory/TRACEABILITY.yaml',     '.ai/memory/AUTHORIZATIONS.yaml',
    '.ai/specs/SPEC.md',                'specs.config.yaml',
    'scripts/ingest-spec.sh',           'scripts/Invoke-SpecIngestion.ps1',
    '.claude/CLAUDE.md',                '.markdownlint.yaml'
)
foreach ($f in $Required) {
    if (Test-Path $f -PathType Leaf) { Write-Pass "exists: $f" }
    else { Write-Fail "missing: $f" }
}

# =============================================================================
Write-Section "2. YAML Syntax Validity"
# =============================================================================
$YamlFiles = @(
    '.ai/config.yaml',              '.ai/decisions/INDEX.yaml',
    '.ai/memory/SESSION_LOG.yaml',  '.ai/memory/LEARNINGS.yaml',
    '.ai/memory/TRACEABILITY.yaml', '.ai/memory/AUTHORIZATIONS.yaml',
    'specs.config.yaml'
)
foreach ($f in $YamlFiles) {
    if (-not (Test-Path $f)) { Write-Fail "cannot validate (missing): $f"; continue }
    if ($null -eq $YamlParser) { Write-Skip "yaml syntax: $f"; continue }
    if (Test-YamlValid $f) { Write-Pass "valid yaml: $f" }
    else                   { Write-Fail "invalid yaml: $f" }
}

# =============================================================================
Write-Section "3. YAML Frontmatter"
# =============================================================================
$FrontmatterRequired = @(
    '.ai/README.md',                    '.ai/DIRECTIVES.md',
    '.ai/CONTEXT.md',                   '.ai/architecture/ARCHITECTURE.md',
    '.ai/architecture/PATTERNS.md',     '.ai/decisions/template.md'
)
foreach ($f in $FrontmatterRequired) {
    if (-not (Test-Path $f)) { Write-Fail "cannot check (missing): $f"; continue }
    if (Test-Frontmatter $f) { Write-Pass "has frontmatter: $f" }
    else                     { Write-Fail "missing frontmatter: $f" }
}

# =============================================================================
Write-Section "4. Cross-Reference Integrity"
# =============================================================================

# config.yaml entry_points
if (Test-Path '.ai/config.yaml') {
    if ($YamlParser) {
        $entryPoints = Get-YamlList '.ai/config.yaml' 'context.entry_points'
        foreach ($p in $entryPoints) {
            if (-not $p) { continue }
            if ((Test-Path $p -PathType Leaf) -or (Test-Path $p -PathType Container)) {
                Write-Pass "config entry_point: $p"
            } else {
                Write-Fail "config entry_point missing: $p"
            }
        }
    } else {
        Write-Skip "config.yaml entry_points check (YAML parser unavailable)"
    }
}

# DIRECTIVES.md §0 session-init files
$DirectivesRefs = @(
    '.ai/CONTEXT.md', '.ai/memory/SESSION_LOG.yaml',
    '.ai/memory/LEARNINGS.yaml', '.ai/memory/TRACEABILITY.yaml',
    '.ai/decisions/INDEX.yaml'
)
foreach ($f in $DirectivesRefs) {
    if (Test-Path $f) { Write-Pass "DIRECTIVES §0 ref: $f" }
    else              { Write-Fail "DIRECTIVES §0 ref missing: $f" }
}

# decisions/README.md references INDEX.yaml
if (Test-Path '.ai/decisions/README.md') {
    $content = Get-Content '.ai/decisions/README.md' -Raw
    if ($content -match 'INDEX\.yaml') { Write-Pass "decisions/README.md links to INDEX.yaml" }
    else                               { Write-Fail "decisions/README.md does not reference INDEX.yaml" }
}

# memory/README.md references all four memory yaml files
if (Test-Path '.ai/memory/README.md') {
    $content = Get-Content '.ai/memory/README.md' -Raw
    foreach ($mf in @('SESSION_LOG.yaml','LEARNINGS.yaml','TRACEABILITY.yaml','AUTHORIZATIONS.yaml')) {
        if ($content -match [regex]::Escape($mf)) { Write-Pass "memory/README.md references $mf" }
        else                                      { Write-Fail "memory/README.md does not reference $mf" }
    }
}

# =============================================================================
Write-Section "5. Schema Consistency"
# =============================================================================
if (-not $YamlParser) {
    Write-Skip "all schema checks (YAML parser unavailable)"
} else {
    # INDEX.yaml
    if (Test-Path '.ai/decisions/INDEX.yaml') {
        $nid = [int](Get-YamlValue '.ai/decisions/INDEX.yaml' 'next_adr_id')
        $cnt = Get-YamlCount '.ai/decisions/INDEX.yaml' 'decisions'
        $exp = $cnt + 1
        if ($nid -eq $exp) { Write-Pass "INDEX.yaml: next_adr_id=$nid with $cnt decisions" }
        else               { Write-Fail "INDEX.yaml: next_adr_id=$nid, expected $exp ($cnt + 1)" }
    }

    # TRACEABILITY.yaml
    if (Test-Path '.ai/memory/TRACEABILITY.yaml') {
        $nid = [int](Get-YamlValue '.ai/memory/TRACEABILITY.yaml' 'next_tr_id')
        $cnt = Get-YamlCount '.ai/memory/TRACEABILITY.yaml' 'traces'
        $exp = $cnt + 1
        if ($nid -eq $exp) { Write-Pass "TRACEABILITY.yaml: next_tr_id=$nid with $cnt traces" }
        else               { Write-Fail "TRACEABILITY.yaml: next_tr_id=$nid, expected $exp ($cnt + 1)" }
    }

    # AUTHORIZATIONS.yaml
    if (Test-Path '.ai/memory/AUTHORIZATIONS.yaml') {
        $nid = [int](Get-YamlValue '.ai/memory/AUTHORIZATIONS.yaml' 'next_auth_id')
        $cnt = Get-YamlCount '.ai/memory/AUTHORIZATIONS.yaml' 'learned_authorizations'
        $exp = $cnt + 1
        if ($nid -eq $exp) { Write-Pass "AUTHORIZATIONS.yaml: next_auth_id=$nid with $cnt learned" }
        else               { Write-Fail "AUTHORIZATIONS.yaml: next_auth_id=$nid, expected $exp ($cnt + 1)" }
    }

    # LEARNINGS.yaml
    if (Test-Path '.ai/memory/LEARNINGS.yaml') {
        $nid = [int](Get-YamlValue '.ai/memory/LEARNINGS.yaml' 'next_learning_id')
        $cnt = Get-YamlCount '.ai/memory/LEARNINGS.yaml' 'learnings'
        $exp = $cnt + 1
        if ($nid -eq $exp) { Write-Pass "LEARNINGS.yaml: next_learning_id=$nid with $cnt learnings" }
        else               { Write-Fail "LEARNINGS.yaml: next_learning_id=$nid, expected $exp ($cnt + 1)" }
    }

    # SESSION_LOG.yaml
    if (Test-Path '.ai/memory/SESSION_LOG.yaml') {
        $cnt = Get-YamlCount '.ai/memory/SESSION_LOG.yaml' 'sessions'
        if ($cnt -gt 0) { Write-Pass "SESSION_LOG.yaml: $cnt session(s) logged" }
        else            { Write-Warn "SESSION_LOG.yaml: no sessions logged yet" }
    }
}

# =============================================================================
Write-Section "6. No Stale .md Memory References"
# =============================================================================
$DocFiles = @(
    '.ai/README.md',                '.ai/DIRECTIVES.md',
    '.ai/CONTEXT.md',               '.ai/architecture/ARCHITECTURE.md',
    '.ai/architecture/PATTERNS.md', '.ai/decisions/README.md',
    '.ai/decisions/template.md',    '.ai/memory/README.md',
    '.ai/config.yaml',              '.claude/CLAUDE.md'
)
$StalePatterns = @(
    'SESSION_LOG\.md', 'LEARNINGS\.md',
    'TRACEABILITY\.md', 'AUTHORIZATIONS\.md',
    'decisions/INDEX\.md'
)
foreach ($pat in $StalePatterns) {
    $found = $false
    foreach ($f in $DocFiles) {
        if (-not (Test-Path $f)) { continue }
        $matches = Select-String -Path $f -Pattern $pat -Quiet 2>$null
        if ($matches) {
            Write-Fail "stale ref '$pat' in: $f"
            if ($VerboseOutput) {
                Select-String -Path $f -Pattern $pat | ForEach-Object { Write-Detail $_.Line }
            }
            $found = $true
        }
    }
    if (-not $found) { Write-Pass "no stale ref: $pat" }
}

# =============================================================================
Write-Section "7. ADR Files (if any)"
# =============================================================================
$adrFiles = Get-ChildItem -Path '.ai/decisions' -Filter 'ADR-*.md' -ErrorAction SilentlyContinue |
            Sort-Object Name
if ($adrFiles.Count -eq 0) {
    Write-Skip "no ADR files found (expected for a fresh template)"
} else {
    foreach ($adr in $adrFiles) {
        $name = $adr.Name
        $top15 = Get-Content $adr.FullName -TotalCount 15

        if (Test-Frontmatter $adr.FullName) { Write-Pass "frontmatter: $name" }
        else                               { Write-Fail "missing frontmatter: $name" }

        foreach ($field in @('id','title','status','date')) {
            if ($top15 -match "^${field}:") { Write-Pass "field '$field': $name" }
            else                            { Write-Fail "missing field '$field': $name" }
        }

        $statusLine = ($top15 | Where-Object { $_ -match '^status:' } | Select-Object -First 1)
        $status = ($statusLine -replace '^status:\s*','').Trim().Trim('"').Trim("'")
        if ($status -in @('proposed','accepted','deprecated','superseded')) {
            Write-Pass "valid status ($status): $name"
        } else {
            Write-Fail "invalid status '$status': $name"
        }

        # Check ADR in INDEX.yaml
        if ((Test-Path '.ai/decisions/INDEX.yaml') -and $YamlParser) {
            $adrId = (($top15 | Where-Object { $_ -match '^id:' } | Select-Object -First 1) `
                     -replace '^id:\s*','').Trim().Trim('"').Trim("'")
            $code = @"
import yaml, sys
data = yaml.safe_load(open(sys.argv[1]))
ids = [str(d.get('id','')) for d in data.get('decisions',[])]
print('yes' if sys.argv[2] in ids else 'no')
"@
            $inIndex = python3 -c $code '.ai/decisions/INDEX.yaml' $adrId 2>$null
            if ($inIndex -eq 'yes') { Write-Pass "registered in INDEX.yaml: $name ($adrId)" }
            else                    { Write-Fail "not in INDEX.yaml: $name (id=$adrId)" }
        }
    }
}

# =============================================================================
Write-Section "8. Feature Spec Files (if any)"
# =============================================================================
$specFiles = Get-ChildItem -Path 'specs/features' -Filter '*.yaml' -ErrorAction SilentlyContinue |
             Sort-Object Name
if ($specFiles.Count -eq 0) {
    Write-Skip "no feature specs found (expected for a fresh template)"
} else {
    foreach ($spec in $specFiles) {
        if (-not $YamlParser) { Write-Skip "yaml syntax: $($spec.Name)"; continue }
        if (Test-YamlValid $spec.FullName) { Write-Pass "valid yaml: $($spec.Name)" }
        else                              { Write-Fail "invalid yaml: $($spec.Name)" }
    }
}

# =============================================================================
Write-Host "`n-- Summary --" -ForegroundColor Cyan
Write-Host "  Passed : $Pass"  -ForegroundColor Green
Write-Host "  Failed : $Fail"  -ForegroundColor Red
Write-Host "  Warned : $Warn"  -ForegroundColor Yellow
Write-Host "  Skipped: $Skip"  -ForegroundColor DarkYellow
Write-Host ""

if ($Fail -gt 0) {
    Write-Host "FAILED — $Fail test(s) failed." -ForegroundColor Red
    exit 1
} else {
    Write-Host "PASSED — all tests passed." -ForegroundColor Green
    exit 0
}
