# sp5-CPU

This repository contains the design of a simple RISC-V CPU core, written in VHDL, implementing a subset of the RV32I instruction set architecture.

The CPU supports most of the RV32I Base Integer Instruction Set, with the following exceptions:

- No support for Memory Ordering Instructions (e.g. FENCE)

- No support for Environment Calls and Breakpoints (e.g. ECALL, EBREAK)

- HINT instructions are not implemented


This CPU is based on a 4-stage pipeline:

1. Fetch

2. Decode

3. Execute

4. Memory/Writeback

In particular it has: 

- Bypass (forwarding) logic for both source operands during arithmetic operations, reducing pipeline stalls due to data hazards.

- JAL optimization: the control logic detects JAL instructions during the Fetch stage and immediately redirects the PC to the jump target in the next cycle, avoiding pipeline stalls.

Note: The CPU was tested on Vivado, using the Xilinx Memories both for the instruction memory and data memory.
Therefore in the top module structure (CPU_top.vhd) you can see the connections between the memories and the core. However for a general use, I wrote the general memory interfaces in the I/O ports of the core. 
