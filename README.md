# RV32I RISC-V CPU Verilog Project
---
en
---

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
├── dockerfile/							# Docker config
└── README.md               # This file
```

## Getting Started

### Prerequisites

- Verilog simulation tool such as Icarus Verilog
- A terminal or shell environment to run simulation scripts

### Compilation and Simulation

To compile and simulate the CPU with Icarus Verilog:

```
# Make sure Docker is installed and running.
docker build -t my-iverilog .
docker run --rm -v "$(pwd):/workspace" my-iverilog ./sim/build_run.sh
```


### Running Tests

- Modify or add test programs to load into the instruction memory.
- Run simulations to verify instruction execution and state transitions.
- Use waveform viewers (e.g., GTKWave, ModelSim waveform window) to inspect signals visually.

---
ru
---

## Обзор

В этом проекте реализовано базовое 32-битное ядро ​​ЦП RISC-V (подмножество RV32I) с использованием языка описания аппаратуры Verilog. ЦП имеет однотактную архитектуру и поддерживает базовый набор целочисленных инструкций. Он включает модульные компоненты, такие как счетчик команд, память инструкций, память данных, регистровый файл, блок управления, АЛУ, управление АЛУ и генератор непосредственных значений.

Проект включает подробную систему логирования для моделирования, что облегчает отладку и понимание внутренних операций ЦП.

## Особенности

- Однотактный тракт данных для инструкций RV32I
- Модульные исходные файлы Verilog для удобства сопровождения и повторного использования
- Базовое выполнение программ, включая арифметические операции, ветвления, загрузки и сохранения
- Логирование всех ключевых сигналов ЦП в каждом тактовом цикле
- Включает пример тестового стенда для проверки

## Структура файлов

```
riscv32_cpu_project/
├── src/ 							# Модули исходного кода Verilog
├── tb/ 							# Файлы тестового стенда и стимулы
├── sim/ 							# Скрипты моделирования и конфигурация
├── programs/ 				# Примеры программ на ассемблере/машинном коде
├── dockerfile/				# Docker конфигурация
└── README.md 				# Этот файл
```

## Начало работы

### Предварительные условия

- Инструмент моделирования Verilog например, Icarus Verilog
- Терминальная или командная среда для запуска скриптов моделирования

### Компиляция и моделирование

Для компиляции и моделирования ЦП с помощью Icarus Verilog:

```
# Убедитесь, что Docker установлен и запущен.
docker build -t my-iverilog .
docker run --rm -v "$(pwd):/workspace" my-iverilog ./sim/build_run.sh
```

### Запуск тестов

- Изменение или добавление тестовых программ для загрузки в память инструкций.

- Запуск моделирования для проверки выполнения инструкций и переходов состояний.

- Использование средств просмотра сигналов (например, GTKWave, окно осциллограмм ModelSim) для визуального анализа сигналов.