
module memory_control(
    instr, data_phase, cond_pass, src1, src2, ram_dout,
    read_write, ldr_sel, addr_sel, ram_din, ldr_data, data_addr
);
    parameter ADDR_W = 16;          

    input  [31:0]       instr;
    input               data_phase; // fetch or data
    input               cond_pass;  // cond in file
    input  [31:0]       src1;       // Address
    input  [31:0]       src2;       // Data
    input  [31:0]       ram_dout;   // (RAM -> Mem Ctr)

    output              read_write; // R/W to RAM
    output              ldr_sel;
    output              addr_sel;
    output [31:0]       ram_din;    // (Mem Ctr -> RAM)
    output [31:0]       ldr_data;
    output [ADDR_W-1:0] data_addr;  

    wire [3:0] opcode = instr[27:24];
    wire is_ldr = (opcode == 4'b1101) & cond_pass;
    wire is_str = (opcode == 4'b1110) & cond_pass;

    assign ldr_sel    = is_ldr & data_phase;
    assign addr_sel   = (is_ldr | is_str) & data_phase;
    assign read_write = ~(is_str & data_phase);   // write only in an STR  0=Write 1=Read

    assign data_addr  = src1[ADDR_W-1:0];         
    assign ram_din    = src2;
    assign ldr_data   = ram_dout;
endmodule


// Add Bus Mux
module addr_bus_mux(pc, data_addr, address, sel);
    parameter PC_W   = 8;
    parameter ADDR_W = 16;

    input  [PC_W-1:0]   pc;        // PC Instruction Access
    input  [ADDR_W-1:0] data_addr;
    input               sel;       // addr_sel from memory control
    output [ADDR_W-1:0] address;   // to RAM Address

    assign address = sel ? data_addr : pc;
endmodule

//ldr MUX
module ldr_mux (
    input  [31:0] ALUResult,
    input  [31:0] ldr_data,
    input         sel,         // ldr_sel from memory control
    output [31:0] write_data   // to register file
);
    assign write_data = sel ? ldr_data : ALUResult;
endmodule




