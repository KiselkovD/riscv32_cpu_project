# RV32I RISC-V CPU Verilog Project

## Overview

This project implements a basic 32-bit RISC-V CPU core (RV32I subset) using Verilog HDL. The CPU is a single-cycle design supporting the base integer instruction set. It features modular components including the Program Counter, Instruction Memory, Data Memory, Register File, Control Unit, ALU, ALU Control, and Immediate Generator.

The design includes detailed logging for simulation to aid debugging and understanding CPU internal operations.

## Features

- Single-cycle datapath for RV32I instructions
- Modular Verilog source files for maintainability and reuse
- Basic program execution including arithmetic, branches, loads, and stores
- Simulation logging for all key CPU signals each clock cycle
- Includes example testbench for verification

## File Structure

```
riscv32_cpu_project/
├── src/                    # Verilog source code modules
├── tb/                     # Testbench files and stimuli
├── sim/                    # Simulation scripts and configuration
├── programs/               # Sample assembly/machine code programs
├── docs/                   # Documentation
└── README.md               # This file
```

## Getting Started

### Prerequisites

- Verilog simulation tool such as Icarus Verilog
- A terminal or shell environment to run simulation scripts

### Compilation and Simulation

To compile and simulate the CPU with Icarus Verilog (example):

```
.sim/build.sh
.sim/run.sh
```


### Running Tests

- Modify or add test programs to load into the instruction memory.
- Run simulations to verify instruction execution and state transitions.
- Use waveform viewers (e.g., GTKWave, ModelSim waveform window) to inspect signals visually.

## Contributing

Contributions and improvements are welcome. Please open issues or pull requests on the project repository for review.
