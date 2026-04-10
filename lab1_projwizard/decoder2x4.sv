`timescale 1ns/10ps

// This is a 2x4 decoder using gate-level logic with enable.
// Gates have a 50ps delay.
module decoder2x4 (en, in, out);

	input logic en;
	input logic [1:0] in;
	output logic [3:0] out;
	
	// Inverted input bits
	logic [1:0] n;
	not #0.05 not0 (n[0], in[0]);
	not #0.05 not1 (n[1], in[1]);
	
	// Output logic
	and #0.05 out0 (out[0], en, n[1], n[0]);
	and #0.05 out1 (out[1], en, n[1], in[0]); 
	and #0.05 out2 (out[2], en, in[1], n[0]);
	and #0.05 out3 (out[3], en, in[1], in[0]);
	
endmodule

// Testbench for 2x4 decoder.
module decoder2x4_testbench();

	logic en;
	logic [1:0] in;
	logic [3:0] out;
	
	decoder2x4 dut (.*);
	
	integer i;
	initial begin
	
		// Without enable
		en = 1'b0;
		for (i = 0; i < 2**2; i++) begin
			in = i; #10;
		end
		
		// With enable
		en = 1'b1;
		for (i = 0; i < 2**2; i++) begin
			in = i; #10;
		end
		
		$stop;
	end
	
endmodule 