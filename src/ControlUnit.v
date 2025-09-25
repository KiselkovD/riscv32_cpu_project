// ControlUnit.v
module ControlUnit(
    input wire [31:0] instruction,
    output reg reg_write,
    output reg alu_src,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg branch,
    output reg [1:0] alu_op,
    output reg [2:0] branch_funct3,
    output reg trap
);

// Decode instruction fields for RV32I Base instructions
wire [6:0] opcode = instruction[6:0];
wire [2:0] funct3 = instruction[14:12];
wire [6:0] funct7 = instruction[31:25];
wire [11:0] funct12 = instruction[31:20]; // For SYSTEM instructions (ECALL, EBREAK)

always @(*) begin
    // Defaults (no instruction)
    reg_write = 0;
    alu_src = 0;
    mem_read = 0;
    mem_write = 0;
    mem_to_reg = 0;
    branch = 0;
    alu_op = 2'b00;
    branch_funct3 = funct3;
    trap = 0;

    // SYSTEM instructions (ECALL, EBREAK) from RV32I Base
    if (opcode == 7'b1110011) begin
        if (funct12 == 12'b000000000000)  // ECALL instruction, triggers trap
            trap = 1;
        else if (funct12 == 12'b000000000001) // EBREAK instruction, triggers trap
            trap = 1;
    end else begin
        case(opcode)
            7'b0110011: begin // R-type RV32I instructions: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
                reg_write = 1;
                alu_src = 0;       // Operand2 from register rs2
                alu_op = 2'b10;    // ALU control for R-type ops
            end
            
            7'b0010011: begin // I-type ALU immediate instructions: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
                reg_write = 1;
                alu_src = 1;       // Operand2 from immediate
                alu_op = 2'b10;    // ALU control for immediate ops
            end
            
            7'b0000011: begin // Load instructions: LB, LH, LW, LBU, LHU
                reg_write = 1;
                alu_src = 1;       // Calculate address with immediate
                mem_read = 1;
                mem_to_reg = 1;    // Write memory data back to register
                alu_op = 2'b00;    // ALU does ADD for address calculation
            end
            
            7'b0100011: begin // Store instructions: SB, SH, SW
                alu_src = 1;       // Calculate address with immediate
                mem_write = 1;
                alu_op = 2'b00;    // ALU does ADD for address calculation
            end
            
            7'b1100011: begin // Branch instructions: BEQ, BNE, BLT, BGE, BLTU, BGEU
                branch = 1;
                alu_src = 0;       // Compare registers rs1 and rs2
                alu_op = 2'b01;    // ALU control for branch compare
                branch_funct3 = funct3; // Pass branch type
            end
            
            7'b1101111: begin // JAL instruction
                reg_write = 1;
                alu_src = 0;
                alu_op = 2'b00;    // No ALU operation required, PC+imm used for jump
            end
            
            7'b1100111: begin // JALR instruction
                reg_write = 1;
                alu_src = 1;
                alu_op = 2'b00;
            end
            
            7'b0110111: begin // LUI (Load Upper Immediate)
                reg_write = 1;
                alu_src = 1;
                alu_op = 2'b00;
            end
            
            7'b0010111: begin // AUIPC (Add Upper Immediate to PC)
                reg_write = 1;
                alu_src = 1;
                alu_op = 2'b00;
            end
            
            default: begin
                // Unknown opcode: do nothing
                reg_write = 0;
                alu_src = 0;
                mem_read = 0;
                mem_write = 0;
                mem_to_reg = 0;
                branch = 0;
                alu_op = 2'b00;
                branch_funct3 = 3'b000;
                trap = 0;
            end
        endcase
    end
end

endmodule
