`timescale 1ns / 1ps

module stimulus();

    // Clock and reset signals
    reg clk;
    reg reset;

    // Instantiate the CPU
    RV32ICPU cpu (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation: 10ns period (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus: Initialize reset and release it
    initial begin
        // Apply reset
        reset = 1;
        #20;      // Hold reset for 20 ns

        // Release reset
        reset = 0;

        // Let CPU run for some cycles
        #500;

        // End simulation
        $stop;
    end

endmodule
