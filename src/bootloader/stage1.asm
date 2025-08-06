; Rylo OS Stage 1 Bootloader (MBR) - Ultra Fast <50ms
; This is the Master Boot Record that loads Stage 2 as quickly as possible
; Goal: Minimize everything for maximum speed
;
; Memory Layout:
; 0x7c00 - 0x7dff : Stage 1 (this code) - 512 bytes
; 0x7e00 - 0x87ff : Stage 2 (loaded here) - 4KB max
; 0x8800+         : Available for kernel

org 0x7c00          ; BIOS loads us here
bits 16             ; Start in 16-bit real mode

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
    
    ; === SPEED OPTIMIZATION: Batch load Stage 2 ===
    ; Load 8 sectors (4KB) in one operation instead of multiple reads
    ; This is significantly faster than reading sector by sector
    
    mov ah, 0x02        ; BIOS read sectors function
    mov al, 8           ; Read 8 sectors (4KB) - entire Stage 2
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
    
    ; === LIGHTNING FAST JUMP TO STAGE 2 ===
    ; No delays, no additional checks - just jump
    jmp 0x0000:0x7e00   ; Far jump to Stage 2
    
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
loading_msg db 'Rylo', 0
stage2_msg  db 'Fast!', 0  
error_msg   db 'ERR', 0

    ; === PADDING AND BOOT SIGNATURE ===
    times 510-($-$$) db 0   ; Pad to 510 bytes
    dw 0xaa55               ; Boot sector signature

; === PERFORMANCE NOTES ===
; - Total code: ~60 bytes (lots of room for optimization)
; - Batch disk read: 8 sectors in single operation
; - Minimal string output for visual feedback
; - No unnecessary delays or complex error handling
; - Direct far jump to Stage 2 with zero overhead
