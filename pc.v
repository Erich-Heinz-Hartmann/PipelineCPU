`timescale 1ns / 1ps

module pc(
    input clk,
    input reset,
    input stall,
    input [31:0] nextPC,
    output reg [31:0] PC
);

initial begin
    PC = 32'h00003000;
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        PC <= 32'h00003000;
    end
    else if (!stall) begin
        PC <= nextPC;
    end
end

endmodule