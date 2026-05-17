// THis is the provided DFF module
module D_FF (q, d, reset, clk);
	output reg q;
	input d, reset, clk;
	
	always_ff @(posedge clk)
	if (reset)
		q <= 0; // On reset, set to 0
	else
		q <= d; // Otherwise out = d
endmodule

// This is a modified DFF with enable.
module D_FF_enable (q, d, reset, clk, enable);
	output q;
	input d, reset, clk, enable;
	
	wire mux_enable;
	
	//	mux2_1 m0(.out(mux_enable), .i0(q), .i1(d), .sel(enable));
	
	mux2_1 m0(.out(mux_enable), .i({d, q}), .sel(enable)); // updated mux
	D_FF d0(.q(q), .d(mux_enable), .reset(reset), .clk(clk));
	
endmodule

// Creates an N-bit register using DFFs
module DFFs #(parameter N = 64) (
	input logic [N-1:0] q,
	output logic [N-1:0] d,
	input logic clk,
	input logic reset
);

	genvar i;
	generate
		for (i = 0; i < N; i++) begin : makeFFs
			D_FF dff (.q(q[i]), .d(d[i]), .reset(reset), .clk(clk));
		end
	endgenerate
endmodule
