# Rylo OS 64-bit Build Script
# Builds the complete 64-bit operating system

param(
    [switch]$Clean,
    [switch]$Test
)

$Green = "Green"
$Yellow = "Yellow" 
$Red = "Red"
$Cyan = "Cyan"
$White = "White"

Write-Host "=== Rylo OS 64-bit Build System ===" -ForegroundColor $Cyan
Write-Host "Building complete 64-bit OS with unlimited RAM support" -ForegroundColor $White
Write-Host ""

# Create build directory
if (-not (Test-Path "build")) {
    New-Item -ItemType Directory -Path "build" | Out-Null
}

if ($Clean) {
    Write-Host "Cleaning build directory..." -ForegroundColor $Yellow
    Remove-Item "build\*" -Force -ErrorAction SilentlyContinue
}

# Step 1: Build LBA Stage 1 Bootloader
Write-Host "Step 1: Building LBA Stage 1 Bootloader..." -ForegroundColor $Green
nasm -f bin src\bootloader\stage1-lba.asm -o build\stage1.bin

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Stage 1 build failed!" -ForegroundColor $Red
    exit 1
}

$stage1Size = (Get-Item "build\stage1.bin").Length
Write-Host "  Stage 1: $stage1Size bytes" -ForegroundColor $White

# Step 2: Build 64-bit LBA Stage 2 Bootloader
Write-Host "Step 2: Building 64-bit LBA Stage 2 Bootloader..." -ForegroundColor $Green
nasm -f bin src\bootloader\stage2-64bit-lba.asm -o build\stage2.bin

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Stage 2 build failed!" -ForegroundColor $Red
    exit 1
}

$stage2Size = (Get-Item "build\stage2.bin").Length
$stage2Sectors = [math]::Ceiling($stage2Size / 512)
Write-Host "  Stage 2: $stage2Size bytes ($stage2Sectors sectors)" -ForegroundColor $White

# Step 3: Build 64-bit Test Kernel
Write-Host "Step 3: Building 64-bit Test Kernel..." -ForegroundColor $Green
nasm -f bin src\kernel\test_kernel_64.asm -o build\kernel.bin

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Kernel build failed!" -ForegroundColor $Red
    exit 1
}

$kernelSize = (Get-Item "build\kernel.bin").Length
$kernelSectors = [math]::Ceiling($kernelSize / 512)
Write-Host "  Kernel: $kernelSize bytes ($kernelSectors sectors)" -ForegroundColor $White

# Step 4: Sector Layout
$kernelStartSector = 1 + $stage2Sectors # Kernel starts right after Stage 2
Write-Host "  64-bit Disk Layout:" -ForegroundColor $White
Write-Host "    Sector 0: MBR (Stage 1) - 512 bytes" -ForegroundColor $White
Write-Host "    Sectors 1 to $($stage2Sectors): Stage 2 - $stage2Size bytes" -ForegroundColor $White
Write-Host "    Sector $kernelStartSector+: 64-bit Kernel - $kernelSize bytes" -ForegroundColor $White

# Step 5: Create 64-bit disk image
Write-Host "Step 5: Creating 64-bit disk image..." -ForegroundColor $Green

# Create disk image
$null = dd if=/dev/zero of=build\rylo_64bit.img bs=1024 count=1024 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create disk image!" -ForegroundColor $Red
    exit 1
}

# Write components to disk
$null = dd if=build\stage1.bin of=build\rylo_64bit.img conv=notrunc 2>$null
$null = dd if=build\stage2.bin of=build\rylo_64bit.img bs=512 seek=1 conv=notrunc 2>$null  
$null = dd if=build\kernel.bin of=build\rylo_64bit.img bs=512 seek=$kernelStartSector conv=notrunc 2>$null

Write-Host ""
Write-Host "=== 64-bit Build Complete! ===" -ForegroundColor $Green
Write-Host "Disk image: build\rylo_64bit.img" -ForegroundColor $Cyan
Write-Host ""
Write-Host "64-bit Features:" -ForegroundColor $Yellow
Write-Host "- Unlimited RAM access (no 4GB limit!)" -ForegroundColor $White
Write-Host "- 64-bit registers and pointers" -ForegroundColor $White  
Write-Host "- Long mode CPU operation" -ForegroundColor $White
Write-Host "- Modern x86-64 architecture" -ForegroundColor $White
Write-Host ""
Write-Host "To test:" -ForegroundColor $Yellow
Write-Host "  qemu-system-x86_64 -drive file=build\rylo_64bit.img,format=raw" -ForegroundColor $White
Write-Host ""

# Show expected output
Write-Host "Expected 64-bit screen output:" -ForegroundColor $Cyan
Write-Host "1. Text mode: 'Rylo' 'Fast!' 'Stage2' 'A20' 'Kernel' '64CPU' 'GDT'" -ForegroundColor $White
Write-Host "2. Brief VGA: '64BIT!' and 'LONG MODE' messages" -ForegroundColor $White
Write-Host "3. 64-bit Kernel displays:" -ForegroundColor $White
Write-Host "   - '64-BIT RYLO OS' in colorful text" -ForegroundColor $White
Write-Host "   - 'LONG MODE ACTIVE'" -ForegroundColor $White
Write-Host "   - 'UNLIMITED RAM ACCESS!'" -ForegroundColor $White
Write-Host "   - '64-BIT REGISTERS & POINTERS'" -ForegroundColor $White
Write-Host "   - 'PHASE II COMPLETE - 64BIT!'" -ForegroundColor $White
Write-Host ""

if ($Test) {
    Write-Host "Running 64-bit QEMU test..." -ForegroundColor $Yellow
    # -no-reboot and -no-shutdown prevent QEMU from closing or rebooting on a crash (triple fault)
    qemu-system-x86_64 -drive file=build\rylo_64bit.img,format=raw -no-reboot -no-shutdown
}
