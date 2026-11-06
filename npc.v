`timescale 1ns / 1ps

module npc(
    input [31:0] PC,
    input [31:0] reg_data,
    input isBeq,
    input isJal,
    input isJr,
    input [15:0] imm,
    input isEqual,
    input [25:0] imm_j,
    output reg [31:0] nextPC
);

wire [31:0] trueIMM;
wire [31:0] preNPC;

assign trueIMM = {{16{imm[15]}}, imm} << 2;
assign preNPC = PC + 4;

always @(*) begin
    if (isJr) begin
        nextPC = reg_data;
    end
	else if (isJal) begin
        nextPC = {PC[31:28], imm_j, 2'b00};
    end
    else if (isBeq && isEqual) begin
        nextPC = PC + trueIMM;
		//nextPC = PC + 4 + trueIMM?
    end
    else begin
        nextPC = preNPC;
    end
end

endmodule