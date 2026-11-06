module MEM_WB(
    input wire clk,
    input wire reset,
    input wire [31:0] alu_result_in,
    input wire [31:0] mem_read_data_in,
    input wire [31:0] pc_plus_4_in,
    input wire [4:0] write_reg_in,
    input wire RegWrite_in,
    input wire MemtoReg_in,
    input wire isJal_in,
	input [2:0]T_new_M,
	input [2:0]T_use_rs,
	input [2:0]T_use_rt,
    output reg [31:0] alu_result_out,
    output reg [31:0] mem_read_data_out,
    output reg [31:0] pc_plus_4_out,
    output reg [4:0] write_reg_out,
    output reg RegWrite_out,
    output reg MemtoReg_out,
    output reg isJal_out,
	output reg [2:0]T_use_rs_next,
	output reg [2:0]T_use_rt_next,
	output reg [2:0]T_new_W
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        alu_result_out <= 32'b0;
        mem_read_data_out <= 32'b0;
        pc_plus_4_out <= 32'b0;
        write_reg_out <= 5'b0;
        RegWrite_out <= 1'b0;
        MemtoReg_out <= 1'b0;
        isJal_out <= 1'b0;
		T_new_W <= 3'b000;
		T_use_rs_next <= 3'b100;
		T_use_rt_next <= 3'b100;
    end else begin
        alu_result_out <= alu_result_in;
        mem_read_data_out <= mem_read_data_in;
        pc_plus_4_out <= pc_plus_4_in;
        write_reg_out <= write_reg_in;
        RegWrite_out <= RegWrite_in;
        MemtoReg_out <= MemtoReg_in;
        isJal_out <= isJal_in;
		T_new_W <= (T_new_M == 3'b000) ? 3'b000 : T_new_M - 1;
		T_use_rs_next <= T_use_rs;
		T_use_rt_next <= T_use_rt;
    end
end

endmodule