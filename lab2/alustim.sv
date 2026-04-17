// Test bench for ALU
`timescale 1ns/10ps

// Meaning of signals in and out of the ALU:

// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

module alustim();

	parameter delay = 100000;

	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carry_out ;

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	

	alu dut (.A, .B, .cntrl, .result, .negative, .zero, .overflow, .carry_out);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	integer i;
	logic [63:0] test_val;
	initial begin
	
//		$display("%t testing PASS_A operations", $time);
//		cntrl = ALU_PASS_B;
//		for (i=0; i<100; i++) begin
//			A = $random(); B = $random();
//			#(delay);
//			assert(result == B && negative == B[63] && zero == (B == '0));
//		end
//		
//		$display("%t testing addition", $time);
//		cntrl = ALU_ADD;
//		A = 64'h0000000000000001; B = 64'h0000000000000001;
//		#(delay);
//		assert(result == 64'h0000000000000002 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		
		$display("%t testing PASS_B operations", $time);
		cntrl = ALU_PASS_B;

		A = 64'h0; B = 64'h0; #delay;
		assert(result == B && negative == B[63] && zero == (B == '0));

		A = 64'h0; B = 64'hFF; #delay;
		assert(result == B && negative == B[63] && zero == (B == '0));

		A = 64'hFFF; B = 64'hAA; #delay;
		assert(result == B && negative == B[63] && zero == (B == '0));
		
		// Moved loop from above and shortened
		for (i = 0; i < 20; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end

		

		
		
		
		// Added to mirror ALU testbench in ALU module and cycle through random variables
		
		$display("%t testing addition", $time);
		cntrl = ALU_ADD;

		A = 64'h0; B = 64'h0; #delay;
		assert(result == 64'h0 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 1);

		A = 64'h3; B = 64'h5; #delay;
		assert(result == 64'h8 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);

		A = 64'hFFFFFFFFFFFFFFFF; B = 64'h1; #delay;
		assert(result == 64'h0 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 1);

		A = 64'h7FFFFFFFFFFFFFFF; B = 64'h1; #delay;
		assert(result == 64'h8000000000000000 && carry_out == 0 && overflow == 1 && negative == 1 && zero == 0);

		A = 64'h8000000000000000; B = 64'hFFFFFFFFFFFFFFFF; #delay;
		assert(result == 64'h7FFFFFFFFFFFFFFF && carry_out == 1 && overflow == 1 && negative == 0 && zero == 0);
		
		for (i = 0; i < 20; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == (A + B));
		end


		
		
		
		$display("%t testing subtraction", $time);
		cntrl = ALU_SUBTRACT;

		A = 64'h0; B = 64'h0; #delay;
		assert(result == 64'h0 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 1);

		A = 64'h5; B = 64'h3; #delay;
		assert(result == 64'h2 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 0);

		A = 64'h3; B = 64'h5; #delay;
		assert(result == 64'hFFFFFFFFFFFFFFFE && carry_out == 0 && overflow == 0 && negative == 1 && zero == 0);

		A = 64'h0; B = 64'h1; #delay;
		assert(result == 64'hFFFFFFFFFFFFFFFF && carry_out == 0 && overflow == 0 && negative == 1 && zero == 0);

		A = 64'h7FFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFF; #delay;
		assert(result == 64'h8000000000000000 && carry_out == 0 && overflow == 1 && negative == 1 && zero == 0);
		
		for (i = 0; i < 20; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == (A - B));
		end


		
		
		
		$display("%t testing AND", $time);
		cntrl = ALU_AND;

		A = 64'h0; B = 64'h0; #delay;
		assert(result == 64'h0 && zero == 1);

		A = 64'hAAAAAAAAAAAAAAAA; B = 64'h5555555555555555; #delay;
		assert(result == 64'h0 && zero == 1);

		A = 64'h00FF; B = 64'h00FF; #delay;
		assert(result == 64'h00FF);
		
		for (i = 0; i < 20; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == (A & B));
		end

		
		
		

		$display("%t testing OR", $time);
		cntrl = ALU_OR;

		A = 64'h0; B = 64'h0; #delay;
		assert(result == 64'h0 && zero == 1);

		A = 64'hAAAAAAAAAAAAAAAA; B = 64'h5555555555555555; #delay;
		assert(result == 64'hFFFFFFFFFFFFFFFF);

		A = 64'h0F0F; B = 64'hF0F0; #delay;
		assert(result == 64'hFFFF);
		
		for (i = 0; i < 20; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == (A | B));
		end

		

		
		
		$display("%t testing XOR", $time);
		cntrl = ALU_XOR;

		A = 64'h0; B = 64'h0; #delay;
		assert(result == 64'h0 && zero == 1);

		A = 64'hAAAAAAAAAAAAAAAA; B = 64'h5555555555555555; #delay;
		assert(result == 64'hFFFFFFFFFFFFFFFF);

		A = 64'h00FF; B = 64'h00FF; #delay;
		assert(result == 64'h0 && zero == 1);
		
		for (i = 0; i < 20; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == (A ^ B));
		end
		
	end
endmodule
