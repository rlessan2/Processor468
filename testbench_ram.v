module test_memory; // Memory Write
parameter Address_W = 4;
parameter DataIn_W  = 32;
reg  clk, enable, R_W;
reg  [DataIn_W-1:0]  D_In;
reg  [Address_W-1:0] Address;
wire [DataIn_W-1:0]  D_Out;

memory #(.Address_W(Address_W), .DataIn_W(DataIn_W))  // allows me to test the parms working
    ram (enable, R_W, Address, D_In, D_Out, clk);

initial clk = 0;
always #5 clk = ~clk;

initial
begin
enable = 0; R_W = 0; Address = 16'd0; D_In = 32'h00000000;

// ---- Memory Write ----
@(negedge clk) enable = 1; R_W = 0; Address = 16'd0;  D_In = 32'hAAAAAAAA;
@(negedge clk) enable = 1; R_W = 0; Address = 16'd1;  D_In = 32'h00000011;
@(negedge clk) enable = 1; R_W = 0; Address = 16'd2;  D_In = 32'h00000022;
@(negedge clk) enable = 1; R_W = 0; Address = 16'd3;  D_In = 32'h00000033;
@(negedge clk) enable = 1; R_W = 0; Address = 16'd4;  D_In = 32'h00000044;
@(negedge clk) enable = 1; R_W = 0; Address = 16'd5;  D_In = 32'h00000055;
@(negedge clk) enable = 1; R_W = 0; Address = 16'd6;  D_In = 32'h00000066;
@(negedge clk) enable = 1; R_W = 0; Address = 16'd7;  D_In = 32'h00000077;
@(negedge clk) enable = 1; R_W = 0; Address = 16'd8;  D_In = 32'h00000088;
@(negedge clk) enable = 1; R_W = 0; Address = 16'd9;  D_In = 32'h00000099;
@(negedge clk) enable = 1; R_W = 0; Address = 16'd10; D_In = 32'h000000AA;
@(negedge clk) enable = 1; R_W = 0; Address = 16'd11; D_In = 32'h000000BB;
@(negedge clk) enable = 1; R_W = 0; Address = 16'd12; D_In = 32'h000000CC;
@(negedge clk) enable = 1; R_W = 0; Address = 16'd13; D_In = 32'h000000DD;
@(negedge clk) enable = 1; R_W = 0; Address = 16'd14; D_In = 32'h000000EE;
@(negedge clk) enable = 1; R_W = 0; Address = 16'd15; D_In = 32'hFFFFFFFF;
@(negedge clk) enable=0;
$writememh("data_write_param.txt", ram.Ram); // copy memory t
$finish;
end
endmodule
