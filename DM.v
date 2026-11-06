`timescale 1ns / 1ps

module DM(
    input wire clk,
    input wire reset,
    input wire MemWrite,
    input wire [31:0] addr,
    input wire [31:0] din, 
    input wire [31:0] pc,
    output wire [31:0] dout
);

reg [31:0] memory [0:3071];
integer i;

wire [11:0] word_addr = addr[13:2];
assign address_valid = (addr[1:0] == 2'b00) && (addr);
assign dout = (word_addr < 3072) ? memory[word_addr] : 32'b0;

always @(posedge clk) begin
    if (reset) begin
        for (i = 0; i < 3072; i = i + 1) begin
            memory[i] <= 32'b0;
        end
    end
    else if (MemWrite && address_valid && !reset) begin
        memory[addr[13:2]] <= din;
        $display("%d@%h: *%h <= %h", $time, pc, addr, din);
    end
end

endmodule