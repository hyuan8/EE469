module decoder5x32 (en, in, out);

	input logic en;
	input logic [4:0] in;
	output logic [31:0] out;
	
	// 2x4 mux uses in[4:3] to select which 3x8 mux to select from
	logic [3:0] block;
	decoder2x4 sel (.en, .in(in[4:3]), .out(block[3:0]);
	
	// create four 3x8 muxes to select the output line
	genvar i;
	generate
		for (i = 0; i < 4; i++) begin : decoders3x8
			decoder3x8 decoder (.en(block[i], .in(in[2:0]), .out(block[(8*i) + 7 : 8 * i];
		end
	endgenerate
	
endmodule

module decoder5x32_testbench();

	logic en;
	logic [4:0] in;
	logic [31:0] out;
	
	decoder5x32 dut (.*);
	
	integer i;
	initial begin
	
		en = 1'b0;
		for (i = 0; i < 2**5; i++) begin
			in = i; #10;
		end
		
		en = 1'b1;
		for (i = 0; i < 2**5; i++) begin
			in = i; #10;
		end
		
		$stop;
	end
	
endmodule 