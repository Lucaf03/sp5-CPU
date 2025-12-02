/* Linker script minimal per CPU RISC-V 32-bit freestanding */

ENTRY(_start)

MEMORY
{
    IMEM (rx)  : ORIGIN = 0x0000, LENGTH = 0x2000
    DRAM (rwx) : ORIGIN = 0x2000, LENGTH = 0x2000
}

SECTIONS
{
    . = ORIGIN(IMEM);
    _start = .; 
    /* codice eseguibile nella Instruction Memory */
    
      /* metti le sezioni di startup qui */
  	.init : {
    	KEEP(*(.init))
    	KEEP(*(.init.*))
  	} > IMEM
    .text :
    {
        KEEP(*(.text*))
        KEEP(*(.rodata*))
    } > IMEM

    /* dati inizializzati nella RAM */
    .data :
    {
        _sdata = .;
        KEEP(*(.data*))
        _edata = .;
    } > DRAM

    /* dati non inizializzati (BSS) nella RAM */
    .bss :
    {
        _sbss = .;
        KEEP(*(.bss*))
        *(COMMON)
        _ebss = .;
    } > DRAM

    /* simboli richiesti dalla toolchain minimal */
    __global_pointer$ = 0;
    _stack_top = ORIGIN(DRAM) + LENGTH(DRAM);
    _end = ORIGIN(DRAM) + LENGTH(DRAM);
}
