`timescale 1ns / 1ps

module alu(
    input [31:0] A,
    input [31:0] B,
    input [2:0] controll,
    input [4:0] shamt,
    output reg [31:0] out,
    output isEqual
);

assign isEqual = (A == B) ? 1'b1 : 1'b0;

always @(*) begin
    case(controll)
        3'b000: out = A + B;
        3'b001: out = A - B;
        3'b010: out = A & B;
        3'b011: out = A | B;
        default: out = 32'b0;
    endcase
end

endmodule