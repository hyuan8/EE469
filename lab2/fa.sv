// This module builds a full adder.
module fa(A, B, Cin, Cout, S);

	input logic A, B, Cin;
	output logic Cout, S;
	
	// Sum logic
	xor xor0 (S, A, B, Cin);
	
	// Carry logic
	and and0 (a0, A, B);
	and and1 (a1, B, Cin);
	and and2 (a2, A, Cin);
	or or0 (Cout, a0, a1, a2);
	
endmodule

// Full adder testbench.
module fa_testbench();

	logic A, B, Cin;
	logic Cout, S;
	
	fa dut (.*);
	
	initial begin
	
		A = 0; B = 0; Cin = 0; #10;
		A = 0; B = 0; Cin = 1; #10;
		A = 0; B = 1; Cin = 0; #10;
		A = 0; B = 1; Cin = 1; #10;
		A = 1; B = 0; Cin = 0; #10;
		A = 1; B = 0; Cin = 1; #10;
		A = 1; B = 1; Cin = 0; #10;
		A = 1; B = 1; Cin = 1; #10;
		
		$stop;
	end
	
endmodule
	