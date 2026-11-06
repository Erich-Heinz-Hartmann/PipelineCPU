`timescale 1ns / 1ps

module extender(
    input [15:0] imm,
    input isSignExt,
    input isLui,
    output reg [31:0] out
    );
    
reg [31:0] signExt;
reg [31:0] luiExt;

always @(*) begin 
    signExt = (isSignExt) ? {{16{imm[15]}}, imm} : {16'b0, imm};
    luiExt = {imm, 16'b0};
    out = (isLui) ? luiExt : signExt;
end

endmodule
