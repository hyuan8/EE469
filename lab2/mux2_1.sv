`timescale 1ns/10ps

// This is a 2x1 multiplexer using gate-level logic.
// Gates have a 50ps delay.
module mux2_1(
    output logic out,
    input logic [1:0] i,
    input logic sel
);
	
	// Logic matching logic below (from previous mux module)
	// Code has been modified to use an array for i instead of i1 and i0.
	logic nsel, a0, a1;
	not #0.05 not0 (nsel, sel);
	
	and #0.05 and0 (a0, i[1], sel);
	and #0.05 and1 (a1, i[0], nsel);

	or #0.05 or0 (out, a0, a1);
	
endmodule

// Old code (modified to avoid RTL)
// module mux2_1(out, i0, i1, sel);
//	output out;
//	input i0, i1, sel;
//	assign out = (i1 & sel) | (i0 & ~sel);
// endmodule

// Testbench for 2x1 multiplexer.
module mux2_1_testbench();

	logic [1:0] i;
	logic sel, out;
	
	mux2_1 dut (.*);
	
	initial begin
	
		// Select = 0
		sel = 0;				#10;
		i = 2'b00;			#10;
		i = 2'b01;			#10;
		i = 2'b10;			#10;
		i = 2'b11;			#10;
		
		// Select = 1
		sel = 1;				#10;
		i = 2'b00;			#10;
		i = 2'b01;			#10;
		i = 2'b10;			#10;
		i = 2'b11;			#10;
		
		$stop;
	end
	
endmodule
	