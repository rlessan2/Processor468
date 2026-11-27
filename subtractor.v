module subtractor(in1, in2, c, out);
input [31:0] in1,in2;
wire [31:0] w1;
wire cout;
output[31:0] out;
output c;
assign w1 = ~in2;
adder s_adder(.in1(in1), .in2(w1), .cin(1'b1), .c(cout), .out(out));
assign c = ~cout; // subtractor carry is 1 when there is borrow
endmodule