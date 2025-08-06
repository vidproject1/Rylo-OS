# Rylo OS Development Environment Setup
# Sets up PATH and environment variables for OS development

Write-Host "Setting up Rylo OS development environment..." -ForegroundColor Green

# MSYS2 tool paths
$MSYS2_ROOT = "D:\msys64"
$GCC_PATH = "$MSYS2_ROOT\ucrt64\bin"
$UNIX_TOOLS = "$MSYS2_ROOT\usr\bin"  
$QEMU_PATH = "$MSYS2_ROOT\mingw64\bin"

# Add to PATH for this session
$env:PATH = "$GCC_PATH;$UNIX_TOOLS;$QEMU_PATH;" + $env:PATH

# OS Development specific settings
$env:RYLO_ROOT = $PWD
$env:RYLO_BUILD = "$env:RYLO_ROOT\build"
$env:RYLO_TOOLS = "$env:RYLO_ROOT\tools"

Write-Host "✓ GCC Path: $GCC_PATH" -ForegroundColor Yellow
Write-Host "✓ QEMU Path: $QEMU_PATH" -ForegroundColor Yellow  
Write-Host "✓ Unix Tools: $UNIX_TOOLS" -ForegroundColor Yellow
Write-Host "✓ Project Root: $env:RYLO_ROOT" -ForegroundColor Yellow

# Verify tools
Write-Host "`nVerifying tools..." -ForegroundColor Cyan
try {
    $gccVer = & gcc --version 2>$null | Select-Object -First 1
    Write-Host "✓ GCC: $gccVer" -ForegroundColor Green
} catch {
    Write-Host "✗ GCC not found" -ForegroundColor Red
}

try {
    $nasmVer = & nasm --version 2>$null
    Write-Host "✓ NASM: $nasmVer" -ForegroundColor Green  
} catch {
    Write-Host "✗ NASM not found" -ForegroundColor Red
}

try {
    $makeVer = & make --version 2>$null | Select-Object -First 1
    Write-Host "✓ Make: $makeVer" -ForegroundColor Green
} catch {
    Write-Host "✗ Make not found" -ForegroundColor Red  
}

try {
    $qemuVer = & qemu-system-x86_64 --version 2>$null | Select-Object -First 1
    Write-Host "✓ QEMU: $qemuVer" -ForegroundColor Green
} catch {
    Write-Host "✗ QEMU not found" -ForegroundColor Red
}

Write-Host "`nDevelopment environment ready! 🚀" -ForegroundColor Green
Write-Host "Use './tools/build.ps1' to build Rylo OS" -ForegroundColor Cyan
