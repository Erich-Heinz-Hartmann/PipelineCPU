`timescale 1ns / 1ps

module forwarding_unit(
	input [4:0] ID_rs,
    input [4:0] ID_rt,
	input [31:0] id_read_data1,
    input [31:0] id_read_data2,
	input isBeq_ID,
    input isJal_ID,
    input isJr_ID,
    input ID_isEqual,
	input [2:0]T_use_rs_D,
	input [2:0]T_use_rt_D,
	input [2:0]T_new_D,
	
    input [4:0] EX_rs,
    input [4:0] EX_rt,
	input EX_MemRead,
    input EX_RegWrite,
    input [4:0] EX_write_reg,
    input [31:0] EX_alu_result,
	input [2:0]T_use_rs_E,
	input [2:0]T_use_rt_E,
	input [2:0]T_new_E,
	
    input [4:0] MEM_rt,
	input [4:0] MEM_rd,
    input MEM_RegWrite,
	input MEM_MemWrite,
    input [4:0] MEM_write_reg,
    input [31:0] MEM_alu_result,
	input [31:0] MEM_read_data2,
	input [2:0]T_use_rs_M,
	input [2:0]T_use_rt_M,
	input [2:0]T_new_M,
	
    input [4:0] WB_rd,
    input WB_RegWrite,
    input [4:0] WB_write_reg,
    input [31:0] WB_write_data,
	input [2:0]T_new_W,
    
    output reg [1:0] forward_rs_D,
    output reg [1:0] forward_rt_D,
	output reg [31:0] id_rs_data_forwarded,
    output reg [31:0] id_rt_data_forwarded,
	
    output reg [1:0] forwardA,
    output reg [1:0] forwardB,
	
	output reg [31:0] mem_store_data_forwarded,
    output reg [1:0] forward_rt_M,
	
	output reg stall,
    output reg flush
);
	always @(*) begin
	//to D
        forward_rs_D = 2'b00;
        forward_rt_D = 2'b00;
        id_rs_data_forwarded = id_read_data1;
        id_rt_data_forwarded = id_read_data2;
        
        // rs
        // EX
        if (EX_RegWrite && EX_write_reg != 5'b0 && EX_write_reg == ID_rs) begin
            if (T_new_E <= T_use_rs_D) begin
                id_rs_data_forwarded = EX_alu_result;
                forward_rs_D = 2'b01;
            end
        end
        // MEM
        else if (MEM_RegWrite && MEM_write_reg != 5'b0 && MEM_write_reg == ID_rs) begin
            if (T_new_M <= T_use_rs_D) begin
                id_rs_data_forwarded = MEM_alu_result;
                forward_rs_D = 2'b10;
            end
        end
        // WB
        else if (WB_RegWrite && WB_write_reg != 5'b0 && WB_write_reg == ID_rs) begin
            if (T_new_W <= T_use_rs_D) begin
                id_rs_data_forwarded = WB_write_data;
                forward_rs_D = 2'b11;
            end
        end
        
        // rt
        // EX
        if (EX_RegWrite && EX_write_reg != 5'b0 && EX_write_reg == ID_rt) begin
            if (T_new_E <= T_use_rt_D) begin
                id_rt_data_forwarded = EX_alu_result;
                forward_rt_D = 2'b01;
            end
        end
        // MEM
        else if (MEM_RegWrite && MEM_write_reg != 5'b0 && MEM_write_reg == ID_rt) begin
            if (T_new_M <= T_use_rt_D) begin
                id_rt_data_forwarded = MEM_alu_result;
                forward_rt_D = 2'b10;
            end
        end
        // WB
        else if (WB_RegWrite && WB_write_reg != 5'b0 && WB_write_reg == ID_rt) begin
            if (T_new_W <= T_use_rt_D) begin
                id_rt_data_forwarded = WB_write_data;
                forward_rt_D = 2'b11;
            end
        end
    end
	
    always @(*) begin
	//to E
        forwardA = 2'b00;
        forwardB = 2'b00;
        
        //rs
        // MEM
        if (MEM_RegWrite && MEM_write_reg != 5'b0 && MEM_write_reg == EX_rs) begin
            if (T_new_M <= T_use_rs_E) begin
                forwardA = 2'b10;
            end
        end
        // WB
        else if (WB_RegWrite && WB_write_reg != 5'b0 && WB_write_reg == EX_rs) begin
            if (T_new_W <= T_use_rs_E) begin
                forwardA = 2'b01;
            end
        end
        
        // rt
        // MEM
        if (MEM_RegWrite && MEM_write_reg != 5'b0 && MEM_write_reg == EX_rt) begin
            if (T_new_M <= T_use_rt_E) begin
                forwardB = 2'b10;
            end
        end
        // WB
        else if (WB_RegWrite && WB_write_reg != 5'b0 && WB_write_reg == EX_rt) begin
            if (T_new_W <= T_use_rt_E) begin
                forwardB = 2'b01;
            end
        end
    end
	
	always @(*) begin
        mem_store_data_forwarded = MEM_read_data2;
        forward_rt_M = 2'b00;
        
        //rt
        if (MEM_MemWrite) begin
            if (WB_RegWrite && WB_write_reg != 5'b0 && WB_write_reg == MEM_rt) begin
                if (T_new_W <= T_use_rt_M) begin
                    mem_store_data_forwarded = WB_write_data;
                    forward_rt_M = 2'b11;
                end
            end
        end
    end
	
	//stall
    wire stall_rs, stall_rt;
    
    assign stall_rs = 
        (EX_RegWrite && EX_write_reg != 5'b0 && EX_write_reg == ID_rs && T_new_E > T_use_rs_D) ||
        (MEM_RegWrite && MEM_write_reg != 5'b0 && MEM_write_reg == ID_rs && T_new_M > T_use_rs_D) ||
        (WB_RegWrite && WB_write_reg != 5'b0 && WB_write_reg == ID_rs && T_new_W > T_use_rs_D);
    
    assign stall_rt = 
        (EX_RegWrite && EX_write_reg != 5'b0 && EX_write_reg == ID_rt && T_new_E > T_use_rt_D) ||
        (MEM_RegWrite && MEM_write_reg != 5'b0 && MEM_write_reg == ID_rt && T_new_M > T_use_rt_D) ||
        (WB_RegWrite && WB_write_reg != 5'b0 && WB_write_reg == ID_rt && T_new_W > T_use_rt_D);
    
    always @(*) begin
        stall = 1'b0;
        flush = 1'b0;
        
        if (stall_rs || stall_rt) begin
            stall = 1'b1;
        end
        
    end
	
endmodule