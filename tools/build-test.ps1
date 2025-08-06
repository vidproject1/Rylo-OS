# Build simple two-stage test
Write-Host "Building simple two-stage test..." -ForegroundColor Green

# Build bootloaders
nasm -f bin src\bootloader\stage1-simple.asm -o build\stage1-simple.bin
nasm -f bin src\bootloader\stage2-simple.asm -o build\stage2-simple.bin

# Create disk image
dd if=/dev/zero of=build\test-simple.img bs=512 count=100 2>$null
dd if=build\stage1-simple.bin of=build\test-simple.img conv=notrunc 2>$null
dd if=build\stage2-simple.bin of=build\test-simple.img bs=512 seek=1 conv=notrunc 2>$null

Write-Host "Built! Test with:" -ForegroundColor Green
Write-Host "qemu-system-x86_64 -drive file=build\test-simple.img,format=raw -m 128M" -ForegroundColor Cyan
