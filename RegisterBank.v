// Register bank: 16 registers (R0 - R15), 32 bits each.

module RegisterBank (Source1, Source2, Clk, Reset, write_enable, Destination, write_data, Source1Sel, Source2Sel);

input Clk, Reset;              
input write_enable;             
input [3:0] Destination;           
input [31:0] write_data;       
input [3:0] Source1Sel;           
input [3:0] Source2Sel;           
output [31:0] Source1;        
output [31:0] Source2;        

wire [15:0] en;              
wire [31:0] Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15;

Decoder4to16 Dec (write_enable, Destination, en);

Register32 R0  (Q0, Clk, Reset, en[0],  write_data);
Register32 R1  (Q1, Clk, Reset, en[1],  write_data);
Register32 R2  (Q2, Clk, Reset, en[2],  write_data);
Register32 R3  (Q3, Clk, Reset, en[3],  write_data);
Register32 R4  (Q4, Clk, Reset, en[4],  write_data);
Register32 R5  (Q5, Clk, Reset, en[5],  write_data);
Register32 R6  (Q6, Clk, Reset, en[6],  write_data);
Register32 R7  (Q7, Clk, Reset, en[7],  write_data);
Register32 R8  (Q8, Clk, Reset, en[8],  write_data);
Register32 R9  (Q9, Clk, Reset, en[9],  write_data);
Register32 R10 (Q10, Clk, Reset, en[10], write_data);
Register32 R11 (Q11, Clk, Reset, en[11], write_data);
Register32 R12 (Q12, Clk, Reset, en[12], write_data);
Register32 R13 (Q13, Clk, Reset, en[13], write_data);
Register32 R14 (Q14, Clk, Reset, en[14], write_data);
Register32 R15 (Q15, Clk, Reset, en[15], write_data);

Mux16x1 Mux1 (Source1, Source1Sel, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15);
Mux16x1 Mux2 (Source2, Source2Sel, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15);
endmodule
