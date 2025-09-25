module RegisterFile(
    input wire clk,
    input wire reset,
    input wire reg_write,
    input wire [4:0] rs1_addr,
    input wire [4:0] rs2_addr,
    input wire [4:0] rd_addr,
    input wire [31:0] write_data,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data
);

    reg [31:0] registers [0:31];
    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end else if (reg_write && (rd_addr != 0)) begin
            registers[rd_addr] <= write_data;
            $display("RegisterFile: Write x%0d = 0x%08h", rd_addr, write_data);
        end
    end

    assign rs1_data = (rs1_addr == 0) ? 32'b0 : registers[rs1_addr];
    assign rs2_data = (rs2_addr == 0) ? 32'b0 : registers[rs2_addr];

    // Periodically print all registers (optional and verbose)
    always @(posedge clk) begin
        $write("RegisterFile State: ");
        for (i = 0; i < 32; i = i + 1) begin
            $write("x%0d=0x%08h ", i, registers[i]);
        end
        $write("\n");
    end

endmodule
