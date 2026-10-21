<# 
.SYNOPSIS
    Daily backup sync for Hermes Agent personal data to GitHub repo.
    EXCLUDES sensitive data: auth.json, tokens, secrets, vault files.
#>

param(
    [string]$HermesHome = "$env:LOCALAPPDATA\hermes",
    [string]$RepoRoot   = (Split-Path $PSScriptRoot -Parent),
    [string]$BackupDir  = "$RepoRoot\hermes-backup",
    [string]$CommitMsg  = "chore: daily hermes backup $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
)

$EXIT_OK = 0
$EXIT_NO_CHANGES = 1
$EXIT_ERROR = 2

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Write-Host "[$timestamp] [$Level] $Message"
}

function Copy-WithStructure {
    param([string]$Source, [string]$Destination, [string[]]$Include = @('*'), [string[]]$Exclude = @())
    if (-not (Test-Path $Source)) { Write-Log "Source not found: $Source" 'WARN'; return }
    $params = @{ Path = $Source; Destination = $Destination; Recurse = $true; Force = $true; Container = $true }
    if ($Include.Count -gt 0 -and $Include[0] -ne '*') { $params['Include'] = $Include }
    if ($Exclude.Count -gt 0) { $params['Exclude'] = $Exclude }
    try { Copy-Item @params -ErrorAction Stop; Write-Log ("Copied: {0} -> {1}" -f $Source, $Destination) }
    catch { $err = $_; Write-Log ("Failed to copy {0}: {1}" -f $Source, $err) 'ERROR' }
}

# SENSITIVE FILES TO NEVER BACKUP
$SensitiveExcludes = @(
    'auth.json', '*.key', '*.pem', '*.p12', '*.pfx',
    'vault.json.enc', 'vault.key', 'mcp-tokens',
    '*.secret', '*.token', 'credentials*', '*.env*',
    '*.db-shm', '*.db-wal', '*.lock', '*.bak'
)

Write-Log "Starting Hermes backup sync..."
Write-Log ("Hermes home: {0}" -f $HermesHome)
Write-Log ("Repo root:   {0}" -f $RepoRoot)
Write-Log ("Backup dir:  {0}" -f $BackupDir)

$dirs = @('config', 'skills', 'memory', 'kanban', 'sessions', 'state', 'plugins', 'cron', 'desktop')
foreach ($d in $dirs) { if (-not (Test-Path "$BackupDir\$d")) { New-Item -ItemType Directory -Path "$BackupDir\$d" -Force | Out-Null } }

# CONFIG (exclude auth.json and sensitive)
Copy-WithStructure "$HermesHome\config.yaml" "$BackupDir\config\config.yaml"
Copy-WithStructure "$HermesHome\config.yaml.bak-*" "$BackupDir\config\"
Copy-WithStructure "$HermesHome\context_length_cache.yaml" "$BackupDir\config\"
Copy-WithStructure "$HermesHome\channel_directory.json" "$BackupDir\config\"
Copy-WithStructure "$HermesHome\gateway_state.json" "$BackupDir\config\"
Copy-WithStructure "$HermesHome\provider_models_cache.json" "$BackupDir\config\"
Copy-WithStructure "$HermesHome\spawn-ledger.json" "$BackupDir\config\"
Copy-WithStructure "$HermesHome\processes.json" "$BackupDir\config\"
# SKIP: auth.json (credential store)
Copy-WithStructure "$HermesHome\SOUL.md" "$BackupDir\config\"

# SKILLS (personal only)
$bundledManifest = "$HermesHome\skills\.bundled_manifest"
$bundledSkills = @()
if (Test-Path $bundledManifest) {
    $bundledSkills = Get-Content $bundledManifest -Raw | ConvertFrom-Json | ForEach-Object { $_.name }
}
$skillsDir = "$HermesHome\skills"
if (Test-Path $skillsDir) {
    $allSkillDirs = Get-ChildItem $skillsDir -Directory | Where-Object { $_.Name -notmatch '^\.' }
    foreach ($skillDir in $allSkillDirs) {
        if ($bundledSkills -notcontains $skillDir.Name) {
            Copy-WithStructure $skillDir.FullName "$BackupDir\skills\$($skillDir.Name)" -Exclude @('.git', 'node_modules', '__pycache__', '*.pyc', '.curator_*', '.usage.json*', '.locks') + $SensitiveExcludes
            Write-Log ("Backed up personal skill: {0}" -f $skillDir.Name)
        }
    }
    Copy-WithStructure "$HermesHome\skills\.curator_ledger.jsonl" "$BackupDir\skills\"
    Copy-WithStructure "$HermesHome\skills\.usage.json" "$BackupDir\skills\"
    Copy-WithStructure "$HermesHome\skills\.curator_state" "$BackupDir\skills\"
}

