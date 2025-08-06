# Simple test runner for Rylo OS
Write-Host "Running Rylo OS in QEMU..." -ForegroundColor Green

$imgPath = Join-Path $PWD "build\rylo_simple.img"

if (!(Test-Path $imgPath)) {
    Write-Host "Build image not found. Run build-simple.ps1 first." -ForegroundColor Red
    exit 1
}

Write-Host "Expected: Should see '*' from Stage 1, 'STAGE2' from Stage 2, then 'KERNEL!' from kernel" -ForegroundColor Yellow
Write-Host "Press Ctrl+Alt+G to release mouse, Alt+F4 to close" -ForegroundColor Cyan
Write-Host ""

# Launch QEMU with basic VGA display
Start-Process -Wait -FilePath "qemu-system-x86_64" -ArgumentList @(
    "-drive", "file=$imgPath,format=raw",
    "-m", "128M",
    "-no-reboot"
)
