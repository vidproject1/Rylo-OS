# Run Rylo OS test bootloader in QEMU
Write-Host "Starting Rylo OS test in QEMU..." -ForegroundColor Green
Write-Host "Press Ctrl+Alt+G to release mouse, Alt+F4 to close" -ForegroundColor Yellow

# Run QEMU (this will open a graphical window)
qemu-system-x86_64 -drive file=build\rylo_test.img,format=raw -m 128M
