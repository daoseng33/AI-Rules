# Installs the shared AI rules for Claude Code and Codex on Windows.
# - ~/.ai-rules: a directory junction to this clone (no admin rights needed).
# - Claude Code: ~/.claude/CLAUDE.md is a one-line import of ~/.ai-rules/CLAUDE.md.
# - Codex: ~/.codex/AGENTS.md is a copy, because Codex cannot import files and
#   file symlinks need admin rights. Re-run this script after every `git pull`.
$ErrorActionPreference = "Stop"

# Resolve the clone's real path: run as ~/.ai-rules/scripts/install-windows.ps1,
# $PSScriptRoot would make the clone look like the ~/.ai-rules junction itself.
$RepoItem = Get-Item -LiteralPath (Split-Path -Parent $PSScriptRoot)
$RepoDir = if ($RepoItem.LinkType) { @($RepoItem.Target)[0] } else { $RepoItem.FullName }
$RulesLink = Join-Path $env:USERPROFILE ".ai-rules"
$ClaudeDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE ".claude" }
$CodexDir = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE ".codex" }
# Legacy path that some projects' rules reference literally.
$LegacyDocsLink = Join-Path $env:USERPROFILE ".claude\docs"
$BackupSuffix = "bak." + (Get-Date -Format "yyyyMMdd-HHmmss")
$ClaudeImport = "@~/.ai-rules/CLAUDE.md"
# Windows PowerShell 5.1 writes a BOM with -Encoding utf8, which would hide the
# leading "@" of the import from Claude Code.
$Utf8NoBom = New-Object System.Text.UTF8Encoding $false

# Moves an existing path aside and returns the backup path, or $null if there
# was nothing to back up.
function Backup-Path([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    $Backup = "$Path.$BackupSuffix"
    Move-Item -LiteralPath $Path -Destination $Backup
    Write-Host "Backed up $Path -> $Backup"
    return $Backup
}

# Backs up $Path, runs $Write, and puts the backup back if $Write fails, so a
# failed install never leaves the path missing.
function Invoke-Replace([string]$Path, [scriptblock]$Write) {
    $Backup = Backup-Path $Path
    try {
        & $Write
    } catch {
        if ($Backup) {
            # Drop a partial write so the backup can move back into place.
            Remove-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
            Move-Item -LiteralPath $Backup -Destination $Path
        }
        throw
    }
}

# Points $Link at the $Target directory with a junction: replaces an existing
# link, backs up a real file or directory, and leaves the path alone when it
# already is the target. If creating the junction fails, the previous state is
# restored.
function Set-Junction([string]$Link, [string]$Target) {
    $Existing = Get-Item -LiteralPath $Link -Force -ErrorAction SilentlyContinue
    if ($Existing -and -not $Existing.LinkType -and $Existing.FullName -eq (Get-Item -LiteralPath $Target).FullName) {
        Write-Host "Skipped ${Link}: it already is $Target"
        return
    }
    if ($Existing -and $Existing.LinkType) {
        $OldTarget = @($Existing.Target)[0]
        # Deleting the link itself (non-recursively) never touches the files it points to.
        if ($Existing.PSIsContainer) {
            [System.IO.Directory]::Delete($Link, $false)
        } else {
            [System.IO.File]::Delete($Link)
        }
        try {
            New-Item -ItemType Junction -Path $Link -Target $Target | Out-Null
        } catch {
            if ($Existing.PSIsContainer -and $OldTarget) {
                New-Item -ItemType Junction -Path $Link -Target $OldTarget | Out-Null
            }
            throw
        }
        Write-Host "Linked $Link -> $Target (was -> $OldTarget)"
    } else {
        Invoke-Replace $Link { New-Item -ItemType Junction -Path $Link -Target $Target | Out-Null }
        Write-Host "Linked $Link -> $Target"
    }
}

# 1. ~/.ai-rules -> this clone
Set-Junction $RulesLink $RepoDir

# 2. Claude Code: import stub, plus the legacy ~/.claude/docs path
New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null
$ClaudeMd = Join-Path $ClaudeDir "CLAUDE.md"
$CurrentStub = if (Test-Path -LiteralPath $ClaudeMd) { [System.IO.File]::ReadAllText($ClaudeMd).Trim() } else { $null }
if ($CurrentStub -ne $ClaudeImport) {
    Invoke-Replace $ClaudeMd { [System.IO.File]::WriteAllText($ClaudeMd, "$ClaudeImport`n", $Utf8NoBom) }
}
Write-Host "Installed $ClaudeMd (imports ~/.ai-rules/CLAUDE.md)"
New-Item -ItemType Directory -Path (Split-Path -Parent $LegacyDocsLink) -Force | Out-Null
Set-Junction $LegacyDocsLink (Join-Path $RepoDir "docs")

# 3. Codex: copy
New-Item -ItemType Directory -Path $CodexDir -Force | Out-Null
$CodexAgents = Join-Path $CodexDir "AGENTS.md"
$SourceAgents = Join-Path $RepoDir "AGENTS.md"
$IsCurrent = (Test-Path -LiteralPath $CodexAgents) -and
    ((Get-FileHash -LiteralPath $CodexAgents).Hash -eq (Get-FileHash -LiteralPath $SourceAgents).Hash)
if (-not $IsCurrent) {
    Invoke-Replace $CodexAgents { Copy-Item -LiteralPath $SourceAgents -Destination $CodexAgents }
}
Write-Host "Installed $CodexAgents (a copy: re-run this script after git pull)"

if (Test-Path -LiteralPath (Join-Path $CodexDir "AGENTS.override.md")) {
    Write-Warning "$CodexDir\AGENTS.override.md exists; Codex reads it instead of AGENTS.md."
}
