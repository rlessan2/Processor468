//ENGR 468 - Milestone 1
//Condition check module, checks current N, Z, C, V flags
module condition_check(
    input  [3:0] flags, //NZCV
    input  [3:0] cond,  //Condition code
    output reg       cond_met
);
    wire N = flags[3];
    wire Z = flags[2];
    wire C = flags[1];
    wire V = flags[0];

    always @(*) begin
        case (cond)
            4'b0000: cond_met = 1'b1;              // No Condition
            4'b0001: cond_met = Z;                 // EQ - Equal
            4'b0010: cond_met = ~Z & (N == V);     // GT - Signed Greater Than
            4'b0011: cond_met = (N != V);          // LT - Signed Less Than
            4'b0100: cond_met = (N == V);          // GE - Signed Greater Than or Equal To
            4'b0101: cond_met = Z | (N != V);      // LE - Signed Less Than or Equal To
            // Unsigned conditions: C = 1 means borrow (a < b) after SUB/CMP
            4'b0110: cond_met = ~C & ~Z;           // HI - Unsigned Higher
            4'b0111: cond_met = C;                 // LO - Unsigned Lower
            4'b1000: cond_met = ~C;                // HS - Unsigned Higher or Same
            default: cond_met = 1'b0;              // Undefined
        endcase
    end
endmodule

module opcode_mux (
    input  wire [3:0]  opcode,
    input  wire        cond_met,
    input  wire [31:0] add_result,     // 0000: ADD R1, R2, R3
    input  wire [31:0] sub_result,     // 0001: SUB R1, R2, R3 & 1011: CMP R1, R2
    input  wire [31:0] mul_result,     // 0010: MUL R1, R2, R3
    input  wire [31:0] or_result,      // 0011: ORR R1, R2, R3
    input  wire [31:0] and_result,     // 0100: AND R1, R2, R3
    input  wire [31:0] xor_result,     // 0101: EOR R1, R2, R3
    input  wire [31:0] mov_imm_result, // 0110: MOV R1, n (16-bit immediate)
    input  wire [31:0] mov_reg_result, // 0111: MOV R1, R2
    input  wire [31:0] ldr_addr,       // 1101: LDR R2, [R1] (Source 1 address)
    input  wire [31:0] str_data,       // 1110: STR R2, [R1] (Source 2 data)
    output reg  [31:0] result,
    output wire        write_en        // 1 = valid writeback, 0 = NOP / no register write
);

    wire is_nop = (~cond_met) | (opcode == 4'b1111);

    assign write_en = cond_met &
                      (opcode != 4'b1011) &
                      (opcode != 4'b1110) &
                      (opcode != 4'b1111);

    always @(*) begin
        if (is_nop) begin
            result = 32'b0;
        end else begin
            case (opcode)
                4'b0000: result = add_result;     // ADD R1, R2, R3
                4'b0001: result = sub_result;     // SUB R1, R2, R3
                4'b0010: result = mul_result;     // MUL R1, R2, R3
                4'b0011: result = or_result;      // ORR R1, R2, R3
                4'b0100: result = and_result;     // AND R1, R2, R3
                4'b0101: result = xor_result;     // XOR R1, R2, R3
                4'b0110: result = mov_imm_result; // MOV R1, n
                4'b0111: result = mov_reg_result; // MOV R1, R2
                4'b1011: result = sub_result;     // CMP R1, R2 (uses subtraction result for flags)
                4'b1101: result = ldr_addr;       // LDR R2, [R1]
                4'b1110: result = str_data;       // STR R2, [R1]
                4'b1111: result = 32'b0;          // NOP
                default: result = 32'b0;          // Unused opcodes (1000, 1001, 1010, 1100)
            endcase
        end
    end
endmodule