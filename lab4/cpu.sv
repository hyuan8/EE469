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

module cpu (input logic clock, reset);
	logic [31:0] instruction_IF;
	logic [63:0] currentPC, PC_4_IF, newPC;
	
	//instruction fetch
	//only is a register for the pc, does not do the addition, need full adder for this
	program_counter PC (.in(newPC), .out(currentPC), .clk(clk), .reset(reset));
	
	full_adder_64bits PC_4 (.S(PC_4_IF), .A(currentPC), .B(64'd4), .Cin(1'b0), .Cout());
	
	instructmem instruction_memory (.address(currentPC), .instruction(instruction_IF), .clk);
 
	
	//if/id reg
	logic [31:0] instruction_ID;
	logic [63:0] PC_4_ID;
	IF_ID_reg IF_ID (.clk(clk), .reset(reset), .instruction(instruction_IF), .PC(PC_4_IF), .instruction_out(instruction_ID), .PC_out(PC_4_ID))
	
	
	//instruction decode - moved from datapath
	logic [2:0] ALUOp_ID;
	logic ALUSrc_ID, MemToReg_ID, Reg2Loc_ID, RegWrite_ID, MemWrite_ID, MemRead_ID;
	logic	UncondBr_ID, BrTaken_ID, SetFlags_ID;
	logic BrLink_ID, BrReg_ID, Imm12_ID;
	
	logic [4:0] Rd_ID, Rm_ID, Rn_ID;
	logic [63:0] Da_ID, Db_ID;
	logic [4:0] Ab_ID;
	
	//write back signals
	logic [4:0] Rd_WB;
	logic [63:0] Dw_ID;
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
	

	mux2_1_Nbits #(.length(5)) Reg2LocMux (.out(Ab_ID), .A(Rd_ID), .B(Rm_ID), .sel(Reg2Loc_ID));
	
	sign_extender #(.length(9)) extender9 (.in(instruction[20:12]), .out(imm9_ID));
	zero_extender #(.length(12)) extender12 (.in(instruction[21:10]), .out(imm12_ID));
	
	regfile register (.ReadData1(Da_ID), .ReadData2(Db_ID), .WriteData(Dw_WB), 
				.ReadRegister1(Rn_ID), .ReadRegister2(Ab_ID), .WriteRegister(Aw_WB), .RegWrite(RegWrite_WB), .clk(clk));
	
	//id/ex reg
	
	ID_EX_reg ID_EX (
	
	
	
	
	
);
	

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
		reset = 1; @(posedge clk); @(posedge clk);
		reset = 0; @(posedge clk);
		for (i = 0; i < 1000; i++) begin
			@(posedge clk);
		end
		$stop;
	end	
endmodule