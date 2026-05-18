module flag_register (
	input logic clk, reset, enable
	input logic negative, zero, overflow, carry_out
	output logic negative_out, zero_out, overflow_out, carry_out_out
);
	
	
	D_FF_enable neg_ff 	(.q(negative_out), 	.d(negative), 	.reset(reset), .clk(clk), .enable(SetFlags));
	D_FF_enable zero_ff 	(.q(zero_out), 		.d(zero), 		.reset(reset), .clk(clk), .enable(SetFlags));
	D_FF_enable ov_ff 	(.q(overflow_out), 	.d(overflow), 	.reset(reset), .clk(clk), .enable(SetFlags));
	D_FF_enable co_ff 	(.q(carry_out_out), 	.d(carry_out), .reset(reset), .clk(clk), .enable(SetFlags));
	
endmodule