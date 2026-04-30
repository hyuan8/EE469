module sign_extender #(parameter length = 1) (in, out);
	
	input logic [length - 1:0] in;
	output logic [63:0] out;
	
	assign out = { {{64 - length}{in[length - 1]}}, in };
	
endmodule