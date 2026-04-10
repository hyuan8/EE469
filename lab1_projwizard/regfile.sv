// This is an ARM 64-bit register file with 32 addresses.
module regfile(ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, clk);

	input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister; // respective addresses
	input logic [63:0] WriteData; // data being written
	input logic RegWrite; // enable
	input logic clk;
	output logic [63:0] ReadData1, ReadData2; // output data

	// Instaniate the 5x32 decoder to select the address to write to.
	logic [31:0] address;
	decoder5x32 write1 (.en(RegWrite), .in(WriteRegister), .out(address));
	
	// Use DFFs to create 64-bit registers.
	logic [63:0] q [31:0];
	
	genvar i;
	genvar j;
	genvar z;
	generate
		// Registers 0-30
		for(i = 0; i < 31; i++) begin : registers
			for (j = 0; j < 64; j++)  begin : bitnumbers
				D_FF_enable dff (.q(q[i][j]), .d(WriteData[j]), .reset(1'b0), .clk(clk), .enable(address[i]));
				
			end
		end
		// Register 31 equals 0.
		for (z = 0; z < 64; z++) begin : zero_register
			 assign q[31][z] = 1'b0;
		end
	endgenerate
	
	// Instantiate the muxes to manage data being read.
	genvar k;
	genvar m;
	generate
		for (k = 0; k < 64; k++) begin : muxes
			// Create columns of to bits in the same position
			// For example, a column contains all bits in position b2.
			// This is necessary as the mux takes 1 bit at a time.
			logic [31:0] column;
			for (m = 0; m < 32; m++) begin : buildColumns
				assign column[m] = q[m][k];
			end
			mux32_1 mux1 (.out(ReadData1[k]), .i(column), .sel(ReadRegister1)); // mux for read1
			mux32_1 mux2 (.out(ReadData2[k]), .i(column), .sel(ReadRegister2)); // mux for read2
		end
	endgenerate
		
endmodule

