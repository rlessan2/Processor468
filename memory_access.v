module memory_access( instr, data_phase, cond_pass, pc, src1, src2, ALUResult, ram_dout,
    address, ram_din, read_write, write_data, ldr_sel, addr_sel
);
    parameter ADDR_W = 16;
    parameter DATA_W = 32;
    parameter PC_W   = 8;

    input  [DATA_W-1:0] instr, src1, src2, ALUResult, ram_dout;
    input  [PC_W-1:0]   pc;
    input               data_phase, cond_pass;

    output [ADDR_W-1:0] address;
    output [DATA_W-1:0] ram_din, write_data;
    output              read_write, ldr_sel, addr_sel;

    wire [DATA_W-1:0] ldr_data;
    wire [ADDR_W-1:0] data_addr;


   memory_control #(.ADDR_W(ADDR_W)) MemCtrl (
    .instr(instr), .data_phase(data_phase), .cond_pass(cond_pass),
    .src1(src1), .src2(src2), .ram_dout(ram_dout),
    .read_write(read_write), .ldr_sel(ldr_sel), .addr_sel(addr_sel),
    .ram_din(ram_din), .ldr_data(ldr_data), .data_addr(data_addr)
    );

    addr_bus_mux #(.PC_W(PC_W), .ADDR_W(ADDR_W)) AddMux (
        .pc(pc), .data_addr(data_addr), .sel(addr_sel), .address(address)
    );

    ldr_mux LdrMux (
        .ALUResult(ALUResult), .ldr_data(ldr_data),
        .sel(ldr_sel), .write_data(write_data)
    );
endmodule