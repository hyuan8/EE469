`timescale 1ns/10ps

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
	
	genvar i, j, z;
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
	
	logic [63:0] internal_ReadData1, internal_ReadData2;
	// Instantiate the muxes to manage data being read.
	genvar k, m;
	generate
		for (k = 0; k < 64; k++) begin : muxes
			// Create columns of to bits in the same position
			// For example, a column contains all bits in position b2.
			// This is necessary as the mux takes 1 bit at a time.
			logic [31:0] column;
			for (m = 0; m < 32; m++) begin : buildColumns
				assign column[m] = q[m][k];
			end
			mux32_1 mux1 (.out(internal_ReadData1[k]), .i(column), .sel(ReadRegister1)); // mux for read1
			mux32_1 mux2 (.out(internal_ReadData2[k]), .i(column), .sel(ReadRegister2)); // mux for read2
		end
	endgenerate

	// Logic for pipelining
	logic [4:0] eq1_bits, eq2_bits;
	logic eq1_all1, eq2_all1, eq1_all, eq2_all;
	logic not_x31;
	logic Forward1, Forward2;
	logic x31_1_val, x31_2_val;
	
	//	Forward1 = RegWrite && (WriteRegister == ReadRegister1) && (WriteRegister != 5'd31);
	//	Forward2 = RegWrite && (WriteRegister == ReadRegister2) && (WriteRegister != 5'd31);
	
	// Write Register == Read Register
	genvar n;
	generate
		for (n = 0; n < 5; n++) begin : eq_bits
			xnor #0.05 xnor1 (eq1_bits[n], WriteRegister[n], ReadRegister1[n]);
			xnor #0.05 xnor2 (eq2_bits[n], WriteRegister[n], ReadRegister2[n]);
		end
	endgenerate
	
	and #0.05 eq1_and1 (eq1_all1, eq1_bits[0], eq1_bits[1], eq1_bits[2]);
	and #0.05 eq2_and1 (eq2_all1, eq2_bits[0], eq2_bits[1], eq2_bits[2]);
	and #0.05 eq1_and (eq1_all, eq1_all1, eq1_bits[3], eq1_bits[4]);
	and #0.05 eq2_and (eq2_all, eq2_all1, eq2_bits[3], eq2_bits[4]);

	// Write Register != 5'd31
	and #0.05 x31_1 (x31_1_val, WriteRegister[0], WriteRegister[1], WriteRegister[2]);
	and #0.05 x31_2 (x31_2_val, x31_1_val, WriteRegister[3], WriteRegister[4]);
	not #0.05 notx31 (not_x31, x31_2_val);
	
	// && all parts
	and #0.05 fw1_gate (Forward1, RegWrite, eq1_all, not_x31);
	and #0.05 fw2_gate (Forward2, RegWrite, eq2_all, not_x31);

	// Forwards register stored value or incoming write data
	mux2_1_Nbits #(.length(64)) bypassMux1 (.out(ReadData1), .A(internal_ReadData1), .B(WriteData), .sel(Forward1));
	mux2_1_Nbits #(.length(64)) bypassMux2 (.out(ReadData2), .A(internal_ReadData2), .B(WriteData), .sel(Forward2));
		
endmodule

