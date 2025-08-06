# Simple Context Update Script for Rylo OS
param(
    [string]$Message = "Context update",
    [switch]$CreateCheckpoint = $false
)

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$Date = Get-Date -Format "yyyy-MM-dd"
$DateTime = Get-Date -Format "yyyy-MM-dd HH:mm UTC"

Write-Host "Updating Rylo OS context..." -ForegroundColor Green

# Update current context file timestamp
$ContextFile = Join-Path $ProjectRoot "docs\context\current-context.md"
if (Test-Path $ContextFile) {
    $Content = Get-Content $ContextFile -Raw
    $Content = $Content -replace '\*\*Last Updated\*\*: .*', "**Last Updated**: $DateTime"
    $Content | Set-Content $ContextFile -NoNewline
    Write-Host "✓ Updated current-context.md timestamp" -ForegroundColor Yellow
}

# Generate project status JSON
$StatusFile = Join-Path $ProjectRoot "docs\context\project-status.json"
$GitBranch = ""
$GitCommit = ""
try {
    $GitBranch = git rev-parse --abbrev-ref HEAD 2>$null
    $GitCommit = git rev-parse --short HEAD 2>$null
} catch {
    $GitBranch = "unknown"
    $GitCommit = "unknown"
}

$ProjectStatus = @{
    timestamp = $DateTime
    phase = "Phase 0 - Foundation and Documentation"
    directory = $ProjectRoot
    git_branch = $GitBranch
    git_commit = $GitCommit
    message = $Message
}

$ProjectStatus | ConvertTo-Json -Depth 2 | Set-Content $StatusFile
Write-Host "✓ Updated project-status.json" -ForegroundColor Yellow

# Create checkpoint if requested
if ($CreateCheckpoint) {
    $CheckpointDir = Join-Path $ProjectRoot "checkpoints\$Date"
    New-Item -ItemType Directory -Force -Path $CheckpointDir | Out-Null
    
    # Copy documentation
    Copy-Item -Path (Join-Path $ProjectRoot "docs") -Destination $CheckpointDir -Recurse -Force
    
    # Create simple checkpoint metadata
    $CheckpointData = @{
        date = $Date
        message = $Message
        phase = "Phase 0"
    }
    $CheckpointData | ConvertTo-Json | Set-Content (Join-Path $CheckpointDir "checkpoint.json")
    
    Write-Host "✓ Created checkpoint in checkpoints\$Date" -ForegroundColor Green
}

Write-Host "Context update complete!" -ForegroundColor Green
