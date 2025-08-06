# Rylo OS Development Environment Setup (Windows)

## Overview
This guide sets up a complete OS development environment on Windows for building Rylo OS from scratch.

## Required Tools

### 1. **MSYS2** (Package Manager & Unix-like Environment)
**Why**: Provides cross-compiler toolchain and Unix tools on Windows  
**Download**: https://www.msys2.org/  
**Install**: Run installer, follow default options

### 2. **Cross-Compiler Toolchain**
**Components**:
- `x86_64-elf-gcc` (C compiler targeting x86-64)
- `x86_64-elf-ld` (Linker)
- `x86_64-elf-objcopy` (Binary utilities)
- `x86_64-elf-gdb` (Debugger)

### 3. **NASM** (Netwide Assembler)
**Purpose**: Assembly language compiler for bootloader
**Version**: Latest stable

### 4. **QEMU** (System Emulator)
**Purpose**: Testing environment for OS
**Components**: qemu-system-x86_64

### 5. **Make** (Build Automation)
**Purpose**: Automated build system

## Installation Steps

### Step 1: Install MSYS2
1. Download MSYS2 installer from https://www.msys2.org/
2. Run installer with default settings
3. Launch MSYS2 terminal
4. Update package database:
   ```bash
   pacman -Syu
   ```

### Step 2: Install Development Tools via MSYS2
Open MSYS2 terminal and run:
```bash
# Update system
pacman -Syu

# Install base development tools
pacman -S base-devel

# Install cross-compiler toolchain
pacman -S mingw-w64-x86_64-gcc
pacman -S mingw-w64-x86_64-binutils
pacman -S mingw-w64-x86_64-gdb

# Install NASM
pacman -S nasm

# Install Make
pacman -S make

# Install QEMU
pacman -S mingw-w64-x86_64-qemu
```

### Step 3: Alternative - Direct Downloads (if MSYS2 issues)
If MSYS2 has problems, download directly:

**NASM**:
- Download: https://www.nasm.us/pub/nasm/releasebuilds/
- Install to: `C:\nasm\`
- Add to PATH: `C:\nasm`

**QEMU**:
- Download: https://www.qemu.org/download/#windows
- Install to: `C:\Program Files\qemu\`
- Add to PATH: `C:\Program Files\qemu`

**Cross-Compiler**:
- Download pre-built: http://crossgcc.rts-software.org/doku.php
- Extract to: `C:\cross-compiler\`
- Add to PATH: `C:\cross-compiler\bin`

### Step 4: Verify Installation
Run these commands in PowerShell/CMD:
```bash
# Check NASM
nasm --version

# Check QEMU
qemu-system-x86_64 --version

# Check cross-compiler
x86_64-elf-gcc --version

# Check make
make --version

# Check GDB
x86_64-elf-gdb --version
```

## PATH Configuration

Add these to Windows PATH environment variable:
- MSYS2: `C:\msys64\mingw64\bin`
- MSYS2 Unix tools: `C:\msys64\usr\bin`
- Or direct installs as listed above

## Verification Test

### Create Test Assembly File
```assembly
; test.asm
org 0x7c00
bits 16

start:
    mov ah, 0x0e
    mov al, 'H'
    int 0x10
    mov al, 'i'
    int 0x10
    
hang:
    jmp hang

times 510-($-$$) db 0
dw 0xaa55
```

### Build and Test
```bash
# Assemble
nasm -f bin test.asm -o test.bin

# Create disk image
qemu-img create test.img 1M
dd if=test.bin of=test.img conv=notrunc

# Test in QEMU
qemu-system-x86_64 -drive file=test.img,format=raw
```

Should display "Hi" and hang - confirms bootloader basics work!

## Troubleshooting

### Common Issues
1. **PATH not found**: Restart PowerShell after PATH changes
2. **MSYS2 conflicts**: Use separate terminal for MSYS2 vs PowerShell
3. **Cross-compiler missing**: May need manual cross-compiler build
4. **QEMU graphics**: Use `-nographic` flag if display issues

### Alternative Solutions
- **WSL2**: Install Linux subsystem with native tools
- **Docker**: Use pre-configured OS development container
- **Virtual Machine**: Linux VM with development tools

## Next Steps After Installation
1. [ ] Verify all tools work with test build
2. [ ] Create build scripts for Rylo OS
3. [ ] Configure QEMU debugging setup
4. [ ] Test bootloader compilation
5. [ ] Document any Windows-specific configurations

---
*Complete this setup before proceeding to Phase 1*
