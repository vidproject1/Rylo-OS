/*
 * Rylo OS Kernel Linker Script
 * This script tells the linker how to arrange our kernel in memory
 * 
 * Memory Layout:
 * - Kernel loaded at 1MB (0x100000) - standard location
 * - Identity mapped by bootloader
 * - Running in 64-bit long mode
 */

ENTRY(kernel_main)

SECTIONS
{
    /* Kernel starts at 1MB (standard kernel load address) */
    . = 0x100000;
    
    /* Code section - executable instructions */
    .text ALIGN(4K) : {
        *(.text)
        *(.text.*)
    }
    
    /* Read-only data section */
    .rodata ALIGN(4K) : {
        *(.rodata)
        *(.rodata.*)
    }
    
    /* Read-write data section */  
    .data ALIGN(4K) : {
        *(.data)
        *(.data.*)
    }
    
    /* Uninitialized data section */
    .bss ALIGN(4K) : {
        *(.bss)
        *(.bss.*)
        *(COMMON)
    }
    
    /* Mark the end of kernel for memory management */
    kernel_end = .;
}
