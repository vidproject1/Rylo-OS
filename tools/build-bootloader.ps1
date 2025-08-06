# Rylo OS Two-Stage Bootloader Build Script
# Builds speed-optimized Stage 1 (MBR) + Stage 2 bootloader
Write-Host "Building Rylo OS Speed-Optimized Bootloader..." -ForegroundColor Green

# Clean previous builds
Write-Host "Cleaning build directory..." -ForegroundColor Yellow
Remove-Item "build\*.bin" -ErrorAction SilentlyContinue
Remove-Item "build\*.img" -ErrorAction SilentlyContinue

# Build Stage 1 (MBR) - 512 bytes
Write-Host "Building Stage 1 (MBR)..." -ForegroundColor Cyan
nasm -f bin src\bootloader\stage1.asm -o build\stage1.bin

if ($LASTEXITCODE -ne 0) {
    Write-Host "Stage 1 build failed!" -ForegroundColor Red
    exit 1
}

# Verify Stage 1 is exactly 512 bytes
$stage1Size = (Get-Item "build\stage1.bin").Length
if ($stage1Size -ne 512) {
    Write-Host "ERROR: Stage 1 must be exactly 512 bytes, got $stage1Size" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Stage 1: $stage1Size bytes (perfect!)" -ForegroundColor Green

# Build Stage 2 (Extended Bootloader)
Write-Host "Building Stage 2 (Extended)..." -ForegroundColor Cyan
nasm -f bin src\bootloader\stage2.asm -o build\stage2.bin

if ($LASTEXITCODE -ne 0) {
    Write-Host "Stage 2 build failed!" -ForegroundColor Red
    exit 1
}

# Check Stage 2 size (should be under 4KB)
$stage2Size = (Get-Item "build\stage2.bin").Length
if ($stage2Size -gt 4096) {
    Write-Host "WARNING: Stage 2 is $stage2Size bytes (>4KB may be slow)" -ForegroundColor Yellow
} else {
    Write-Host "✓ Stage 2: $stage2Size bytes (under 4KB limit)" -ForegroundColor Green
}

# Create bootable disk image
Write-Host "Creating bootable disk image..." -ForegroundColor Cyan

# Create 1MB disk image filled with zeros
dd if=/dev/zero of=build\rylo_boot.img bs=1024 count=1024 2>$null

# Write Stage 1 to sector 0 (MBR)
dd if=build\stage1.bin of=build\rylo_boot.img conv=notrunc 2>$null

# Write Stage 2 to sector 1 (starts at byte 512)
dd if=build\stage2.bin of=build\rylo_boot.img bs=512 seek=1 conv=notrunc 2>$null

# Verify disk image was created
if (Test-Path "build\rylo_boot.img") {
    $imageSize = (Get-Item "build\rylo_boot.img").Length
    Write-Host "✓ Bootable image: $imageSize bytes" -ForegroundColor Green
} else {
    Write-Host "ERROR: Failed to create disk image" -ForegroundColor Red
    exit 1
}

# Performance summary
Write-Host "`n=== SPEED-OPTIMIZED BOOTLOADER READY ===" -ForegroundColor Magenta
Write-Host "Stage 1 (MBR): $stage1Size bytes - Target: under 50ms" -ForegroundColor White
Write-Host "Stage 2 (Ext): $stage2Size bytes - Target: under 200ms" -ForegroundColor White  
Write-Host "Total Target: under 250ms boot time" -ForegroundColor White

Write-Host "`nRun with: .\tools\run-bootloader.ps1" -ForegroundColor Cyan
Write-Host "Debug with: qemu-system-x86_64 -drive file=build\rylo_boot.img,format=raw" -ForegroundColor Yellow
