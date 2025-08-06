# Complete Rylo OS Build Script - Bootloader + Kernel
Write-Host "Building Complete Rylo OS (Bootloader + Kernel)..." -ForegroundColor Green

# Clean build directory
Write-Host "Cleaning build directory..." -ForegroundColor Yellow
Remove-Item "build\*.bin" -ErrorAction SilentlyContinue
Remove-Item "build\*.o" -ErrorAction SilentlyContinue  
Remove-Item "build\*.img" -ErrorAction SilentlyContinue

# === BUILD BOOTLOADER ===
Write-Host "Building Stage 1 bootloader..." -ForegroundColor Cyan
nasm -f bin src\bootloader\stage1.asm -o build\stage1.bin

if ($LASTEXITCODE -ne 0) {
    Write-Host "Stage 1 build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Building Stage 2 bootloader..." -ForegroundColor Cyan  
nasm -f bin src\bootloader\stage2.asm -o build\stage2.bin

if ($LASTEXITCODE -ne 0) {
    Write-Host "Stage 2 build failed!" -ForegroundColor Red
    exit 1
}

# === BUILD KERNEL ===
Write-Host "Compiling kernel..." -ForegroundColor Cyan

# Compile kernel with cross-compiler flags for 64-bit freestanding target  
gcc -m64 -ffreestanding -nostdlib -nostdinc -fno-builtin -fno-stack-protector -fno-pic -mno-sse -mno-sse2 -mno-mmx -mno-80387 -mno-red-zone -c src\kernel\kernel.c -o build\kernel.o

if ($LASTEXITCODE -ne 0) {
    Write-Host "Kernel compilation failed!" -ForegroundColor Red
    exit 1
}

# Link kernel to ELF first, then convert to binary
Write-Host "Linking kernel..." -ForegroundColor Cyan
ld -T src\kernel\linker.ld -o build\kernel.elf build\kernel.o

if ($LASTEXITCODE -ne 0) {
    Write-Host "Kernel linking failed!" -ForegroundColor Red
    exit 1
}

# Convert ELF to raw binary
Write-Host "Converting to binary..." -ForegroundColor Cyan
objcopy -O binary build\kernel.elf build\kernel.bin

if ($LASTEXITCODE -ne 0) {
    Write-Host "Binary conversion failed!" -ForegroundColor Red
    exit 1
}

# === CREATE DISK IMAGE ===
Write-Host "Creating bootable disk image..." -ForegroundColor Cyan

# Create 10MB disk image (enough for kernel)
dd if=/dev/zero of=build\rylo_complete.img bs=1024 count=10240 2>$null

# Write Stage 1 to MBR (sector 0)
dd if=build\stage1.bin of=build\rylo_complete.img conv=notrunc 2>$null

# Write Stage 2 starting at sector 1
dd if=build\stage2.bin of=build\rylo_complete.img bs=512 seek=1 conv=notrunc 2>$null

# Write kernel at 1MB offset (0x100000) - standard kernel load address
dd if=build\kernel.bin of=build\rylo_complete.img bs=1024 seek=1024 conv=notrunc 2>$null

# === VERIFY BUILD ===
$stage1Size = (Get-Item "build\stage1.bin").Length
$stage2Size = (Get-Item "build\stage2.bin").Length  
$kernelSize = (Get-Item "build\kernel.bin").Length
$imageSize = (Get-Item "build\rylo_complete.img").Length

Write-Host "`n=== BUILD COMPLETE ===" -ForegroundColor Magenta
Write-Host "Stage 1 (MBR): $stage1Size bytes" -ForegroundColor White
Write-Host "Stage 2 (Extended): $stage2Size bytes" -ForegroundColor White
Write-Host "Kernel (C code): $kernelSize bytes" -ForegroundColor White  
Write-Host "Total image: $imageSize bytes" -ForegroundColor White

Write-Host "`n=== BOOT CHAIN READY ===" -ForegroundColor Green
Write-Host "1. BIOS loads Stage 1 (MBR)" -ForegroundColor Yellow
Write-Host "2. Stage 1 loads Stage 2" -ForegroundColor Yellow
Write-Host "3. Stage 2 sets up CPU modes" -ForegroundColor Yellow  
Write-Host "4. Stage 2 loads kernel from disk" -ForegroundColor Yellow
Write-Host "5. Kernel runs in 64-bit C code!" -ForegroundColor Yellow

Write-Host "`nRun with: qemu-system-x86_64 -drive file=build\rylo_complete.img,format=raw -m 128M" -ForegroundColor Cyan
