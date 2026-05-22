`timescale 1ns/10ps

// ID/EX Pipeline Register holds values from ID and passes them to the EX stage
module ID_EX_reg (
	input logic clk, reset,
	input logic RegWrite, MemWrite, MemRead, MemToReg, UncondBr, BrTaken, 
	input logic ALUSrc, SetFlags, BrLink, Imm12, BrReg, isCBZ,
	input logic [2:0] ALUOp,
	input logic [63:0] Da, Db,
	input logic [4:0] Rn, Rm, Rd, Ab,
	input logic [63:0] imm9, imm12,
	input logic [63:0] PC_plus4, currentPC,
	input logic [63:0] condOffset, brOffset,
	output logic RegWrite_out, MemWrite_out, MemRead_out, MemToReg_out,
	output logic ALUSrc_out, SetFlags_out, BrLink_out, Imm12_out, BrReg_out, isCBZ_out,
	output logic [2:0] ALUOp_out,
	output logic [63:0] Da_out, Db_out,
	output logic [4:0] Rn_out, Rm_out, Rd_out, Ab_out,
	output logic [63:0] imm9_out, imm12_out,
	output logic [63:0] PC_plus4_out, currentPC_out,
	output logic UncondBr_out, BrTaken_out,
	output logic [63:0] condOffset_out, brOffset_out,
);

	// Control unit signals
	D_FF RegWrite_DFF (.d(RegWrite), .q(RegWrite_out), .clk(clk), .reset(reset));
	D_FF MemWrite_DFF (.d(MemWrite), .q(MemWrite_out), .clk(clk), .reset(reset));
	D_FF MemRead_DFF 	(.d(MemRead), 	.q(MemRead_out), 	.clk(clk), .reset(reset));
	D_FF MemToReg_DFF (.d(MemToReg), .q(MemToReg_out), .clk(clk), .reset(reset));
	D_FF ALUSrc_DFF 	(.d(ALUSrc), 	.q(ALUSrc_out), 	.clk(clk), .reset(reset));
	D_FF SetFlags_DFF (.d(SetFlags), .q(SetFlags_out), .clk(clk), .reset(reset));
	D_FF BrLink_DFF 	(.d(BrLink), 	.q(BrLink_out), 	.clk(clk), .reset(reset));
	D_FF Imm12_DFF 	(.d(Imm12), 	.q(Imm12_out), 	.clk(clk), .reset(reset));
	D_FF BrReg_DFF 	(.d(BrReg), 	.q(BrReg_out), 	.clk(clk), .reset(reset));
	D_FF UncondBr_DFF (.d(UncondBr), .q(UncondBr_out), .clk(clk), .reset(reset));
	D_FF BrTaken_DFF 	(.d(BrTaken), 	.q(BrTaken_out), 	.clk(clk), .reset(reset));
	D_FF isCBZ_DFF 	(.d(isCBZ), 	.q(isCBZ_out), 	.clk(clk), .reset(reset));
	DFFs #(.N(3))	ALUOp_DFF	(.d(ALUOp), .q(ALUOp_out), .clk(clk), .reset(reset));
	
	// Datapath values
	DFFs #(.N(64)) Da_DFFs 	(.d(Da), .q(Da_out), .clk(clk), .reset(reset));
	DFFs #(.N(64)) Db_DFFs 	(.d(Db), .q(Db_out), .clk(clk), .reset(reset));
	
	// Register addresses
	DFFs #(.N(5)) 	Ab_DFFs 	(.d(Ab), .q(Ab_out), .clk(clk), .reset(reset));
	DFFs #(.N(5)) 	Rn_DFFs	(.d(Rn), .q(Rn_out), .clk(clk), .reset(reset));
	DFFs #(.N(5))	Rm_DFFs	(.d(Rm), .q(Rm_out), .clk(clk), .reset(reset));
	DFFs #(.N(5))	Rd_DFFs	(.d(Rd), .q(Rd_out), .clk(clk), .reset(reset));
	
	// Immediate values
	DFFs #(.N(64))	imm9_DFFs 	(.d(imm9), 	.q(imm9_out), 	.clk(clk), .reset(reset));
	DFFs #(.N(64))	imm12_DFFs 	(.d(imm12), .q(imm12_out), .clk(clk), .reset(reset));
	
	// PC and branch offset
	DFFs #(.N(64)) PC_plus4_DFFs		(.d(PC_plus4), 	.q(PC_plus4_out), 	.clk(clk), .reset(reset));
	DFFs #(.N(64)) cond_offset_DFFs	(.d(condOffset), 	.q(condOffset_out), 	.clk(clk), .reset(reset));
	DFFs #(.N(64)) brOffset_DFFs		(.d(brOffset), 	.q(brOffset_out), 	.clk(clk), .reset(reset));
	DFFs #(.N(64)) currentPC_DFFs 	(.d(currentPC), 	.q(currentPC_out), 	.clk(clk), .reset(reset));

endmodule 