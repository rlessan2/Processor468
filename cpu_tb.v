`timescale 1ns/1ps

module tb_processor_32bit;
    localparam RAM_DEPTH = 65536;
    localparam NUM_INSTR = 16;
    localparam NOP = 32'h0F00_0000;

    reg Clk, Reset;
    integer i, changed;
    reg [31:0] RamInit [0:RAM_DEPTH-1];   // snapshot of RAM before the program runs

    processor_32bit dut (
        .Clk(Clk),
        .Reset(Reset)
    );

    initial Clk = 0;
    always #5 Clk = ~Clk;

    // Trace: print one line per instruction during its execute/data phase
    always @(negedge Clk)
        if (Reset && dut.DataPhase)
            $display("PC=%0d IR=%b | RegWrite=%b R%0d<=%h | RAM %s addr=%0d din=%h | FlagsNext=%b",
                     dut.PC - 1, dut.IR, dut.DP.ALUWriteEnable, dut.DP.Destination,
                     dut.DP.WriteData, dut.RamReadWrite ? "R" : "W", dut.RamAddr,
                     dut.RamDin, dut.DP.FlagsNext);

    
    initial begin
        #5000;
        $display("TIMEOUT: PC=%0d", dut.PC);
        $stop;
    end

    initial
    begin
        
// clear and write to RAM
        for (i = 0; i < RAM_DEPTH; i = i + 1)
            dut.RAM.Ram[i] = (i < NUM_INSTR) ? NOP : 32'd0;
        $readmemb("data.txt", dut.RAM.Ram);

        //Before we start
        for (i = 0; i < RAM_DEPTH; i = i + 1)
            RamInit[i] = dut.RAM.Ram[i];

        //Active-low reset (hold for 2 clocks, release on a falling edge)
        Reset = 0;
        #20; // clk even multiple of 5 
        Reset = 1;

        //Run all instruction slots
        wait (dut.PC == NUM_INSTR);
        @(posedge Clk);   // last execute
        #1;               // let settle

        // 4. Display all 16 registers + flags
        $display("\n--- REGISTERS ---");
        $display("R0  = %h", dut.DP.RB.Q0);
        $display("R1  = %h", dut.DP.RB.Q1);
        $display("R2  = %h", dut.DP.RB.Q2);
        $display("R3  = %h", dut.DP.RB.Q3);
        $display("R4  = %h", dut.DP.RB.Q4);
        $display("R5  = %h", dut.DP.RB.Q5);
        $display("R6  = %h", dut.DP.RB.Q6);
        $display("R7  = %h", dut.DP.RB.Q7);
        $display("R8  = %h", dut.DP.RB.Q8);
        $display("R9  = %h", dut.DP.RB.Q9);
        $display("R10 = %h", dut.DP.RB.Q10);
        $display("R11 = %h", dut.DP.RB.Q11);
        $display("R12 = %h", dut.DP.RB.Q12);
        $display("R13 = %h", dut.DP.RB.Q13);
        $display("R14 = %h", dut.DP.RB.Q14);
        $display("R15 = %h", dut.DP.RB.Q15);
        $display("Flags (NZCV) = %b", dut.Flags);

        // 5. Save all of RAM to output_ram.txt; print only words the program changed
        $writememb("output_ram.txt", dut.RAM.Ram);

        $display("\n--- RAM (changed by program) ---");
        changed = 0;
        for (i = 0; i < RAM_DEPTH; i = i + 1)
            if (dut.RAM.Ram[i] !== RamInit[i]) begin
                $display("RAM[%0d] : %h -> %h", i, RamInit[i], dut.RAM.Ram[i]);
                changed = changed + 1;
            end
        if (changed == 0)
            $display("(no RAM words changed)");


        //$finish;
	$stop;
    end
endmodule
