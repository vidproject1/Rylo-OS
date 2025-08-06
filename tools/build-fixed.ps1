# Build with smaller Stage 2 that fits in 18 sectors
Write-Host "Building Rylo OS (Fixed Version)..." -ForegroundColor Green

# Build bootloaders  
nasm -f bin src\bootloader\stage1.asm -o build\stage1-fixed.bin
nasm -f bin src\bootloader\stage2-small.asm -o build\stage2-fixed.bin

# Check sizes
$s1 = (Get-Item build\stage1-fixed.bin).Length
$s2 = (Get-Item build\stage2-fixed.bin).Length
Write-Host "Stage1: $s1 bytes" -ForegroundColor Yellow
Write-Host "Stage2: $s2 bytes (needs $([Math]::Ceiling($s2/512)) sectors)" -ForegroundColor Yellow

# Create disk image
dd if=/dev/zero of=build\rylo-fixed.img bs=1024 count=100 2>$null
dd if=build\stage1-fixed.bin of=build\rylo-fixed.img conv=notrunc 2>$null
dd if=build\stage2-fixed.bin of=build\rylo-fixed.img bs=512 seek=1 conv=notrunc 2>$null

Write-Host "Build complete! Test with:" -ForegroundColor Green
Write-Host "qemu-system-x86_64 -drive file=build\rylo-fixed.img,format=raw -m 128M" -ForegroundColor Cyan
