#!/bin/bash

# Create simulation directory if not exist
mkdir -p sim

# Compile all source files and testbench with Icarus Verilog
iverilog -g2012 -o sim/riscv32_cpu.vvp \
    src/ProgramCounter.v \
    src/InstructionMemory.v \
    src/DataMemory.v \
    src/RegisterFile.v \
    src/ControlUnit.v \
    src/ALUControl.v \
    src/ALU.v \
    src/ImmediateGenerator.v \
    src/RV32ICPU.v \
    src/BranchComparator.v \
    tb/RV32ICPU_tb.v

if [ $? -eq 0 ]; then
    echo "Build succeeded, output file sim/riscv32_cpu.vvp created."
else
    echo "Build failed."
    exit 1
fi
