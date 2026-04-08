module decoder3x8 (en, in, out);

	input logic en;
	input logic [2:0] in;
	output logic [7:0] out;
	
	logic [2:0] n;
	not #0.05 not0 (n[0], in[0]);
	not #0.05 not1 (n[1], in[1]);
	not #0.05 not2 (n[2], in[2]);
	
	and #0.05 out0 (out[0], en, n[2], n[1], n[0]);
	and #0.05 out1 (out[1], en, n[2], n[1], in[0]); 
	and #0.05 out2 (out[2], en, n[2], in[1], n[0]);
	and #0.05 out3 (out[3], en, n[2], in[1], in[0]);
	and #0.05 out4 (out[4], en, in[2], n[1], n[0]);
	and #0.05 out5 (out[5], en, in[2], n[1], in[0]); 
	and #0.05 out6 (out[6], en, in[2], in[1], n[0]);
	and #0.05 out7 (out[7], en, in[2], in[1], in[0]);
	
endmodule

module decoder3x8_testbench();

	logic en;
	logic [2:0] in;
	logic [7:0] out;
	
	decoder3x8 dut (.*);
	
	integer i;
	initial begin
	
		en = 1'b0;
		for (i = 0; i < 2**3; i++) begin
			in = i; #10;
		end
		
		en = 1'b1;
		for (i = 0; i < 2**3; i++) begin
			in = i; #10;
		end
		
		$stop;
	end
	
endmodule 