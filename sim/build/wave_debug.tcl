add wave sim:/tb_cpu/clk_i
add wave sim:/tb_cpu/rst_i
add wave sim:/tb_cpu/global_en_i
add wave -group "ALL" sim:/tb_cpu/cpu_inst/*

add wave -group "PC" -radix hexadecimal sim:/tb_cpu/cpu_inst/PC_INST/*
add wave -group "FETCH" -radix hexadecimal sim:/tb_cpu/cpu_inst/FETCH_INST/*
add wave -group "BRANCH" -radix hexadecimal sim:/tb_cpu/cpu_inst/BRANCH_INST/*
add wave -group "DECODE" -radix unsigned sim:/tb_cpu/cpu_inst/DECODE_INST/*
add wave -group "EXECUTE" -radix decimal sim:/tb_cpu/cpu_inst/EX_INST/*
add wave -group "REGFILE" -radix decimal sim:/tb_cpu/cpu_inst/RF_INST/reg_file

add wave -group "DATA_MEMORY" -radix decimal sim:/tb_cpu/cpu_inst/data_mem_addr_o
add wave -group "DATA_MEMORY" -radix hexadecimal sim:/tb_cpu/cpu_inst/data_mem_data_i
add wave -group "DATA_MEMORY" -radix hexadecimal sim:/tb_cpu/cpu_inst/data_mem_data_o
add wave -group "DATA_MEMORY" -radix hexadecimal sim:/tb_cpu/cpu_inst/data_mem_we_o
add wave -group "DATA_MEMORY" -radix hexadecimal sim:/tb_cpu/cpu_inst/data_mem_en_o




