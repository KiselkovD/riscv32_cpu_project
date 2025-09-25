#!/usr/bin/env python3
import os
import glob
import argparse

# Registers mapping
registers = {f"x{i}": i for i in range(32)}
registers.update({
    "zero": 0, "ra": 1, "sp": 2, "gp": 3, "tp": 4,
    "t0": 5, "t1": 6, "t2":7,
    "s0":8, "fp":8, "s1":9,
    "a0":10, "a1":11, "a2":12, "a3":13, "a4":14, "a5":15, "a6":16, "a7":17,
    "s2":18, "s3":19, "s4":20, "s5":21, "s6":22, "s7":23, "s8":24, "s9":25, "s10":26, "s11":27,
    "t3":28, "t4":29, "t5":30, "t6":31
})

# Instruction set with encoding parameters for RV32I base instructions
instructions = {
    # R-type
    "ADD": {"type": "R", "opcode": 0x33, "funct3": 0x0, "funct7": 0x00},
    "SUB": {"type": "R", "opcode": 0x33, "funct3": 0x0, "funct7": 0x20},
    "SLL": {"type": "R", "opcode": 0x33, "funct3": 0x1, "funct7": 0x00},
    "SLT": {"type": "R", "opcode": 0x33, "funct3": 0x2, "funct7": 0x00},
    "SLTU": {"type": "R", "opcode": 0x33, "funct3": 0x3, "funct7": 0x00},
    "XOR": {"type": "R", "opcode": 0x33, "funct3": 0x4, "funct7": 0x00},
    "SRL": {"type": "R", "opcode": 0x33, "funct3": 0x5, "funct7": 0x00},
    "SRA": {"type": "R", "opcode": 0x33, "funct3": 0x5, "funct7": 0x20},
    "OR": {"type": "R", "opcode": 0x33, "funct3": 0x6, "funct7": 0x00},
    "AND": {"type": "R", "opcode": 0x33, "funct3": 0x7, "funct7": 0x00},

    # I-type
    "ADDI": {"type": "I", "opcode": 0x13, "funct3": 0x0},
    "SLTI": {"type": "I", "opcode": 0x13, "funct3": 0x2},
    "SLTIU": {"type": "I", "opcode": 0x13, "funct3": 0x3},
    "XORI": {"type": "I", "opcode": 0x13, "funct3": 0x4},
    "ORI": {"type": "I", "opcode": 0x13, "funct3": 0x6},
    "ANDI": {"type": "I", "opcode": 0x13, "funct3": 0x7},
    "SLLI": {"type": "I-shift", "opcode": 0x13, "funct3": 0x1, "funct7": 0x00},
    "SRLI": {"type": "I-shift", "opcode": 0x13, "funct3": 0x5, "funct7": 0x00},
    "SRAI": {"type": "I-shift", "opcode": 0x13, "funct3": 0x5, "funct7": 0x20},

    "LB": {"type": "I-load", "opcode": 0x03, "funct3": 0x0},
    "LH": {"type": "I-load", "opcode": 0x03, "funct3": 0x1},
    "LW": {"type": "I-load", "opcode": 0x03, "funct3": 0x2},
    "LBU": {"type": "I-load", "opcode": 0x03, "funct3": 0x4},
    "LHU": {"type": "I-load", "opcode": 0x03, "funct3": 0x5},

    "JALR": {"type": "I", "opcode": 0x67, "funct3": 0x0},

    # S-type
    "SB": {"type": "S", "opcode": 0x23, "funct3": 0x0},
    "SH": {"type": "S", "opcode": 0x23, "funct3": 0x1},
    "SW": {"type": "S", "opcode": 0x23, "funct3": 0x2},

    # B-type
    "BEQ": {"type": "B", "opcode": 0x63, "funct3": 0x0},
    "BNE": {"type": "B", "opcode": 0x63, "funct3": 0x1},
    "BLT": {"type": "B", "opcode": 0x63, "funct3": 0x4},
    "BGE": {"type": "B", "opcode": 0x63, "funct3": 0x5},
    "BLTU": {"type": "B", "opcode": 0x63, "funct3": 0x6},
    "BGEU": {"type": "B", "opcode": 0x63, "funct3": 0x7},

    # U-type
    "LUI": {"type": "U", "opcode": 0x37},
    "AUIPC": {"type": "U", "opcode": 0x17},

    # J-type
    "JAL": {"type": "J", "opcode": 0x6F},

    # SYSTEM
    "ECALL": {"type": "SYS", "opcode": 0x73, "funct3": 0, "funct7": 0},
    "EBREAK": {"type": "SYS", "opcode": 0x73, "funct3": 0, "funct7": 1},
}

