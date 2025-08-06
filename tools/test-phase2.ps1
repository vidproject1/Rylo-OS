# Rylo OS Phase II Test Script
# Builds and runs the Phase II bootloader with debug output

param(
    [switch]$NoBuild,
    [switch]$Debug,
    [switch]$Monitor
)

$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$Cyan = "Cyan"
$White = "White"

Write-Host "=== Rylo OS Phase II Test Runner ===" -ForegroundColor $Cyan
Write-Host ""

# Build first unless skipped
if (-not $NoBuild) {
    Write-Host "Building Phase II..." -ForegroundColor $Green
    & "tools\build-phase2-simple.ps1"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Build failed!" -ForegroundColor $Red
        exit 1
    }
    Write-Host ""
}

# Check if disk image exists
if (-not (Test-Path "build\rylo_phase2.img")) {
    Write-Host "Error: Disk image not found! Run build first." -ForegroundColor $Red
    exit 1
}

Write-Host "=== Running Phase II Test ===" -ForegroundColor $Green
Write-Host ""
Write-Host "What you should see:" -ForegroundColor $Yellow
Write-Host "1. Black screen with text messages from bootloader stages" -ForegroundColor $White
Write-Host "2. Brief VGA messages from Stage 2 ('STAGE2', '32BIT')" -ForegroundColor $White 
Write-Host "3. Kernel clears screen and displays colorful success messages" -ForegroundColor $White
Write-Host "4. Final message '32-bit kernel running!' means Phase II is complete" -ForegroundColor $White
Write-Host ""
Write-Host "Starting QEMU..." -ForegroundColor $Green
Write-Host "(Press Ctrl+Alt+G to release mouse, Ctrl+Alt+2 for QEMU monitor)" -ForegroundColor $White
Write-Host ""

# Build QEMU command with appropriate options
$qemuCmd = "qemu-system-x86_64"
$qemuArgs = @(
    "-drive", "file=build\rylo_phase2.img,format=raw"
    "-m", "128"          # 128MB RAM (plenty for our simple kernel)
    "-no-reboot"         # Don't reboot on triple fault
    "-no-shutdown"       # Keep QEMU open after halt
)

if ($Debug) {
    # Add debug options
    $qemuArgs += @(
        "-d", "int,cpu_reset"
        "-D", "build\qemu_debug.log"
    )
    Write-Host "Debug mode enabled - check build\qemu_debug.log after run" -ForegroundColor $Yellow
}

if ($Monitor) {
    # Add monitor console
    $qemuArgs += @(
        "-monitor", "stdio"
    )
    Write-Host "Monitor mode enabled - QEMU monitor available in this console" -ForegroundColor $Yellow
}

# Run QEMU
& $qemuCmd @qemuArgs

Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor $Green

# Show results interpretation
if ($Debug -and (Test-Path "build\qemu_debug.log")) {
    Write-Host ""
    Write-Host "Debug log created: build\qemu_debug.log" -ForegroundColor $Cyan
    Write-Host "Check this file if the bootloader didn't work as expected" -ForegroundColor $White
}

Write-Host ""
Write-Host "Results interpretation:" -ForegroundColor $Yellow
Write-Host "[SUCCESS]: Colorful kernel messages displayed = Phase II complete" -ForegroundColor $Green
Write-Host "[FAIL]: Only bootloader messages, then black screen = Kernel load issue" -ForegroundColor $Red  
Write-Host "[FAIL]: Reboot loop = Triple fault in bootloader/kernel transition" -ForegroundColor $Red
Write-Host "[FAIL]: Immediate close = Stage 1 failed to load Stage 2" -ForegroundColor $Red
