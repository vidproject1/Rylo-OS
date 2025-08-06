; Simple Stage 2 bootloader - just display message and halt
org 0x7e00
bits 16

stage2_start:
    ; Display message
    mov si, stage2_msg
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

stage2_msg db 'STAGE2!', 0

; Pad to make it at least 1024 bytes (2 sectors)
times 1024-($-$$) db 0
