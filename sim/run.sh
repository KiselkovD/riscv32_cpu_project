#!/bin/bash

# Run the simulation
vvp sim/riscv32_cpu.vvp

# Check if VCD file was created for waveform viewing
if [ -f "sim/riscv32_cpu.vcd" ]; then
    echo "Launching GTKWave with waveform sim/riscv32_cpu.vcd"
    gtkwave sim/riscv32_cpu.vcd &
else
    echo "No VCD waveform file found."
fi
