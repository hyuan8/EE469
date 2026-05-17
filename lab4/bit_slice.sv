// cntrl			Operation						Notes:

// 000:			result = B						value of overflow and carry_out unimportant
// 001 not wired

// CNTRL[1] = 1 --> add or subtract
// 010:			result = A + B
// 011:			result = A - B

// CNTRL[2] = 1 --> bitwise operation
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant
// 111 not wired

`timescale 1ns/10ps

// This module builds a bit slicer.
module bit_slice(A, B, cntrl, R, Cin, Cout);

	input logic A, B;
	input logic [2:0] cntrl;
	output logic R;
	
	logic four, five, six;
	// 100: result = bitwise A & B -- value of overflow and carry_out unimportant
	and #0.05 and0 (four, A, B);
	
	// 101: result = bitwise A | B -- value of overflow and carry_out unimportant
	or #0.05 or0 (five, A, B);	
	
	// 110: result = bitwise A XOR B	value of overflow and carry_out unimportant
	xor #0.05 xor0 (six, A, B);
	
	// 2x1 mux for full adder
	logic mux2out, nB;
	not #0.05 not0 (nB, B);
	mux2_1 mux2 (.out(mux2out), .i({nB, B}), .sel(cntrl[0])); // not sure if sel is correct
	
	// full adder
	input logic Cin;
	output logic Cout;
	logic S;
	fa fulladder (.A(A), .B(mux2out), .Cin(Cin), .Cout(Cout), .S(S));
	
	// flipped due to mux logic (i goes from [7:0])
	mux8_1 mux8 (.out(R), .i({1'b0, six, five, four, S, S, 1'b0, B}), .sel(cntrl));
	
endmodule

// Testbench for bit slicer.
module bit_slice_testbench();

	logic A, B;
	logic [2:0] cntrl;
	logic R;
	logic Cin, Cout;
	
	//	bit_slice dut (.A(A), .B(B), .cntrl(cntrl), .R(R), .Cin(Cin), .Cout(Cout)); 
	bit_slice dut (.*);
	
	initial begin
	
		for (int i = 0; i < 8; i++) begin
			cntrl = i;
			
			for (int j = 0; j < 8; j++) begin 
				{A, B, Cin} = j;
				#10;
				
			end
		end
		
	$stop;
	end
	
endmodule
	