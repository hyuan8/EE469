module mux4_1(i, sel, out);

	output logic out;
	input logic [3:0] i;
	input logic [1:0] sel; 
	
	logic internal_out0;
	mux2_1 mux0 (.out(internal_out0), .i(i[1:0]), .sel(sel[0]));

	logic internal_out1;
	mux2_1 mux1 (.out(internal_out1), .i(i[3:2]), .sel(sel[0]));
	
	mux2_1 mux2 (.out(out), .i({internal_out1, internal_out0}), .sel(sel[1]));
	
endmodule

module mux4_1_testbench();

	logic out;
	logic [3:0] i;
	logic [1:0] sel;
	
	mux4_1 dut (.*);
	
	initial begin
	
		sel = 2'b00;	#10;
		i = 4'b0001;	#10;
		sel = 2'b01;	#10;
		i = 4'b0010;	#10;
		sel = 2'b10;	#10;
		i = 4'b0100;	#10;
		sel = 2'b11;	#10;
		i = 4'b1000;	#10;
		
		$stop;
	end
	
endmodule
