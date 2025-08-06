; Simple Stage 1 bootloader - loads Stage 2 only
org 0x7c00
bits 16

start:
    ; Set up segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    
    ; Display loading message
    mov si, loading_msg
    call print
    
    ; Load Stage 2 - just 2 sectors for now
    mov ah, 0x02        ; BIOS read sectors
    mov al, 2           ; Read 2 sectors only
    mov ch, 0           ; Cylinder 0
    mov cl, 2           ; Start from sector 2
    mov dh, 0           ; Head 0
    mov dl, 0x80        ; Drive 0x80
    mov bx, 0x7e00      ; Load to 0x7e00
    
    int 0x13            ; Call BIOS
    jc disk_error       ; Jump if error
    
    ; Show success and jump to Stage 2
    mov si, success_msg
    call print
    
    jmp 0x0000:0x7e00   ; Jump to Stage 2

disk_error:
    mov si, error_msg
    call print
    hlt

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

loading_msg db '*', 0
success_msg db '+', 0
error_msg   db 'ERR', 0

; Pad to boot sector size
times 510-($-$$) db 0
dw 0xaa55
