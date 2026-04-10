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
	genvar z;
	
	generate
		for(i = 0; i < 31; i++) begin : registers
			for (j = 0; j < 64; j++)  begin : bitnumbers
				D_FF_enable dff (.q(q[i][j]), .d(WriteData[j]), .reset(1'b0), .clk(clk), .enable(address[i]));
				
			end
		end
		
		
		for (z = 0; z < 64; z++) begin : register_zero
			 assign q[31][z] = 1'b0;
		end
		
		
	endgenerate
	
	// Muxes
	genvar k;
	genvar m;
	generate
		for (k = 0; k < 64; k++) begin : muxes
			
			logic [31:0] column;
			for (m = 0; m < 32; m++) begin : buildColumns
				assign column[m] = q[m][k];
			end
		
			mux32_1 mux1 (.out(ReadData1[k]), .i(column), .sel(ReadRegister1));
			mux32_1 mux2 (.out(ReadData2[k]), .i(column), .sel(ReadRegister2));
		end
	endgenerate
		
endmodule

