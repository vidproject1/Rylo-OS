; Rylo OS Stage 2 Bootloader - Compact Version
; Fits in 18 sectors (9KB) - removes large page tables
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

; Minimal GDT
gdt_start:
    dq 0                    ; Null descriptor
    
    ; 32-bit code segment
    dw 0xFFFF, 0x0000
    db 0x00, 0x9A, 0xCF, 0x00
    
    ; 32-bit data segment  
    dw 0xFFFF, 0x0000
    db 0x00, 0x92, 0xCF, 0x00
    
    ; 64-bit code segment
    dw 0x0000, 0x0000
    db 0x00, 0x9A, 0x20, 0x00
    
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
    mov esp, 0x7c00
    
    ; Setup minimal paging for 64-bit
    call setup_paging
    
    ; Enable PAE
    mov eax, cr4
    or eax, 0x20
    mov cr4, eax
    
    ; Load page directory
    mov eax, 0x9000
    mov cr3, eax
    
    ; Enable long mode
    mov ecx, 0xC0000080
    rdmsr
    or eax, 0x100
    wrmsr
    
    ; Enable paging
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax
    
    ; Jump to 64-bit
    jmp 0x18:long_mode_start

setup_paging:
    ; Simple identity paging setup at 0x9000
    ; Clear page table memory first
    mov edi, 0x9000
    mov ecx, 1024      ; Clear 4KB (1024 dwords)
    xor eax, eax
    rep stosd
    
    mov edi, 0xA000
    mov ecx, 1024      ; Clear another 4KB
    rep stosd
    
    mov edi, 0xB000
    mov ecx, 1024      ; Clear another 4KB  
    rep stosd
    
    ; Set up page tables
    ; PML4[0] points to PDPT at 0xA000
    mov dword [0x9000], 0xA003
    mov dword [0x9004], 0
    
    ; PDPT[0] points to PD at 0xB000
    mov dword [0xA000], 0xB003
    mov dword [0xA004], 0
    
    ; PD[0] = 2MB page covering 0x0-0x200000
    mov dword [0xB000], 0x000083
    mov dword [0xB004], 0
    
    ret

bits 64
long_mode_start:
    ; Set 64-bit segments
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov rsp, 0x90000
    
    ; Display success messages
    mov rax, 0xB8000
    
    ; Show "STAGE2"
    mov byte [rax+2], 'S'
    mov byte [rax+3], 0x0F
    mov byte [rax+4], 'T'
    mov byte [rax+5], 0x0F
    mov byte [rax+6], 'A'
    mov byte [rax+7], 0x0F
    mov byte [rax+8], 'G'
    mov byte [rax+9], 0x0F
    mov byte [rax+10], 'E'
    mov byte [rax+11], 0x0F
    mov byte [rax+12], '2'
    mov byte [rax+13], 0x0F
    
    ; Show "64BIT!"
    mov byte [rax+80], '6'
    mov byte [rax+81], 0x0F
    mov byte [rax+82], '4'
    mov byte [rax+83], 0x0F
    mov byte [rax+84], 'B'
    mov byte [rax+85], 0x0F
    mov byte [rax+86], 'I'
    mov byte [rax+87], 0x0F
    mov byte [rax+88], 'T'
    mov byte [rax+89], 0x0F
    mov byte [rax+90], '!'
    mov byte [rax+91], 0x0F

halt_loop:
    hlt
    jmp halt_loop

; Data section
bits 16
stage2_banner db 'Stage2!', 0
a20_msg       db 'A20', 0
gdt_msg       db 'GDT', 0
