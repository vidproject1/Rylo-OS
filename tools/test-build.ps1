# Test Build Script for Rylo OS Development Environment
Write-Host "Building Rylo OS test bootloader..." -ForegroundColor Green

# Build bootloader
Write-Host "Assembling bootloader..." -ForegroundColor Yellow
nasm -f bin src\bootloader\test_boot.asm -o build\test_boot.bin

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Creating disk image..." -ForegroundColor Yellow
# Create 1MB disk image
$diskImage = "build\rylo_test.img"
$bootloader = "build\test_boot.bin"

# Create empty 1MB file
$null = New-Item -Path $diskImage -ItemType File -Force
$stream = [System.IO.File]::OpenWrite($diskImage)
$stream.SetLength(1048576)  # 1MB
$stream.Close()

# Copy bootloader to first sector
$bootData = [System.IO.File]::ReadAllBytes($bootloader)
$imageData = [System.IO.File]::ReadAllBytes($diskImage)
[System.Array]::Copy($bootData, 0, $imageData, 0, $bootData.Length)
[System.IO.File]::WriteAllBytes($diskImage, $imageData)

Write-Host "✓ Build complete: $diskImage" -ForegroundColor Green
Write-Host "Run with: qemu-system-x86_64 -drive file=build\rylo_test.img,format=raw" -ForegroundColor Cyan
