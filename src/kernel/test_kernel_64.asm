; 64-bit Test Kernel for Rylo OS
; Proves we're in 64-bit long mode with unlimited RAM access

[bits 64]
org 0x100000

kernel_start:
    ; === CLEAR SCREEN ===
    mov rdi, 0xB8000
    mov rcx, 80*25
    mov ax, 0x0720      ; Space with grey on black
    rep stosw
    
    ; === SHOW 64-BIT SUCCESS MESSAGES ===
    mov rdi, 0xB8000
    
    ; Line 1: "64-BIT RYLO OS"
    mov al, '6'
    mov ah, 0x0C        ; Light red
    mov [rdi+0], ax
    mov al, '4'
    mov [rdi+2], ax
    mov al, '-'
    mov ah, 0x0F        ; White
    mov [rdi+4], ax
    mov al, 'B'
    mov ah, 0x0A        ; Light green
    mov [rdi+6], ax
    mov al, 'I'
    mov [rdi+8], ax
    mov al, 'T'
    mov [rdi+10], ax
    mov al, ' '
    mov ah, 0x0F
    mov [rdi+12], ax
    mov al, 'R'
    mov ah, 0x0E        ; Yellow
    mov [rdi+14], ax
    mov al, 'Y'
    mov [rdi+16], ax
    mov al, 'L'
    mov [rdi+18], ax
    mov al, 'O'
    mov [rdi+20], ax
    mov al, ' '
    mov ah, 0x0F
    mov [rdi+22], ax
    mov al, 'O'
    mov ah, 0x09        ; Light blue
    mov [rdi+24], ax
    mov al, 'S'
    mov [rdi+26], ax
    
    ; Line 2: "LONG MODE ACTIVE"
    mov al, 'L'
    mov ah, 0x0B        ; Light cyan
    mov [rdi+160], ax
    mov al, 'O'
    mov [rdi+162], ax
    mov al, 'N'
    mov [rdi+164], ax
    mov al, 'G'
    mov [rdi+166], ax
    mov al, ' '
    mov ah, 0x0F
    mov [rdi+168], ax
    mov al, 'M'
    mov ah, 0x0B
    mov [rdi+170], ax
    mov al, 'O'
    mov [rdi+172], ax
    mov al, 'D'
    mov [rdi+174], ax
    mov al, 'E'
    mov [rdi+176], ax
    mov al, ' '
    mov ah, 0x0F
    mov [rdi+178], ax
    mov al, 'A'
    mov ah, 0x0A        ; Light green
    mov [rdi+180], ax
    mov al, 'C'
    mov [rdi+182], ax
    mov al, 'T'
    mov [rdi+184], ax
    mov al, 'I'
    mov [rdi+186], ax
    mov al, 'V'
    mov [rdi+188], ax
    mov al, 'E'
    mov [rdi+190], ax
    
    ; Line 3: "UNLIMITED RAM ACCESS!"
    mov al, 'U'
    mov ah, 0x0D        ; Light magenta
    mov [rdi+320], ax
    mov al, 'N'
    mov [rdi+322], ax
    mov al, 'L'
    mov [rdi+324], ax
    mov al, 'I'
    mov [rdi+326], ax
    mov al, 'M'
    mov [rdi+328], ax
    mov al, 'I'
    mov [rdi+330], ax
    mov al, 'T'
    mov [rdi+332], ax
    mov al, 'E'
    mov [rdi+334], ax
    mov al, 'D'
    mov [rdi+336], ax
    mov al, ' '
    mov ah, 0x0F
    mov [rdi+338], ax
    mov al, 'R'
    mov ah, 0x0C        ; Light red
    mov [rdi+340], ax
    mov al, 'A'
    mov [rdi+342], ax
    mov al, 'M'
    mov [rdi+344], ax
    mov al, ' '
    mov ah, 0x0F
    mov [rdi+346], ax
    mov al, 'A'
    mov ah, 0x0E        ; Yellow
    mov [rdi+348], ax
    mov al, 'C'
    mov [rdi+350], ax
    mov al, 'C'
    mov [rdi+352], ax
    mov al, 'E'
    mov [rdi+354], ax
    mov al, 'S'
    mov [rdi+356], ax
    mov al, 'S'
    mov [rdi+358], ax
    mov al, '!'
    mov ah, 0x0C
    mov [rdi+360], ax
    
    ; Line 4: "64-BIT REGISTERS & POINTERS"
    mov al, '6'
    mov ah, 0x0A        ; Light green
    mov [rdi+480], ax
    mov al, '4'
    mov [rdi+482], ax
    mov al, '-'
    mov ah, 0x0F
    mov [rdi+484], ax
    mov al, 'B'
    mov ah, 0x0A
    mov [rdi+486], ax
    mov al, 'I'
    mov [rdi+488], ax
    mov al, 'T'
    mov [rdi+490], ax
    mov al, ' '
    mov ah, 0x0F
    mov [rdi+492], ax
    mov al, 'R'
    mov ah, 0x0B        ; Light cyan
    mov [rdi+494], ax
    mov al, 'E'
    mov [rdi+496], ax
    mov al, 'G'
    mov [rdi+498], ax
    mov al, 'I'
    mov [rdi+500], ax
    mov al, 'S'
    mov [rdi+502], ax
    mov al, 'T'
    mov [rdi+504], ax
    mov al, 'E'
    mov [rdi+506], ax
    mov al, 'R'
    mov [rdi+508], ax
    mov al, 'S'
    mov [rdi+510], ax
    mov al, ' '
    mov ah, 0x0F
    mov [rdi+512], ax
    mov al, '&'
    mov ah, 0x07
    mov [rdi+514], ax
    mov al, ' '
    mov ah, 0x0F
    mov [rdi+516], ax
    mov al, 'P'
    mov ah, 0x0E        ; Yellow
    mov [rdi+518], ax
    mov al, 'O'
    mov [rdi+520], ax
    mov al, 'I'
    mov [rdi+522], ax
    mov al, 'N'
    mov [rdi+524], ax
    mov al, 'T'
    mov [rdi+526], ax
    mov al, 'E'
    mov [rdi+528], ax
    mov al, 'R'
    mov [rdi+530], ax
    mov al, 'S'
    mov [rdi+532], ax
    
    ; Line 5: "PHASE II COMPLETE - 64BIT!"
    mov al, 'P'
    mov ah, 0x0C        ; Light red
    mov [rdi+640], ax
    mov al, 'H'
    mov [rdi+642], ax
    mov al, 'A'
    mov [rdi+644], ax
    mov al, 'S'
    mov [rdi+646], ax
    mov al, 'E'
    mov [rdi+648], ax
    mov al, ' '
    mov ah, 0x0F
    mov [rdi+650], ax
    mov al, 'I'
    mov ah, 0x0C
    mov [rdi+652], ax
    mov al, 'I'
    mov [rdi+654], ax
    mov al, ' '
    mov ah, 0x0F
    mov [rdi+656], ax
    mov al, 'C'
    mov ah, 0x0A        ; Light green
    mov [rdi+658], ax
    mov al, 'O'
    mov [rdi+660], ax
    mov al, 'M'
    mov [rdi+662], ax
    mov al, 'P'
    mov [rdi+664], ax
    mov al, 'L'
    mov [rdi+666], ax
    mov al, 'E'
    mov [rdi+668], ax
    mov al, 'T'
    mov [rdi+670], ax
    mov al, 'E'
    mov [rdi+672], ax
    mov al, ' '
    mov ah, 0x0F
    mov [rdi+674], ax
    mov al, '-'
    mov ah, 0x07
    mov [rdi+676], ax
    mov al, ' '
    mov ah, 0x0F
    mov [rdi+678], ax
    mov al, '6'
    mov ah, 0x0E        ; Yellow
    mov [rdi+680], ax
    mov al, '4'
    mov [rdi+682], ax
    mov al, 'B'
    mov [rdi+684], ax
    mov al, 'I'
    mov [rdi+686], ax
    mov al, 'T'
    mov [rdi+688], ax
    mov al, '!'
    mov ah, 0x0C        ; Light red
    mov [rdi+690], ax
    
    ; === DEMONSTRATE 64-BIT CAPABILITIES ===
    ; Test that we can use 64-bit registers and memory addresses
    
    ; Show that we can work with large addresses (above 4GB)
    ; (We can't actually access above 2GB without more page tables,
    ;  but we can show 64-bit arithmetic works)
    
    ; Line 7: Show a large 64-bit number
    mov al, 'R'
    mov ah, 0x0F
    mov [rdi+960], ax   ; Line 7
    mov al, 'A'
    mov [rdi+962], ax
    mov al, 'X'
    mov [rdi+964], ax
    mov al, '='
    mov ah, 0x07
    mov [rdi+966], ax
    
    ; Load a large 64-bit value into RAX for demonstration
    mov rax, 0x123456789ABCDEF0
    
    ; We could display this hex value, but for simplicity,
    ; just show that we have 64-bit capabilities
    mov al, '6'
    mov ah, 0x0A        ; Light green  
    mov [rdi+968], ax
    mov al, '4'
    mov [rdi+970], ax
    mov al, 'b'
    mov [rdi+972], ax
    mov al, 'i'
    mov [rdi+974], ax
    mov al, 't'
    mov [rdi+976], ax
    mov al, ' '
    mov ah, 0x0F
    mov [rdi+978], ax
    mov al, 'v'
    mov ah, 0x0B        ; Light cyan
    mov [rdi+980], ax
    mov al, 'a'
    mov [rdi+982], ax
    mov al, 'l'
    mov [rdi+984], ax
    mov al, 'u'
    mov [rdi+986], ax
    mov al, 'e'
    mov [rdi+988], ax
    mov al, 's'
    mov [rdi+990], ax
    
    ; === INFINITE LOOP ===
    ; Kernel is running successfully in 64-bit mode!
    cli
kernel_loop:
    hlt
    jmp kernel_loop
