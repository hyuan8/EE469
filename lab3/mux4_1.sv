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

// Testbench for 4x1 multiplexer.
module mux4_1_testbench();

	logic out;
	logic [3:0] i;
	logic [1:0] sel;
	
	mux4_1 dut (.*);
	
	initial begin
	
		// Select increases and the bit shifts right. 
		// Should alternate between 0s and 1s.
		sel = 2'b00;	#10;
		i = 4'b0001;	#10;
		sel = 2'b01;	#10;
		i = 4'b0010;	#10;
		sel = 2'b10;	#10;
		i = 4'b0100;	#10;
		sel = 2'b11;	#10;
		i = 4'b1000;	#10;
		
		$stop;
	end
	
endmodule
