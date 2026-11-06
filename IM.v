`timescale 1ns / 1ps

module IM(
    input wire [31:0] addr,
    output reg [31:0] instr
);
reg [31:0] memory [0:4095];
integer i;
reg [11:0] word_addr;

initial begin
    for (i = 0; i < 4096; i = i + 1) begin
        memory[i] = 32'h00000000;
    end
    $readmemh("code.txt", memory);
    
end

always @(*) begin

    if (addr >= 32'h00003000 && addr <= 32'h00006FFF) begin
        word_addr = (addr - 32'h00003000) >> 2;
        instr = memory[word_addr];
    end else begin
        instr = 32'h00000000;
    end
end

endmodule