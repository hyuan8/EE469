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