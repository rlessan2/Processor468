module test_read_memory;   // Read test: load the write test's output file, then read it back
parameter Address_W = 16;
parameter DataIn_W  = 32;
parameter DEPTH     = 1 << Address_W;
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
    enable = 0; R_W = 1; Address = 0; D_In = 0; errors = 0;

    $readmemh("data_write.txt", ram.Ram); //load the existing file comb so no negedge
    enable = 1; R_W = 1;
    for (i = 0; i < DEPTH; i = i + 1)
    begin
        Address = i;
        #3;
        if (D_Out !== {i[Address_W-1:0], ~i[Address_W-1:0]})
        begin
            errors = errors + 1;
            if (errors <= 10)
                $display("MISMATCH addr %h: got %h, expected %h",
                         i[Address_W-1:0], D_Out, {i[Address_W-1:0], ~i[Address_W-1:0]});
        end
    end

    // Output must be high impedancew when disabled 
    enable = 0;
    #3 if (D_Out !== {DataIn_W{1'bz}})
    begin
        errors = errors + 1;
        $display("ERROR: D_Out not 1'bz (%h)", D_Out);
    end

    if (errors == 0) $display("PASS: all %0d read correctly", DEPTH);
    else             $display("FAIL: %0d errors", errors);

    $finish;
end
endmodule
