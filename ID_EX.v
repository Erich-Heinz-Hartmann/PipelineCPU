module ID_EX(
//aka E-reg
    input wire clk,
    input wire reset,
    input wire stall,
    input wire [31:0] pc_plus_4_in,
    input wire [31:0] read_data1_in,
    input wire [31:0] read_data2_in,
    input wire [31:0] extended_imm_in,
    input wire [4:0] rt_in,
    input wire [4:0] rd_in,
    input wire [4:0] rs_in,
    input wire [5:0] funct_in,
    input wire RegWrite_in,
    input wire MemWrite_in,
    input wire MemtoReg_in,
    input wire [2:0] ALUOp_in,
    input wire ALUSrc_in,
    input wire RegDst_in,
    input wire isJal_in,
    input wire isJr_in,
    input wire isBeq_in,
    input wire LuiOp_in,
	
	input [2:0]T_use_rs,
	input [2:0]T_use_rt,
	input [2:0]T_new_D,
	
    output reg [31:0] pc_plus_4_out,
    output reg [31:0] read_data1_out,
    output reg [31:0] read_data2_out,
    output reg [31:0] extended_imm_out,
    output reg [4:0] rt_out,
    output reg [4:0] rd_out,
    output reg [4:0] rs_out,
    output reg [5:0] funct_out,
    output reg RegWrite_out,
    output reg MemWrite_out,
    output reg MemtoReg_out,
    output reg [2:0] ALUOp_out,
    output reg ALUSrc_out,
    output reg RegDst_out,
    output reg isJal_out,
    output reg isJr_out,
    output reg isBeq_out,
    output reg LuiOp_out,
	
	output reg [2:0]T_use_rs_next,
	output reg [2:0]T_use_rt_next,
	output reg [2:0]T_new_E
);
always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc_plus_4_out <= 32'b0;
        read_data1_out <= 32'b0;
        read_data2_out <= 32'b0;
        extended_imm_out <= 32'b0;
        rt_out <= 5'b0;
        rd_out <= 5'b0;
        rs_out <= 5'b0;
        funct_out <= 6'b0;
        RegWrite_out <= 1'b0;
        MemWrite_out <= 1'b0;
        MemtoReg_out <= 1'b0;
        ALUOp_out <= 3'b0;
        ALUSrc_out <= 1'b0;
        RegDst_out <= 1'b0;
        isJal_out <= 1'b0;
        isJr_out <= 1'b0;
        isBeq_out <= 1'b0;
        LuiOp_out <= 1'b0;
		T_new_E <= 3'b000;
		T_use_rs_next <= 3'b100;
		T_use_rt_next <= 3'b100;
    end else if (stall) begin
        RegWrite_out <= 1'b0;
        MemWrite_out <= 1'b0;
        MemtoReg_out <= 1'b0;
        ALUOp_out <= 3'b0;
        ALUSrc_out <= 1'b0;
        RegDst_out <= 1'b0;
        isJal_out <= 1'b0;
        isJr_out <= 1'b0;
        isBeq_out <= 1'b0;
        LuiOp_out <= 1'b0;
        
        pc_plus_4_out <= 32'b0;
        read_data1_out <= 32'b0;
        read_data2_out <= 32'b0;
        extended_imm_out <= 32'b0;
        rt_out <= 5'b0;
        rd_out <= 5'b0;
        rs_out <= 5'b0;
        funct_out <= 6'b0;
		T_new_E <= 3'b000;
		T_use_rs_next <= 3'b100;
		T_use_rt_next <= 3'b100;
    end else begin
        pc_plus_4_out <= pc_plus_4_in;
        read_data1_out <= read_data1_in;
        read_data2_out <= read_data2_in;
        extended_imm_out <= extended_imm_in;
        rt_out <= rt_in;
        rd_out <= rd_in;
        rs_out <= rs_in;
        funct_out <= funct_in;
        RegWrite_out <= RegWrite_in;
        MemWrite_out <= MemWrite_in;
        MemtoReg_out <= MemtoReg_in;
        ALUOp_out <= ALUOp_in;
        ALUSrc_out <= ALUSrc_in;
        RegDst_out <= RegDst_in;
        isJal_out <= isJal_in;
        isJr_out <= isJr_in;
        isBeq_out <= isBeq_in;
        LuiOp_out <= LuiOp_in;
		T_new_E <= (T_new_D == 3'b000) ? 3'b000 : T_new_D - 1;
		T_use_rs_next <= T_use_rs;
		T_use_rt_next <= T_use_rt;
    end
end

endmodule