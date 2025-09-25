// ALU.v
// Arithmetic Logic Unit for RV32I Base Integer Instruction Set
// Performs operations such as ADD, SUB, logical AND, OR, XOR, shifts, and set less than.
//
// Inputs:
// - a: 32-bit operand 1 (usually rs1)
// - b: 32-bit operand 2 (usually rs2 or immediate)
// - alu_op: 4-bit control signal from ALUControl module specifying operation
//
// Outputs:
// - result: 32-bit ALU result
// - zero: 1 if result == 0 (used for branch decisions)

module ALU(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] alu_op,
    output reg [31:0] result,
    output wire zero
);

    // Compute result combinationally based on alu_op
    always @(*) begin
        case (alu_op)
            4'b0000: result = a + b;                    // ADD
            4'b0001: result = a - b;                    // SUB
            4'b0010: result = a << b[4:0];              // SLL (shift left logical)
            4'b0011: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;  // SLT (signed)
            4'b0100: result = (a < b) ? 32'd1 : 32'd0; // SLTU (unsigned)
            4'b0101: result = a ^ b;                    // XOR
            4'b0110: result = a >> b[4:0];              // SRL (shift right logical)
            4'b0111: result = $signed(a) >>> b[4:0];   // SRA (shift right arithmetic)
            4'b1000: result = a | b;                    // OR
            4'b1001: result = a & b;                    // AND
            default: result = 32'b0;
        endcase
    end

    // Zero flag (used in branch conditions)
    assign zero = (result == 0) ? 1'b1 : 1'b0;

endmodule
