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

// Testbench for 8x1 multiplexer.
module mux8_1_testbench();

	logic out;
	logic [7:0] i;
	logic [2:0] sel;
	
	mux8_1 dut (.*);
	
	initial begin
	
		// Select increases and the bit shifts right. 
		// Should alternate between 0s and 1s.
		integer j; // use j because i is input
		for (j = 0; j < 8; j++) begin
			sel = j[2:0]; #10;
			i = 8'b1 << j; #10;
		end
		$stop;
	end
	
endmodule
