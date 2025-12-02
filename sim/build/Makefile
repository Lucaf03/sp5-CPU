# Makefile minimal CPU RISC-V freestanding

# Toolchain
RISCV_PREFIX = riscv32-unknown-elf-
CC      = $(RISCV_PREFIX)gcc
OBJCOPY = $(RISCV_PREFIX)objcopy

# Directory
SRC_DIR       = ../sw/apps
HEX_DIR       = hex
VSIM_SCRIPT   = ../scripts/vsim.sh
LINKER_SCRIPT = ../sw/linker/mem.ld
CRT0          = ../sw/linker/crt0.S

# Flags compilazione
CFLAGS  = -march=rv32im -mabi=ilp32 -O0 -g -ffreestanding -nostartfiles -nostdlib
LDFLAGS = -T $(LINKER_SCRIPT) -nostdlib -nostartfiles

# Target ELF da file .c (usa anche crt0.S)
%.elf: $(SRC_DIR)/%.c $(CRT0) $(LINKER_SCRIPT)
	@echo "Compilazione $< con crt0..."
	$(CC) $(CFLAGS) $(CRT0) $< $(LDFLAGS) -o $@
	riscv32-unknown-elf-objdump -d $@ > disassembly.txt

# Genera HEX verilog e lo copia direttamente in hex/prog.hex
%.hex: %.elf
	@echo "Generazione HEX per $<..."
	$(OBJCOPY) -O verilog $< $@
	@mkdir -p $(HEX_DIR)
	cp $@ $(HEX_DIR)/prog.hex

# Target finale: compilazione + HEX + simulazione
%: %.elf %.hex
	@echo "Lancio simulazione..."
	$(VSIM_SCRIPT)

# Pulizia
clean:
	rm -f *.elf *.hex
	rm -f $(HEX_DIR)/prog.hex
