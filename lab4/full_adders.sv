`timescale 1ns/10ps

// This module builds a full adder.
module fa(A, B, Cin, Cout, S);

	input logic A, B, Cin;
	output logic Cout, S;
	
	logic a0, a1, a2;
	
	// Sum logic
	xor #0.05 xor0 (S, A, B, Cin);
	
	// Carry logic
	and #0.05 and0 (a0, A, B);
	and #0.05 and1 (a1, B, Cin);
	and #0.05 and2 (a2, A, Cin);
	or #0.05 or0 (Cout, a0, a1, a2);
	
endmodule

module full_adder_64bits(S, A, B, Cin, Cout);

	input logic [63:0] A, B;
	input logic Cin;
	output logic Cout;
	output logic [63:0] S;
	logic [63:0] carries;
	
	fa adderOne (.S(S[0]), .A(A[0]), .B(B[0]), .Cin(Cin), .Cout(carries[0]));
	genvar i;
	generate 
		for (i = 1; i < 64; i++) begin: gen_other_adders
			fa adders (.S(S[i]), .A(A[i]), .B(B[i]), .Cin(carries[i-1]), .Cout(carries[i]));
		end
	endgenerate
	
	assign Cout = carries[63];
	
endmodule