// 16x1 multiplexer

module Mux16x1 (Out, Sel, In0, In1, In2, In3, In4, In5, In6, In7,
                   In8, In9, In10, In11, In12, In13, In14, In15);
input [3:0] Sel;
input [31:0] In0, In1, In2, In3, In4, In5, In6, In7, In8, In9, In10, In11, In12, In13, In14, In15;
output reg [31:0] Out;

always @*
case (Sel)
        4'd0:  Out = In0;
        4'd1:  Out = In1;
        4'd2:  Out = In2;
        4'd3:  Out = In3;
        4'd4:  Out = In4;
        4'd5:  Out = In5;
        4'd6:  Out = In6;
        4'd7:  Out = In7;
        4'd8:  Out = In8;
        4'd9:  Out = In9;
        4'd10: Out = In10;
        4'd11: Out = In11;
        4'd12: Out = In12;
        4'd13: Out = In13;
        4'd14: Out = In14;
        4'd15: Out = In15;
	default: Out = 32'b0;
endcase
endmodule
