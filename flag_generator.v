module flag(in1,in2, result, mod_c, OP, s, c, v, z, n, flag_en);
input [31:0] in1,in2, result; //result will be connected to wire [31:0] out of the adder/subtractor/multiplier
input mod_c; // carry out from the adder/subtractor/multiplier (module carry)
input [3:0] OP;
input s;
output reg c,v,z,n;
output flag_en; 
assign flag_en = s || (OP == 4'b1011); // 1 when a flags register should save c,v,z,n (S-bit set or CMP)
always @(*) begin
    if(flag_en) begin
        z = (result == 32'd0)? 1'b1 : 1'b0; //zero flag
        n = (result[31] == 1'b1)? 1'b1 : 1'b0; //negative flag
        case(OP)
             4'b0000: begin // Add flag
                 c = mod_c; 
                 v = (in1[31] & in2[31] & ~result[31]) | (~in1[31] & ~in2[31] & result[31]);
             end
             4'b0001, 4'b1011: begin //Sub flag
                 c = mod_c; // 
                 v = (in1[31] & ~in2[31] & ~result[31]) | (~in1[31] & in2[31] & result[31]);
             end
            4'b0010: begin // Mul flag
                 c = mod_c; 
                 v = mod_c;
             end
            default: begin
                 c = 1'b0;
                 v = 1'b0;
             end
    endcase
    end
    else begin // flags not being updated, fixed values so no latch is created
        c = 1'b0;
        v = 1'b0;
        z = 1'b0;
        n = 1'b0;
    end
end
endmodule