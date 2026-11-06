`timescale 1ns / 1ps

module mips(
    input clk,
    input reset
);

reg [31:0] cycle_count;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        cycle_count <= 32'b0;
    end else begin
        cycle_count <= cycle_count + 1;
    end
end

// IF
wire [31:0] pc;
wire [31:0] next_pc;
wire stall;
wire flush;

pc program_counter(
    .clk(clk),
    .reset(reset),
    .stall(stall),
    .nextPC(next_pc),
    .PC(pc)
);

wire [31:0] if_instr;
IM instruction_memory(
    .addr(pc),
    .instr(if_instr)
);

wire [31:0] id_instr;
wire [31:0] id_pc_plus_4;
wire [31:0] pc_plus_4;
assign pc_plus_4 = pc + 32'd4;

IF_ID if_id_reg(
    .clk(clk),
    .reset(reset),
    .stall(stall),
    .flush(flush),
    .instr_in(if_instr),
    .pc_plus_4_in(pc_plus_4),
    .instr_out(id_instr),
    .pc_plus_4_out(id_pc_plus_4)
);

// ID
wire [5:0] id_op, id_funct;
wire [4:0] id_rs, id_rt, id_rd, id_shamt;
wire [15:0] id_imm;
wire [25:0] id_imm_j;

splitter instr_splitter(
    .command(id_instr),
    .op(id_op),
    .rs(id_rs),
    .rt(id_rt),
    .rd(id_rd),
    .shamt(id_shamt),
    .funct(id_funct),
    .imm(id_imm),
    .imm_j(id_imm_j)
);

wire id_RegWrite, id_MemWrite, id_MemtoReg, id_ALUSrc, id_RegDst;
wire id_isBeq, id_isJal, id_isJr, id_ExtOp, id_LuiOp;
wire [2:0] id_ALUOp;
wire [2:0] id_T_use_rs, id_T_use_rt, id_T_new_D;
wire id_MemRead, id_isLoad;

controller control_unit(
    .op(id_op),
    .funct(id_funct),
    .RegWrite(id_RegWrite),
    .MemWrite(id_MemWrite),
    .MemtoReg(id_MemtoReg),
    .ALUOp(id_ALUOp),
    .ALUSrc(id_ALUSrc),
    .RegDst(id_RegDst),
    .isBeq(id_isBeq),
    .isJal(id_isJal),
    .isJr(id_isJr),
    .ExtOp(id_ExtOp),
    .LuiOp(id_LuiOp),
    .T_use_rs(id_T_use_rs),
    .T_use_rt(id_T_use_rt),
    .T_new_D(id_T_new_D)
);

wire [31:0] id_read_data1, id_read_data2;
wire [31:0] wb_write_data;
wire wb_RegWrite;
wire [4:0] wb_write_reg;
wire [31:0] wb_pc_plus_4;

grf register_file(
    .clk(clk),
    .reset(reset),
    .we(wb_RegWrite),
    .A1(id_rs),
    .A2(id_rt),
    .A3(wb_write_reg),
    .WD(wb_write_data),
    .WPC(wb_pc_plus_4 - 32'd4),
    .RD1(id_read_data1),
    .RD2(id_read_data2)
);

wire [31:0] id_extended_imm;
extender imm_extender(
    .imm(id_imm),
    .isSignExt(id_ExtOp),
    .isLui(id_LuiOp),
    .out(id_extended_imm)
);

// ID
wire ID_isEqual;
wire [31:0] id_rs_data_forwarded, id_rt_data_forwarded;
wire [1:0] forward_rs_D, forward_rt_D;

branch_equal BEQ_D(
    .rs(id_rs_data_forwarded),
    .rt(id_rt_data_forwarded),
    .isEqual(ID_isEqual)
);

npc next_pc_calculator(
    .PC(pc),
    .reg_data(id_rs_data_forwarded),
    .isBeq(id_isBeq),
    .isJal(id_isJal),
    .isJr(id_isJr),
    .imm(id_imm),
    .imm_j(id_imm_j),
    .nextPC(next_pc),
    .isEqual(ID_isEqual)
);

// EX
wire [31:0] ex_pc_plus_4, ex_read_data1, ex_read_data2, ex_extended_imm;
wire [4:0] ex_rt, ex_rd, ex_rs;
wire [5:0] ex_funct;
wire ex_RegWrite, ex_MemWrite, ex_MemtoReg, ex_ALUSrc, ex_RegDst;
wire ex_isJal, ex_isJr, ex_isBeq, ex_LuiOp;
wire [2:0] ex_ALUOp;
wire [2:0] ex_T_use_rs_next, ex_T_use_rt_next, ex_T_new_E;

ID_EX id_ex_reg(
    .clk(clk),
    .reset(reset),
    .stall(stall),
    .pc_plus_4_in(id_pc_plus_4),
    .read_data1_in(id_read_data1),
    .read_data2_in(id_read_data2),
    .extended_imm_in(id_extended_imm),
    .rt_in(id_rt),
    .rd_in(id_rd),
    .rs_in(id_rs),
    .funct_in(id_funct),
    .RegWrite_in(id_RegWrite),
    .MemWrite_in(id_MemWrite),
    .MemtoReg_in(id_MemtoReg),
    .ALUOp_in(id_ALUOp),
    .ALUSrc_in(id_ALUSrc),
    .RegDst_in(id_RegDst),
    .isJal_in(id_isJal),
    .isJr_in(id_isJr),
    .isBeq_in(id_isBeq),
    .LuiOp_in(id_LuiOp),
    .T_use_rs(id_T_use_rs),
    .T_use_rt(id_T_use_rt),
    .T_new_D(id_T_new_D),
    .pc_plus_4_out(ex_pc_plus_4),
    .read_data1_out(ex_read_data1),
    .read_data2_out(ex_read_data2),
    .extended_imm_out(ex_extended_imm),
    .rt_out(ex_rt),
    .rd_out(ex_rd),
    .rs_out(ex_rs),
    .funct_out(ex_funct),
    .RegWrite_out(ex_RegWrite),
    .MemWrite_out(ex_MemWrite),
    .MemtoReg_out(ex_MemtoReg),
    .ALUOp_out(ex_ALUOp),
    .ALUSrc_out(ex_ALUSrc),
    .RegDst_out(ex_RegDst),
    .isJal_out(ex_isJal),
    .isJr_out(ex_isJr),
    .isBeq_out(ex_isBeq),
    .LuiOp_out(ex_LuiOp),
    .T_use_rs_next(ex_T_use_rs_next),
    .T_use_rt_next(ex_T_use_rt_next),
    .T_new_E(ex_T_new_E)
);

// ALU
wire [31:0] ex_alu_a_forwarded, ex_alu_b_forwarded;
wire [31:0] ex_alu_b_input;
wire [1:0] forwardA, forwardB;

assign ex_alu_a_forwarded = 
    (forwardA == 2'b10) ? mem_alu_result :
    (forwardA == 2'b01) ? wb_write_data :
    ex_read_data1;

assign ex_alu_b_forwarded = 
    (forwardB == 2'b10) ? mem_alu_result :
    (forwardB == 2'b01) ? wb_write_data :
    ex_read_data2;

assign ex_alu_b_input = ex_ALUSrc ? ex_extended_imm : ex_alu_b_forwarded;

wire [31:0] ex_alu_result;
wire ex_alu_equal;

alu arithmetic_logic_unit(
    .A(ex_alu_a_forwarded),
    .B(ex_alu_b_input),
    .controll(ex_ALUOp),
    .out(ex_alu_result),
    .isEqual(ex_alu_equal)
);

wire ex_MemRead;
assign ex_MemRead = ex_MemtoReg;
wire [4:0] ex_write_reg;
assign ex_write_reg = ex_isJal ? 5'd31 : (ex_RegDst ? ex_rd : ex_rt);

// MEM
wire [31:0] mem_alu_result, mem_read_data2, mem_pc_plus_4;
wire [4:0] mem_write_reg, mem_rt;
wire mem_RegWrite, mem_MemWrite, mem_MemtoReg, mem_isJal;
wire [2:0] mem_T_use_rs_next, mem_T_use_rt_next, mem_T_new_M;

EX_MEM ex_mem_reg(
    .clk(clk),
    .reset(reset),
    .alu_result_in(ex_alu_result),
    .read_data2_in(ex_alu_b_forwarded),
    .pc_plus_4_in(ex_pc_plus_4),
    .write_reg_in(ex_write_reg),
    .rt_in(ex_rt),
    .RegWrite_in(ex_RegWrite),
    .MemWrite_in(ex_MemWrite),
    .MemtoReg_in(ex_MemtoReg),
    .isJal_in(ex_isJal),
    .T_new_E(ex_T_new_E),
    .T_use_rs(ex_T_use_rs_next),
    .T_use_rt(ex_T_use_rt_next),
    .alu_result_out(mem_alu_result),
    .read_data2_out(mem_read_data2),
    .pc_plus_4_out(mem_pc_plus_4),
    .write_reg_out(mem_write_reg),
    .rt_out(mem_rt),
    .RegWrite_out(mem_RegWrite),
    .MemWrite_out(mem_MemWrite),
    .MemtoReg_out(mem_MemtoReg),
    .isJal_out(mem_isJal),
    .T_use_rs_next(mem_T_use_rs_next),
    .T_use_rt_next(mem_T_use_rt_next),
    .T_new_M(mem_T_new_M)
);

wire [31:0] mem_read_data;
wire [31:0] mem_store_data_forwarded;
wire [1:0] forward_rt_M;

DM data_memory(
    .clk(clk),
    .reset(reset),
    .MemWrite(mem_MemWrite),
    .addr(mem_alu_result),
    .din(mem_store_data_forwarded),
    .pc(mem_pc_plus_4 - 32'd4),
    .dout(mem_read_data)
);

// WB
wire [31:0] wb_alu_result, wb_mem_read_data;
wire wb_MemtoReg, wb_isJal;
wire [2:0] wb_T_new_W, wb_T_use_rs_next, wb_T_use_rt_next;

MEM_WB mem_wb_reg(
    .clk(clk),
    .reset(reset),
    .alu_result_in(mem_alu_result),
    .mem_read_data_in(mem_read_data),
    .pc_plus_4_in(mem_pc_plus_4),
    .write_reg_in(mem_write_reg),
    .RegWrite_in(mem_RegWrite),
    .MemtoReg_in(mem_MemtoReg),
    .isJal_in(mem_isJal),
    .T_new_M(mem_T_new_M),
    .T_use_rs(mem_T_use_rs_next),
    .T_use_rt(mem_T_use_rt_next),
    .alu_result_out(wb_alu_result),
    .mem_read_data_out(wb_mem_read_data),
    .pc_plus_4_out(wb_pc_plus_4),
    .write_reg_out(wb_write_reg),
    .RegWrite_out(wb_RegWrite),
    .MemtoReg_out(wb_MemtoReg),
    .isJal_out(wb_isJal),
    .T_use_rs_next(wb_T_use_rs_next),
    .T_use_rt_next(wb_T_use_rt_next),
    .T_new_W(wb_T_new_W)
);

assign wb_write_data = 
    wb_isJal ? (wb_pc_plus_4 + 32'd4) :
    (wb_MemtoReg ? wb_mem_read_data : wb_alu_result);

// Forwarding & Stall
wire [4:0] mem_rd;
assign mem_rd = mem_write_reg;
wire [4:0] wb_rd;
assign wb_rd = wb_write_reg;

forwarding_unit forward_unit(
    .ID_rs(id_rs),
    .ID_rt(id_rt),
    .id_read_data1(id_read_data1),
    .id_read_data2(id_read_data2),
    .isBeq_ID(id_isBeq),
    .isJal_ID(id_isJal),
    .isJr_ID(id_isJr),
    .ID_isEqual(ID_isEqual),
    .T_use_rs_D(id_T_use_rs),
    .T_use_rt_D(id_T_use_rt),
    .T_new_D(id_T_new_D),
    
    .EX_rs(ex_rs),
    .EX_rt(ex_rt),
    .EX_MemRead(ex_MemRead),
    .EX_RegWrite(ex_RegWrite),
    .EX_write_reg(ex_write_reg),
    .EX_alu_result(ex_alu_result),
    .T_use_rs_E(ex_T_use_rs_next),
    .T_use_rt_E(ex_T_use_rt_next),
    .T_new_E(ex_T_new_E),
    
    .MEM_rt(mem_rt),
    .MEM_rd(mem_rd),
    .MEM_RegWrite(mem_RegWrite),
    .MEM_MemWrite(mem_MemWrite),
    .MEM_write_reg(mem_write_reg),
    .MEM_alu_result(mem_alu_result),
    .MEM_read_data2(mem_read_data2),
    .T_use_rs_M(mem_T_use_rs_next),
    .T_use_rt_M(mem_T_use_rt_next),
    .T_new_M(mem_T_new_M),
    
    .WB_rd(wb_rd),
    .WB_RegWrite(wb_RegWrite),
    .WB_write_reg(wb_write_reg),
    .WB_write_data(wb_write_data),
    .T_new_W(wb_T_new_W),
    
    .forward_rs_D(forward_rs_D),
    .forward_rt_D(forward_rt_D),
    .id_rs_data_forwarded(id_rs_data_forwarded),
    .id_rt_data_forwarded(id_rt_data_forwarded),
    
    .forwardA(forwardA),
    .forwardB(forwardB),
    
    .mem_store_data_forwarded(mem_store_data_forwarded),
    .forward_rt_M(forward_rt_M),
    
    .stall(stall),
    .flush(flush)
);

endmodule