def set_bits(value, start, length):
    mask = (1 << length) - 1
    return (value & mask) << start

def encode_r_type(opcode, rd, funct3, rs1, rs2, funct7):
    instr = set_bits(opcode, 0, 7)
    instr |= set_bits(rd, 7, 5)
    instr |= set_bits(funct3, 12, 3)
    instr |= set_bits(rs1, 15, 5)
    instr |= set_bits(rs2, 20, 5)
    instr |= set_bits(funct7, 25, 7)
    return instr

def encode_i_type(opcode, rd, funct3, rs1, imm12):
    imm12 &= 0xFFF
    instr = set_bits(opcode, 0, 7)
    instr |= set_bits(rd, 7, 5)
    instr |= set_bits(funct3, 12, 3)
    instr |= set_bits(rs1, 15, 5)
    instr |= set_bits(imm12, 20, 12)
    return instr

def encode_i_type_shift(opcode, rd, funct3, rs1, shamt, funct7):
    # shamt is 5 bits
    instr = set_bits(opcode, 0, 7)
    instr |= set_bits(rd, 7, 5)
    instr |= set_bits(funct3, 12, 3)
    instr |= set_bits(rs1, 15, 5)
    instr |= set_bits(shamt, 20, 5)
    instr |= set_bits(funct7, 25, 7)
    return instr

def encode_s_type(opcode, funct3, rs1, rs2, imm12):
    imm_4_0 = imm12 & 0x1F
    imm_11_5 = (imm12 >> 5) & 0x7F
    instr = set_bits(opcode, 0, 7)
    instr |= set_bits(imm_4_0, 7, 5)
    instr |= set_bits(funct3, 12, 3)
    instr |= set_bits(rs1, 15, 5)
    instr |= set_bits(rs2, 20, 5)
    instr |= set_bits(imm_11_5, 25, 7)
    return instr

def encode_b_type(opcode, funct3, rs1, rs2, imm13):
    imm_11 = (imm13 >> 11) & 0x1
    imm_4_1 = (imm13 >> 1) & 0xF
    imm_10_5 = (imm13 >> 5) & 0x3F
    imm_12 = (imm13 >> 12) & 0x1
    instr = set_bits(opcode, 0, 7)
    instr |= set_bits(imm_11, 7, 1)
    instr |= set_bits(imm_4_1, 8, 4)
    instr |= set_bits(funct3, 12, 3)
    instr |= set_bits(rs1, 15, 5)
    instr |= set_bits(rs2, 20, 5)
    instr |= set_bits(imm_10_5, 25, 6)
    instr |= set_bits(imm_12, 31, 1)
    return instr

def encode_u_type(opcode, rd, imm20):
    imm20 &= 0xFFFFF
    instr = set_bits(opcode, 0, 7)
    instr |= set_bits(rd, 7, 5)
    instr |= set_bits(imm20, 12, 20)
    return instr

def encode_j_type(opcode, rd, imm21):
    imm_20 = (imm21 >> 20) & 0x1
    imm_10_1 = (imm21 >> 1) & 0x3FF
    imm_11 = (imm21 >> 11) & 0x1
    imm_19_12 = (imm21 >> 12) & 0xFF
    instr = set_bits(opcode, 0, 7)
    instr |= set_bits(rd, 7, 5)
    instr |= set_bits(imm_19_12, 12, 8)
    instr |= set_bits(imm_11, 20, 1)
    instr |= set_bits(imm_10_1, 21, 10)
    instr |= set_bits(imm_20, 31, 1)
    return instr

def encode_system(opcode, funct3, funct7):
    imm = 0 if funct7 == 0 else 1
    instr = (imm << 20) | (funct7 << 25) | (funct3 << 12) | opcode
    return instr

def parse_register(reg):
    reg = reg.strip()
    if reg not in registers:
        raise ValueError(f"Unknown register: {reg}")
    return registers[reg]

def parse_imm(imm_str):
    imm_str = imm_str.strip()
    if imm_str.startswith("0x") or imm_str.startswith("0X"):
        return int(imm_str, 16)
    return int(imm_str)

