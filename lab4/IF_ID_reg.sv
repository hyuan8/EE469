module IF_ID_reg (
	input logic clk, reset,
	input logic [31:0] instruction,
	input logic [63:0] PC,
	output logic [31:0] instruction_out,
	output logic [63:0] PC_out
);

	generateDFFs #(.N(32)) instruction_DFFs (.d(instruction), .q(instruction_out), .clk(clk), .reset(reset));
	generateDFFs #(.N(64)) PC_DFFs (.d(PC_in), .q(PC_out), .clk(clk), .reset(reset));
	
endmodule