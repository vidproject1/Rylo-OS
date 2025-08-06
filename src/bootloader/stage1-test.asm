; Minimal test bootloader - just display message and halt
org 0x7c00
bits 16

start:
    ; Set up segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    
    ; Display message
    mov si, msg
    call print
    
    ; Halt forever
halt_loop:
    hlt
    jmp halt_loop

print:
    mov ah, 0x0e
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

msg db 'RYLO TEST!', 0

; Pad to boot sector size
times 510-($-$$) db 0
dw 0xaa55
