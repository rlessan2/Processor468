// =====================================================================
// Testbench: memory_access (memory_control + addr_bus_mux + ldr_mux)
//            connected to the real RAM (memory.v)
// Compile with: memory_access.v memory_control.v ram.v
//               (addr_bus_mux and ldr_mux are inside memory_control.v)
//
// STR really writes the RAM and LDR really reads it back.
// Self-checking: prints PASS/FAIL for each check and a summary at the
// end. Also dumps waveforms to tb_memory_access.vcd.
// =====================================================================
`timescale 1ns/1ps

module tb_memory_access;

    reg  [31:0]  instr;
    reg  data_phase;
    reg  cond_pass;
    reg  [15:0] pc;
    reg  [31:0] src1;
    reg  [31:0] src2;
    reg  [31:0] alu_result;

    wire [3:0] opcode = instr[27:24];
    wire [15:0] address;
    wire [31:0] ram_din;
    wire  read_write;
    wire [31:0] write_data;
    wire  ldr_sel;
    wire  addr_sel;
    reg   clk;
    wire [31:0] ram_dout;

    memory RAM (
        .Enable(1'b1),            // always enabled
        .ReadWrite(read_write),   // 1 = read, 0 = write
        .Address(address),
        .DataIn(ram_din),
        .DataOut(ram_dout),
        .clk(clk)
    );

    `define mem RAM.Ram  // find and replace to help with the double RAM 

 
     memory_access DUT (
        .instr(instr), .data_phase(data_phase), .cond_pass(cond_pass),
        .pc(pc), .src1(src1), .src2(src2),
        .ALUResult(alu_result), .ram_dout(ram_dout),
        .address(address), .ram_din(ram_din), .read_write(read_write),
        .write_data(write_data), .ldr_sel(ldr_sel), .addr_sel(addr_sel)
    );


    localparam [31:0] ADD = 32'h00000000;   // opcode 0000
    localparam [31:0] CMP = 32'h0B000000;   // opcode 1011
    localparam [31:0] LDR = 32'h0D000000;   // opcode 1101
    localparam [31:0] STR = 32'h0E000000;   // opcode 1110
    localparam [31:0] NOP = 32'h0F000000;   // opcode 1111

    integer pass_count = 0;
    integer fail_count = 0;

    task check;
        input [255:0] name;   // label for the printout
        input         ok;
        begin
            if (ok) begin
                pass_count = pass_count + 1;
                $display("  PASS  %0s", name);
            end else begin
                fail_count = fail_count + 1;
                $display("  FAIL  %0s   (addr=%h rw=%b addr_sel=%b ldr_sel=%b wdata=%h din=%h)",
                         name, address, read_write, addr_sel, ldr_sel, write_data, ram_din);
            end
        end
    endtask

    task tick;                 //clock cycle 
        begin
            #5 clk = 1;
            #5 clk = 0;
        end
    endtask

     task set_inputs;
        input [31:0] ins;
        input        phase;
        input        cp;
        input [31:0] s1;
        input [31:0] s2;
        begin
            instr      = ins;
            data_phase = phase;
            cond_pass  = cp;
            src1       = s1;
            src2       = s2;
            #3;
        end
    endtask

    integer i;


    initial begin

        $dumpfile("tb_memory_access.vcd");
        $dumpvars(0, tb_memory_access);

        // init
        clk = 0;
        pc = 16'h1;
        alu_result = 32'h11111111;
        for (i = 0; i < 65536; i = i + 1) `mem[i] = 32'h0;  //2^16=65536 set all to zero
        `mem[16'h20] = 32'hBBBBBBBB;   // data for the LDR test

        $display("\n=== 1. ADD (non-memory instruction) ===");
        set_inputs(ADD, 0, 1, 32'h20, 32'h0);
        check("fetch: address = PC",            address == pc);
        check("fetch: R/W = read",              read_write == 1);
        check("fetch: selects both 0",          addr_sel == 0 && ldr_sel == 0);
        set_inputs(ADD, 1, 1, 32'h20, 32'h0);
        check("exec: address stays on PC",      address == pc);
        check("exec: R/W = read",               read_write == 1);
        check("exec: write_data = ALU result",  write_data == alu_result);

        $display("\n=== 2. LDR R2,[R1]  (R1 = 0x20, RAM[0x20] = BBBBBBBB) ===");
        set_inputs(LDR, 0, 1, 32'h20, 32'h0);
        check("fetch: address = PC",            address == pc);
        check("fetch: ldr_sel = 0",             ldr_sel == 0);
        set_inputs(LDR, 1, 1, 32'h20, 32'h0);
        check("data: addr_sel = 1",             addr_sel == 1);
        check("data: address = R1 (0x20)",      address == 16'h20);
        check("data: R/W = read",               read_write == 1);
        check("data: ldr_sel = 1",              ldr_sel == 1);
        check("data: write_data = BBBBBBBB",    write_data == 32'hBBBBBBBB);

        $display("\n=== 3. STR R2,[R1]  (R1 = 0x30, R2 = CCCCCCCC) ===");
        set_inputs(STR, 0, 1, 32'h30, 32'hCCCCCCCC);
        check("fetch: address = PC",            address == pc);
        check("fetch: R/W = read (no write)",   read_write == 1);
        tick;
        check("fetch: RAM[0x30] untouched",     `mem[16'h30] == 32'h0);
        set_inputs(STR, 1, 1, 32'h30, 32'hCCCCCCCC);
        check("data: addr_sel = 1",             addr_sel == 1);
        check("data: address = R1 (0x30)",      address == 16'h30);
        check("data: R/W = write",              read_write == 0);
        check("data: ram_din = R2",             ram_din == 32'hCCCCCCCC);
        check("data: ldr_sel = 0",              ldr_sel == 0);
        tick;
        check("RAM[0x30] = CCCCCCCC after clk", `mem[16'h30] == 32'hCCCCCCCC);

        $display("\n=== 4. STR with failed condition (R1 = 0x40) ===");
        set_inputs(STR, 1, 0, 32'h40, 32'h12345678);
        check("R/W stays read",                 read_write == 1);
        check("address stays on PC",            address == pc);
        tick;
        check("RAM[0x40] unchanged",            `mem[16'h40] == 32'h0);

        $display("\n=== 5. LDR with failed condition ===");
        set_inputs(LDR, 1, 0, 32'h20, 32'h0);
        check("ldr_sel = 0",                    ldr_sel == 0);
        check("write_data = ALU result",        write_data == alu_result);

        $display("\n=== 6. Upper address bits ignored (R1 = FFFF0050) ===");
        `mem[16'h50] = 32'hDDDDDDDD;
        set_inputs(LDR, 1, 1, 32'hFFFF0050, 32'h0);
        check("address = 0x0050",               address == 16'h50);
        check("write_data = DDDDDDDD",          write_data == 32'hDDDDDDDD);

        $display("\n=== 7. Round trip: STR to 0x60 then LDR from 0x60 ===");
        set_inputs(STR, 1, 1, 32'h60, 32'hEEEEEEEE);
        tick;
        set_inputs(LDR, 1, 1, 32'h60, 32'h0);
        check("loaded value = EEEEEEEE",        write_data == 32'hEEEEEEEE);

        $display("\n=== 8. CMP and NOP never touch memory ===");
        set_inputs(CMP, 1, 1, 32'h70, 32'hFFFFFFFF);
        check("CMP: R/W = read",                read_write == 1);
        check("CMP: address = PC",              address == pc);
        set_inputs(NOP, 1, 1, 32'h70, 32'hFFFFFFFF);
        check("NOP: R/W = read",                read_write == 1);
        check("NOP: address = PC",              address == pc);
        tick;
        check("RAM[0x70] unchanged",            `mem[16'h70] == 32'h0);

        $display("\n=== SUMMARY: %0d passed, %0d failed ===\n", pass_count, fail_count);
        $finish;
    end
endmodule

