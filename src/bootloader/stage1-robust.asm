; Rylo OS Robust Stage 1 Bootloader (MBR)
; Loads a large Stage 2 by reading one sector at a time in a loop.

org 0x7c00
bits 16

; Constants
STAGE2_SECTORS  equ 41 ; Number of sectors for the 64-bit Stage 2

stage1_start:
    ; === MINIMAL SETUP ===
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax ; ES=0 for the disk read buffer
    mov ss, ax
    mov sp, 0x7c00
    sti
    
    ; === VISUAL INDICATOR ===
    mov si, loading_msg
    call print_fast

    ; === ROBUST STAGE 2 LOADING LOOP ===
    mov cx, STAGE2_SECTORS      ; Loop counter (41 sectors)
    
    ; Set up starting parameters for the read
    mov ax, 2                   ; Start reading from sector 2 (CHS is 1-based)
    mov [current_sector], ax
    mov bx, 0x7e00              ; Start loading at address 0x7e00

read_loop:
    ; Read one sector
    mov ah, 0x02                ; BIOS read function
    mov al, 1                   ; Read 1 sector
    mov ch, 0                   ; Cylinder 0
    mov cl, [current_sector]    ; Current sector to read
    mov dh, 0                   ; Head 0
    mov dl, 0x80                ; First hard disk
    ; ES:BX points to the current destination address
    int 0x13
    jc disk_error               ; If read fails, jump to error
    
    ; Print a dot for each sector read, for visual progress
    mov si, dot_msg
    call print_fast
    
    ; Advance buffer pointer for the next sector
    add bx, 512
    
    ; Advance sector number
    mov ax, [current_sector]
    inc ax
    mov [current_sector], ax

    dec cx                      ; Decrement loop counter
    jnz read_loop               ; If not zero, read next sector

    ; === SUCCESS INDICATOR ===
    mov si, stage2_msg
    call print_fast
    
    ; === JUMP TO STAGE 2 ===
    jmp 0x0000:0x7e00

print_fast:
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

disk_error:
    mov si, error_msg
    call print_fast
    hlt

; === DATA ===
loading_msg     db 'Rylo', 0
stage2_msg      db 'OK', 0
error_msg       db 'ERR', 0
dot_msg         db '.', 0
current_sector  dw 0
    
; === BOOT SIGNATURE ===
times 510-($-$$) db 0
dw 0xaa55

