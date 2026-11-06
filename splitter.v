`timescale 1ns / 1ps

module splitter(
    input [31:0] command,
    output [5:0] op,
    output [4:0] rs,
    output [4:0] rt,
    output [4:0] rd,
    output [4:0] shamt,
    output [5:0] funct,
    output [15:0] imm,
    output [25:0] imm_j
    );

	assign op=command[31:26];
	assign rs=command[25:21];
	assign rt=command[20:16];
	assign rd=command[15:11];
	assign shamt=command[10:6];
	assign funct=command[5:0];
	assign imm=command[15:0];
	assign imm_j=command[25:0];

endmodule

