#!/bin/bash

echo "Running vsim.sh..."

source ../scripts/setup.sh 
LIB_NAME="work"
LIB_PATH=$BUILD_PATH/$LIB_NAME

if [ -d $LIB_PATH ]
then 
	echo "$LIB_NAME already exists"
else 
	vlib $LIB_PATH
fi

vmap $LIB_NAME $LIB_PATH

vcom -2008 -quiet -suppress 2583 -work $LIB_NAME  ${RTL_PATH}/sp-PKG.vhd		|| exit 1
vcom -2008 -quiet -suppress 2583 -work $LIB_NAME  ${RTL_PATH}/Data_ram.vhd		|| exit 1
vcom -2008 -quiet -suppress 2583 -work $LIB_NAME  ${RTL_PATH}/Instr_mem.vhd		|| exit 1
vcom -2008 -quiet -suppress 2583 -work $LIB_NAME  ${RTL_PATH}/Fetch_Unit.vhd		|| exit 1
vcom -2008 -quiet -suppress 2583 -work $LIB_NAME  ${RTL_PATH}/Branch_Unit.vhd		|| exit 1
vcom -2008 -quiet -suppress 2583 -work $LIB_NAME  ${RTL_PATH}/Decode_Unit.vhd		|| exit 1
vcom -2008 -quiet -suppress 2583 -work $LIB_NAME  ${RTL_PATH}/Exec_Unit.vhd		|| exit 1
vcom -2008 -quiet -suppress 2583 -work $LIB_NAME  ${RTL_PATH}/WriteBack_Unit.vhd	|| exit 1
vcom -2008 -quiet -suppress 2583 -work $LIB_NAME  ${RTL_PATH}/Reg_file.vhd		|| exit 1
vcom -2008 -quiet -suppress 2583 -work $LIB_NAME  ${RTL_PATH}/PC_reg.vhd			|| exit 1
vcom -2008 -quiet -suppress 2583 -work $LIB_NAME  ${RTL_PATH}/CPU_top.vhd			|| exit 1
vcom -2008 -quiet -suppress 2583 -work $LIB_NAME  ${RTL_PATH}/tb_cpu.vhd		|| exit 1



vsim $LIB_NAME.tb_cpu 

echo "Exiting vsim.sh..."
