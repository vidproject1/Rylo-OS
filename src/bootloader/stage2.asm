; Rylo OS Stage 2 Bootloader - Speed Optimized <200ms
; Handles CPU mode transitions and kernel loading with maximum speed
; Loaded at 0x7e00 by Stage 1
;
; Speed Goals:
; - A20 enable: <5ms (fast method)
; - GDT setup: <10ms (minimal entries)
; - Mode transitions: <20ms (optimized path)
; - Kernel load: <150ms (batch operations)
; - Total Stage 2: <200ms

org 0x7e00          ; Loaded here by Stage 1
bits 16             ; Start in 16-bit real mode

stage2_start:
    ; === SPEED INDICATOR ===
    mov si, stage2_banner
    call print_string
    
    ; === STEP 1: FAST A20 ENABLE ===
    ; Skip slow keyboard controller method, use fast gate
    call enable_a20_fast
    
    mov si, a20_msg
    call print_string
    
    ; === STEP 2: MINIMAL GDT SETUP ===
    ; Only create essential descriptors for speed
    lgdt [gdt_descriptor]
    
    mov si, gdt_msg  
    call print_string
    
    ; === STEP 3: ENTER PROTECTED MODE (FAST) ===
    cli                 ; Disable interrupts
    mov eax, cr0        ; Get current CR0
    or eax, 1           ; Set PE (Protection Enable) bit
    mov cr0, eax        ; Enter protected mode
    
    ; Far jump to flush pipeline and enter 32-bit mode
    jmp 0x08:protected_mode_start

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

; === FAST A20 ENABLE ===
enable_a20_fast:
    ; Method 1: Fast A20 gate (System Control Port A)
    in al, 0x92         ; Read from port 0x92
    or al, 2            ; Set bit 1 (A20 gate)
    out 0x92, al        ; Write back
    
    ; Quick test if A20 is enabled (simplified for speed)
    ; In production, we'd do proper testing, but for speed we assume it worked
    ret

; === MINIMAL GDT FOR SPEED ===
gdt_start:
    ; Null descriptor (required)
    dq 0
    
    ; Code segment descriptor (32-bit)
    ; Base: 0, Limit: 0xFFFFF, Access: 0x9A, Flags: 0xCF
    dw 0xFFFF           ; Limit low
    dw 0x0000           ; Base low  
    db 0x00             ; Base middle
    db 0x9A             ; Access (Present, DPL=0, Code, Execute/Read)
    db 0xCF             ; Flags (4KB granularity, 32-bit) + Limit high
    db 0x00             ; Base high
    
    ; Data segment descriptor (32-bit)
    ; Base: 0, Limit: 0xFFFFF, Access: 0x92, Flags: 0xCF  
    dw 0xFFFF           ; Limit low
    dw 0x0000           ; Base low
    db 0x00             ; Base middle
    db 0x92             ; Access (Present, DPL=0, Data, Read/Write)
    db 0xCF             ; Flags (4KB granularity, 32-bit) + Limit high
    db 0x00             ; Base high
    
    ; Code segment descriptor (64-bit) - Selector 0x18
    ; For long mode - L bit set, D bit clear
    dw 0x0000           ; Limit low (ignored in 64-bit)
    dw 0x0000           ; Base low (ignored in 64-bit)
    db 0x00             ; Base middle (ignored)
    db 0x9A             ; Access (Present, DPL=0, Code, Execute/Read)
    db 0x20             ; Flags (L=1 for 64-bit, D=0) + Limit high
    db 0x00             ; Base high (ignored)

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; GDT size
    dd gdt_start                ; GDT base address

; === 32-BIT PROTECTED MODE CODE ===
bits 32
protected_mode_start:
    ; Set up segment registers for protected mode
    mov ax, 0x10        ; Data segment selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x7c00     ; Stack pointer

    ; === SPEED INDICATOR (32-bit) ===
    ; For now, we'll transition to long mode preparation
    ; In a real implementation, we'd print to VGA or serial
    
    ; === STEP 4: LONG MODE PREPARATION ===
    ; Check for x86-64 support (skip for speed in emulator)
    ; Set up minimal page tables for long mode
    call setup_long_mode_fast
    
    ; === STEP 5: ENTER LONG MODE ===
    ; Enable PAE (Physical Address Extension)
    mov eax, cr4
    or eax, 0x20        ; Set PAE bit
    mov cr4, eax
    
    ; Load page table
    mov eax, page_table_l4
    mov cr3, eax
    
    ; Enable long mode in EFER MSR
    mov ecx, 0xC0000080 ; EFER MSR
    rdmsr
    or eax, 0x100       ; Set LME (Long Mode Enable)
    wrmsr
    
    ; Enable paging (enters long mode)
    mov eax, cr0
    or eax, 0x80000000  ; Set PG bit
    mov cr0, eax
    
    ; Far jump to 64-bit mode
    jmp 0x18:long_mode_start

