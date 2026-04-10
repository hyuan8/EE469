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

// Testbench for 16x1 multiplexer.
module mux16_1_testbench();

	logic out;
	logic [15:0] i;
	logic [3:0] sel;
	
	mux16_1 dut (.*);
	
	initial begin
	
		// Select increases and the bit shifts right. 
		// Should alternate between 0s and 1s.
		integer j; // use j because i is input
		for (j = 0; j < 16; j++) begin
			sel = j[3:0]; #10;
			i = 16'b1 << j; #10;
		end
		$stop;
	end
	
endmodule