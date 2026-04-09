module mux2_1(out, i0, i1, sel);

	output logic out;
	input logic i0, i1, sel;
	
	logic n;
	not #0.05 not0 (nsel, sel);
	
	and #0.05 and0 (a0, i1, sel);
	and #0.05 and1 (a1, i0, nsel);

	or #0.05 or0 (out, a0, a1);
	
endmodule

// Old code (modified to avoid RTL)
// module mux2_1(out, i0, i1, sel);
//	output out;
//	input i0, i1, sel;
//	assign out = (i1 & sel) | (i0 & ~sel);
// endmodule

module mux2_1_testbench();

	logic i0, i1, sel, out;
	
	mux2_1 dut (.*);
	
	initial begin
	
		sel = 0;				#10;
		i0 = 0; i1 = 0; 	#10;
		i0 = 0; i1 = 1; 	#10;
		i0 = 1; i1 = 0; 	#10;
		i0 = 1; i1 = 1; 	#10;
		
		sel = 1;				#10;
		i0 = 0; i1 = 0; 	#10;
		i0 = 0; i1 = 1; 	#10;
		i0 = 1; i1 = 0; 	#10;
		i0 = 1; i1 = 1; 	#10;
		
		$stop;
	end
	
endmodule
	