module adder(in1, in2, cin, c, out);
input [31:0] in1,in2;
input cin;
output c;
output[31:0] out;
assign {c, out} = cin + in1 + in2;
endmodule
