module mux32_1(i, sel, out);

	output logic out;
	input logic [32:0] i;
	input logic [4:0] sel; 
	
	logic internal_out0;
	mux8_1 mux0 (.out(internal_out0), .i(i[15:0]), .sel(sel[3:0]));

	logic internal_out1;
	mux8_1 mux1 (.out(internal_out1), .i(i[31:16]), .sel(sel[3:0]));
	
	mux2_1 mux2 (.out(out), .i({internal_out0, internal_out1}), .sel(sel[4]));
	
endmodule