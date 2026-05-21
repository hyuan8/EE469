`timescale 1ns/10ps

module IF_ID_reg (
	input logic clk, reset, flush,
	input logic [31:0] instruction,
	input logic [63:0] PC,
	output logic [31:0] instruction_out,
	output logic [63:0] PC_out,
	
	input logic [63:0] currentPC,
	output logic [63:0] currentPC_out
);
	
	logic flushOrReset;
	or #0.05 or0 (flushOrReset, reset, flush);
	
	DFFs #(.N(32)) instruction_DFFs (.d(instruction), .q(instruction_out), .clk(clk), .reset(flushOrReset));
	DFFs #(.N(64)) PC_DFFs (.d(PC), .q(PC_out), .clk(clk), .reset(flushOrReset));
	DFFs #(.N(64)) currentPC_DFFs (.d(currentPC), .q(currentPC_out), .clk(clk), .reset(flushOrReset));

	
endmodule