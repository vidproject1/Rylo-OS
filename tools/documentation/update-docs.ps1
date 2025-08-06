# Rylo OS Documentation Automation Script
# This script helps maintain the project's living documentation.

param(
    [switch]$UpdateContext,
    [switch]$GenerateSummary
)

$ProjectRoot = (Get-Location).Path
$DocsRoot = "$ProjectRoot\docs"

if ($UpdateContext) {
    Write-Host "Updating context file..." -ForegroundColor Green
    $ContextFile = "$DocsRoot\context\current-context.md"
    if (Test-Path $ContextFile) {
        $Content = Get-Content $ContextFile -Raw
        $DateTime = Get-Date -Format "yyyy-MM-dd HH:mm UTC"
        $UpdatedContent = $Content -replace '(?<=Last Updated: ).*', $DateTime
        $UpdatedContent | Set-Content $ContextFile
        Write-Host "✓ current-context.md timestamp updated to $DateTime" -ForegroundColor Yellow
    } else {
        Write-Host "✗ Context file not found!" -ForegroundColor Red
    }
}

if ($GenerateSummary) {
    Write-Host "Generating daily summary..." -ForegroundColor Green
    $Date = Get-Date -Format "yyyy-MM-dd"
    $JournalFile = "$DocsRoot\journal\$Date.md"
    
    # Get last 5 commits
    $Commits = git log --pretty=format:"- %s" -n 5
    
    # Get new ADRs
    $ADRFiles = Get-ChildItem -Path "$DocsRoot\decisions" -Filter "*.md" | Where-Object { $_.Name -ne "000-adr-template.md" }
    
    $Summary = "
---
## Auto-Generated Session Summary ($Date)

### Recent Commits:
$Commits

### New Architecture Decision Records (ADRs):
"
    
    foreach ($adr in $ADRFiles) {
        $Summary += "- $($adr.Name)
"
    }

    Write-Host "---" 
    Write-Host "Copy the summary below into: $JournalFile" -ForegroundColor Cyan
    Write-Host $Summary
    Write-Host "---"
}

