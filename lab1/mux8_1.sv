module mux8_1(i, sel, out);

	output logic out;
	input logic [7:0] i;
	input logic [2:0] sel; 
	
	logic internal_out0;
	mux4_1 mux0 (.out(internal_out0), .i(i[3:0]), .sel(sel[1:0]));

	logic internal_out1;
	mux4_1 mux1 (.out(internal_out1), .i(i[7:4]), .sel(sel[1:0]));
	
	mux2_1 mux2 (.out(out), .i({internal_out0, internal_out1}), .sel(sel[2]));
	
endmodule


//module mux8_1_testbench();
//
//	logic i0, i1, i2, i3, i4, i5, i6, i7, out;
//	logic [2:0] sel;
//	
//	mux8_1 dut (.*);
//	
//	initial begin
//	
//		sel = 3'b000;		#10;
//		i0 = 1'b1; i1 = 1'b0; i2 = 1'b0; i3 = 1'b0; i4 = 1'b0; i5 = 1'b0; i6 = 1'b0; i7 = 1'b0; #10
//		
//		sel = 3'b001;		#10;
//		i0 = 1'b0; i1 = 1'b1; i2 = 1'b0; i3 = 1'b0; i4 = 1'b0; i5 = 1'b0; i6 = 1'b0; i7 = 1'b0; #10
//		
//		sel = 3'b010;		#10;
//		i0 = 1'b0; i1 = 1'b0; i2 = 1'b1; i3 = 1'b0; i4 = 1'b0; i5 = 1'b0; i6 = 1'b0; i7 = 1'b0; #10
//		
//		sel = 3'b011;		#10;
//		i0 = 1'b0; i1 = 1'b0; i2 = 1'b0; i3 = 1'b1; i4 = 1'b0; i5 = 1'b0; i6 = 1'b0; i7 = 1'b0; #10
//		
//		sel = 3'b100;		#10;
//		i0 = 1'b0; i1 = 1'b0; i2 = 1'b0; i3 = 1'b0; i4 = 1'b1; i5 = 1'b0; i6 = 1'b0; i7 = 1'b0; #10
//		
//		sel = 3'b101;		#10;
//		i0 = 1'b0; i1 = 1'b0; i2 = 1'b0; i3 = 1'b0; i4 = 1'b0; i5 = 1'b1; i6 = 1'b0; i7 = 1'b0; #10
//		
//		sel = 3'b110;		#10;
//		i0 = 1'b0; i1 = 1'b0; i2 = 1'b0; i3 = 1'b0; i4 = 1'b0; i5 = 1'b0; i6 = 1'b1; i7 = 1'b0; #10
//		
//		sel = 3'b111;		#10;
//		i0 = 1'b0; i1 = 1'b0; i2 = 1'b0; i3 = 1'b0; i4 = 1'b0; i5 = 1'b0; i6 = 1'b0; i7 = 1'b1; #10
//		
//		$stop;
//	end
//	
//endmodule
