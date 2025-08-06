# Rylo OS Phase II Complete Build Script
# Builds Stage 1 bootloader, Stage 2 bootloader, C kernel, and creates disk image

param(
    [switch]$Clean,
    [switch]$Test,
    [switch]$Verbose
)

# Colors for output
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$Cyan = "Cyan"
$White = "White"

Write-Host "=== Rylo OS Phase II Build System ===" -ForegroundColor $Cyan
Write-Host "Building complete OS with bootloader + C kernel" -ForegroundColor $White
Write-Host ""

# Create build directory if it doesn't exist
if (-not (Test-Path "build")) {
    New-Item -ItemType Directory -Path "build" | Out-Null
}

# Clean build directory if requested
if ($Clean) {
    Write-Host "Cleaning build directory..." -ForegroundColor $Yellow
    Remove-Item "build\*" -Force -ErrorAction SilentlyContinue
}

# Step 1: Build Stage 1 Bootloader
Write-Host "Step 1: Building Stage 1 Bootloader..." -ForegroundColor $Green
nasm -f bin src\bootloader\stage1.asm -o build\stage1.bin

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Stage 1 build failed!" -ForegroundColor $Red
    exit 1
}

$stage1Size = (Get-Item "build\stage1.bin").Length
Write-Host "  Stage 1: $stage1Size bytes (should be 512)" -ForegroundColor $White

# Step 2: Build Stage 2 Bootloader (Phase II version)
Write-Host "Step 2: Building Stage 2 Bootloader (Phase II)..." -ForegroundColor $Green
nasm -f bin src\bootloader\stage2-phase2.asm -o build\stage2.bin

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Stage 2 build failed!" -ForegroundColor $Red
    exit 1
}

$stage2Size = (Get-Item "build\stage2.bin").Length
$stage2Sectors = [math]::Ceiling($stage2Size / 512)
Write-Host "  Stage 2: $stage2Size bytes ($stage2Sectors sectors)" -ForegroundColor $White

# Step 3: Compile C Kernel
Write-Host "Step 3: Building C Kernel..." -ForegroundColor $Green

# Compile kernel directly to binary using a different approach
# First, create a simple assembly wrapper that calls our C function
$asmWrapper = @"
[bits 32]
section .text
global _start
extern kernel_main

_start:
    call kernel_main
    ; Halt if kernel returns
    cli
    hlt
    jmp $
"@

# Write the wrapper to a file
$asmWrapper | Out-File -FilePath "build\kernel_entry.asm" -Encoding ASCII

# Assemble the wrapper
nasm -f win32 build\kernel_entry.asm -o build\kernel_entry.o

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Kernel entry assembly failed!" -ForegroundColor $Red
    exit 1
}

# Compile kernel.c to object file
gcc -m32 -c src\kernel\kernel.c -o build\kernel.o -ffreestanding -Wall -Wextra -nostdlib -fno-builtin -fno-stack-protector -fno-pie

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Kernel compilation failed!" -ForegroundColor $Red
    exit 1
}

# Link both object files and output raw binary
ld --oformat binary -Ttext 0x100000 build\kernel_entry.o build\kernel.o -o build\kernel.bin

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Kernel linking failed!" -ForegroundColor $Red
    exit 1
}

$kernelSize = (Get-Item "build\kernel.bin").Length
$kernelSectors = [math]::Ceiling($kernelSize / 512)
Write-Host "  Kernel: $kernelSize bytes ($kernelSectors sectors)" -ForegroundColor $White

# Step 4: Calculate sector layout
$totalStage2Sectors = 34  # Fixed allocation for Stage 2
$kernelStartSector = 1 + $totalStage2Sectors  # After MBR + Stage 2
Write-Host "  Sector layout:" -ForegroundColor $White
Write-Host "    MBR (Stage 1): Sector 0" -ForegroundColor $White
Write-Host "    Stage 2: Sectors 1-$totalStage2Sectors ($totalStage2Sectors sectors allocated)" -ForegroundColor $White
Write-Host "    Kernel: Sector $kernelStartSector+ ($kernelSectors sectors needed)" -ForegroundColor $White

# Step 5: Create disk image
Write-Host "Step 4: Creating disk image..." -ForegroundColor $Green

# Create 1MB empty disk image
$null = dd if=/dev/zero of=build\rylo_phase2.img bs=1024 count=1024 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create disk image!" -ForegroundColor $Red
    exit 1
}

# Write Stage 1 (MBR) to sector 0
$null = dd if=build\stage1.bin of=build\rylo_phase2.img conv=notrunc 2>$null

# Write Stage 2 starting at sector 1
$null = dd if=build\stage2.bin of=build\rylo_phase2.img bs=512 seek=1 conv=notrunc 2>$null

# Write Kernel starting at calculated sector
$null = dd if=build\kernel.bin of=build\rylo_phase2.img bs=512 seek=$kernelStartSector conv=notrunc 2>$null

Write-Host ""
Write-Host "=== Build Complete! ===" -ForegroundColor $Green
Write-Host "Disk image: build\rylo_phase2.img" -ForegroundColor $Cyan
Write-Host ""
Write-Host "To test:" -ForegroundColor $Yellow
Write-Host "  qemu-system-x86_64 -drive file=build\rylo_phase2.img,format=raw" -ForegroundColor $White
Write-Host ""

# Show what you should expect to see
Write-Host "Expected screen output:" -ForegroundColor $Cyan
Write-Host "1. Stage 1 will show: 'Rylo' 'Fast!'" -ForegroundColor $White
Write-Host "2. Stage 2 will show: 'Stage2' 'A20' 'Kernel' 'GDT'" -ForegroundColor $White
Write-Host "3. Protected mode will show: 'STAGE2' and '32BIT'" -ForegroundColor $White
Write-Host "4. C Kernel will clear screen and show colorful kernel messages" -ForegroundColor $White
Write-Host ""

# Test if requested
if ($Test) {
    Write-Host "Running QEMU test..." -ForegroundColor $Yellow
    qemu-system-x86_64 -drive file=build\rylo_phase2.img,format=raw
}
