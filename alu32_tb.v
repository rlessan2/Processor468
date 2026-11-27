`timescale 1ns/1ps

module alu32_tb;

    reg  [31:0] a;
    reg  [31:0] b;
    reg  [15:0] imm_shift;
    reg  [3:0]  opcode;
    reg  [3:0]  cond;
    reg  [2:0]  sr_ctrl;
    reg         s_bit;
    reg  [3:0]  flags_in;

    wire [31:0] result;
    wire [3:0]  flags_out;
    wire        write_en;

    // Instantiate Top-Level ALU
    alu_top #(.SHAMT_LSB(0)) uut (
        .a         (a),
        .b         (b),
        .imm_shift (imm_shift),
        .opcode    (opcode),
        .cond      (cond),
        .sr_ctrl   (sr_ctrl),
        .s_bit     (s_bit),
        .flags_in  (flags_in),
        .result    (result),
        .flags_out (flags_out),
        .write_en  (write_en)
    );

initial begin
        // All zeros so initial state is clear on waveform
        a = 32'h0000_0000; b = 32'h0000_0000; imm_shift = 16'd0;
        opcode = 4'b1111; cond = 4'b0000; sr_ctrl = 3'b000;
        s_bit = 1'b0; flags_in = 4'b0000;
        #10;

        // ORR (0011) with No Shift (000)
        a = 32'hD0D0_00DD; b = 32'h0D0D_00D0;
        imm_shift = 16'd0; sr_ctrl = 3'b000;
        opcode = 4'b0011; cond = 4'b0000;
        #10;

        // AND (0100) with No Shift (000)
        opcode = 4'b0100;
        #10;

        // XOR (0101) with No Shift (000)
        opcode = 4'b0101;
        #10;

        // AND (0100) with LSL #1 (sr_ctrl = 010)
        imm_shift = 16'd1; sr_ctrl = 3'b010;
        opcode = 4'b0100;
        #10;

        // ORR (0011) with LSR #1 (sr_ctrl = 001)
        imm_shift = 16'd1; sr_ctrl = 3'b001;
        opcode = 4'b0011;
        #10;

        // XOR (0101) with ROR #1 (sr_ctrl = 011)
        a = 32'h0F00_0000; b = 32'h8000_000F;
        imm_shift = 16'd1; sr_ctrl = 3'b011;
        opcode = 4'b0101;
        #10;

        // MOV Immediate (0110) with imm_shift = 14 (0x000E)
        imm_shift = 16'd14; sr_ctrl = 3'b000;
        opcode = 4'b0110;
        #10;

        // MOV Register (0111) with ROR #1 (sr_ctrl = 011) on b = 8000000f
        imm_shift = 16'd1; sr_ctrl = 3'b011;
        opcode = 4'b0111;
        #10;

        // Condition Check FAIL (Cond = 0001 EQ, flags_in = 0010 where Z=0)
        // Forces NOP
        cond = 4'b0001; flags_in = 4'b0010; s_bit = 1'b1;
        opcode = 4'b0011; sr_ctrl = 3'b000;
        #10;

        // Condition Check PASS (Cond = 0001 EQ, flags_in = 0100 where Z=1)
        // Executes
        flags_in = 4'b0100; s_bit = 1'b0;
        #10;

        $stop;
    end

endmodule