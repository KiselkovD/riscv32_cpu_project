`timescale 1ns / 1ps

// Testbench for RV32ICPU module
// Handles clock generation, reset sequencing, and simulation control
// Monitors PC, current instruction, and trap signal
// Ends simulation upon trap (ECALL/EBREAK) or timeout

module RV32ICPU_tb();

    // Clock and reset signals as regs for driving the CPU
    reg clk;
    reg reset;

    // Instantiate the RV32ICPU under test
    RV32ICPU cpu (
        .clk(clk),
        .reset(reset)
    );

    // Clock generator
    // Generates a 100MHz clock with 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle every 5ns for 10ns period
    end

    // Reset sequence
    // Assert reset high initially, then release it after 20ns
    initial begin
        reset = 1;
        #20;
        reset = 0;
    end

    // Optional: initialize Instruction Memory
    // Could add $readmemh here if InstrumentMemory module instance is accessible
    // e.g., initial $readmemh("program.hex", cpu.imem.memory);

    // Monitor PC, instruction, and trap on every clock change
    initial begin
        $monitor("Time: %0t | PC=0x%08h Instruction=0x%08h trap=%b",
                 $time, cpu.pc, cpu.instruction, cpu.trap);
    end

    // Trap detection process
    // On detection of a trap (e.g., ECALL or EBREAK), print info and end simulation
    initial begin
        forever begin
            @(posedge clk);
            if (cpu.trap) begin
                $display("Trap detected at time %0t, PC=0x%08h. Ending simulation.", $time, cpu.pc);
                #10;  // Wait a bit for log output before finishing
                $finish;
            end
        end
    end

    // Simulation timeout to prevent endless runs
    // Limits simulation time to 2000ns if no trap occurs
    initial begin
        #600;
        if (!cpu.trap) begin
            $display("Simulation timeout without trap, ending.");
            $finish;
        end
    end

endmodule
