module adder_tb;
    reg  [31:0] in1, in2;
    reg  cin;
    wire [31:0] out;
    wire c;

    initial begin
        in1 = 32'd9; in2 = 32'd8; cin = 1'b0; // simple add
        #10 in1 = 32'd0; in2 = 32'd0; cin = 1'b0; // zero
        #10 in1 = 32'd0; in2 = 32'd0; cin = 1'b1; // carry in adds 1
        #10 in1 = 32'hFFFFFFFF; in2 = 32'd1; cin = 1'b0; // carry out, sum wraps to 0
        #10 in1 = 32'h7FFFFFFF; in2 = 32'd1; cin = 1'b0; // signed overflow, no carry out
        #10 $finish;
    end

    initial
    begin
    $monitor($time, " 1st num.=%d, 2nd num.=%d, Carry In=%d, Sum=%d, Carry Out=%d", in1, in2, cin, out, c);
    end

    adder MUT(in1, in2, cin, c, out);
endmodule
