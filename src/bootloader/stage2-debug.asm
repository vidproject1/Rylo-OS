; Debug version of Stage 2 with detailed error reporting

org 0x7e00
bits 16

stage2_start:
    mov si, stage2_banner
    call print_string
    
    call enable_a20_fast
    mov si, a20_msg
    call print_string
    
    ; Try kernel load with debug info
    call load_kernel_debug
    
    ; If we get here, kernel loaded successfully
    mov si, kernel_loaded_msg
    call print_string
    
    lgdt [gdt_descriptor]
    mov si, gdt_msg  
    call print_string
    
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

enable_a20_fast:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret

; Print a single hex digit
print_hex_digit:
    cmp al, 10
    jl .digit
    add al, 'A' - '0' - 10
.digit:
    add al, '0'
    mov ah, 0x0e
    int 0x10
    ret

; Print AL as hex
print_hex_byte:
    push ax
    shr al, 4
    call print_hex_digit
    pop ax
    and al, 0x0f
    call print_hex_digit
    ret

load_kernel_debug:
    ; Show what we're trying to do
    mov si, debug_msg1
    call print_string
    
    ; Try the disk read
    mov ah, 0x02        ; BIOS read sectors function
    mov al, 8           ; Read 8 sectors
    mov ch, 0           ; Cylinder 0
    mov cl, 3           ; Sector 3 (kernel location)
    mov dh, 0           ; Head 0
    mov dl, 0x80        ; First hard disk
    mov bx, 0x2000      
    mov es, bx
    mov bx, 0
    
    int 0x13
    jc .error
    
    ; Success!
    mov si, debug_success
    call print_string
    ret

.error:
    ; Show error details
    mov si, debug_error
    call print_string
    
    ; Print error code from AH
    mov si, debug_err_code
    call print_string
    mov al, ah
    call print_hex_byte
    
    mov si, debug_newline
    call print_string
    hlt

bits 32
protected_mode_start:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    ; Copy kernel
    mov esi, 0x20000
    mov edi, 0x100000
    mov ecx, 4096
    rep movsb
    
    ; Jump to kernel
    call 0x100000
    
infinite_loop:
    hlt
    jmp infinite_loop

; GDT (same as before)
gdt_start:
    dq 0
    dw 0xFFFF, 0x0000
    db 0x00, 0x9A, 0xCF, 0x00
    dw 0xFFFF, 0x0000
    db 0x00, 0x92, 0xCF, 0x00
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; Data
bits 16
stage2_banner    db 'Stage2', 0
a20_msg         db 'A20', 0  
gdt_msg         db 'GDT', 0
kernel_loaded_msg db 'Kernel', 0
debug_msg1      db 'TryRead', 0
debug_success   db 'OK', 0
debug_error     db 'DiskErr', 0
debug_err_code  db 'Code:', 0
debug_newline   db 13, 10, 0
