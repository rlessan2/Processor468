module Test_Datapath;
reg Clk, Reset, S;
reg [3:0] Cond, Opcode, Destination, Source1Sel, Source2Sel;
reg [15:0] ImmShift;
reg [2:0] ShiftCmd;
reg [31:0] MemReadData;       // stands in for the RAM's read data
wire [31:0] MemAddr, MemWriteData, ALUResult, WriteData;
wire CondMet;
wire [3:0] Flags;

// Stands in for the LDR MUX in memory control: LDR writes the RAM data, everything else the ALU result
assign WriteData = (Opcode == 4'b1101 && CondMet) ? MemReadData : ALUResult;

initial
begin
    Clk=0; Reset=1; Cond=4'b0000; Opcode=4'b1111; S=0; Destination=0; Source1Sel=0; Source2Sel=0;
    ImmShift=0; ShiftCmd=3'b000; MemReadData=32'hCAFEF00D;
#3  Reset=0;                    // reset registers and flags
#4  Reset=1;

    // Each step runs on the next clock edge
#3  Opcode=4'b0110; Destination=1; ImmShift=16'd20;                       // MOV R1, 20
#10 Opcode=4'b0110; Destination=2; ImmShift=16'd7;                        // MOV R2, 7
#10 Opcode=4'b0000; Destination=3; Source1Sel=1; Source2Sel=2; ImmShift=0; // ADD R3, R1, R2   R3 = 27
#10 Opcode=4'b0001; Destination=4; Source1Sel=2; Source2Sel=1; S=1;        // SUBS R4, R2, R1  R4 = -13, NZCV = 1010
#10 Opcode=4'b0110; Destination=6; ImmShift=16'd99; S=0; Cond=4'b0011;     // MOVLT R6, 99     runs (N!=V)
#10 Opcode=4'b0110; Destination=7; ImmShift=16'd55; Cond=4'b0100;          // MOVGE R7, 55     skipped, R7 stays 0
#10 Opcode=4'b0011; Destination=8; Source1Sel=1; Source2Sel=2; Cond=4'b0000;
    ImmShift=16'd16; ShiftCmd=3'b010;                                      // ORR R8, R1, R2, LSL 2  R8 = 28 (shift 2 at ImmShift[7:3])
#10 Opcode=4'b1011; Destination=15; Source1Sel=1; Source2Sel=1;
    ImmShift=0; ShiftCmd=3'b000;                                           // CMP R1, R1       no write, NZCV = 0100
#10 Opcode=4'b1110; Source1Sel=1; Source2Sel=3;                            // STR R3, [R1]     no write, Addr=20, Data=27
#10 Opcode=4'b1101; Destination=9; Source1Sel=1;                           // LDR R9, [R1]     R9 = CAFEF00D
#10 Opcode=4'b1111;                                                        // NOP
    $display("---- Registers ----");
    $display("R0=%h R1=%h R2=%h R3=%h",     MUT.RB.Q0,  MUT.RB.Q1,  MUT.RB.Q2,  MUT.RB.Q3);
    $display("R4=%h R5=%h R6=%h R7=%h",     MUT.RB.Q4,  MUT.RB.Q5,  MUT.RB.Q6,  MUT.RB.Q7);
    $display("R8=%h R9=%h R10=%h R11=%h",   MUT.RB.Q8,  MUT.RB.Q9,  MUT.RB.Q10, MUT.RB.Q11);
    $display("R12=%h R13=%h R14=%h R15=%h", MUT.RB.Q12, MUT.RB.Q13, MUT.RB.Q14, MUT.RB.Q15);
    $finish;
end

always #5 Clk=~Clk;

initial
begin
$monitor($time, " Op=%b Cond=%b Dest=R%0d ALU=%h WE=%b CondMet=%b | Addr=%h Data=%h | NZCV=%b",
         Opcode, Cond, Destination, ALUResult, MUT.ALUWriteEnable, CondMet,
         MemAddr, MemWriteData, Flags);
end

Datapath MUT(MemAddr, MemWriteData, CondMet, Flags, ALUResult, Clk, Reset, Cond, Opcode, S,
             Destination, Source1Sel, Source2Sel, ImmShift, ShiftCmd, WriteData);
endmodule
