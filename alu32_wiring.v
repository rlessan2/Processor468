//ENGR 468 - Milestone 1
module alu_top #(
    parameter SHAMT_LSB = 3
) (
    input  wire [31:0] a,          // Source Register_1 (32-bit)
    input  wire [31:0] b,          // Source Register_2 (32-bit)
    input  wire [15:0] imm_shift,  // Immediate Value / Shift Bits (16-bit)
    input  wire [3:0]  opcode,     // Op-Code (Bits 27-24)
    input  wire [3:0]  cond,       // Condition Code (Bits 31-28)
    input  wire [2:0]  sr_ctrl,    // S/R Control (Bits 2-0)
    input  wire        s_bit,      // S-bit (Bit 23)
    input  wire [3:0]  flags_in,   // Current status flags {N, Z, C, V}
    output wire [31:0] result,     // 32-bit ALU Result
    output wire [3:0]  flags_out,  // Updated status flags {N, Z, C, V}
    output wire [3:0]  computed_flags,  // Computed status flags {N, Z, C, V} before gating
    output wire        write_en    // 1 = valid register writeback, 0 = forced NOP
);

    // Extract 5-bit shift amount from the 16-bit Immediate/Shift bus
    wire [4:0] shamt = imm_shift[SHAMT_LSB +: 5];

    // Internal wires
    wire [31:0] b_shifted;
    wire [31:0] add_res, sub_res, mul_res;
    wire [31:0] or_res, and_res, xor_res;
    wire [31:0] mov_imm_res, mov_reg_res;
    wire        add_c, sub_c, mul_c;  // sub_c = 1 means borrow (subtractor convention)
    wire        carry_for_flag;
    wire        f_c, f_v, f_z, f_n, flag_en;
    wire        cond_met;

    // ------------------------------------------------------------------------
    // STAGE 1: SHIFT-BEFORE-OPERATE ON SOURCE REGISTER 2
    // "Any shift or rotate operations should be performed on source register-2."
    // ------------------------------------------------------------------------
    shift_stage_mux #(.WIDTH(32)) u_shifter_stage (
        .b         (b),
        .shamt     (shamt),
        .sr_ctrl   (sr_ctrl),
        .b_shifted (b_shifted)
    );

    // ------------------------------------------------------------------------
    // STAGE 2A: LOGIC & MOV SUBMODULES
    // ------------------------------------------------------------------------
    alu_or      u_or      (.a(a), .b(b_shifted),      .result(or_res));
    alu_and     u_and     (.a(a), .b(b_shifted),      .result(and_res));
    alu_xor     u_xor     (.a(a), .b(b_shifted),      .result(xor_res));
    alu_mov_imm u_mov_imm (.imm16(imm_shift),         .result(mov_imm_res));
    alu_mov_reg u_mov_reg (.b_shifted(b_shifted),     .result(mov_reg_res));

    // ------------------------------------------------------------------------
    // STAGE 2B: ARITHMETIC SUBMODULES AREN'T MY RESPONSIBILITY BUT I WILL SHOW
    // THEM WIRED UP TO SHOW COMPLTETE WIRING. NAMES OF THE SUBMODULES ARE SUBJECT
    // TO CHANGE WHEN ALL STUDENTS' PARTS ARE PUT TOGETHER.
    // ------------------------------------------------------------------------
    adder      u_add (.in1(a), .in2(b_shifted), .cin(1'b0), .out(add_res), .c(add_c));
    subtractor u_sub (.in1(a), .in2(b_shifted),             .out(sub_res), .c(sub_c));
    multiplier u_mul (.in1(a), .in2(b_shifted),             .out(mul_res), .cout(mul_c));

    // Overflow (V) is computed inside the flag module, so only carries are needed here.
    // For SUB/CMP, C = 1 means a borrow happened (a < b, unsigned).
    assign carry_for_flag =
        (opcode == 4'b0000) ? add_c :
        ((opcode == 4'b0001) || (opcode == 4'b1011)) ? sub_c :
        (opcode == 4'b0010) ? mul_c : 1'b0;

    // ------------------------------------------------------------------------
    // STAGE 3: CONDITION CHECK & 16x1 OPCODE MUX
    // ------------------------------------------------------------------------
    condition_check u_cond (.flags (flags_in), .cond(cond), .cond_met (cond_met));

    opcode_mux u_mux (
        .opcode         (opcode),
        .cond_met       (cond_met),
        .add_result     (add_res),
        .sub_result     (sub_res),
        .mul_result     (mul_res),
        .or_result      (or_res),
        .and_result     (and_res),
        .xor_result     (xor_res),
        .mov_imm_result (mov_imm_res),
        .mov_reg_result (mov_reg_res),
        .ldr_addr       (a),
        .str_data       (b_shifted),
        .result         (result),
        .write_en       (write_en)
    );

    // ------------------------------------------------------------------------
    // STAGE 4: FLAG GENERATOR ISN'T MY RESPONSIBILITY BUT I WILL SHOW IT WIRED
    // UP TO SHOW COMPLETE WIRING. NAMES OF THE SUBMODULES ARE SUBJECT TO CHANGE
    // WHEN ALL STUDENTS PARTS ARE PUT TOGETHER.
    // ------------------------------------------------------------------------
    flag u_flags (
        .OP(opcode),
        .in1(a),
        .in2(b_shifted),
        .result(result),
        .mod_c(carry_for_flag),
        .s(s_bit),
        .c(f_c),
        .v(f_v),
        .z(f_z),
        .n(f_n),
        .flag_en(flag_en)
    );
    // Flags change only if the flag module allows it (S=1 or CMP) AND the instruction ran
    assign computed_flags = flag_en ? {f_n, f_z, f_c, f_v} : flags_in;
    assign flags_out      = (cond_met && (opcode != 4'b1111)) ? computed_flags : flags_in;
endmodule
