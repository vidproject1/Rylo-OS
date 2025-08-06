; Rylo OS LBA Stage 1 Bootloader (MBR) - Final Version
; Loads a large Stage 2 using modern LBA disk reads, the most robust method.

org 0x7c00
bits 16

STAGE2_LBA_START equ 1      ; Stage 2 starts at LBA 1 (first sector after MBR)
STAGE2_SECTORS   equ 41     ; Number of sectors for the 64-bit Stage 2

stage1_start:
    ; === MINIMAL SETUP ===
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

    ; Check for extended disk services support (LBA)
    mov ah, 0x41
    mov bx, 0x55aa
    mov dl, 0x80 ; First hard disk
    int 0x13
    jc no_lba    ; If carry is set, no LBA support, fail

    ; === VISUAL INDICATOR ===
    mov si, loading_msg
    call print_fast

    ; === LBA STAGE 2 LOADING LOOP ===
    mov cx, STAGE2_SECTORS
    
    ; Set up the DAP (Disk Address Packet)
    ; Destination: 0x07e0:0000 which is linear address 0x7E00
    mov word [dap + 6], 0x07e0 ; Destination Segment
    mov word [dap + 4], 0      ; Destination Offset (starts at 0)
    mov dword [lba_start], STAGE2_LBA_START ; Starting LBA (sector)

read_loop:
    ; Prepare DAP for this iteration
    mov si, dap
    mov ah, 0x42 ; Extended read function
    mov dl, 0x80 ; Drive number
    int 0x13
    jc disk_error

    ; Print progress
    mov si, dot_msg
    call print_fast

    ; Advance destination offset in DAP for the next 512-byte sector
    mov ax, [dap + 4]
    add ax, 512
    mov [dap + 4], ax

    ; Advance LBA for the next sector
    inc dword [lba_start]

    dec cx
    jnz read_loop
    
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

no_lba:
    mov si, no_lba_msg
    call print_fast
    hlt

disk_error:
    mov si, error_msg
    call print_fast
    hlt

; --- Data Section ---
dap:
    db 0x10       ; Size of packet (16 bytes)
    db 0          ; Reserved, must be 0
    dw 1          ; Number of blocks to transfer (1 at a time)
    dw 0          ; Destination offset
    dw 0          ; Destination segment
lba_start:
    dq STAGE2_LBA_START ; LBA is a 64-bit value

loading_msg db 'Rylo', 0
stage2_msg  db 'OK', 0
error_msg   db 'ERR', 0
dot_msg     db '.', 0
no_lba_msg  db 'NoLBA', 0
    
; === BOOT SIGNATURE ===
times 510-($-$$) db 0
dw 0xaa55

