// To change the file that is loaded, edit the filename here:
`define BENCHMARK "../benchmarks/test01_AddiB.arm"
//`define BENCHMARK "../benchmarks/test02_AddsSubs.arm"
//`define BENCHMARK "../benchmarks/test03_CbzB.arm"
//`define BENCHMARK "../benchmarks/test04_LdurStur.arm"
//`define BENCHMARK "../benchmarks/test05_Blt.arm"

module cpu (
	input logic clk,
	input logic reset
);

	logic [31:0] instruction;
	logic [63:0] unbranchedAddr;
	
	logic [2:0] ALUOp;
	logic ALUSrc, MemToReg, Reg2Loc, RegWrite, MemWrite, MemRead;
	
	logic negative, zero, overflow, carry_out;
	logic	UncondBr, BrTaken, SetFlags;
	
	instruction_fetch IF (.UncondBr(UncondBr), .BrTaken(BrTaken), .reset(reset), .clk(clk), 
		.instruction(instruction), .unbranchedAddr(unbranchedAddr));
	
	control CTL (.instruction(instruction), .negative(negative), .zero(zero), .overflow(overflow),
		.carry_out(carry_out), .ALUOp(ALUOp), .Reg2Loc(Reg2Loc), .ALUSrc(ALUSrc), .MemToReg(MemToReg),
		.RegWrite(RegWrite), .MemWrite(MemWrite), .MemRead(MemRead), .BrTaken(BrTaken), .UncondBr(UncondBr), .SetFlags(SetFlags));
		
	datapath DP (.instruction(instruction), .ALUOp(ALUOp), .ALUSrc(ALUSrc), .MemToReg(MemToReg),
		.Reg2Loc(Reg2Loc), .RegWrite(RegWrite), .MemWrite(MemWrite), .MemRead(MemRead), .clk(clk), .reset(reset), 
		.XferSize(4'd8), .negative(negative), .zero(zero), .overflow(overflow), .carry_out(carry_out)); //xfer size 8 because 64 bits = 8 bytes (double-word)
	
endmodule
	