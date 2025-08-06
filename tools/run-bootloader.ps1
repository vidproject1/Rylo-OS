# Run Rylo OS Speed-Optimized Bootloader in QEMU
Write-Host "Starting Rylo OS Bootloader Test..." -ForegroundColor Green

# Check if bootloader image exists
if (-not (Test-Path "build\rylo_boot.img")) {
    Write-Host "Bootloader image not found! Run .\tools\build-bootloader.ps1 first" -ForegroundColor Red
    exit 1
}

Write-Host "Bootloader: Two-stage speed optimized" -ForegroundColor Yellow
Write-Host "Target: Sub-300ms boot time" -ForegroundColor Yellow
Write-Host "Press Ctrl+Alt+G to release mouse, Alt+F4 to close QEMU" -ForegroundColor Cyan
Write-Host ""

# Run QEMU with our bootloader
# -no-reboot: Don't reboot on triple fault (helps with debugging)
# -d cpu_reset: Debug CPU resets (optional)
qemu-system-x86_64 -drive file=build\rylo_boot.img,format=raw -m 128M -no-reboot

Write-Host "QEMU session ended." -ForegroundColor Green
