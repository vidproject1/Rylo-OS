; Debug Stage 1 - test just the loading part
org 0x7c00
bits 16

stage1_start:
    ; === SPEED OPTIMIZATION: Minimal setup ===
    cli                 ; Disable interrupts during setup
    
    ; Set up segments (minimal, fast)
    xor ax, ax          ; AX = 0
    mov ds, ax          ; Data segment = 0
    mov es, ax          ; Extra segment = 0
    mov ss, ax          ; Stack segment = 0
    mov sp, 0x7c00      ; Stack pointer (grows down from bootloader)
    
    sti                 ; Re-enable interrupts
    
    ; === VISUAL INDICATOR FOR YOUTUBE ===
    mov si, loading_msg
    call print_fast
    
    ; === TEST DISK LOAD ===
    ; Try to load 34 sectors
    
    mov ah, 0x02        ; BIOS read sectors function
    mov al, 34          ; Read 34 sectors
    mov ch, 0           ; Cylinder 0
    mov cl, 2           ; Start from sector 2 (after MBR)
    mov dh, 0           ; Head 0
    mov dl, 0x80        ; First hard disk
    mov bx, 0x7e00      ; Load Stage 2 to 0x7e00
    
    int 0x13            ; Call BIOS disk service
    jc disk_error       ; Jump if carry flag set (error)
    
    ; === SPEED SUCCESS INDICATOR ===
    mov si, stage2_msg
    call print_fast
    
    ; === DON'T JUMP TO STAGE 2 - JUST HALT ===
    mov si, halt_msg
    call print_fast
    
halt_loop:
    hlt
    jmp halt_loop
    
    ; === ULTRA-FAST PRINT FUNCTION ===
print_fast:
    pusha
    mov ah, 0x0e        ; BIOS teletype function
.loop:
    lodsb               ; Load byte from SI into AL
    test al, al         ; Check for null terminator
    jz .done            ; Jump if zero (end of string)
    int 0x10            ; Print character
    jmp .loop           ; Continue
.done:
    popa
    ret
    
    ; === ERROR HANDLING (minimal) ===
disk_error:
    mov si, error_msg
    call print_fast
    hlt                 ; Halt system
    
    ; === DATA SECTION (minimal strings for speed) ===
loading_msg db 'LOAD', 0
stage2_msg  db 'OK', 0  
halt_msg    db 'HALT', 0
error_msg   db 'ERR', 0

    ; === PADDING AND BOOT SIGNATURE ===
    times 510-($-$$) db 0   ; Pad to 510 bytes
    dw 0xaa55               ; Boot sector signature
