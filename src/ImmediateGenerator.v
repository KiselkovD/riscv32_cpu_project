// ImmediateGenerator.v
// Extracts immediate values from different RV32I instruction formats and sign-extends to 32-bit.
//
// Inputs:
// - instruction: 32-bit instruction word
//
// Outputs:
// - imm: Sign-extended immediate value (32-bit)

module ImmediateGenerator(
    input wire [31:0] instruction,
    output reg [31:0] imm
);

    wire [6:0] opcode = instruction[6:0];

    always @(*) begin
        case(opcode)
            7'b0010011,  // I-type ALU immediate
            7'b0000011,  // I-type loads
            7'b1100111:  // JALR (I-type)
                imm = {{20{instruction[31]}}, instruction[31:20]};  // sign-extend bits 31:20

            7'b0100011:  // S-type stores
                imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // concat and sign-extend

            7'b1100011:  // B-type branches
                imm = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0}; // concat bits and zero LSB

            7'b0110111,  // LUI (U-type)
            7'b0010111:  // AUIPC (U-type)
                imm = {instruction[31:12], 12'b0};                 // upper 20 bits with zero lower bits

            7'b1101111: begin
                imm = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                $display("ImmediateGenerator: J-type immediate = 0x%08h", imm);
            end

            default:    // Default zero
                imm = 32'b0;
        endcase
    end

endmodule
