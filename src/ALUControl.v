// ALUControl.v
// Decodes ALU operation signals for RV32I instructions
// Inputs:
// - alu_op: 2-bit code from Control Unit indicating operation type category
// - funct3: 3-bit funct3 field from instruction (specifies operation variant)
// - funct7: 7-bit funct7 field from instruction (further operation details)
//
// Output:
// - alu_control: 4-bit ALU operation code selecting exact ALU behavior
module ALUControl(
    input wire [1:0] alu_op,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    output reg [3:0] alu_control
);

    /*
    ALU Operation Encoding:
    0000 = ADD
    0001 = SUB
    0010 = SLL (shift left logical)
    0011 = SLT (set less than signed)
    0100 = SLTU (set less than unsigned)
    0101 = XOR
    0110 = SRL (shift right logical)
    0111 = SRA (shift right arithmetic)
    1000 = OR
    1001 = AND
    */

    always @(*) begin
        case (alu_op)
            2'b00: alu_control = 4'b0000; // For loads/stores (ADD for address calculation)
            2'b01: alu_control = 4'b0001; // For branches (SUB used to compare)
            2'b10: begin // R-type or I-type arithmetic
                case (funct3)
                    3'b000: alu_control = (funct7 == 7'b0100000) ? 4'b0001 : 4'b0000; // SUB if funct7=0x20 else ADD
                    3'b001: alu_control = 4'b0010; // SLL
                    3'b010: alu_control = 4'b0011; // SLT
                    3'b011: alu_control = 4'b0100; // SLTU
                    3'b100: alu_control = 4'b0101; // XOR
                    3'b101: alu_control = (funct7 == 7'b0100000) ? 4'b0111 : 4'b0110; // SRA if funct7=0x20 else SRL
                    3'b110: alu_control = 4'b1000; // OR
                    3'b111: alu_control = 4'b1001; // AND
                    default: alu_control = 4'b0000;
                endcase
            end
            default: alu_control = 4'b0000;
        endcase
    end
endmodule
