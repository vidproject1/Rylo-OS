; Rylo OS Stage 2 Bootloader - 64-bit LBA (Final Version)
; This version uses modern LBA reads for loading the kernel.

org 0x7e00
bits 16

KERNEL_LBA_START equ 42     ; Kernel starts at LBA 42 (after Stage 2)
KERNEL_SECTORS   equ 8      ; How many sectors to read for the kernel

stage2_start:
    mov si, stage2_banner
    call print_string
    
    call enable_a20_fast
    mov si, a20_msg
    call print_string
    
    ; Use modern LBA to load the kernel
    call load_kernel_lba
    mov si, kernel_loaded_msg
    call print_string
    
    call check_long_mode
    mov si, cpu64_msg
    call print_string
    
    lgdt [gdt_descriptor]
    mov si, gdt_msg  
    call print_string
    
    cli
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:protected_mode_32

; --- 16-Bit Functions ---
print_string:
    pusha
    mov ah, 0x0e
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

enable_a20_fast:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret

load_kernel_lba:
    ; Load kernel using BIOS extended disk services (LBA)
    mov si, dap         ; Point SI to the Disk Address Packet
    mov ah, 0x42        ; Extended read function
    mov dl, 0x80        ; Drive number
    int 0x13
    jc disk_error
    ret

disk_error:
    mov si, error_msg
    call print_string
    hlt

check_long_mode:
    pushfd
    pop eax
    mov ecx, eax
    xor eax, 1 << 21
    push eax
    popfd
    pushfd
    pop eax
    cmp eax, ecx
    je no_long_mode
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz no_long_mode
    ret

no_long_mode:
    mov si, no64_msg
    call print_string
    hlt

; --- 32-Bit Protected Mode (Intermediate) ---
bits 32
protected_mode_32:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x7c00
    call setup_page_tables
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax
    mov eax, pml4_table
    mov cr3, eax
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax
    jmp 0x18:long_mode_64

setup_page_tables:
    mov edi, pml4_table
    mov ecx, 4096 * 4 / 4
    xor eax, eax
    rep stosd
    mov eax, pdp_table
    or eax, 3
    mov [pml4_table], eax
    mov eax, pd_table
    or eax, 3
    mov [pdp_table], eax
    mov edi, pd_table
    mov eax, 0x83
    mov ecx, 1024
.map_pd:
    mov [edi], eax
    add eax, 0x200000
    add edi, 8
    loop .map_pd
    ret

; --- 64-Bit Long Mode ---
bits 64
long_mode_64:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov rsp, 0x90000
    
    mov rax, 0xB8000
    mov byte [rax+0], '6'
    mov byte [rax+1], 0x0C
    mov byte [rax+2], '4'
    mov byte [rax+3], 0x0E
    mov byte [rax+4], 'B'
    mov byte [rax+5], 0x0A
    mov byte [rax+6], 'I'
    mov byte [rax+7], 0x0B
    mov byte [rax+8], 'T'
    mov byte [rax+9], 0x0D
    mov byte [rax+10], '!'
    mov byte [rax+11], 0x0F

    mov rsi, 0x20000
    mov rdi, 0x100000
    mov rcx, KERNEL_SECTORS * 512
    rep movsb
    
    ; === JUMP TO 64-BIT KERNEL (Absolute Jump) ===
    mov rax, 0x100000   ; Load kernel address into register
    call rax            ; Call the address in the register
    
infinite_loop:
    hlt
    jmp infinite_loop

; --- Data Section ---
bits 16
gdt_start:
    ; Null descriptor
    dq 0
    ; 32-bit Code Segment (for protected mode transition)
    dw 0xFFFF       ; Limit
    dw 0x0000       ; Base
    db 0x00         ; Base
    db 0x9A         ; Access (present, ring 0, code, execute/read)
    db 0xCF         ; Flags (4K granularity, 32-bit)
    db 0x00         ; Base
    ; 32-bit Data Segment
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x92         ; Access (present, ring 0, data, read/write)
    db 0xCF
    db 0x00
    ; 64-bit Code Segment (for long mode)
    dw 0x0000       ; Limit (ignored)
    dw 0x0000       ; Base (ignored)
    db 0x00         ; Base (ignored)
    db 0x9A         ; Access (present, ring 0, code, execute/read)
    db 0x20         ; Flags (L-bit for 64-bit)
    db 0x00         ; Base (ignored)
    ; 64-bit Data Segment
    dw 0x0000
    dw 0x0000
    db 0x00
    db 0x92
    db 0x00
    db 0x00
gdt_end:
gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

dap: ; Disk Address Packet for LBA kernel load
    db 0x10
    db 0
    dw KERNEL_SECTORS
    dw 0x0000           ; Destination Offset (temp buffer)
    dw 0x2000           ; Destination Segment (0x20000 linear)
    dq KERNEL_LBA_START ; Starting LBA sector

stage2_banner    db 'Stage2', 0
a20_msg         db 'A20', 0
kernel_loaded_msg db 'Kernel', 0
cpu64_msg       db '64CPU', 0
gdt_msg         db 'GDT', 0
error_msg       db 'ERR', 0
no64_msg        db 'No64bit', 0

; === Page Tables (must be 4k-aligned) ===
align 4096
pml4_table:     times 512 dq 0
pdp_table:      times 512 dq 0
pd_table:       times 512 dq 0

