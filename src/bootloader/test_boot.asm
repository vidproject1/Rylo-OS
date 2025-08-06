; Test Bootloader for Rylo OS Development Environment
; This is a simple bootloader that displays "Rylo OS!" to verify our tools work

org 0x7c00          ; Boot sector is loaded at 0x7c00
bits 16             ; 16-bit real mode

start:
    ; Clear screen and set up segment registers
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00  ; Stack grows downward from bootloader

    ; Print message using BIOS interrupts
    mov si, msg
    call print_string

    ; Infinite loop to hang system
hang:
    hlt             ; Halt CPU until interrupt
    jmp hang        ; Jump back to halt

; Print string function
; Input: SI points to null-terminated string
print_string:
    pusha           ; Save all registers
    mov ah, 0x0e    ; BIOS teletype function

.next_char:
    lodsb           ; Load byte from SI into AL, increment SI
    cmp al, 0       ; Check for null terminator
    je .done        ; Jump if end of string
    int 0x10        ; Call BIOS video interrupt
    jmp .next_char  ; Continue with next character

.done:
    popa            ; Restore all registers
    ret

; Data section
msg db 'Rylo OS Development Environment Working!', 13, 10
    db 'GCC 15.1.0, NASM 2.16.03, QEMU 10.0.2', 13, 10
    db 'Ready for bootloader development...', 13, 10, 0

; Pad to 510 bytes and add boot signature
times 510-($-$$) db 0
dw 0xaa55           ; Boot sector signature
