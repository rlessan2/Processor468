//Phase control 
module phase_ctrl(clk, reset, ram_dout, data_phase, fetch, pc, ir, exec_instr);
    parameter PC_W = 8;

    input  clk, reset;
    input  [31:0] ram_dout;
    output reg  data_phase;
    output  fetch;
    output reg [PC_W-1:0] pc;
    output reg [31:0]   ir;
    output [31:0]       exec_instr;

    always @(posedge clk or negedge reset)
    begin
        if (~reset) begin
            data_phase <= 1'b0;    //Fetch DP=0
            pc         <= {PC_W{1'b0}};  //reset to 0
            ir         <= 32'd0;  //NOP
        end
        else begin
            data_phase <= ~data_phase;
            if (fetch) begin
                ir <= ram_dout;
                pc <= pc + 1'b1;
            end
        end
    end

    assign fetch      = ~data_phase;
    assign exec_instr = data_phase ? ir : 32'h0F00_0000; // NOP during fetch
endmodule

