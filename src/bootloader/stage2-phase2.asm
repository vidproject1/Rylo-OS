; Rylo OS Stage 2 Bootloader - Phase II (32-bit Protected Mode)
; Handles CPU mode transitions and kernel loading for Phase II
; Loaded at 0x7e00 by Stage 1
;
; Phase II Goals:
; - Enter 32-bit protected mode
; - Load C kernel from disk
; - Execute C kernel 
; - No 64-bit complexity yet

org 0x7e00          ; Loaded here by Stage 1
bits 16             ; Start in 16-bit real mode

stage2_start:
    ; === PHASE II INDICATOR ===
    mov si, stage2_banner
    call print_string
    
    ; === STEP 1: FAST A20 ENABLE ===
    call enable_a20_fast
    mov si, a20_msg
    call print_string
    
    ; === STEP 2: LOAD KERNEL FIRST (while in 16-bit mode) ===
    ; Load kernel from disk before switching to protected mode
    ; This is easier than doing disk I/O from protected mode
    call load_kernel_16bit
    mov si, kernel_loaded_msg
    call print_string
    
    ; === STEP 3: SETUP GDT ===
    lgdt [gdt_descriptor]
    mov si, gdt_msg  
    call print_string
    
    ; === STEP 4: ENTER PROTECTED MODE ===
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
    in al, 0x92         ; Read from port 0x92
    or al, 2            ; Set bit 1 (A20 gate)
    out 0x92, al        ; Write back
    ret

; === LOAD KERNEL FROM DISK (16-bit BIOS) ===
load_kernel_16bit:
    ; Load kernel from disk sectors (starting after Stage 2)
    ; Kernel starts at sector 2 (sector 0 = MBR, sector 1 = Stage 2)
    ; Load to 0x20000 (128KB) temporarily, we'll copy to 1MB in 32-bit mode
    
    mov ah, 0x02        ; BIOS read sectors function
    mov al, 8           ; Read 8 sectors (4KB) - should be enough for our small kernel
    mov ch, 0           ; Cylinder 0
    mov cl, 3           ; Start from sector 3 (BIOS sectors start from 1: sector 1=MBR, 2=Stage2, 3=Kernel)
    mov dh, 0           ; Head 0
    mov dl, 0x80        ; First hard disk
    mov ax, 0x2000      ; Load to 0x2000:0000 (which = 0x20000 = 128KB)
    mov es, ax
    mov bx, 0
    
    int 0x13            ; Call BIOS disk service
    jc disk_error       ; Jump if carry flag set (error)
    ret

disk_error:
    mov si, error_msg
    call print_string
    hlt

; === MINIMAL GDT FOR 32-BIT ===
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
    mov esp, 0x90000     ; Stack pointer (above kernel area)

    ; === SHOW SUCCESS MESSAGE IN VGA ===
    ; Show "STAGE2" in VGA text mode
    mov edi, 0xB8000    ; VGA text buffer address
    mov al, 'S'
    mov ah, 0x0F        ; White on black
    mov [edi+0], ax
    mov al, 'T'
    mov [edi+2], ax
    mov al, 'A'
    mov [edi+4], ax
    mov al, 'G'
    mov [edi+6], ax
    mov al, 'E'
    mov [edi+8], ax
    mov al, '2'
    mov [edi+10], ax
    
    ; Show "32BIT" on next line
    mov al, '3'
    mov ah, 0x0A        ; Light green
    mov [edi+160], ax   ; Next line (80*2 = 160 bytes down)
    mov al, '2'
    mov [edi+162], ax
    mov al, 'B'
    mov [edi+164], ax
    mov al, 'I'
    mov [edi+166], ax
    mov al, 'T'
    mov [edi+168], ax
    
    ; === COPY KERNEL TO FINAL LOCATION ===
    ; Copy kernel from 0x20000 (temp location) to 0x100000 (final location)
    mov esi, 0x20000    ; Source: temporary kernel location
    mov edi, 0x100000   ; Destination: 1MB (final kernel location)
    mov ecx, 4096       ; Copy 4KB (8 sectors * 512 bytes)
    rep movsb           ; Copy byte by byte
    
    ; === JUMP TO KERNEL ===
    ; Call the kernel entry point at 0x100000
    call 0x100000
    
    ; If kernel returns (shouldn't happen), halt
infinite_loop:
    hlt
    jmp infinite_loop

; === DATA SECTION ===
bits 16  ; Back to 16-bit for data section
stage2_banner    db 'Stage2', 0
a20_msg         db 'A20', 0  
gdt_msg         db 'GDT', 0
kernel_loaded_msg db 'Kernel', 0
error_msg       db 'ERR', 0
