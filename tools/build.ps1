# Simple Rylo OS Bootloader Build Script
Write-Host "Building Rylo OS Bootloader..." -ForegroundColor Green

# Build Stage 1
Write-Host "Building Stage 1..." -ForegroundColor Yellow
nasm -f bin src\bootloader\stage1.asm -o build\stage1.bin

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

# Build Stage 2  
Write-Host "Building Stage 2..." -ForegroundColor Yellow
nasm -f bin src\bootloader\stage2.asm -o build\stage2.bin

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

# Create disk image
Write-Host "Creating disk image..." -ForegroundColor Yellow
dd if=/dev/zero of=build\rylo_boot.img bs=1024 count=1024 2>$null
dd if=build\stage1.bin of=build\rylo_boot.img conv=notrunc 2>$null
dd if=build\stage2.bin of=build\rylo_boot.img bs=512 seek=1 conv=notrunc 2>$null

Write-Host "Build complete!" -ForegroundColor Green
Write-Host "Run with: qemu-system-x86_64 -drive file=build\rylo_boot.img,format=raw" -ForegroundColor Cyan
