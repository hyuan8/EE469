module mux4_1(i, sel, out);

	output logic out;
	input logic [3:0] i;
	input logic [1:0] sel; 
	
	logic internal_out0;
	mux2_1 mux0 (.out(internal_out0), .i(i[1:0]), .sel(sel[0]));

	logic internal_out1;
	mux2_1 mux1 (.out(internal_out1), .i(i[3:2]), .sel(sel[0]));
	
	mux2_1 mux2 (.out(out), .i({internal_out0, internal_out1}), .sel(sel[1]));
	
endmodule


//module mux4_1_testbench();
//
//	logic i0, i1, i2, i3, out;
//	logic [1:0] sel;
//	
//	mux4_1 dut (.*);
//	
//	initial begin
//	
//		sel = 2'b00;		#10;
//		i0 = 1'b1; i1 = 1'b0; i2 = 1'b0; i3 = 1'b0; #10
//		sel = 2'b01;		#10;
//		i0 = 1'b0; i1 = 1'b1; i2 = 1'b0; i3 = 1'b0; #10
//		sel = 2'b10;		#10;
//		i0 = 1'b0; i1 = 1'b0; i2 = 1'b1; i3 = 1'b0; #10
//		sel = 2'b11;		#10;
//		i0 = 1'b0; i1 = 1'b0; i2 = 1'b0; i3 = 1'b1; #10
//		
//		$stop;
//	end
//	
//endmodule
