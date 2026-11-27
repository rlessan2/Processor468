module test_write_memory;
parameter Address_W = 16;
parameter DataIn_W  = 32;
parameter DEPTH = 1 << Address_W;  
reg  clk, enable, R_W;
reg  [DataIn_W-1:0]  D_In;
reg  [Address_W-1:0] Address;
wire [DataIn_W-1:0]  D_Out;

integer i, errors;

memory #(.Address_W(Address_W), .DataIn_W(DataIn_W))
    ram (enable, R_W, Address, D_In, D_Out, clk);

initial clk = 0;
always #5 clk = ~clk;

initial
begin
    enable = 0; R_W = 0; Address = 0; D_In = 0; errors = 0;

    //Write all 2^16 locations
    @(negedge clk) enable = 1; R_W = 0;
    for (i = 0; i < DEPTH; i = i + 1)
    begin
        Address = i;
        D_In = {i[Address_W-1:0], ~i[Address_W-1:0]};   // unique 32-bit pattern per address
        @(negedge clk);
    end

    $writememh("data_write.txt", ram.Ram);   // full 2^16 x 32 dump

    //Read back and check 
    R_W = 1;
    for (i = 0; i < DEPTH; i = i + 1)
    begin
        Address = i;
        #1;
        if (D_Out !== {i[Address_W-1:0], ~i[Address_W-1:0]})
        begin
            errors = errors + 1;
             $display("MISMATCH addr %h: got %h, expected %h",
                         i[Address_W-1:0], D_Out, {i[Address_W-1:0], ~i[Address_W-1:0]});
        end
        @(negedge clk);
    end
    enable = 0;
    #1 if (D_Out !== {DataIn_W{1'bz}})
        begin
            errors = errors + 1;
            $display("ERROR: D_Out not high-Z when disabled (%h)", D_Out);
        end

    if (errors == 0) $display("PASS: all %0d words written and read correctly", DEPTH);
    else             $display("FAIL: %0d errors", errors);

    $finish;
end
endmodule