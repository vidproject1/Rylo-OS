# Rylo OS Phase II Simple Build Script
# Builds bootloader with assembly test kernel to prove Phase II works

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

Write-Host "=== Rylo OS Phase II Build System (Simple) ===" -ForegroundColor $Cyan
Write-Host "Building bootloader + assembly test kernel" -ForegroundColor $White
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
Write-Host "  Stage 1: $stage1Size bytes" -ForegroundColor $White

# Step 2: Build Stage 2 Bootloader
Write-Host "Step 2: Building Stage 2 Bootloader..." -ForegroundColor $Green
nasm -f bin src\bootloader\stage2-phase2.asm -o build\stage2.bin

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Stage 2 build failed!" -ForegroundColor $Red
    exit 1
}

$stage2Size = (Get-Item "build\stage2.bin").Length
$stage2Sectors = [math]::Ceiling($stage2Size / 512)
Write-Host "  Stage 2: $stage2Size bytes ($stage2Sectors sectors)" -ForegroundColor $White

# Step 3: Build Test Kernel (Assembly)
Write-Host "Step 3: Building Test Kernel (Assembly)..." -ForegroundColor $Green
nasm -f bin src\kernel\test_kernel.asm -o build\kernel.bin

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Kernel build failed!" -ForegroundColor $Red
    exit 1
}

$kernelSize = (Get-Item "build\kernel.bin").Length
$kernelSectors = [math]::Ceiling($kernelSize / 512)
Write-Host "  Kernel: $kernelSize bytes ($kernelSectors sectors)" -ForegroundColor $White

# Step 4: Calculate sector layout - corrected for actual sizes
$kernelStartSector = 2  # Kernel right after Stage 1 (sector 0) and Stage 2 (sector 1)
Write-Host "  Sector layout:" -ForegroundColor $White
Write-Host "    MBR (Stage 1): Sector 0 (512 bytes)" -ForegroundColor $White
Write-Host "    Stage 2: Sector 1 (293 bytes, 1 sector)" -ForegroundColor $White
Write-Host "    Kernel: Sector $kernelStartSector+ ($kernelSectors sectors)" -ForegroundColor $White

# Step 5: Create disk image
Write-Host "Step 5: Creating disk image..." -ForegroundColor $Green

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
Write-Host "1. Text mode: 'Rylo' 'Fast!' 'Stage2' 'A20' 'Kernel' 'GDT'" -ForegroundColor $White
Write-Host "2. VGA mode: 'STAGE2' and '32BIT' messages" -ForegroundColor $White
Write-Host "3. Kernel clears screen and shows:" -ForegroundColor $White
Write-Host "   - 'KERNEL!' in green" -ForegroundColor $White
Write-Host "   - 'RYLO OS' in red/white/blue" -ForegroundColor $White
Write-Host "   - 'PHASE 2 COMPLETE!' in yellow/green" -ForegroundColor $White
Write-Host "   - '32-bit kernel running!' in various colors" -ForegroundColor $White
Write-Host ""

# Test if requested
if ($Test) {
    Write-Host "Running QEMU test..." -ForegroundColor $Yellow
    qemu-system-x86_64 -drive file=build\rylo_phase2.img,format=raw
}
