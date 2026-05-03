module full_adder_64bits(result, A, B, Cin, Cout);

	input  logic [63:0] A, B;
	input  logic Cin, Cout;
	output logic [63:0] result;
	logic [63:0] carry;
	
	fullAdder adderOne (.result(result[0]), .A(A[0]), .B(B[0]), .Cin(cin), .Cout(carry[0]));
	genvar i;
	generate 
		for (i = 1; i < 64; i++) begin: gen_other_adders
			fullAdder adders (.result(result[i]), .A(A[i]), .B(B[i]), .Cin(carry[i-1]), .Cout(carry[i]));
		end
	endgenerate
	
	assign Cout = carries[63];
	
endmodule