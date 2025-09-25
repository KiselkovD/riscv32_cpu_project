// PCUpdate.v
// Module that updates the Program Counter (PC) based on jump, branch, or sequential execution.
// Implements PC update logic matching RV32I control flow instructions: jumps and branches.
module PCUpdate(
    input wire [31:0] pc_current,     // Current value of PC
    input wire branch,                // Branch control signal (active when a branch instruction)
    input wire zero_flag,             // Zero flag from ALU (used for branch condition)
    input wire jump,                  // Jump control signal (active when jump instruction)
    input wire [31:0] branch_target, // Computed branch target address
    input wire [31:0] jump_target,   // Computed jump target address
    output reg [31:0] pc_next        // Next PC value after update
);

    always @(*) begin
        if (jump)
            // For JAL and JALR instructions (Jump/Link)
            pc_next = jump_target;
        else if (branch && zero_flag)
            // For conditional branch instructions (BEQ, BNE, BLT, BGE, etc.)
            pc_next = branch_target;
        else
            // Sequential execution for non-branching instructions (+4 bytes to PC)
            pc_next = pc_current + 4;
    end

endmodule