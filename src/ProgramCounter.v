// ProgramCounter.v
// Synchronous register holding the PC value.
// PC updated every clock cycle or reset asynchronously.
// Matches the invariant of RV32I where PC increments in 4-byte steps or jumps.
module ProgramCounter(
    input wire clk,               // Clock signal
    input wire reset,             // Active high synchronous reset to zero PC
    input wire [31:0] pc_next,   // Next PC value to load
    output reg [31:0] pc         // Current PC value output
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'b0;         // Reset PC to address 0 
        else
            pc <= pc_next;       // Update PC to next value
    end

endmodule