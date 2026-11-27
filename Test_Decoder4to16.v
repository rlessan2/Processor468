module Test_Decoder4to16;
reg Enable;
reg [3:0] Sel;
wire [15:0] Y;

initial
begin
    Enable=0; Sel=0;          
#10 Sel=5;
#10 Sel=15;
#10 Enable=1; Sel=0;          
#10 Sel=1;
#10 Sel=2;
#10 Sel=3;
#10 Sel=4;
#10 Sel=5;
#10 Sel=6;
#10 Sel=7;
#10 Sel=8;
#10 Sel=9;
#10 Sel=10;
#10 Sel=11;
#10 Sel=12;
#10 Sel=13;
#10 Sel=14;
#10 Sel=15;
#10 $finish;
end

initial
begin
$monitor($time, " Enable=%b, Sel=%d, Y=%b", Enable, Sel, Y);
end

Decoder4to16 MUT(Enable, Sel, Y);
endmodule