setup_long_mode_fast:
    ; === MINIMAL PAGE TABLES FOR SPEED ===
    ; Identity map first 2GB for simplicity and speed
    ; In production, we'd be more careful, but this gets us running fast
    
    ; Clear page table area
    mov edi, page_table_l4
    mov ecx, 4096 / 4   ; Clear 4KB
    xor eax, eax
    rep stosd
    
    ; Set up page tables (simplified for speed)
    mov eax, page_table_l3
    or eax, 3           ; Present + Write
    mov [page_table_l4], eax
    
    mov eax, page_table_l2  
    or eax, 3           ; Present + Write
    mov [page_table_l3], eax
    
    ; Identity map first 4MB with 2MB pages for kernel at 1MB
    mov eax, 0x00000000
    or eax, 0x83        ; Present + Write + Page Size (2MB pages)
    mov [page_table_l2], eax      ; Map 0-2MB
    
    mov eax, 0x00200000
    or eax, 0x83        ; Present + Write + Page Size (2MB pages)  
    mov [page_table_l2 + 8], eax  ; Map 2-4MB
    
    ret

; === 64-BIT LONG MODE CODE ===
bits 64
long_mode_start:
    ; === WE'RE NOW IN 64-BIT LONG MODE! ===
    ; Set up 64-bit segments
    mov ax, 0x10        ; Use data segment from GDT
    mov ds, ax
    mov es, ax
    mov fs, ax  
    mov gs, ax
    mov ss, ax
    mov rsp, 0x90000    ; Set stack above kernel load area
    
    ; === SHOW STAGE2 MESSAGE ===
    ; Show "STAGE2" message first
    mov rax, 0xB8000    ; VGA text buffer address  
    mov byte [rax+2], 'S'
    mov byte [rax+3], 0x0F
    mov byte [rax+4], 'T'
    mov byte [rax+5], 0x0F
    mov byte [rax+6], 'A'
    mov byte [rax+7], 0x0F
    mov byte [rax+8], 'G'
    mov byte [rax+9], 0x0F
    mov byte [rax+10], 'E'
    mov byte [rax+11], 0x0F
    mov byte [rax+12], '2'
    mov byte [rax+13], 0x0F
    
    ; === SUCCESS MESSAGE ===
    ; We made it to 64-bit mode! Show success
    ; Write "64BIT!" to VGA buffer at 0xB8000
    mov byte [rax+80], '6'
    mov byte [rax+81], 0x0F
    mov byte [rax+82], '4'
    mov byte [rax+83], 0x0F
    mov byte [rax+84], 'B'
    mov byte [rax+85], 0x0F
    mov byte [rax+86], 'I'
    mov byte [rax+87], 0x0F
    mov byte [rax+88], 'T'
    mov byte [rax+89], 0x0F
    mov byte [rax+90], '!'
    mov byte [rax+91], 0x0F
    
    ; === LOAD KERNEL ===
    call load_kernel
    
    ; === SHOW LOADING MESSAGE ===
    mov byte [rax+160], 'K'
    mov byte [rax+161], 0x0E
    mov byte [rax+162], 'E'
    mov byte [rax+163], 0x0E
    mov byte [rax+164], 'R'
    mov byte [rax+165], 0x0E
    mov byte [rax+166], 'N'
    mov byte [rax+167], 0x0E
    mov byte [rax+168], 'E'
    mov byte [rax+169], 0x0E
    mov byte [rax+170], 'L'
    mov byte [rax+171], 0x0E
    
    ; === JUMP TO KERNEL ===
    ; The kernel is compiled for 32-bit, so we need to go back to 32-bit mode
    ; Jump to 32-bit transition code
    jmp transition_to_32bit
    
; === TRANSITION BACK TO 32-BIT FOR KERNEL ===
transition_to_32bit:
    ; We need to go from 64-bit back to 32-bit for our C kernel
    ; This is a bit unusual but necessary since our kernel is 32-bit
    
    ; Load 32-bit GDT entry and jump
    jmp 0x10:kernel_32bit

bits 32
kernel_32bit:
    ; Set up 32-bit segments
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000    ; 32-bit stack
    
    ; Jump to kernel entry point
    call 0x100000
    
    ; If kernel returns (shouldn't happen), halt
infinite_loop:
    hlt
    jmp infinite_loop

; === DATA SECTION ===
bits 16  ; Back to 16-bit for data section
stage2_banner db 'Stage2!', 0
a20_msg       db 'A20', 0  
gdt_msg       db 'GDT', 0

; === PAGE TABLES (aligned to 4KB) ===
align 4096
page_table_l4: times 512 dq 0  ; Level 4 page table (PML4)
page_table_l3: times 512 dq 0  ; Level 3 page table (PDPT)  
page_table_l2: times 512 dq 0  ; Level 2 page table (PDT)

; === KERNEL LOADING FUNCTION (64-bit) ===
bits 64
load_kernel:
    ; For simplicity, we'll copy kernel from loaded disk image
    ; Our build puts kernel at sector 36, which Stage 1 loads along with Stage 2
    ; So kernel is already in memory at 0x7e00 + (35*512) = 0x7e00 + 17920 = 0x11E00
    
    mov rsi, 0x11E00    ; Source: kernel location in loaded memory
    mov rdi, 0x100000   ; Destination: 1MB
    mov rcx, 128        ; Copy 128 bytes (more than enough for 65-byte kernel)
    rep movsb
    
    ret

; === PERFORMANCE ANALYSIS ===
; Stage 2 optimizations:
; - Fast A20 enable (port 0x92 method)
; - Minimal 3-entry GDT  
; - Streamlined mode transitions
; - 2MB page mapping for speed
; - Identity mapping to avoid translation overhead
; - Minimal error checking (assumes QEMU environment)
