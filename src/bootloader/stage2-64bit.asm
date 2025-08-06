; Rylo OS Stage 2 Bootloader - 64-bit Long Mode
; Transitions: Real Mode → 32-bit Protected Mode → 64-bit Long Mode
; Supports unlimited RAM (well, up to 256TB practically)

org 0x7e00
bits 16

stage2_start:
    ; === PHASE II INDICATOR ===
    mov si, stage2_banner
    call print_string
    
    ; === STEP 1: FAST A20 ENABLE ===
    call enable_a20_fast
    mov si, a20_msg
    call print_string
    
    ; === STEP 2: LOAD KERNEL (while in 16-bit mode) ===
    call load_kernel_16bit
    mov si, kernel_loaded_msg
    call print_string
    
    ; === STEP 3: CHECK 64-BIT SUPPORT ===
    call check_long_mode
    mov si, cpu64_msg
    call print_string
    
    ; === STEP 4: SETUP GDT FOR LONG MODE ===
    lgdt [gdt_descriptor]
    mov si, gdt_msg  
    call print_string
    
    ; === STEP 5: ENTER 32-BIT PROTECTED MODE (intermediate step) ===
    cli
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:protected_mode_32

; === 16-BIT FUNCTIONS ===
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

load_kernel_16bit:
    mov ah, 0x02
    mov al, 8
    mov ch, 0
    mov cl, 42          ; Kernel starts at sector 42 (after 41 sectors of Stage 2)
    mov dh, 0
    mov dl, 0x80
    mov ax, 0x2000      ; Load to 0x20000 temporarily
    mov es, ax
    mov bx, 0
    int 0x13
    jc disk_error
    ret

disk_error:
    mov si, error_msg
    call print_string
    hlt

check_long_mode:
    ; Check if CPUID is supported
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
    
    ; Check if long mode is available
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb no_long_mode
    
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29   ; Check LM bit
    jz no_long_mode
    ret

no_long_mode:
    mov si, no64_msg
    call print_string
    hlt

; === 32-BIT PROTECTED MODE (Intermediate) ===
bits 32
protected_mode_32:
    ; Set up segments
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x7c00

    ; === SETUP PAGING FOR LONG MODE ===
    call setup_page_tables
    
    ; === ENTER LONG MODE ===
    ; Enable PAE (Physical Address Extension)
    mov eax, cr4
    or eax, 1 << 5      ; Set PAE bit
    mov cr4, eax
    
    ; Load PML4 (Page Map Level 4)
    mov eax, pml4_table
    mov cr3, eax
    
    ; Enable long mode in EFER MSR
    mov ecx, 0xC0000080 ; EFER MSR
    rdmsr
    or eax, 1 << 8      ; Set LME (Long Mode Enable)
    wrmsr
    
    ; Enable paging (this activates long mode)
    mov eax, cr0
    or eax, 1 << 31     ; Set PG bit
    mov cr0, eax
    
    ; Jump to 64-bit code segment
    jmp 0x18:long_mode_64

setup_page_tables:
    ; Clear page table area
    mov edi, pml4_table
    mov ecx, 4096 * 4 / 4  ; Clear 4 pages (16KB)
    xor eax, eax
    rep stosd
    
    ; Set up page tables for identity mapping of first 2GB
    ; PML4[0] -> PDP
    mov eax, pdp_table
    or eax, 3           ; Present + Write
    mov [pml4_table], eax
    
    ; PDP[0] -> PD
    mov eax, pd_table
    or eax, 3
    mov [pdp_table], eax
    
    ; PD entries -> 2MB pages
    mov edi, pd_table
    mov eax, 0x83       ; Present + Write + Page Size (2MB pages)
    mov ecx, 1024       ; 1024 entries = 2GB
.map_pd:
    mov [edi], eax
    add eax, 0x200000   ; Next 2MB page
    add edi, 8
    loop .map_pd
    
    ret

; === 64-BIT LONG MODE ===
bits 64
long_mode_64:
    ; === WE'RE NOW IN 64-BIT LONG MODE! ===
    ; Set up segments (most are ignored in long mode)
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov rsp, 0x90000    ; 64-bit stack pointer
    
    ; === SHOW SUCCESS MESSAGE ===
    mov rax, 0xB8000    ; VGA text buffer
    
    ; Show "64BIT!" in bright colors
    mov byte [rax+0], '6'
    mov byte [rax+1], 0x0C   ; Light red
    mov byte [rax+2], '4'
    mov byte [rax+3], 0x0E   ; Yellow
    mov byte [rax+4], 'B'
    mov byte [rax+5], 0x0A   ; Light green  
    mov byte [rax+6], 'I'
    mov byte [rax+7], 0x0B   ; Light cyan
    mov byte [rax+8], 'T'
    mov byte [rax+9], 0x0D   ; Light magenta
    mov byte [rax+10], '!'
    mov byte [rax+11], 0x0F  ; White
    
    ; Show "LONG MODE" on next line
    mov byte [rax+160], 'L'
    mov byte [rax+161], 0x0A ; Light green
    mov byte [rax+162], 'O'
    mov byte [rax+163], 0x0A
    mov byte [rax+164], 'N'
    mov byte [rax+165], 0x0A
    mov byte [rax+166], 'G'
    mov byte [rax+167], 0x0A
    mov byte [rax+168], ' '
    mov byte [rax+169], 0x0F
    mov byte [rax+170], 'M'
    mov byte [rax+171], 0x0E
    mov byte [rax+172], 'O'
    mov byte [rax+173], 0x0E
    mov byte [rax+174], 'D'
    mov byte [rax+175], 0x0E
    mov byte [rax+176], 'E'
    mov byte [rax+177], 0x0E
    
    ; === COPY KERNEL TO FINAL LOCATION ===
    mov rsi, 0x20000    ; Source: temporary location
    mov rdi, 0x100000   ; Destination: 1MB
    mov rcx, 4096       ; Copy 4KB
    rep movsb
    
    ; === JUMP TO 64-BIT KERNEL ===
    call 0x100000
    
    ; If kernel returns, halt
infinite_loop:
    hlt
    jmp infinite_loop

; === GDT FOR 64-BIT ===
bits 16  ; Back to 16-bit for data
gdt_start:
    ; Null descriptor
    dq 0
    
    ; 32-bit code segment (for intermediate step)
    dw 0xFFFF, 0x0000
    db 0x00, 0x9A, 0xCF, 0x00
    
    ; 32-bit data segment
    dw 0xFFFF, 0x0000  
    db 0x00, 0x92, 0xCF, 0x00
    
    ; 64-bit code segment
    dw 0x0000, 0x0000
    db 0x00, 0x9A, 0x20, 0x00  ; L=1, D=0 for 64-bit
    
    ; 64-bit data segment (mostly unused in long mode)
    dw 0x0000, 0x0000
    db 0x00, 0x92, 0x00, 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; === DATA ===
stage2_banner    db 'Stage2', 0
a20_msg         db 'A20', 0
kernel_loaded_msg db 'Kernel', 0
cpu64_msg       db '64CPU', 0
gdt_msg         db 'GDT', 0
error_msg       db 'ERR', 0
no64_msg        db 'No64bit', 0

; === PAGE TABLES (16KB aligned) ===
align 4096
pml4_table:     times 512 dq 0    ; Page Map Level 4
pdp_table:      times 512 dq 0    ; Page Directory Pointer  
pd_table:       times 512 dq 0    ; Page Directory
pt_table:       times 512 dq 0    ; Page Table (unused for 2MB pages)
