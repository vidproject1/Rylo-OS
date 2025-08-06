# Debug build for troubleshooting the disk read issue

Write-Host "=== Debug Build ===" -ForegroundColor Yellow

# Build Stage 1
nasm -f bin src\bootloader\stage1.asm -o build\stage1.bin
if ($LASTEXITCODE -ne 0) { exit 1 }

# Build DEBUG Stage 2
nasm -f bin src\bootloader\stage2-debug.asm -o build\stage2.bin
if ($LASTEXITCODE -ne 0) { exit 1 }

# Build Kernel
nasm -f bin src\kernel\test_kernel.asm -o build\kernel.bin
if ($LASTEXITCODE -ne 0) { exit 1 }

# Create disk image
dd if=/dev/zero of=build\debug.img bs=1024 count=1024 2>$null
dd if=build\stage1.bin of=build\debug.img conv=notrunc 2>$null
dd if=build\stage2.bin of=build\debug.img bs=512 seek=1 conv=notrunc 2>$null
dd if=build\kernel.bin of=build\debug.img bs=512 seek=2 conv=notrunc 2>$null

Write-Host "Debug build complete. Running..." -ForegroundColor Green
qemu-system-x86_64 -drive file=build\debug.img,format=raw
