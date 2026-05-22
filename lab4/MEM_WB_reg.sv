`timescale 1ns/10ps

// MEM/WB Pipeline Register holds values from MEM and passes them to the WB stage
module MEM_WB_reg (
	input logic clk, reset,
	input logic RegWrite, MemToReg, BrLink,
	input logic [63:0] ALU_operation,
	input logic [63:0] dataMem, // data memory output
	input logic [4:0] Rd,
	input logic [63:0] PC_plus4,
	output logic RegWrite_out, MemToReg_out, BrLink_out,
	output logic [63:0] ALU_operation_out,
	output logic [63:0] dataMem_out,
	output logic [4:0] Rd_out,
	output logic [63:0] PC_plus4_out

);

	// Control unit signals
	D_FF RegWrite_DFF (.d(RegWrite), .q(RegWrite_out), .clk(clk), .reset(reset));
	D_FF MemToReg_DFF (.d(MemToReg), .q(MemToReg_out), .clk(clk), .reset(reset));
	D_FF BrLink_DFF 	(.d(BrLink), 	.q(BrLink_out), 	.clk(clk), .reset(reset));
	
	// ALU out
	DFFs #(.N(64)) ALU_Operation_DFFs 	(.d(ALU_operation), .q(ALU_operation_out), .clk(clk), .reset(reset));
	
	// Data memory output
	DFFs #(.N(64)) DataMem_DFFs (.d(dataMem), .q(dataMem_out), .clk(clk), .reset(reset));
	
	// Datapath values
	DFFs #(.N(5))	Rd_DFFs	(.d(Rd), .q(Rd_out), .clk(clk), .reset(reset));
	
	// BL return address
	DFFs #(.N(64)) PC_plus4_DFFs 	(.d(PC_plus4), .q(PC_plus4_out), .clk(clk), .reset(reset));
	
endmodule