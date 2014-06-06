#!/bin/bash

# Quick and dirty helper script to make a few things easier for the Basys 2.
# Options are:
# 	flash - configure the next build to target flash (need to run a make after)
# 	device - configure the next build to target the fpga (need to run a make after)
# 	program - program the device using digilents tools

DEVICE=Basys2
PROJECT=emu_awg

if [[ "$#" -eq "0" ]]; then
	echo "Please enter an option"
	echo "----------------------------------------"
	echo "Available options:"
	echo "flash - configure the next build to target flash (need to run a make after)"
	echo "device - configure the next build to target the fpga (need to run a make after)"
	echo "program_flash - program the flash using digilents tools"
	echo "program_device - program the device using digilents tools"
else
	if [[ "$1" = "flash" ]]; then
		sed -i 's/JtagClk/CCLK/g' ise/graph_radius.ut
	fi
	if [[ "$1" = "device" ]]; then
		sed -i 's/CCLK/JtagClk/g' ise/graph_radius.ut
	fi
	if [[ "$1" = "program_device" ]]; then
		djtgcfg init -d $DEVICE
		djtgcfg prog -d $DEVICE -i 0 -f ${PROJECT}.bit
	fi
	if [[ "$1" = "program_flash" ]]; then
		djtgcfg init -d $DEVICE
		djtgcfg prog -d $DEVICE -i 1 -f ${PROJECT}.bit
	fi
fi
