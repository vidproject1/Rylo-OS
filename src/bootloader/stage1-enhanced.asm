; Rylo OS Enhanced Stage 1 Bootloader (MBR) 
; Can load large Stage 2 files by reading in multiple chunks
; Supports up to 63 sectors (32KB) Stage 2 files

org 0x7c00
bits 16

stage1_start:
    ; === MINIMAL SETUP ===
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti
    
    ; === VISUAL INDICATOR ===
    mov si, loading_msg
    call print_fast
    
    ; === ENHANCED STAGE 2 LOADING ===
    ; Need to load 41 sectors for 64-bit Stage 2
    ; BIOS limit is usually 18-36 sectors per call, so we'll do it in chunks
    
    ; First chunk: Load 18 sectors 
    mov ah, 0x02        ; BIOS read function
    mov al, 18          ; Read 18 sectors
    mov ch, 0           ; Cylinder 0
    mov cl, 2           ; Start from sector 2 (after MBR)
    mov dh, 0           ; Head 0
    mov dl, 0x80        ; Hard disk
    mov bx, 0x7e00      ; Load to 0x7e00
    int 0x13
    jc disk_error
    
    ; Second chunk: Load remaining 23 sectors  
    mov ah, 0x02        ; BIOS read function
    mov al, 23          ; Read 23 more sectors (18+23=41 total)
    mov ch, 0           ; Cylinder 0
    mov cl, 20          ; Start from sector 20 (2+18=20)
    mov dh, 0           ; Head 0
    mov dl, 0x80        ; Hard disk
    ; Load to address right after first chunk
    ; 0x7e00 + 18*512 = 0x7e00 + 9216 = 0xA200 in linear address
    ; Convert to segment:offset = 0xA20:0x0000  
    mov ax, 0xA20       ; Segment for second chunk
    mov es, ax
    mov bx, 0           ; Offset 0
    int 0x13
    jc disk_error
    
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
loading_msg db 'Rylo', 0
stage2_msg  db 'Fast!', 0  
error_msg   db 'ERR', 0

; === BOOT SIGNATURE ===
times 510-($-$$) db 0
dw 0xaa55
