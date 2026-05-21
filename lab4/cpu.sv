`timescale 1ns/10ps

/* OLD CPU
// This module builds the CPU.

	INPUTS:
	- clk: 		clock
	- reset: 	reset signal

	OUTPUTS: N/A
	
	Signals are read through the instruction mem, whnich reads the .arm files.
	
	INTERNAL SIGNALS:
	- instruction:			32-bit instruction
	- unbranchedAddr:		unbranched address
	
	- ALUOp:			3-bit ALU operation
	- Reg2Loc: 		selects second register
	- ALUSrc: 		selects ALUB input
	- MemToReg:		selects what is written back to the register
	- RegWrite:		enables writing to the register file
	- MemWrite:		enables writing to the data memory
	- MemRead:		enables reading from the data memory
	- BrTaken:		selects next PC source
	- UncondBr:		selects which sign-extended offset feeds to the branch adder
	- SetFlags:		enables flag outputs to be stored
	- Imm12:			selects which extension to use
	- BrLink:		signal for BL instruction
	- BrReg:			signal for BR instruction 
	- Db:				read data from second register
	- BrRegAddr:	address of branched register, used in BR instruction 
	- ALUzero: 		unregistered zero flag for CBZ instruction (BrTaken) 
*/

//module cpu (
//	input logic clk, reset
//);
//
//	logic [31:0] instruction;
//	logic [63:0] unbranchedAddr;
//	
//	logic [2:0] ALUOp;
//	logic ALUSrc, MemToReg, Reg2Loc, RegWrite, MemWrite, MemRead;
//	
//	logic negative, zero, overflow, carry_out;
//	logic	UncondBr, BrTaken, SetFlags;
//	
//	logic BrLink, BrReg;
//	logic [63:0] BrRegAddr;
//	
//	logic Imm12;
//	logic [63:0] Db;
//
//	// Registered flags (using DFF w/ enable) - only update when SetFlags=1
//	logic neg_reg, zero_reg, ov_reg, co_reg;
//
//	flag_register FR (.clk(clk), .reset(reset), .enable(SetFlags), 
//		.negative(negative), .zero(zero), .overflow(overflow), .carry_out(carry_out), 
//		.negative_out(neg_reg), .zero_out(zero_reg), .overflow_out(overflow_out), .carry_out_out(co_reg));
//	
//	// Instantiates instruction fetch
//	instruction_fetch IF (.UncondBr(UncondBr), .BrTaken(BrTaken), .BrReg(BrReg), .BrRegAddr(BrRegAddr),
//		.reset(reset), .clk(clk), .instruction(instruction), .unbranchedAddr(unbranchedAddr));
//		
//	// Instantiates control unit
//	control CTL (.instruction(instruction), .negative(neg_reg), .zero(zero_reg), .overflow(ov_reg),
//		.carry_out(co_reg), .ALUOp(ALUOp), .Reg2Loc(Reg2Loc), .ALUSrc(ALUSrc), .MemToReg(MemToReg),
//		.RegWrite(RegWrite), .MemWrite(MemWrite), .MemRead(MemRead), .BrTaken(BrTaken), .Imm12(Imm12),
//		.UncondBr(UncondBr), .SetFlags(SetFlags), .BrLink(BrLink), .BrReg(BrReg), .ALUzero(zero)) ;
//		
//	// Instantiates main datapath
//	datapath DP (.instruction(instruction), .ALUOp(ALUOp), .ALUSrc(ALUSrc), .Mem2Reg(MemToReg), .BrLink(BrLink),
//		.unbranchAddr(unbranchedAddr), .BrRegAddr(BrRegAddr), .Imm12(Imm12), .Db(Db),
//		.Reg2Loc(Reg2Loc), .RegWrite(RegWrite), .MemWrite(MemWrite), .MemRead(MemRead), .clk(clk), .reset(reset), 
//		.XferSize(4'd8), .negative(negative), .zero(zero), .overflow(overflow), .carry_out(carry_out));
//	
//endmodule

module cpu (input logic clk, reset);
	logic [31:0] instruction_IF;
	logic [63:0] currentPC, PC_plus4_IF, newPC;
	
	//instruction fetch stage
	//computes PC+4 and PC+offset (BR instruction) and chooses between them
	program_counter PC (.in(newPC), .out(currentPC), .clk(clk), .reset(reset));
	
	full_adder_64bits PC_4 (.S(PC_plus4_IF), .A(currentPC), .B(64'd4), .Cin(1'b0), .Cout());
	
	instructmem instruction_memory (.address(currentPC), .instruction(instruction_IF), .clk);
	logic [4:0] Rd_MEM;
	
	logic BrTaken_MEM, BrReg_MEM;
	logic [63:0] branchedAddr_MEM;
	logic [63:0] BrRegAddr_MEM;
	logic [63:0] immBranchPC; // PC from immediate branch
	mux2_1_Nbits #(.length(64)) BrTakenMux (.out(immBranchPC), .A(branchedAddr_MEM), .B(PC_plus4_IF), .sel(BrTaken_MEM));
	
	// BrReg Mux: selects next PC from the immediate branch PC or the register value for BR
	mux2_1_Nbits #(.length(64)) BrRegMux (.out(newPC), .A(immBranchPC), .B(BrRegAddr_MEM), .sel(BrReg_MEM));
	
	//if/id reg
	logic [31:0] instruction_ID;
	logic [63:0] PC_plus4_ID;
	IF_ID_reg IF_ID (.clk(clk), .reset(reset), .instruction(instruction_IF), .PC(PC_plus4_IF), .instruction_out(instruction_ID), .PC_out(PC_plus4_ID));
	
	logic negative_EX, zero_EX, overflow_EX, carry_out_EX;

	
	//instruction decode
	logic [2:0] ALUOp_ID;
	logic ALUSrc_ID, MemToReg_ID, Reg2Loc_ID, RegWrite_ID, MemWrite_ID, MemRead_ID;
	logic	UncondBr_ID, BrTaken_ID, SetFlags_ID;
	logic BrLink_ID, BrReg_ID, Imm12_ID;
	logic [63:0] condOffset_ID, brOffset_ID;

	logic [4:0] Rd_ID, Rm_ID, Rn_ID;
	logic [63:0] Da_ID, Db_ID;
	logic [4:0] Ab_ID;
	
	//write back signals
	logic [4:0] Rd_WB;
	logic RegWrite_WB;
	
	//saved flags
	logic neg_reg, zero_reg, ov_reg, co_reg;
	
	assign Rd_ID = instruction_ID[4:0];
	assign Rm_ID = instruction_ID[20:16];
	assign Rn_ID = instruction_ID[9:5];
		
	control CTL (.instruction(instruction_ID), .negative(neg_reg), .zero(zero_reg), .overflow(ov_reg),
		.carry_out(co_reg), .ALUOp(ALUOp_ID), .Reg2Loc(Reg2Loc_ID), .ALUSrc(ALUSrc_ID), .MemToReg(MemToReg_ID),
		.RegWrite(RegWrite_ID), .MemWrite(MemWrite_ID), .MemRead(MemRead_ID), .BrTaken(BrTaken_ID), .Imm12(Imm12_ID),
		.UncondBr(UncondBr_ID), .SetFlags(SetFlags_ID), .BrLink(BrLink_ID), .BrReg(BrReg_ID), .ALUzero(zero_EX)) ; //raw zero for ALU comes from ex stage
	
	//mux to choose if second register is from memory or from instruction
	mux2_1_Nbits #(.length(5)) Reg2LocMux (.out(Ab_ID), .A(Rd_ID), .B(Rm_ID), .sel(Reg2Loc_ID));
	
	//sign extend for DAddr9, zero extend for ADDI 
	logic [63:0] imm9_ID, imm12_ID;
	sign_extender #(.length(9)) extender9 (.in(instruction_ID[20:12]), .out(imm9_ID));
	zero_extender #(.length(12)) extender12 (.in(instruction_ID[21:10]), .out(imm12_ID));
	
	// condOffset: 64-bits for CBZ/CBNZ instructions
	// brOffset: 64-bits for B/BL instructions
	sign_extender #(.length(19)) extender1 (.in(instruction_ID[23:5]), .out(condOffset_ID));
	sign_extender #(.length(26)) extender2 (.in(instruction_ID[25:0]), .out(brOffset_ID));
	
	logic [63:0] Dw_WB;
	regfile register (.ReadData1(Da_ID), .ReadData2(Db_ID), .WriteData(Dw_WB), 
				.ReadRegister1(Rn_ID), .ReadRegister2(Ab_ID), .WriteRegister(Rd_WB), .RegWrite(RegWrite_WB), .clk(clk));
	
	//id/ex reg
	logic RegWrite_EX, MemWrite_EX, MemRead_EX, MemToReg_EX;
	logic ALUSrc_EX, SetFlags_EX, BrLink_EX, Imm12_EX, BrReg_EX;
	logic [2:0] ALUOp_EX;
	logic [63:0] Da_EX, Db_EX;
	logic [4:0] Rn_EX, Rm_EX, Rd_EX;
	logic [63:0] imm9_EX, imm12_EX, PC_plus4_EX;
	
	logic [4:0] Aw_WB;

	logic UncondBr_EX, BrTaken_EX; 
	logic [63:0] condOffset_EX, brOffset_EX;
	
	
	ID_EX_reg ID_EX (.clk(clk), .reset(reset), .RegWrite(RegWrite_ID), .MemWrite(MemWrite_ID), 
	.MemRead(MemRead_ID), .MemToReg(MemToReg_ID), .UncondBr(UncondBr_ID), .BrTaken(BrTaken_ID), .ALUSrc(ALUSrc_ID), 
	.SetFlags(SetFlags_ID), .BrLink(BrLink_ID), .Imm12(Imm12_ID), .BrReg(BrReg_ID), 
	.ALUOp(ALUOp_ID), .Da(Da_ID), .Db(Db_ID), .Rn(Rn_ID), .Rm(Rm_ID), .Rd(Rd_ID), 
	.imm9(imm9_ID), .imm12(imm12_ID),.PC_plus4(PC_plus4_ID), .condOffset(condOffset_ID), .brOffset(brOffset_ID), .RegWrite_out(RegWrite_EX),
	.MemWrite_out(MemWrite_EX), .MemRead_out(MemRead_EX), .MemToReg_out(MemToReg_EX), 
	.ALUSrc_out(ALUSrc_EX), .SetFlags_out(SetFlags_EX), .BrLink_out(BrLink_EX), .Imm12_out(Imm12_EX), 
	.BrReg_out(BrReg_EX), .ALUOp_out(ALUOp_EX), .Da_out(Da_EX), .Db_out(Db_EX),
	.Rn_out(Rn_EX), .Rm_out(Rm_EX), .Rd_out(Rd_EX),.imm9_out(imm9_EX), .imm12_out(imm12_EX), 
	.PC_plus4_out(PC_plus4_EX), .UncondBr_out(UncondBr_EX), .BrTaken_out(BrTaken_EX), .condOffset_out(condOffset_EX), 
	.brOffset_out(brOffset_EX));
	
	//execute stage
	
	logic [63:0] brAddr_EX, shiftedAddr_EX, branchedAddr_EX;
	logic [4:0] WriteReg_EX;

	//
	mux2_1_Nbits #(.length(64)) UncondBrMux (.out(brAddr_EX), .A(condOffset_EX), .B(brOffset_EX), .sel(UncondBr_EX));
	shifter shift2 (.value(brAddr_EX), .direction(1'b0), .distance(6'd2), .result(shiftedAddr_EX));
	full_adder_64bits branchAddr (.S(branchedAddr_EX), .A(PC_plus4_EX), .B(shiftedAddr_EX), .Cin(1'b0), .Cout());

	logic [63:0] final_imm_EX;
	mux2_1_Nbits #(.length(64)) FinalImmMux (.out(final_imm_EX), .A(imm9_EX), .B(imm12_EX), .sel(Imm12_EX));
	
	logic RegWrite_MEM;
	logic [1:0] ForwardA, ForwardB;
	forwarding_unit FU (.Rn_EX(Rn_EX), .Ab_EX(Rm_EX), .Rd_MEM(Rd_MEM), .Rd_WB(Rd_WB), .RegWrite_MEM(RegWrite_MEM),
		.RegWrite_WB(RegWrite_WB), .ForwardA(ForwardA), .ForwardB(ForwardB));
	
	logic [63:0] ForwardA_out, ForwardB_out;
	logic [63:0] ALUOut_MEM;
	mux4_1_Nbits #(.length(64)) ForwardAMux (.out(ForwardA_out), .A(Da_EX), .B(ALUOut_MEM), .C(Dw_WB), .D(64'd0), .sel(ForwardA));
	mux4_1_Nbits #(.length(64)) ForwardBMux (.out(ForwardB_out), .A(Db_EX), .B(ALUOut_MEM), .C(Dw_WB), .D(64'd0), .sel(ForwardB));
	
	// ALUSrc Mux: selects ALUB input
	logic [63:0] ALUB_EX; // second ALU input
	mux2_1_Nbits #(.length(64)) ALUSrcMux (.out(ALUB_EX), .A(ForwardB_out), .B(final_imm_EX), .sel(ALUSrc_EX));
	
	logic [63:0] ALUOut_EX;
	alu ALU (.A(ForwardA_out), .B(ALUB_EX), .cntrl(ALUOp_EX), .result(ALUOut_EX), .negative(negative_EX), .zero(zero_EX), .overflow(overflow_EX), .carry_out(carry_out_EX));
	
	//BrLink mux to choose which register to write to if BrLink is true
	mux2_1_Nbits #(.length(5)) BrLinkRegMux (.out(WriteReg_EX), .A(Rd_EX), .B(5'd30), .sel(BrLink_EX));
	
	//ex/mem reg
	logic MemWrite_MEM, MemRead_MEM, MemToReg_MEM, BrLink_MEM;
	
	logic [63:0] Db_MEM;
	

	logic SetFlags_MEM;
	
	logic negative_MEM, zero_MEM, overflow_MEM, carry_out_MEM;
	
	
	EX_MEM_reg EX_MEM (.clk(clk), .reset(reset), .RegWrite(RegWrite_EX), .MemWrite(MemWrite_EX), .MemRead(MemRead_EX), .MemToReg(MemToReg_EX), .BrLink(BrLink_EX), .BrTaken(BrTaken_EX), .BrReg(BrReg_EX), .branchedAddr(branchedAddr_EX),
		.ALU_operation(ALUOut_EX), .Db(ForwardB_out), .Rd(WriteReg_EX), .setFlags(SetFlags_EX), .negative(negative_EX), .zero(zero_EX), .overflow(overflow_EX), .carry_out(carry_out_EX), .BrRegAddr(ForwardB_out), .RegWrite_out(RegWrite_MEM), .MemWrite_out(MemWrite_MEM), 
		.MemRead_out(MemRead_MEM), .MemToReg_out(MemToReg_MEM), .BrLink_out(BrLink_MEM), .BrReg_out(BrReg_MEM), .ALU_operation_out(ALUOut_MEM), .Db_out(Db_MEM), .Rd_out(Rd_MEM), .setFlags_out(SetFlags_MEM), .negative_out(negative_MEM), 
		.zero_out(zero_MEM), .overflow_out(overflow_MEM), .carry_out_out(carry_out_MEM), .BrTaken_out(BrTaken_MEM), .branchedAddr_out(branchedAddr_MEM), .BrRegAddr_out(BrRegAddr_MEM));
	

	
	
	//mem stage
	logic [63:0] Dout_MEM; // read data value
	datamem DataMemory (.address(ALUOut_MEM), .write_enable(MemWrite_MEM), .read_enable(MemRead_MEM), 
				.write_data(Db_MEM), .clk(clk), .xfer_size(4'd8), .read_data(Dout_MEM));
				
				
				
				
				
	//mem/wb reg
	logic MemToReg_WB, BrLink_WB;
	logic [63:0] ALUOut_WB, DataMem_WB; 
	MEM_WB_reg MEM_WB (.clk(clk), .reset(reset), .RegWrite(RegWrite_MEM), .MemToReg(MemToReg_MEM), .BrLink(BrLink_MEM), .ALU_operation(ALUOut_MEM), .dataMem(Dout_MEM), .Rd(Rd_MEM),
	.RegWrite_out(RegWrite_WB), .MemToReg_out(MemToReg_WB), .BrLink_out(BrLink_WB), .ALU_operation_out(ALUOut_WB), .dataMem_out(DataMem_WB), .Rd_out(Rd_WB));
	
	
	
	
	
	//wb stage
	mux2_1_Nbits #(.length(64)) MemToRegMux (.out(Dw_WB), .A(ALUOut_WB), .B(DataMem_WB), .sel(MemToReg_WB));
	
	//use mem stage flags to create saved flags 
	flag_register FR (.clk(clk), .reset(reset), .enable(SetFlags_MEM), 
		.negative(negative_MEM), .zero(zero_MEM), .overflow(overflow_MEM), .carry_out(carry_out_MEM), 
		.negative_out(neg_reg), .zero_out(zero_reg), .overflow_out(ov_reg), .carry_out_out(co_reg));
		
endmodule
	

// Testbench for CPU -- runs clock, instructions read in instructionmem
module cpu_testbench();
	logic clk, reset;
	
	cpu dut (.*);
	
	parameter CLOCK_PERIOD = 10000;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	int i;
	initial begin
		reset = 1; @(posedge clk); repeat(8);
		reset = 0; @(posedge clk);
		for (i = 0; i < 1000; i++) begin
			@(posedge clk);
		end
		$stop;
	end	
endmodule