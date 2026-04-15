// cntrl			Operation						Notes:

// CNTRL[2:0] = 000 --> result
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

// This module builds a bit slicer.
module bit_slice(A, B, S, R, Cin, Cout);

	input logic A, B;
	input logic [2:0] S;
	output logic [2:0] R;
	
	// 100: result = bitwise A & B -- value of overflow and carry_out unimportant
	and #0.05 and0 (four, A, B);
	
	// 101: result = bitwise A | B -- value of overflow and carry_out unimportant
	or #0.05 or0 (five, A, B);	
	
	// 110: result = bitwise A XOR B	value of overflow and carry_out unimportant
	xor #0.05 xor0 (six, A, B);
	
	// 2x1 mux for full adder
	logic mux2out;
	not #0.05 not0 (nB, B);
	mux2_1 mux2 (.out(mux2out), .i({nB, B}), .sel(S[1]); // not sure if sel is correct
	
	// full adder
	logic Cin, Cout, S;
	fa fulladder (.A(A), .B(B), .Cin(Cin), .Cout(Cout), .S(S));
	
	mux8_1 mux8 (.out(R), .i({B, 1'b0, S, S, , four, five, six, 1'b0}), .sel(S));
	
endmodule
	