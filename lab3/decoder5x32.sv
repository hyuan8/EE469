// This is a 5x32 decoder. It is built from four 3x8 decoder and a 2x4 decoder.
module decoder5x32 (en, in, out);

	input logic en;
	input logic [4:0] in;
	output logic [31:0] out;
	
	// This 2x4 mux uses the 2 MSB from in (in[4:3]) to select which 3x8 mux to select from
	logic [3:0] block;
	decoder2x4 sel (.en, .in(in[4:3]), .out(block[3:0]));
	
	// Creates four 3x8 decoders to select the output line
	genvar i;
	generate
		for (i = 0; i < 4; i++) begin : decoders3x8
			decoder3x8 decoder (.en(block[i]), .in(in[2:0]), .out(out[(8*i) + 7 : 8 * i]));
		end
	endgenerate
	
endmodule

// Testbench for 5x32 decoder.
module decoder5x32_testbench();

	logic en;
	logic [4:0] in;
	logic [31:0] out;
	
	decoder5x32 dut (.*);
	
	integer i;
	initial begin
	
		// Without enable
		en = 1'b0;
		for (i = 0; i < 2**5; i++) begin
			in = i; #10;
		end
		
		// With enable
		en = 1'b1;
		for (i = 0; i < 2**5; i++) begin
			in = i; #10;
		end
		
		$stop;
	end
	
endmodule 