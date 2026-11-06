module IF_ID(
    input wire clk,
    input wire reset,
    input wire stall,
    input wire flush,
    input wire [31:0] instr_in,
    input wire [31:0] pc_plus_4_in,
	
    output reg [31:0] instr_out,
    output reg [31:0] pc_plus_4_out
	
);
//aka D-reg
always @(posedge clk or posedge reset) begin
    if (reset) begin
        instr_out <= 32'b0;
        pc_plus_4_out <= 32'b0;
		
    end else if (flush) begin
        instr_out <= 32'b0;
        pc_plus_4_out <= 32'b0;
		
		//Maybe some instr. will use it?
    end else if (!stall) begin
        instr_out <= instr_in;
        pc_plus_4_out <= pc_plus_4_in;//plus 4 COZ it's for D stage
		
    end
end

endmodule