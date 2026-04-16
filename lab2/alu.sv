module alu(A, B, cntrl, result, negative, zero, overflow, carry_out)

	input logic	[63:0] A, B;
	input logic	[2:0]	cntrl;
	output logic	negative, zero, overflow, carry_out;
	output logic [63:0] result;
	
	logic [63:0] carry_chain;
	
	bit_slice first_slice (.A(A[0]), .B(B[0]), .control(cntrl), .Cin(cntrl[0]), .Cout(carry_chain[0]), .R(result[0]));
	
	genvar i;
	generate
		for(i = 0; i < 64; i++) begin: slices
			bit_slice slice (.A(A[i]), .B(B[i]), .control(cntrl), .Cin(carry_chain[i-1]), .Cout(carry_chain[i]), .R(result[i]));
		end
	endgenerate
	
	assign negative = result[63];
	assign carry_out = carry_chain[63];
	
	
endmodule
	
	