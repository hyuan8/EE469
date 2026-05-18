module MEM_WB_reg (
	input logic clk, reset,
	input logic RegWrite, MemToReg, BrLink,
	input logic [63:0] ALU_operation,
	input logic [63:0] dataMem, // data memory output
	input logic [4:0] Rd,
	output logic RegWrite_out, MemToReg_out, BrLink_out,
	output logic [63:0] ALU_operation_out,
	output logic [63:0] dataMem_out,
	output logic [4:0] Rd_out
);

	D_FF RegWrite_DFF (.d(RegWrite), .q(RegWrite_out), .clk(clk), .reset(reset));
	D_FF MemToReg_DFF (.d(MemToReg), .q(MemToReg_out), .clk(clk), .reset(reset));
	D_FF BrLink_DFF 	(.d(BrLink), 	.q(BrLink_out), 	.clk(clk), .reset(reset));
	
	DFFs #(.N(64)) ALU_Operation_DFFs 	(.d(ALU_operation), .q(ALU_operation_out), .clk(clk), .reset(reset));
	DFFs #(.N(64)) DataMem_DFFs (.d(dataMem), .q(dataMem_out), .clk(clk), .reset(reset));
	DFFs #(.N(5))	Rd_DFFs	(.d(Rd), .q(Rd_out), .clk(clk), .reset(reset));
	
endmodule