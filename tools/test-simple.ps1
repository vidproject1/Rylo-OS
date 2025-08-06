# Test Rylo OS in QEMU with debugging output
Write-Host "Testing Rylo OS Bootloader + Kernel..." -ForegroundColor Green

$imgPath = "D:\dev\Rylo OS\build\rylo_simple.img"

if (!(Test-Path $imgPath)) {
    Write-Host "Error: Disk image not found. Run build-simple.ps1 first." -ForegroundColor Red
    exit 1
}

Write-Host "Starting QEMU..." -ForegroundColor Yellow
Write-Host "Expected behavior:" -ForegroundColor Cyan
Write-Host "1. Stage 1 bootloader displays '*'" -ForegroundColor Gray
Write-Host "2. Stage 2 bootloader displays 'STAGE2' and transitions to long mode" -ForegroundColor Gray
Write-Host "3. Kernel displays 'KERNEL!' at top of screen" -ForegroundColor Gray
Write-Host "" -ForegroundColor Gray

# Run QEMU with extra debugging and monitor
qemu-system-x86_64 `
    -drive file="$imgPath",format=raw `
    -m 128M `
    -no-reboot `
    -display curses `
    -serial stdio `
    -d int,cpu_reset 2>debug.log

Write-Host "`nQEMU exited. Check debug.log for details." -ForegroundColor Yellow