def assemble_instruction(line, labels, current_addr):
    line = line.split("#")[0].strip()
    if not line:
        return None
    parts = line.replace(',', ' ').replace('(', ' ').replace(')', ' ').split()
    mnemonic = parts[0].upper()

    if mnemonic == "ECALL":
        return encode_system(0x73, 0, 0)
    if mnemonic == "EBREAK":
        return encode_system(0x73, 0, 1)

    inst_info = instructions.get(mnemonic)
    if not inst_info:
        raise ValueError(f"Unsupported instruction: {mnemonic}")
    t = inst_info["type"]

    # R-type
    if t == "R":
        rd = parse_register(parts[1])
        rs1 = parse_register(parts[2])
        rs2 = parse_register(parts[3])
        return encode_r_type(inst_info["opcode"], rd, inst_info["funct3"], rs1, rs2, inst_info["funct7"])

    # I-type arithmetic and loads, JALR
    elif t == "I":
        if mnemonic == "JALR":
            rd = parse_register(parts[1])
            imm = parse_imm(parts[2])
            rs1 = parse_register(parts[3])
            return encode_i_type(inst_info["opcode"], rd, inst_info["funct3"], rs1, imm)
        else:
            rd = parse_register(parts[1])
            rs1 = parse_register(parts[2])
            imm_str = parts[3]
            if imm_str in labels:
                imm = labels[imm_str] - (current_addr + 4)
            else:
                imm = parse_imm(imm_str)
            return encode_i_type(inst_info["opcode"], rd, inst_info["funct3"], rs1, imm)

    # I-type shifts
    elif t == "I-shift":
        rd = parse_register(parts[1])
        rs1 = parse_register(parts[2])
        shamt = parse_imm(parts[3])
        return encode_i_type_shift(inst_info["opcode"], rd, inst_info["funct3"], rs1, shamt, inst_info["funct7"])

    # I-loads
    elif t == "I-load":
        rd = parse_register(parts[1])
        imm = parse_imm(parts[2])
        rs1 = parse_register(parts[3])
        return encode_i_type(inst_info["opcode"], rd, inst_info["funct3"], rs1, imm)

    # S-type stores
    elif t == "S":
        rs2 = parse_register(parts[1])
        imm = parse_imm(parts[2])
        rs1 = parse_register(parts[3])
        return encode_s_type(inst_info["opcode"], inst_info["funct3"], rs1, rs2, imm)

    # B-type branches
    elif t == "B":
        rs1 = parse_register(parts[1])
        rs2 = parse_register(parts[2])
        label = parts[3]
        if label not in labels:
            raise ValueError(f"Label '{label}' not found")
        offset = labels[label] - current_addr
        return encode_b_type(inst_info["opcode"], inst_info["funct3"], rs1, rs2, offset)

    # U-type
    elif t == "U":
        rd = parse_register(parts[1])
        imm_str = parts[2]
        if imm_str in labels:
            imm = labels[imm_str]
        else:
            imm = parse_imm(imm_str)
        return encode_u_type(inst_info["opcode"], rd, imm)

    # J-type
    elif t == "J":
        rd = parse_register(parts[1])
        label = parts[2]
        if label not in labels:
            raise ValueError(f"Label '{label}' not found")
        offset = labels[label] - current_addr
        return encode_j_type(inst_info["opcode"], rd, offset)

    else:
        raise NotImplementedError(f"Instruction format {t} not implemented")

def assemble(asm_lines):
    labels = {}
    instructions_bin = []
    addr = 0
    # First pass: label addresses
    for line in asm_lines:
        line = line.split("#")[0].strip()
        if not line:
            continue
        if line.endswith(":"):
            label = line[:-1]
            labels[label] = addr
        else:
            addr += 4
    addr = 0
    for line in asm_lines:
        line = line.strip()
        if not line or line.endswith(":"):
            continue
        machine_code = assemble_instruction(line, labels, addr)
        if machine_code is not None:
            instructions_bin.append((addr, machine_code))
            addr += 4
    return instructions_bin

def process_file(filepath, verbose=False):
    with open(filepath, "r") as f:
        asm_lines = f.readlines()
    output = assemble(asm_lines)
    base, _ = os.path.splitext(filepath)
    hex_filename = base + ".hex"
    with open(hex_filename, "w") as fout:
        for addr, code in output:
            hex_line = f"{code:08x}"
            fout.write(hex_line + "\n")
            if verbose:
                print(f"{addr:08x}: {hex_line}")

def main():
    import sys
    SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
    parser = argparse.ArgumentParser(description="Full-featured RISC-V RV32I assembler")
    parser.add_argument("-v", "--verbose", action="store_true", help="Print assembly output to stdout")
    args = parser.parse_args()

    txt_files = glob.glob(os.path.join(SCRIPT_DIR, "*.txt"))
    if not txt_files:
        print(f"No .txt assembly files found in {SCRIPT_DIR}")
        sys.exit(1)

    for filepath in txt_files:
        if args.verbose:
            print(f"Assembling {filepath}...")
        process_file(filepath, verbose=args.verbose)

if __name__ == "__main__":
    main()
