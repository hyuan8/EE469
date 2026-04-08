module regfile(ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, clk);

	input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister
	input logic [63:0] WriteData;
	input logic RegWrite;
	input logic clk;
	output logic [63:0] ReadData1, ReadData2;
	
	// instances here
	
endmodule