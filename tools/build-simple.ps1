# Simple Build - Just test the bootloader with kernel placeholder
Write-Host "Building Rylo OS (Simple Version)..." -ForegroundColor Green

# Ensure we're in the right directory and build directory exists
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir
Set-Location $projectDir

if (!(Test-Path "build")) {
    New-Item -ItemType Directory -Path "build" | Out-Null
}

# Build bootloaders
Write-Host "Building bootloader..." -ForegroundColor Yellow
nasm -f bin src\bootloader\stage1.asm -o build\stage1.bin
nasm -f bin src\bootloader\stage2.asm -o build\stage2.bin

# Create a simple "kernel" that just contains machine code to show success
Write-Host "Creating simple test kernel..." -ForegroundColor Yellow

# This creates a minimal binary that writes to VGA and halts
# It's not C code, but proves the bootloader can jump to kernel space
$kernelBytes = @(
    # Write "KERNEL!" to VGA buffer at 0xB8000
    0x48, 0xC7, 0xC0, 0x00, 0x80, 0x0B, 0x00,  # mov rax, 0xB8000
    0xC6, 0x00, 0x4B,                            # mov byte [rax], 'K'  
    0xC6, 0x40, 0x01, 0x0F,                      # mov byte [rax+1], 0x0F
    0xC6, 0x40, 0x02, 0x45,                      # mov byte [rax+2], 'E'
    0xC6, 0x40, 0x03, 0x0F,                      # mov byte [rax+3], 0x0F
    0xC6, 0x40, 0x04, 0x52,                      # mov byte [rax+4], 'R'
    0xC6, 0x40, 0x05, 0x0F,                      # mov byte [rax+5], 0x0F
    0xC6, 0x40, 0x06, 0x4E,                      # mov byte [rax+6], 'N'
    0xC6, 0x40, 0x07, 0x0F,                      # mov byte [rax+7], 0x0F
    0xC6, 0x40, 0x08, 0x45,                      # mov byte [rax+8], 'E'
    0xC6, 0x40, 0x09, 0x0F,                      # mov byte [rax+9], 0x0F
    0xC6, 0x40, 0x0A, 0x4C,                      # mov byte [rax+10], 'L'
    0xC6, 0x40, 0x0B, 0x0F,                      # mov byte [rax+11], 0x0F
    0xC6, 0x40, 0x0C, 0x21,                      # mov byte [rax+12], '!'
    0xC6, 0x40, 0x0D, 0x0F,                      # mov byte [rax+13], 0x0F
    0xF4,                                         # hlt
    0xEB, 0xFD                                    # jmp -3 (infinite loop)
)

# Write kernel bytes to file
$kernelPath = Join-Path $projectDir "build\kernel.bin"
[System.IO.File]::WriteAllBytes($kernelPath, $kernelBytes)

# Create disk image
Write-Host "Creating disk image..." -ForegroundColor Yellow
$imgPath = Join-Path $projectDir "build\rylo_simple.img"
$stage1Path = Join-Path $projectDir "build\stage1.bin"
$stage2Path = Join-Path $projectDir "build\stage2.bin"

dd if=/dev/zero of="$imgPath" bs=1024 count=2048 2>$null
dd if="$stage1Path" of="$imgPath" conv=notrunc 2>$null  
dd if="$stage2Path" of="$imgPath" bs=512 seek=1 conv=notrunc 2>$null
dd if="$kernelPath" of="$imgPath" bs=512 seek=36 conv=notrunc 2>$null

Write-Host "Build complete! Test with:" -ForegroundColor Green
Write-Host "qemu-system-x86_64 -drive file=`"$imgPath`",format=raw -m 128M" -ForegroundColor Cyan
