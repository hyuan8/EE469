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