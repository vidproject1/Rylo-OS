# Update Context Script for Rylo OS
# Automatically updates context files and generates project snapshots

param(
    [string]$Message = "Context update",
    [switch]$CreateCheckpoint = $false
)

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$Date = Get-Date -Format "yyyy-MM-dd"
$DateTime = Get-Date -Format "yyyy-MM-dd HH:mm UTC"

Write-Host "Updating Rylo OS context..." -ForegroundColor Green

# Update current context file
$ContextFile = Join-Path $ProjectRoot "docs\context\current-context.md"
if (Test-Path $ContextFile) {
    $Content = Get-Content $ContextFile -Raw
    $Content = $Content -replace '\*\*Last Updated\*\*: .*', "**Last Updated**: $DateTime"
    $Content | Set-Content $ContextFile -NoNewline
    Write-Host "✓ Updated current-context.md" -ForegroundColor Yellow
}

# Create today's journal if it doesn't exist
$JournalFile = Join-Path $ProjectRoot "docs\journal\$Date.md"
if (-not (Test-Path $JournalFile)) {
    $JournalTemplate = @'
# Development Journal - {0}

## Session Summary
**Start Time**: {1}  
**Duration**: In Progress  
**Phase**: Phase 0 - Foundation & Documentation  
**AI Model**: [Update with current model]

## Today''s Objectives
- [ ] [Add objectives]

## Accomplishments
[Record what was completed]

## Key Decisions Made
[List important decisions]

## Challenges Encountered
[Note any problems or obstacles]

## Next Steps (Priority Order)
1. [Next action items]

## Context for Future Sessions
[Important context for continuation]

## Code/Files Modified Today
[List of modified files with brief descriptions]

---
**End of Session Notes**  
[Final status and notes]
'@ -f $Date, (Get-Date -Format "HH:mm UTC")
    $JournalTemplate | Set-Content $JournalFile
    Write-Host "✓ Created journal for $Date" -ForegroundColor Yellow
}

# Generate project status summary
$StatusFile = Join-Path $ProjectRoot "docs\context\project-status.json"
$GitStatus = if (Test-Path (Join-Path $ProjectRoot ".git")) {
    try {
        $Branch = git rev-parse --abbrev-ref HEAD 2>$null
        $Commit = git rev-parse --short HEAD 2>$null
        $Changes = git status --porcelain 2>$null
        @{
            branch = $Branch
            commit = $Commit
            hasChanges = $Changes.Count -gt 0
            changedFiles = $Changes
        }
    } catch {
        @{ error = "Git not available" }
    }
} else {
    @{ status = "No git repository" }
}

$ProjectStatus = @{
    timestamp = $DateTime
    phase = "Phase 0 - Foundation & Documentation"
    directory = $ProjectRoot
    git = $GitStatus
    message = $Message
} | ConvertTo-Json -Depth 3

$ProjectStatus | Set-Content $StatusFile
Write-Host "✓ Updated project-status.json" -ForegroundColor Yellow

# Create checkpoint if requested
if ($CreateCheckpoint) {
    $CheckpointDir = Join-Path $ProjectRoot "checkpoints\$Date"
    New-Item -ItemType Directory -Force -Path $CheckpointDir | Out-Null
    
    # Copy documentation
    Copy-Item -Path (Join-Path $ProjectRoot "docs") -Destination $CheckpointDir -Recurse -Force
    
    # Create checkpoint metadata
    @{
        date = $Date
        message = $Message
        phase = "Phase 0"
        files_count = (Get-ChildItem $ProjectRoot -Recurse -File).Count
    } | ConvertTo-Json | Set-Content (Join-Path $CheckpointDir "checkpoint.json")
    
    Write-Host "✓ Created checkpoint in checkpoints\$Date" -ForegroundColor Green
}

Write-Host "Context update complete!" -ForegroundColor Green
Write-Host "Next: Review updated files and continue development" -ForegroundColor Cyan
