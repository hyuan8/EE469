`timescale 1ns/10ps

// This is a 2x1 multiplexer using gate-level logic.
// Gates have a 50ps delay.
module mux2_1(
    output logic out,
    input logic [1:0] i,
    input logic sel
);
	
	// Logic matching logic below (from previous mux module)
	// Code has been modified to use an array for i instead of i1 and i0.
	logic nsel, a0, a1;
	not #0.05 not0 (nsel, sel);
	
	and #0.05 and0 (a0, i[1], sel);
	and #0.05 and1 (a1, i[0], nsel);

	or #0.05 or0 (out, a0, a1);
	
endmodule

// This is a 4x1 multiplexer.
module mux4_1(i, sel, out);

	output logic out;
	input logic [3:0] i;
	input logic [1:0] sel; 
	
	// Selects between i[1] and i[0]
	logic internal_out0;
	mux2_1 mux0 (.out(internal_out0), .i(i[1:0]), .sel(sel[0]));

	// Selects between i[3] and i[2]
	logic internal_out1;
	mux2_1 mux1 (.out(internal_out1), .i(i[3:2]), .sel(sel[0]));
	
	// Chooses between intermediates
	mux2_1 mux2 (.out(out), .i({internal_out1, internal_out0}), .sel(sel[1]));
	
endmodule


// This is a 8x1 multiplexer.
module mux8_1(i, sel, out);

	output logic out;
	input logic [7:0] i;
	input logic [2:0] sel; 
	
	// Selects one bit from i[3:0]
	logic internal_out0;
	mux4_1 mux0 (.out(internal_out0), .i(i[3:0]), .sel(sel[1:0]));

	// Selects one bit from i[7:4]
	logic internal_out1;
	mux4_1 mux1 (.out(internal_out1), .i(i[7:4]), .sel(sel[1:0]));
	
	// Chooses between intermediates
	mux2_1 mux2 (.out(out), .i({internal_out1, internal_out0}), .sel(sel[2]));
	
endmodule

// This is a 16x1 multiplexer.
module mux16_1(i, sel, out);

	output logic out;
	input logic [15:0] i;
	input logic [3:0] sel; 
	
	// Selects one bit from i[7:0]
	logic internal_out0;
	mux8_1 mux0 (.out(internal_out0), .i(i[7:0]), .sel(sel[2:0]));

	// Selects one bit from i[15:8]
	logic internal_out1;
	mux8_1 mux1 (.out(internal_out1), .i(i[15:8]), .sel(sel[2:0]));
	
	// Chooses between intermediates
	mux2_1 mux2 (.out(out), .i({internal_out1, internal_out0}), .sel(sel[3]));
	
endmodule

// This is a 32x1 multiplexer.
module mux32_1(i, sel, out);

	output logic out;
	input logic [31:0] i;
	input logic [4:0] sel; 
	
	// Selects one bit from i[15:0]
	logic internal_out0;
	mux16_1 mux0 (.out(internal_out0), .i(i[15:0]), .sel(sel[3:0]));

	// Selects one bit from i[31:16]
	logic internal_out1;
	mux16_1 mux1 (.out(internal_out1), .i(i[31:16]), .sel(sel[3:0]));
	
	// Chooses between intermediates
	mux2_1 mux2 (.out(out), .i({internal_out1, internal_out0}), .sel(sel[4]));
	
endmodule

// Builds a 2x1 multiplexer that takes in 2 N-bit inputs and returns an N-bit output.
module mux2_1_Nbits #(parameter length = 1) (out, A, B, sel);

	output logic [length - 1:0] out;
	input logic [length - 1:0] A, B;
	input logic sel;
	
	genvar i;
	generate
		for (i = 0; i < length; i = i + 1) begin : gen_muxes
			mux2_1 bitwise_mux (.out(out[i]), .i({B[i], A[i]}), .sel(sel));
		end
	endgenerate

endmodule

// Builds a 4x1 multiplexer that takes in 4 N-bit inputs and returns an N-bit output.
module mux4_1_Nbits #(parameter length = 1) (out, A, B, C, D, sel);

	output logic [length - 1:0] out;
	input logic [length - 1:0] A, B, C, D;
	input logic [1:0] sel;
	
	genvar i;
	generate
		for (i = 0; i < length; i = i + 1) begin : gen_muxes
			mux4_1 bitwise_mux (.out(out[i]), .i({D[i], C[i], B[i], A[i]}), .sel(sel));
		end
	endgenerate

endmodule
