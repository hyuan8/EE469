module datapath (
		input logic [31:0] instruction,
		input logic [2:0] ALUOp,
		input logic ALUSrc, Mem2Reg, Reg2Loc, RegWrite,
		input logic MemWrite, MemRead,
		input logic clk, reset,
		input logic [3:0] XferSize, // needed for datamem, not sure what this is
		output logic [63:0] Db,
		output logic overflow, negative, zero, carry_out

	);
	
	logic [4:0] Rd, Rm, Rn;
	logic [63:0] Da, Dw;
	logic [4:0] Aw, Ab;
	assign Rd = instruction[4:0];
	assign Rm = instruction[20:16];
	assign Rn = instruction[9:5];
	
	// Reg2Loc Mux
	mux2_1_Nbits #(.length(5)) Reg2LocMux (.out(Ab), .A(Rd), .B(Rm), .sel(Reg2Loc));
	
	
	// Regfile
	regfile register (.ReadData1(Da), .ReadData2(Db), .WriteData(Dw), 
				.ReadRegister1(Rn), .ReadRegister2(Ab), .WriteRegister(Aw), .RegWrite, .clk);

	// Sign extend DAddr9
	logic [63:0] offset;
	sign_extender #(.length(9)) extender9 (.in(instruction[20:12]), .out(offset));
	
	// ALUSrc Mux
	logic [63:0] ALUB;
	mux2_1_Nbits #(.length(64)) ALUSrcMux (.out(ALUB), .A(Db), .B(offset), .sel(ALUSrc));
	
	// ALU
	logic [63:0] ALUOut;
	alu ALU (.A(Da), .B(ALUB), .cntrl(ALUOp), .result(ALUOut), .negative(negative), .zero(zero), .overflow(overflow), .carry_out(carry_out));
	
	// Data Memory
	logic [63:0] Dout;
	datamem DataMemory (.address(ALUOut), .write_enable(MemWrite), .read_enable(MemRead), 
				.write_data(Db), .clk, .xfer_size(XferSize), .read_data(Dout));
	
	// Mem2Reg Mux
	mux2_1_Nbits #(.length(64)) Mem2RegMux (.out(Dw), .A(ALUOut), .B(Dout), .sel(Mem2Reg));

endmodule
