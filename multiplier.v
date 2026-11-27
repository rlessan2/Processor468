module multiplier(in1, in2, cout, out);
input [31:0] in1,in2;
output cout;
output [31:0] out;
wire [31:0] carry;
assign {carry, out} = in1 * in2;
assign cout = |carry;
endmodule