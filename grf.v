`timescale 1ns / 1ps

module grf(
    input wire clk,
    input wire reset,
    input wire we,
    input wire [4:0] A1,
    input wire [4:0] A2,
    input wire [4:0] A3,
    input wire [31:0] WD,
    input wire [31:0] WPC,
    output wire [31:0] RD1,
    output wire [31:0] RD2
);

reg [31:0] registers [31:0];
integer i;

assign RD1 = (A1 == 5'b0) ? 32'b0 : 
             ((we && A3 == A1) ? WD : registers[A1]);
assign RD2 = (A2 == 5'b0) ? 32'b0 : 
             ((we && A3 == A2) ? WD : registers[A2]);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] <= 32'b0;
        end
    end
    else if (we) begin
		if(A3 != 5'b0) begin
			registers[A3] <= WD;
		end
		if(WPC>=32'h00003000 && WPC<=32'h00007000) begin
        $display("%d@%h: $%d <= %h", $time, WPC, A3, WD);
		end
    end
end

endmodule