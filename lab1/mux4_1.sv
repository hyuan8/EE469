module mux4_1(out, i0, i1, i2, i3, sel);

	output logic [1:0] out;
	input logic [1:0] i0, i1, i2, i3, sel; 
	
	logic [1:0] internal_out0;
	mux2_1 mux0 (.out(internal_out0), .i0(i0), .i1(i1), .sel(sel[0]));

	logic [1:0] internal_out1;
	mux2_1 mux1 (.out(internal_out1), .i0(i2), .i1(i3), .sel(sel[0]));
	
	mux2_1 mux2 (.out(out), .i0(internal_out0), .i1(internal_out1), .sel(sel[1]));
	
endmodule


// Look into later
module mux2_1(out, i0, i1, sel);

    output logic [1:0] out;
    input  logic [1:0] i0, i1;
    input  logic sel;
    
    logic nsel;
    logic [1:0] a0, a1;

    not #0.05 not0 (nsel, sel);
    
    and #0.05 and0 (a0[0], i1[0], sel);
    and #0.05 and1 (a0[1], i1[1], sel);

    and #0.05 and2 (a1[0], i0[0], nsel);
    and #0.05 and3 (a1[1], i0[1], nsel);

    or #0.05 or0 (out[0], a0[0], a1[0]);
    or #0.05 or1 (out[1], a0[1], a1[1]);

endmodule

module mux4_1_testbench();

	logic [1:0] i0, i1, i2, i3, sel, out;
	
	mux4_1 dut (.*);
	
	initial begin
	
		sel = 2'b00;		#10;
		i0 = 2'b00; i1 = 2'b01; i2 = 2'b10; i3 = 2'b11; #10
		sel = 2'b01;		#10;
		i0 = 2'b00; i1 = 2'b01; i2 = 2'b10; i3 = 2'b11; #10
		sel = 2'b10;		#10;
		i0 = 2'b00; i1 = 2'b01; i2 = 2'b10; i3 = 2'b11; #10
		sel = 2'b11;		#10;
		i0 = 2'b00; i1 = 2'b01; i2 = 2'b10; i3 = 2'b11; #10
		
		$stop;
	end
	
endmodule
