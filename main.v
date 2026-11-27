// ENGR 468 - Milestone 2
// Top level CPU: Phase Control (PC + IR) + Datapath + Memory Access + RAM
module processor_32bit (Clk, Reset);
    parameter ADDR_W = 16;
    parameter PC_W   = 8;

    input Clk, Reset; // Reset is active-low

    // Control & Instruction signals
    wire              DataPhase, Fetch, CondMet, RamReadWrite, RamEnable;
    wire [PC_W-1:0]   PC;
    wire [31:0]       IR, ExecInstr;

    // Datapath & Memory buses
    wire [ADDR_W-1:0] RamAddr;
    wire [31:0]       MemAddr, MemWriteData, RamDout, RamDin;
    wire [31:0]       ALUResult, WriteData;
    wire [3:0]        Flags;

    assign RamEnable = 1'b1;

    // 1. Phase Control (PC, IR, Fetch/Data toggle, NOP mux)
    phase_ctrl #(.PC_W(PC_W)) PH (
        .clk(Clk),
        .reset(Reset),
        .ram_dout(RamDout),
        .data_phase(DataPhase),
        .fetch(Fetch),
        .pc(PC),
        .ir(IR),
        .exec_instr(ExecInstr)
    );

    // 2. Datapath (Register Bank + ALU + Flags + Condition Check)
    Datapath DP (
        .Clk(Clk),
        .Reset(Reset),
        .Cond(ExecInstr[31:28]),
        .Opcode(ExecInstr[27:24]),
        .S(ExecInstr[23]),
        .Destination(ExecInstr[22:19]),
        .Source1Sel(ExecInstr[18:15]),
        .Source2Sel(ExecInstr[14:11]),
        .ImmShift(ExecInstr[18:3]),
        .ShiftCmd(ExecInstr[2:0]),
        .WriteData(WriteData),
        .MemAddr(MemAddr),
        .MemWriteData(MemWriteData),
        .CondMet(CondMet),
        .Flags(Flags),
        .ALUResult(ALUResult)
    );

    // 3. Memory Access (Memory Control + AddMux + LdrMux)
    memory_access #(.ADDR_W(ADDR_W), .PC_W(PC_W)) MA (
        .instr(IR),
        .data_phase(DataPhase),
        .cond_pass(CondMet),
        .pc(PC),
        .src1(MemAddr),
        .src2(MemWriteData),
        .ALUResult(ALUResult),
        .ram_dout(RamDout),
        .address(RamAddr),
        .ram_din(RamDin),
        .read_write(RamReadWrite),
        .write_data(WriteData),
        .ldr_sel(),
        .addr_sel()
    );

    // 4. Unified RAM
    memory #(.Address_W(ADDR_W)) RAM (
        .Enable(RamEnable),
        .ReadWrite(RamReadWrite),
        .Address(RamAddr),
        .DataIn(RamDin),
        .DataOut(RamDout),
        .clk(Clk)
    );
endmodule