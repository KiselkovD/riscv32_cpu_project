// BranchComparator.v
// Compares two registers for branch decisions according to RV32I branch instructions.
//
// Inputs:
// - rs1: First source register value (32-bit)
// - rs2: Second source register value (32-bit)
// - funct3: branch type field from instruction opcode `1100011`
// Outputs:
// - branch_taken: high if branch condition satisfied, else low

module BranchComparator(
    input wire [31:0] rs1,
    input wire [31:0] rs2,
    input wire [2:0] funct3,
    output reg branch_taken
);

    always @(*) begin
        case(funct3)
            3'b000: branch_taken = (rs1 == rs2);                  // BEQ: branch if equal
            3'b001: branch_taken = (rs1 != rs2);                  // BNE: branch if not equal
            3'b100: branch_taken = ($signed(rs1) < $signed(rs2)); // BLT: branch if less than (signed)
            3'b101: branch_taken = ($signed(rs1) >= $signed(rs2));// BGE: branch if greater or equal (signed)
            3'b110: branch_taken = (rs1 < rs2);                   // BLTU: branch if less than (unsigned)
            3'b111: branch_taken = (rs1 >= rs2);                  // BGEU: branch if greater or equal (unsigned)
            default: branch_taken = 1'b0;                          // Undefined funct3: no branch
        endcase
    end

endmodule
