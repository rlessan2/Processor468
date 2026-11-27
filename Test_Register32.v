module Test_Register32;
reg Clk, Reset, en;
reg [31:0] D;
wire [31:0] Q;

initial
begin
    Clk=0; Reset=1; en=0; D=32'h00000000;
#3  Reset=0;                              
#4  Reset=1;
#10 en=1; D=32'hBBBBBBBB;               
#10 en=0; D=32'h11111111;               
#10 en=0; D=32'h77777777;               
#10 en=1; D=32'h12345678;               
#10 en=1; D=32'hAAAAAAAA; Reset=0;      
#10 Reset=1; en=0;
#10 $finish;
end

always #5 Clk=~Clk;

initial
begin
$monitor($time, " Clk=%b, Reset=%b, en=%b, D=%h, Q=%h", Clk, Reset, en, D, Q);
end

Register32 MUT(Q, Clk, Reset, en, D);
endmodule
