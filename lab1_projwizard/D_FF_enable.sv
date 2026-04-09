module D_FF_enable (q, d, reset, clk, enable);
	output q;
	input d, reset, clk, enable;
	
	wire mux_enable;
	
	//	mux2_1 m0(.out(mux_enable), .i0(q), .i1(d), .sel(enable));
	mux2_1 m0(.out(mux_enable), .i({d, q}), .sel(enable));
	D_FF d0(.q(q), .d(d), .reset(reset), .clk(clk));
	
endmodule
