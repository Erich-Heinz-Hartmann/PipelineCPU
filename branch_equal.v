`timescale 1ns / 1ps

module branch_equal(
	input [31:0]rs,
	input [31:0]rt,
	
	output reg isEqual
    );
	
always @(*) begin
	isEqual = (rs == rt);
end

endmodule
