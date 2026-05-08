/* This module builds the main datapath for the CPU.

	INPUTS:
	- instruction:		32-bit instruction
	- ALUOp:				3-bit ALU operation
	- Reg2Loc: 			selects second register
	- ALUSrc: 			selects ALUB input
	- Mem2Reg:			selects what is written back to the register
	- RegWrite:			enables writing to the register file
	- MemWrite:			enables writing to the data memory
	- MemRead:			enables reading from the data memory
	- BrLink:			signal for BL instruction
	- Imm12:				selects which extension to use
	- reset:				reset signal
	- clk: 				clock
	- XferSize:			transfer size
	- unbranchAddr:	unbranched address

	OUTPUTS:
	- negative, zero, overflow, carry_out: flags from ALU operations
	- Db:					read data from second register
	- BrRegAddr:		address of branched register, used in BR instruction 
*/

module datapath (
		input logic [31:0] instruction,
		input logic [2:0] ALUOp,
		input logic Reg2Loc, ALUSrc, Mem2Reg,
		input logic RegWrite, MemWrite, MemRead, 
		input logic BrLink, Imm12,
		input logic clk, reset,
		input logic [3:0] XferSize,
		input logic [63:0] unbranchAddr,
		output logic [63:0] Db,
		output logic overflow, negative, zero, carry_out,
		output logic [63:0] BrRegAddr
	);
	
	// Regfile signals
	logic [4:0] Rd, Rm, Rn;
	logic [63:0] Da, Dw;
	logic [4:0] Aw, Ab;
	assign Rd = instruction[4:0];
	assign Rm = instruction[20:16];
	assign Rn = instruction[9:5];
	
	// BR X30 mux: writes to Rd if no link, but if link, uses reg X30
	mux2_1_Nbits #(.length(5)) BrLinkMux (.out(Aw), .A(Rd), .B(5'd30), .sel(BrLink)); 
	
	// Reg2Loc Mux: selects which source to use as second register
	mux2_1_Nbits #(.length(5)) Reg2LocMux (.out(Ab), .A(Rd), .B(Rm), .sel(Reg2Loc));
	
	// Instantiates regfile
	regfile register (.ReadData1(Da), .ReadData2(Db), .WriteData(Dw), 
				.ReadRegister1(Rn), .ReadRegister2(Ab), .WriteRegister(Aw), .RegWrite, .clk);
				
	assign BrRegAddr = Da; // stores BR address

	// Sign extends DAddr9, zero extends for ADD.I, then chooses between inputs based on if doing ADD.I
	logic [63:0] imm9, imm12, final_imm;
	sign_extender #(.length(9)) extender9 (.in(instruction[20:12]), .out(imm9));
	zero_extender #(.length(12)) extender12 (.in(instruction[21:10]), .out(imm12));
	mux2_1_Nbits #(.length(64)) FinalImmMux (.out(final_imm), .A(imm9), .B(imm12), .sel(Imm12));

	// ALUSrc Mux: selects ALUB input
	logic [63:0] ALUB; // second ALU input
	mux2_1_Nbits #(.length(64)) ALUSrcMux (.out(ALUB), .A(Db), .B(final_imm), .sel(ALUSrc));
	
	// Instantiates ALU
	logic [63:0] ALUOut; // ALU output
	alu ALU (.A(Da), .B(ALUB), .cntrl(ALUOp), .result(ALUOut), .negative(negative), .zero(zero), .overflow(overflow), .carry_out(carry_out));
	
	// Instantiates data memory
	logic [63:0] Dout; // read data value
	datamem DataMemory (.address(ALUOut), .write_enable(MemWrite), .read_enable(MemRead), 
				.write_data(Db), .clk, .xfer_size(XferSize), .read_data(Dout));
	
	// Mem2Reg Mux: selects ALUout or memory, wired to BrLinkWB mux
	logic [63:0] AluOrMem; // read data value or ALU output
	mux2_1_Nbits #(.length(64)) Mem2RegMux (.out(AluOrMem), .A(ALUOut),  .B(Dout), .sel(Mem2Reg));

	// BrLinkWB Mux: determines whether to branch or write data from 
	// A: normal write-back (ALU or memory), B: PC+4 for BL return address
	mux2_1_Nbits #(.length(64)) BrLinkWBMux (.out(Dw), .A(AluOrMem), .B(unbranchAddr), .sel(BrLink));

endmodule
