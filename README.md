#emu_awg, an arbitrary waveform generator for FPGAs

NOTE: THIS PROJECT IS BY NO MEANS COMPLETE, THERE IS SOME TERRIBLE CODE IN HERE, LOOK AT YOUR OWN RISK!

Also note that this currently does not support arbitrary waveforms (yet!)

This is just a simple function generator implemented in VHDL targeting a Xilinx Spartan 3E FPGA.

It uses digital direct synthesis (DDS) to obtain a waveform from a look up table of values stored in RAM.

This was tested on the Digilient spartan 3E starter board.
