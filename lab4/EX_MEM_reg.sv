module EX_MEM_reg (
	input logic clk, reset,
	input logic RegWrite, MemWrite, MemRead, MemToReg, BrLink,
	input logic [63:0] ALU_operation,
	input logic [63:0] Db,
	input logic [4:0] Rd,
	input logic setFlags,
	input logic negative, zero, overflow, carry_out,
	output logic RegWrite_out, MemWrite_out, MemRead_out, MemToReg_out, BrLink_out,
	output logic [63:0] ALU_operation_out,
	output logic [63:0] Db_out,
	output logic [4:0] Rd_out,
	output logic setFlags_out,
	output logic negative_out, zero_out, overflow_out, carry_out_out
);

	D_FF RegWrite_DFF (.d(RegWrite), .q(RegWrite_out), .clk(clk), .reset(reset));
	D_FF MemWrite_DFF (.d(MemWrite), .q(MemWrite_out), .clk(clk), .reset(reset));
	D_FF MemRead_DFF 	(.d(MemRead), 	.q(MemRead_out), 	.clk(clk), .reset(reset));
	D_FF MemToReg_DFF (.d(MemToReg), .q(MemToReg_out), .clk(clk), .reset(reset));
	D_FF BrLink_DFF 	(.d(BrLink), 	.q(BrLink_out), 	.clk(clk), .reset(reset));
	
	DFFs #(.N(64)) ALU_Operation_DFFs 	(.d(ALU_operation), .q(ALU_operation_out), .clk(clk), .reset(reset));
	DFFs #(.N(64)) Db_DFFs 	(.d(Db), .q(Db_out), .clk(clk), .reset(reset));
	DFFs #(.N(5))	Rd_DFFs	(.d(Rd), .q(Rd_out), .clk(clk), .reset(reset));
	
	D_FF setFlags_DFF 	(.d(setFlags), 	.q(setFlags_out), 	.clk(clk), .reset(reset));
	
	D_FF negative_DFF 	(.d(negative), 	.q(negative_out), 	.clk(clk), .reset(reset));
	D_FF zero_DFF 			(.d(zero), 			.q(zero_out), 			.clk(clk), .reset(reset));
	D_FF overflow_DFF 	(.d(overflow), 	.q(overflow_out), 	.clk(clk), .reset(reset));
	D_FF carry_out_DFF 	(.d(carry_out),	.q(carry_out_out), 	.clk(clk), .reset(reset));
	
endmodule