module InstructionMemory(
    input wire [31:0] address,
    output reg [31:0] instruction
);

    reg [31:0] memory [0:255];
    integer i;

    initial begin
        for(i = 0; i < 256; i = i + 1)
            memory[i] = 32'h00000013;  // Initialize instruction memory to zero
        // Load program hex file from "programs/prog.hex" relative directory
        $readmemh("./programs/prog.hex", memory);

        // Fill uninitialized memory locations with NOP (ADDI x0, x0, 0)
        for (i = 0; i < 256; i = i + 1) begin
            if (memory[i] === 32'bx)
                memory[i] = 32'h00000013; // RV32I NOP instruction
        end

        // Example program commented out
        // memory[0] = 32'h00500093;  // addi x1, x0, 5
        // memory[1] = 32'h00a00113;  // addi x2, x0, 10
        // memory[2] = 32'h002081b3;  // add x3, x1, x2
        // memory[3] = 32'h00000073;  // ecall (system call)
    end

    // Instruction read combinational logic (word aligned address)
    always @(*) begin
        instruction = memory[address[9:2]];
    end

endmodule