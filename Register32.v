// One 32-bit register with load enable.

module Register32 (Q, Clk, Reset, en, D);
input Clk, Reset, en;
input [31:0] D;
output reg [31:0] Q;

always @(posedge Clk)
if (~Reset)
        Q <= 32'd0;        
else if (en)
        Q <= D;            
                           
endmodule
