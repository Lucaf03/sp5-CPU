    .section .init
    .globl _start
_start:
    nop
    la sp, _stack_top     # inizializza stack pointer
    li x4, 5
    csrr x4, mimpid
    call main             # chiama la funzione main

end:  j end                 # se main ritorna, loop infinito