# MEMORY (exclude locks and DBs)
Copy-WithStructure "$HermesHome\memories" "$BackupDir\memory" -Exclude @('*.lock', '*.db*', '*.wal', '*.shm') + $SensitiveExcludes

# KANBAN (exclude locks, WAL/SHM)
Copy-WithStructure "$HermesHome\kanban.db" "$BackupDir\kanban\"
Copy-WithStructure "$HermesHome\kanban" "$BackupDir\kanban\boards" -Exclude @('*.lock', '*.db-shm', '*.db-wal') + $SensitiveExcludes

# SESSIONS (recent 50, metadata only, no DBs)
$sessionDir = "$HermesHome\sessions"
if (Test-Path $sessionDir) {
    $recentSessions = Get-ChildItem $sessionDir -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 50
    foreach ($sess in $recentSessions) {
        $target = "$BackupDir\sessions\$($sess.Name)"
        New-Item -ItemType Directory -Path $target -Force | Out-Null
        Get-ChildItem $sess.FullName -File -Include '*.json', '*.yaml', '*.md' | Where-Object { $_.Name -notmatch '\.(db|wal|shm|lock)$' } | ForEach-Object { Copy-Item $_.FullName -Destination $target -Force }
    }
}

# STATE (key files only, exclude locks/WAL/SHM/bak)
Copy-WithStructure "$HermesHome\state.db" "$BackupDir\state\" -Exclude @('*.lock', '*.bak', '*.wal', '*.shm')
Copy-WithStructure "$HermesHome\shared-state.db" "$BackupDir\state\"
Copy-WithStructure "$HermesHome\projects.db" "$BackupDir\state\"

# PLUGINS (personal only)
$pluginsDir = "$HermesHome\plugins"
if (Test-Path $pluginsDir) {
    $personalPlugins = Get-ChildItem $pluginsDir -Directory | Where-Object { $_.Name -notmatch '^(chrome-profiles|disk-cleanup|jev)$' }
    foreach ($plug in $personalPlugins) {
        Copy-WithStructure $plug.FullName "$BackupDir\plugins\$($plug.Name)" -Exclude @('.git', 'node_modules', '__pycache__', '*.pyc') + $SensitiveExcludes
    }
}

# CRON
Copy-WithStructure "$HermesHome\cron" "$BackupDir\cron" -Exclude @('*.lock') + $SensitiveExcludes

# DESKTOP
Copy-WithStructure "$HermesHome\desktop" "$BackupDir\desktop" -Exclude @('*.lock') + $SensitiveExcludes

Write-Log "File copy complete. Checking git status..."
Set-Location $RepoRoot
$gitStatus = git status --porcelain 2>&1
if ($LASTEXITCODE -ne 0) { Write-Log ("Git status failed: {0}" -f $gitStatus) 'ERROR'; exit $EXIT_ERROR }
if (-not $gitStatus.Trim()) { Write-Log "No changes to commit."; exit $EXIT_NO_CHANGES }

Write-Log "Changes detected, committing..."
git add hermes-backup/ 2>&1 | ForEach-Object { Write-Log $_ }
git commit -m $CommitMsg 2>&1 | ForEach-Object { Write-Log $_ }
if ($LASTEXITCODE -ne 0) { Write-Log "Commit failed" 'ERROR'; exit $EXIT_ERROR }

Write-Log "Pushing to origin..."
git push origin main 2>&1 | ForEach-Object { Write-Log $_ }
if ($LASTEXITCODE -ne 0) { Write-Log "Push failed" 'ERROR'; exit $EXIT_ERROR }

Write-Log "Backup sync completed successfully."
exit $EXIT_OK
