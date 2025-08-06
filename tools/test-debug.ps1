# Debug test for Rylo OS bootloader
Write-Host "Testing bootloader with debug output..." -ForegroundColor Green
Write-Host "This will stay open so you can see what happens" -ForegroundColor Yellow

# Run QEMU with debug options and keep it open longer
qemu-system-x86_64 -drive file=build\rylo_boot.img,format=raw -m 128M -display gtk

Write-Host "QEMU finished. Press any key to continue..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
