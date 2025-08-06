; Rylo OS Stage 2 Bootloader - 32-bit Version
; Stay in 32-bit protected mode and load a 32-bit kernel
org 0x7e00
bits 16

stage2_start:
    ; Display Stage2 message
    mov si, stage2_banner
    call print_string
    
    ; Enable A20
    in al, 0x92
    or al, 2
    out 0x92, al
    
    mov si, a20_msg
    call print_string
    
    ; Load GDT
    lgdt [gdt_descriptor]
    
    mov si, gdt_msg
    call print_string
    
    ; Enter protected mode
    cli
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    jmp 0x08:protected_mode_start

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

; Minimal GDT for 32-bit
gdt_start:
    dq 0                    ; Null descriptor
    
    ; 32-bit code segment
    dw 0xFFFF, 0x0000
    db 0x00, 0x9A, 0xCF, 0x00
    
    ; 32-bit data segment  
    dw 0xFFFF, 0x0000
    db 0x00, 0x92, 0xCF, 0x00
    
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

bits 32
protected_mode_start:
    ; Set segments
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000        ; Set stack at 0x90000
    
    ; Display success message in VGA text mode
    mov edi, 0xB8000        ; VGA text buffer
    
    ; Clear screen first
    mov ecx, 80 * 25        ; 80x25 screen
    mov ax, 0x0F20          ; White on black space
    rep stosw
    
    ; Reset to start of screen
    mov edi, 0xB8000
    
    ; Display "32BIT PROTECTED MODE!"
    mov esi, protected_msg
    mov ah, 0x0F            ; White on black
.print_loop:
    lodsb
    test al, al
    jz .done_print
    stosb                   ; Store character
    mov al, ah
    stosb                   ; Store attribute
    jmp .print_loop
.done_print:
    
    ; Create inline kernel for testing
    mov edi, 0xB8000
    add edi, 160            ; Second line (80 chars * 2 bytes)
    
    mov esi, kernel_msg
    mov ah, 0x0E            ; Yellow on black
.kernel_print:
    lodsb
    test al, al
    jz .kernel_done
    stosb
    mov al, ah
    stosb
    jmp .kernel_print
.kernel_done:

    ; Halt - Phase 2 kernel will replace this
halt_loop:
    hlt
    jmp halt_loop

; Data section
protected_msg db '32BIT PROTECTED MODE!', 0
kernel_msg    db 'KERNEL SPACE READY', 0

; Back to 16-bit for data
bits 16
stage2_banner db 'Stage2!', 0
a20_msg       db 'A20', 0
gdt_msg       db 'GDT', 0
