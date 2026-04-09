module regfile(ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, clk);

	input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	input logic [63:0] WriteData;
	input logic RegWrite;
	input logic clk;
	output logic [63:0] ReadData1, ReadData2;

	// Decoder
	logic [31:0] address;
	decoder5x32 write1 (.en(RegWrite), .in(WriteRegister), .out(address));
	
	// DFFs
	logic [63:0] q [31:0];
	genvar i;
	genvar j;
	generate
		for(i = 0; i < 32; i++) begin : registers
			for (j = 0; j < 64; j++) : bitnumbers
				D_FF_enable dff (.q(q[i][j]), .d(WriteData[i][]), .reset(1'b0), .clk(clk), .enable(address[i]));
			end
		end
	endgenerate
	
	// Muxes
	genvar k;
	generate
		for (k = 0; k < 64; k++) begin : muxes
			mux32_1 mux1 (.out(ReadData[k]), .i0, .i1, .sel(ReadRegister1));
			mux32_1 mux2 (.out(ReadData[k]), .i0, .i1, .sel(ReadRegister2));
		end
	endgenerate
		
endmodule

