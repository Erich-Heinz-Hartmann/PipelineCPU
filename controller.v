`timescale 1ns / 1ps

module controller(
    input [5:0] op,
    input [5:0] funct,
    output reg RegWrite,
    output reg MemWrite,
    output reg MemtoReg,
    output reg [2:0] ALUOp,
    output reg ALUSrc,
    output reg RegDst,
    output reg isBeq,
    output reg isJal,
    output reg isJr,
	output reg isLoad,
    output reg ExtOp,
    output reg LuiOp,
    output reg MemRead,
	output reg [2:0]T_use_rs,
	output reg [2:0]T_use_rt,
	output reg [2:0]T_new_D
);

always @(*) begin
    RegWrite = 1'b0;
    MemWrite = 1'b0;
    MemtoReg = 1'b0;
    ALUOp = 3'b000;
    ALUSrc = 1'b0;
    RegDst = 1'b0;
    isBeq = 1'b0;
    isJal = 1'b0;
    isJr = 1'b0;
	isLoad = 1'b0;
    ExtOp = 1'b0;
    LuiOp = 1'b0;
    MemRead = 1'b0;
	T_use_rs = 3'b100;//after how many circ we must to use reg
	T_use_rt = 3'b100;//if we needn't readReg,it'll be HUGE.
	T_new_D = 3'b100;
	//how many circ we need to get result
	//if haven't a writeReg, it'll be 0.
	//If >=4, the instr will be forced to stall; Forcestall always has right behavior though slow. 

    case(op)
        6'b000000: begin // R-type
            RegWrite = 1'b1;
            RegDst = 1'b1;
            ALUSrc = 1'b0;
			T_use_rs = 3'b001;
			T_use_rt = 3'b001;
            T_new_D = 3'b010;
            case(funct)
                6'b100000: begin
					ALUOp = 3'b000; // add
				end
                6'b100010: begin
					ALUOp = 3'b001; // sub
                end
				6'b100100: begin
					ALUOp = 3'b010; // and
				end
                6'b100101: begin
					ALUOp = 3'b011; // or
				end
                6'b001000: begin // jr
                    isJr = 1'b1;
                    RegWrite = 1'b0;
					T_use_rs = 3'b000;
					T_use_rt = 3'b100;
					T_new_D = 3'b100;
                end
                default: RegWrite = 1'b0; 
            endcase
        end
        
        6'b001101: begin // ori
            RegWrite = 1'b1;
            ALUSrc = 1'b1;
            ALUOp = 3'b011;
            ExtOp = 1'b0;
			T_use_rs = 3'b001;
			T_use_rt = 3'b100;
			T_new_D = 3'b010;
        end
        
        6'b100011: begin // lw
            RegWrite = 1'b1;
            ALUSrc = 1'b1;
            MemtoReg = 1'b1;
            ALUOp = 3'b000;
            ExtOp = 1'b1;
            MemRead = 1'b1;
			isLoad = 1'b1;
			T_use_rs = 3'b001;
			T_use_rt = 3'b100;
			T_new_D = 3'b100;//I don't know why it is abnormal; Try >=4 param if still WA.
        end
        
        6'b101011: begin // sw
            MemWrite = 1'b1;
            ALUSrc = 1'b1;
            ALUOp = 3'b000;
            ExtOp = 1'b1;
			T_use_rs = 3'b001;
			T_use_rt = 3'b010;
			T_new_D = 3'b000;
        end
        
        6'b000100: begin // beq
            isBeq = 1'b1;
            ALUOp = 3'b001;
			ExtOp = 1'b1;
			T_use_rs = 3'b000;
			T_use_rt = 3'b000;
			T_new_D = 3'b000;
        end
        
        6'b001111: begin // lui
            RegWrite = 1'b1;
            ALUSrc = 1'b1;
			ALUOp = 3'b000;
            LuiOp = 1'b1;
			T_use_rs = 3'b010;
			T_use_rt = 3'b100;
			T_new_D = 3'b010;
        end
        
        6'b000011: begin // jal
            RegWrite = 1'b1;
            isJal = 1'b1;
			T_use_rs = 3'b100;
			T_use_rt = 3'b100;
			T_new_D = 3'b011;//I don't know why it is abnormal; Try >=3 param if still WA.
        end
        
        default: begin
            RegWrite = 1'b0;
        end
    endcase
end

endmodule