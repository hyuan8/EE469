module register_file #(parameter WIDTH=64)(q, d, reset, clk, enable);
	output [WIDTH-1:0] q;
	input [WIDTH-1:0] d; 
	input reset, clk, enable;
	
	initial assert(WIDTH>0);
	genvar i;
	
	generate
		for(i=0; i<WIDTH; i++) begin : eachDff
		D_FF_enable dff (.q(q[i]), .d(d[i]), .reset(reset), .clk(clk), .enable(enable));
		end
	endgenerate
endmodule
