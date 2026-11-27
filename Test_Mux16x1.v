module Test_Mux16x1;
reg [3:0] Sel;
reg [31:0] In0, In1, In2, In3, In4, In5, In6, In7, In8, In9, In10, In11, In12, In13, In14, In15;
wire [31:0] Out;

initial
begin
    
    In0=32'h00000000;  In1=32'h11111111;  In2=32'h22222222;  In3=32'h33333333;
    In4=32'h44444444;  In5=32'h55555555;  In6=32'h66666666;  In7=32'h77777777;
    In8=32'h88888888;  In9=32'h99999999;  In10=32'hAAAAAAAA; In11=32'hBBBBBBBB;
    In12=32'hCCCCCCCC; In13=32'hDDDDDDDD; In14=32'hEEEEEEEE; In15=32'hFFFFFFFF;    

Sel=0;
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
$monitor($time, " Sel=%d, Out=%h", Sel, Out);
end

Mux16x1 MUT(Out, Sel, In0, In1, In2, In3, In4, In5, In6, In7, In8, In9, In10, In11, In12, In13, In14, In15);
endmodule
