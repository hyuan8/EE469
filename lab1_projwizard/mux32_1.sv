module mux32_1(i, sel, out);

	output logic out;
	input logic [31:0] i;
	input logic [4:0] sel; 
	
	logic internal_out0;
	mux16_1 mux0 (.out(internal_out0), .i(i[15:0]), .sel(sel[3:0]));

	logic internal_out1;
	mux16_1 mux1 (.out(internal_out1), .i(i[31:16]), .sel(sel[3:0]));
	
	mux2_1 mux2 (.out(out), .i({internal_out1, internal_out0}), .sel(sel[4]));
	
endmodule

module mux32_1_testbench();

	logic out;
	logic [31:0] i;
	logic [4:0] sel;
	
	mux32_1 dut (.*);
	
	initial begin
	
		integer j; // use j because i is input
		for (j = 0; j < 32; j++) begin
			sel = j[4:0]; #10;
			i = 32'b1 << j; #10;
		end
		$stop;
	end
	
endmodule