module Test_RegisterBank;
reg Clk, Reset, write_enable;
reg [3:0] Destination, Source1Sel, Source2Sel;
reg [31:0] write_data;
wire [31:0] Source1, Source2;

initial
begin
    Clk=0; Reset=1; write_enable=0; Destination=0; write_data=0; Source1Sel=0; Source2Sel=0;
#3  Reset=0;                    // reset all registers
#4  Reset=1;

// write R0 to R15, one per clock (Source1 reads each one back)
#13 write_enable=1; Destination=0;  write_data=32'hA0A0A0A0; Source1Sel=0;
#10 write_enable=1; Destination=1;  write_data=32'h11111111; Source1Sel=1;
#10 write_enable=1; Destination=2;  write_data=32'h22222222; Source1Sel=2;
#10 write_enable=1; Destination=3;  write_data=32'h33333333; Source1Sel=3;
#10 write_enable=1; Destination=4;  write_data=32'h44444444; Source1Sel=4;
#10 write_enable=1; Destination=5;  write_data=32'h55555555; Source1Sel=5;
#10 write_enable=1; Destination=6;  write_data=32'h66666666; Source1Sel=6;
#10 write_enable=1; Destination=7;  write_data=32'h77777777; Source1Sel=7;
#10 write_enable=1; Destination=8;  write_data=32'h88888888; Source1Sel=8;
#10 write_enable=1; Destination=9;  write_data=32'h99999999; Source1Sel=9;
#10 write_enable=1; Destination=10; write_data=32'hAAAAAAAA; Source1Sel=10;
#10 write_enable=1; Destination=11; write_data=32'hBBBBBBBB; Source1Sel=11;
#10 write_enable=1; Destination=12; write_data=32'hCCCCCCCC; Source1Sel=12;
#10 write_enable=1; Destination=13; write_data=32'hDDDDDDDD; Source1Sel=13;
#10 write_enable=1; Destination=14; write_data=32'hEEEEEEEE; Source1Sel=14;
#10 write_enable=1; Destination=15; write_data=32'hFFFFFFFF; Source1Sel=15;

// read two registers at the same time
#10 write_enable=0; Source1Sel=2;  Source2Sel=3;
#10 Source1Sel=0;  Source2Sel=15;
#10 Source1Sel=7;  Source2Sel=7;    // same register on both outputs

// write_enable=0, so R5 should not change
#10 write_enable=0; Destination=5; write_data=32'hDEADBEEF; Source1Sel=5;

// write R3 and read it in the same cycle 
#10 write_enable=1; Destination=3; write_data=32'h12345678; Source1Sel=3;

// reset again, all registers go back to 0
#10 write_enable=0; Reset=0;
#10 Reset=1;
#10 $finish;
end

always #5 Clk=~Clk;

initial
begin
$monitor($time, " Reset=%b WE=%b Dest=%d Data=%h | Src1Sel=%d Source1=%h | Src2Sel=%d Source2=%h",
         Reset, write_enable, Destination, write_data, Source1Sel, Source1, Source2Sel, Source2);
end

RegisterBank MUT(Source1, Source2, Clk, Reset, write_enable, Destination, write_data, Source1Sel, Source2Sel);
endmodule
