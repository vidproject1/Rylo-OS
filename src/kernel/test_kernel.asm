; Simple Test Kernel for Phase II
; This kernel just displays colorful text to prove the boot chain works
; Will be replaced with C kernel once toolchain is set up

[bits 32]
org 0x100000

kernel_start:
    ; === CLEAR SCREEN AND SHOW KERNEL MESSAGE ===
    
    ; Clear VGA screen first
    mov edi, 0xB8000    ; VGA text buffer
    mov ecx, 80*25      ; Screen size (80x25 characters)
    mov ax, 0x0720      ; Space character with grey on black
    rep stosw           ; Fill screen with spaces
    
    ; Reset VGA cursor position
    mov edi, 0xB8000
    
    ; === SHOW "KERNEL!" MESSAGE ===
    mov al, 'K'
    mov ah, 0x0A        ; Light green on black
    mov [edi+0], ax
    mov al, 'E' 
    mov [edi+2], ax
    mov al, 'R'
    mov [edi+4], ax
    mov al, 'N'
    mov [edi+6], ax
    mov al, 'E'
    mov [edi+8], ax
    mov al, 'L'
    mov [edi+10], ax
    mov al, '!'
    mov [edi+12], ax
    
    ; === SHOW "RYLO OS" ON NEXT LINE ===
    mov al, 'R'
    mov ah, 0x0C        ; Light red on black
    mov [edi+160], ax   ; Next line (80*2 = 160 bytes)
    mov al, 'Y'
    mov [edi+162], ax
    mov al, 'L'
    mov [edi+164], ax
    mov al, 'O'
    mov [edi+166], ax
    mov al, ' '
    mov ah, 0x0F        ; White on black
    mov [edi+168], ax
    mov al, 'O'
    mov ah, 0x09        ; Light blue on black
    mov [edi+170], ax
    mov al, 'S'
    mov [edi+172], ax
    
    ; === SHOW "PHASE 2 COMPLETE!" ON LINE 3 ===
    mov al, 'P'
    mov ah, 0x0E        ; Yellow on black
    mov [edi+320], ax   ; Line 3 (80*4 = 320 bytes)
    mov al, 'H'
    mov [edi+322], ax
    mov al, 'A'
    mov [edi+324], ax
    mov al, 'S'
    mov [edi+326], ax
    mov al, 'E'
    mov [edi+328], ax
    mov al, ' '
    mov ah, 0x0F
    mov [edi+330], ax
    mov al, '2'
    mov ah, 0x0E
    mov [edi+332], ax
    mov al, ' '
    mov ah, 0x0F
    mov [edi+334], ax
    mov al, 'C'
    mov ah, 0x0A
    mov [edi+336], ax
    mov al, 'O'
    mov [edi+338], ax
    mov al, 'M'
    mov [edi+340], ax
    mov al, 'P'
    mov [edi+342], ax
    mov al, 'L'
    mov [edi+344], ax
    mov al, 'E'
    mov [edi+346], ax
    mov al, 'T'
    mov [edi+348], ax
    mov al, 'E'
    mov [edi+350], ax
    mov al, '!'
    mov [edi+352], ax
    
    ; === SUCCESS! Kernel is running ===
    ; Show a final success message
    mov al, '3'
    mov ah, 0x0D        ; Light magenta
    mov [edi+480], ax   ; Line 4
    mov al, '2'
    mov [edi+482], ax
    mov al, '-'
    mov ah, 0x0F
    mov [edi+484], ax
    mov al, 'b'
    mov ah, 0x07
    mov [edi+486], ax
    mov al, 'i'
    mov [edi+488], ax
    mov al, 't'
    mov [edi+490], ax
    mov al, ' '
    mov ah, 0x0F
    mov [edi+492], ax
    mov al, 'k'
    mov ah, 0x0B
    mov [edi+494], ax
    mov al, 'e'
    mov [edi+496], ax
    mov al, 'r'
    mov [edi+498], ax
    mov al, 'n'
    mov [edi+500], ax
    mov al, 'e'
    mov [edi+502], ax
    mov al, 'l'
    mov [edi+504], ax
    mov al, ' '
    mov ah, 0x0F
    mov [edi+506], ax
    mov al, 'r'
    mov ah, 0x0A
    mov [edi+508], ax
    mov al, 'u'
    mov [edi+510], ax
    mov al, 'n'
    mov [edi+512], ax
    mov al, 'n'
    mov [edi+514], ax
    mov al, 'i'
    mov [edi+516], ax
    mov al, 'n'
    mov [edi+518], ax
    mov al, 'g'
    mov [edi+520], ax
    mov al, '!'
    mov ah, 0x0C
    mov [edi+522], ax
    
    ; === INFINITE LOOP (kernel successfully running) ===
    cli                 ; Disable interrupts
kernel_loop:
    hlt                 ; Halt CPU until next interrupt  
    jmp kernel_loop     ; Loop forever
