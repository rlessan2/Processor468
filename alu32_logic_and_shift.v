//ENGR 468 - Milestone 1
module alu_or(
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] result
);
    assign result = a | b;
endmodule

module alu_and(
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] result
);
    assign result = a & b;
endmodule

module alu_xor(
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] result
);
    assign result = a ^ b;
endmodule

module right_shift #(
    parameter WIDTH = 32
) (
    input  wire [WIDTH-1:0] a,
    input  wire [4:0]       shamt,
    output wire [WIDTH-1:0] result
);
    assign result = a >> shamt;
endmodule

module left_shift #(
    parameter WIDTH = 32
) (
    input  wire [WIDTH-1:0] a,
    input  wire [4:0]       shamt,
    output wire [WIDTH-1:0] result
);
    assign result = a << shamt;
endmodule

module alu_mov_imm (
    input  wire [15:0] imm16,
    output wire [31:0] result
);
    assign result = {16'b0, imm16};
endmodule

module alu_mov_reg (
    input  wire [31:0] b_shifted,
    output wire [31:0] result
);
    assign result = b_shifted;
endmodule

module rotate_right #(
    parameter WIDTH = 32
) (
    input  wire [WIDTH-1:0] a,
    input  wire [4:0]       shamt,
    output wire [WIDTH-1:0] result
);
    assign result = (shamt == 5'd0) ? a : ((a >> shamt) | (a << (WIDTH - shamt)));
endmodule

module shift_stage_mux #(
    parameter WIDTH = 32
) (
    input  wire [WIDTH-1:0] b,
    input  wire [4:0]       shamt,
    input  wire [2:0]       sr_ctrl,
    output reg  [WIDTH-1:0] b_shifted
);
    wire [WIDTH-1:0] lsr_out;
    wire [WIDTH-1:0] lsl_out;
    wire [WIDTH-1:0] ror_out;

    right_shift  #(.WIDTH(WIDTH)) u_lsr (.a(b), .shamt(shamt), .result(lsr_out));
    left_shift   #(.WIDTH(WIDTH)) u_lsl (.a(b), .shamt(shamt), .result(lsl_out));
    rotate_right #(.WIDTH(WIDTH)) u_ror (.a(b), .shamt(shamt), .result(ror_out));

    always @(*) begin
        case (sr_ctrl)
            3'b000:  b_shifted = b;       // No Shift/Rotate
            3'b001:  b_shifted = lsr_out; // Logical Shift Right
            3'b010:  b_shifted = lsl_out; // Logical Shift Left
            3'b011:  b_shifted = ror_out; // Rotate Right
            default: b_shifted = b;       // Default / 100 unused
        endcase
    end
endmodule