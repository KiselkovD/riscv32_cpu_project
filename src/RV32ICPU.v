module RV32ICPU(
    input wire clk,
    input wire reset
);

    reg [31:0] cycle_count;
    reg [31:0] prev_pc;
    reg [31:0] pc;

    wire [31:0] pc_plus4;
    wire [31:0] pc_next;
    wire [31:0] instruction;

    wire reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, trap;
    wire [1:0] alu_op;
    wire [3:0] alu_control;
    wire [2:0] branch_funct3;

    wire [31:0] imm;

    wire [31:0] rs1_data, rs2_data;
    wire [31:0] alu_operand2, alu_result;
    wire alu_zero;

    wire branch_taken;
    wire take_branch;

    wire [31:0] mem_read_data;
    wire [31:0] trap_vector = 32'h00000010;

    wire jump;
    wire [31:0] jump_target;
    wire [31:0] branch_target;

    assign pc_plus4 = pc + 4;

    // Instruction Memory instance
    InstructionMemory imem(
        .address(pc),
        .instruction(instruction)
    );

    // Control Unit instance
    ControlUnit ctrl(
        .instruction(instruction),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .alu_op(alu_op),
        .branch_funct3(branch_funct3),
        .trap(trap)
    );

    // ALU Control
    ALUControl aluctrl(
        .alu_op(alu_op),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .alu_control(alu_control)
    );

    // Register File write data mux for jal/jalr to write pc+4 (return address)
    wire jal_or_jalr = (instruction[6:0] == 7'b1101111) || (instruction[6:0] == 7'b1100111);
    wire [31:0] reg_write_data = jal_or_jalr ? pc_plus4 : (mem_to_reg ? mem_read_data : alu_result);

    // Register File instance
    RegisterFile regfile(
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write),
        .rs1_addr(instruction[19:15]),
        .rs2_addr(instruction[24:20]),
        .rd_addr(instruction[11:7]),
        .write_data(reg_write_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // Immediate Generator
    ImmediateGenerator immgen(
        .instruction(instruction),
        .imm(imm)
    );

    assign alu_operand2 = alu_src ? imm : rs2_data;

    // ALU instance
    ALU alu(
        .a(rs1_data),
        .b(alu_operand2),
        .alu_op(alu_control),
        .result(alu_result),
        .zero(alu_zero)
    );

    // Branch Comparator instance
    BranchComparator br_comp(
        .rs1(rs1_data),
        .rs2(rs2_data),
        .funct3(branch_funct3),
        .branch_taken(branch_taken)
    );
    assign take_branch = branch & branch_taken;

    // Data Memory
    DataMemory dmem(
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(alu_result),
        .write_data(rs2_data),
        .read_data(mem_read_data)
    );

    // Jump detection for jal, jalr
    assign jump = jal_or_jalr;

    // Calculate branch target PC
    assign branch_target = pc + imm;

    // Calculate jal and jalr jump targets
    wire [31:0] jal_target = pc + imm;                   // JAL uses J-type immediate
    wire [31:0] jalr_target = (rs1_data + imm) & 32'hfffffffe; // JALR uses I-type immediate with masked LSB

    assign jump_target = (instruction[6:0] == 7'b1101111) ? jal_target : jalr_target;

    // PC next selection logic
    assign pc_next = trap ? trap_vector :
                     jump ? jump_target :
                     take_branch ? branch_target :
                     pc_plus4;

    // PC and cycle counter update
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 0;
            cycle_count <= 0;
            prev_pc <= 0;
        end else begin
            pc <= pc_next;
            cycle_count <= cycle_count + 1;
            prev_pc <= pc_next;
        end
    end

    // Debug logging for jal related operations
    always @(posedge clk) begin
        if(jal_or_jalr) begin
            $display("---- JUMP Detected at PC=0x%08h ----", pc);
            $display("Instruction=0x%08h", instruction);
            $display("Jump target=0x%08h, PC+4=0x%08h", jump_target, pc_plus4);
            $display("Write reg %0d with 0x%08h (return address)", instruction[11:7], pc_plus4);
        end
        $display("Cycle %0d: PC=0x%08h Instruction=0x%08h Jump=%b Branch=%b Trap=%b",
                 cycle_count, pc_next, instruction, jump, take_branch, trap);
    end

    // Simulation logging / debug printing
    always @(posedge clk) begin
        if (pc_next != prev_pc) begin
            $display("\nCycle %0d | Time: %0t", cycle_count, $time);
            $display(" PC = 0x%08h Instruction = 0x%08h Trap = %b", pc_next, instruction, trap);
            $display(" Opcode=0x%02h funct3=0x%01h funct7=0x%02h rd=%0d rs1=%0d rs2=%0d",
                instruction[6:0], instruction[14:12], instruction[31:25], instruction[11:7], instruction[19:15], instruction[24:20]);
            $display(" RS1=0x%08h RS2=0x%08h", rs1_data, rs2_data);
            $display(" ALU ctrl=0b%b op2=0x%08h result=0x%08h zero=%b",
                alu_control, alu_operand2, alu_result, alu_zero);
            if(mem_read)
                $display(" MemRead: addr=0x%08h data=0x%08h", alu_result, mem_read_data);
            if(mem_write)
                $display(" MemWrite: addr=0x%08h data=0x%08h", alu_result, rs2_data);
            if(reg_write)
                $display(" RegWrite: rd=%0d data=0x%08h", instruction[11:7], mem_to_reg ? mem_read_data : alu_result);
            $display(" Control: reg_write=%b alu_src=%b mem_read=%b mem_write=%b mem_to_reg=%b branch=%b alu_op=0b%b",
                reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, alu_op);
            $display(" PC_next=0x%08h jump=%b take_branch=%b branch_target=0x%08h jump_target=0x%08h",
                pc_next, jump, take_branch, branch_target, jump_target);

            prev_pc <= pc_next;
        end
    end

endmodule
