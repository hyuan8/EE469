// Meaning of signals in and out of the ALU:

// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

`timescale 1ns/10ps

// This module builds an ALU.
module alu(A, B, cntrl, result, negative, zero, overflow, carry_out);

	input logic	[63:0] A, B;
	input logic	[2:0]	cntrl;
	output logic negative, zero, overflow, carry_out;
	output logic [63:0] result;
	
	logic [63:0] carry_chain;
	
	bit_slice first_slice (.A(A[0]), .B(B[0]), .cntrl(cntrl), .Cin(cntrl[0]), .Cout(carry_chain[0]), .R(result[0]));
	
	genvar i;
	generate
		for(i = 1; i < 64; i++) begin: slices
			bit_slice slice (.A(A[i]), .B(B[i]), .cntrl(cntrl), .Cin(carry_chain[i-1]), .Cout(carry_chain[i]), .R(result[i]));
		end
	endgenerate
	
	// Negative flag
	assign negative = result[63];
	
	// Carry out flag
	assign carry_out = carry_chain[63];
	
	// Overflow flag
	xor #0.05 xor0 (overflow, carry_chain[62], carry_chain[63]);
	
	// FLAG NOTES:
	// zero and negative going up for addition
	
	// Zero flag
	logic [63:0] ors;
	or #0.05 gate0 (ors[0], result[0], result[1]);
	genvar j;
	generate
		for (j = 1; j < 63; j++) begin : zero_gate_array
			or #0.05 gate_next (ors[j], ors[j-1], result[j+1]);
		end
	endgenerate
	not #0.05 gate_inv (zero, ors[62]);
	
endmodule
	
// ALU testbench. Use hex for displaying A, B, and result to view outputs more easily.
module alu_testbench();
	
	logic	[63:0] A, B;
	logic	[2:0]	cntrl;
	logic negative, zero, overflow, carry_out;
	logic [63:0] result;
	
	alu dut (.*);
	
	initial begin
	
		for (int i = 0; i < 8; i++) begin
			cntrl = i;
			for (int j = -1; j < 8; j++) begin 
				if (j == -1) 
					A = 64'b0;
				else
					A = 64'd1 << (8 * j);
				for (int k = -1; k < 8; k++) begin 
					if (k == -1)
						B = 64'b0;
					else
						B = 64'b1 << (8 * k); 
					#30;
				end
			end
			
			//add sub with zero
			cntrl = 3'b010; A = 64'h0; B = 64'h0; #30;
			cntrl = 3'b011; A = 64'h0; B = 64'h0; #30; 
			
			//force carry out
			cntrl = 3'b010; A = 64'hFFFFFFFFFFFFFFFF; B = 64'h1; #30;
			
			//force overflow
			cntrl = 3'b010; A = 64'h7FFFFFFFFFFFFFFF; B = 64'h1; #30;
			cntrl = 3'b010; A = 64'h8000000000000000; B = 64'hFFFFFFFFFFFFFFFF; #30;
	 
			//check and or xor
			cntrl = 3'b100; A = 64'hAAAAAAAAAAAAAAAA; B = 64'h5555555555555555; #30;
			cntrl = 3'b101; A = 64'hAAAAAAAAAAAAAAAA; B = 64'h5555555555555555; #30;
			cntrl = 3'b110; A = 64'hAAAAAAAAAAAAAAAA; B = 64'h5555555555555555; #30;
			
		end
		
	$stop;
	end
	
endmodule