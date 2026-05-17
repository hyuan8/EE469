`timescale 1ns/10ps

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

module decoder3x8 (en, in, out);

	input logic en;
	input logic [2:0] in;
	output logic [7:0] out;
	
	// Inverted input bits
	logic [2:0] n;
	not #0.05 not0 (n[0], in[0]);
	not #0.05 not1 (n[1], in[1]);
	not #0.05 not2 (n[2], in[2]);
	
	// Output logic
	and #0.05 out0 (out[0], en, n[2], n[1], n[0]);
	and #0.05 out1 (out[1], en, n[2], n[1], in[0]); 
	and #0.05 out2 (out[2], en, n[2], in[1], n[0]);
	and #0.05 out3 (out[3], en, n[2], in[1], in[0]);
	and #0.05 out4 (out[4], en, in[2], n[1], n[0]);
	and #0.05 out5 (out[5], en, in[2], n[1], in[0]); 
	and #0.05 out6 (out[6], en, in[2], in[1], n[0]);
	and #0.05 out7 (out[7], en, in[2], in[1], in[0]);
	
endmodule

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