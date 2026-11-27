`timescale 1ns/1ps

// ENGR 468 - Milestone 1

module alu32_subtb;

    // Shared inputs
    reg  [31:0] a, b;
    reg  [4:0]  shamt;
    reg  [2:0]  sr_ctrl;
    reg  [15:0] imm16;
    reg  [3:0]  flags;
    reg  [3:0]  cond;
    reg  [3:0]  opcode;

    // Submodule outputs
    wire [31:0] or_out, and_out, xor_out;
    wire [31:0] lsr_out, lsl_out, ror_out, stage_shift_out;
    wire [31:0] mov_imm_out, mov_reg_out;
    wire        cond_met;
    wire [31:0] mux_result;
    wire        mux_write_en;

    // Instantiate All Submodules
    alu_or  u_or  (.a(a), .b(b), .result(or_out));
    alu_and u_and (.a(a), .b(b), .result(and_out));
    alu_xor u_xor (.a(a), .b(b), .result(xor_out));

    right_shift     #(.WIDTH(32)) u_lsr   (.a(b), .shamt(shamt), .result(lsr_out));
    left_shift      #(.WIDTH(32)) u_lsl   (.a(b), .shamt(shamt), .result(lsl_out));
    rotate_right    #(.WIDTH(32)) u_ror   (.a(b), .shamt(shamt), .result(ror_out));
    shift_stage_mux #(.WIDTH(32)) u_stage (.b(b), .shamt(shamt), .sr_ctrl(sr_ctrl), .b_shifted(stage_shift_out));

    alu_mov_imm u_mov_imm (.imm16(imm16), .result(mov_imm_out));
    alu_mov_reg u_mov_reg (.b_shifted(stage_shift_out), .result(mov_reg_out));

    condition_check u_cond (
        .flags    (flags),
        .cond     (cond),
        .cond_met (cond_met)
    );

    opcode_mux u_mux (
        .opcode         (opcode),
        .cond_met       (cond_met),
        .add_result     (32'hAAAA_0000),
        .sub_result     (32'hAAAA_0001),
        .mul_result     (32'hAAAA_0002),
        .or_result      (or_out),
        .and_result     (and_out),
        .xor_result     (xor_out),
        .mov_imm_result (mov_imm_out),
        .mov_reg_result (mov_reg_out),
        .ldr_addr       (a),
        .str_data       (b),
        .result         (mux_result),
        .write_en       (mux_write_en)
    );

   initial begin
        // Initialize all inputs
        a = 32'h0000_0000;
        b = 32'h0000_0000;
        shamt = 5'd0;
        sr_ctrl = 3'b000;
        imm16 = 16'h0000;
        flags = 4'b0000;
        cond  = 4'b0000;
        opcode = 4'b0011; // ORR
        #10;

        // change values to begin testing
        a = 32'hD0D0_00DD;
        b = 32'h0D0D_00D0;
        shamt = 5'd1;
        sr_ctrl = 3'b000;
        opcode = 4'b0011;
        #10;

        // Logic test #2 & Rotate Right

        a = 32'hFFFF_0000;
        b = 32'h8000_000F;
        shamt = 5'd1;
        sr_ctrl = 3'b001;
        opcode = 4'b0100;
        #10;

        // Step shift_stage_mux to LSL (010) and Opcode Mux to XOR (0101)
        sr_ctrl = 3'b010;
        opcode = 4'b0101;
        #10;

        // Step shift_stage_mux to ROR (011) and test MOV Immediate (0110)
        sr_ctrl = 3'b011;
        imm16 = 16'hABCD;
        opcode = 4'b0110;
        #10;

        // Test MOV Register (0111)
        imm16 = 16'h0019;
        opcode = 4'b0111;
        #10;

        // Condition Check PASS (0001 = EQ with Z=1)
        cond  = 4'b0001;
        flags = 4'b0100;
        opcode = 4'b0011;
        #10;

        // Condition Check FAIL (0001 = EQ with Z=0) which Forces NOP!
        flags = 4'b0000;
        #10;

        // Condition Check GT (0010) PASS (Z=0, N=0, V=0)
        cond  = 4'b0010;
        #10;

        // Condition Check LT (0011) PASS (N=1, V=0)
        cond  = 4'b0011;
        flags = 4'b1000;
        #10;

        $stop;
    end

endmodule
