`timescale 1ns/10ps

/* This module builds the CPU.

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
*/

module cpu (
	input logic clk,
	input logic reset
);

	logic [31:0] instruction;
	logic [63:0] unbranchedAddr;
	
	logic [2:0] ALUOp;
	logic ALUSrc, MemToReg, Reg2Loc, RegWrite, MemWrite, MemRead;
	
	logic negative, zero, overflow, carry_out;
	logic	UncondBr, BrTaken, SetFlags;
	
	logic BrLink, BrReg;
	logic [63:0] BrRegAddr;
	
	logic Imm12;
	logic [63:0] Db;

	// Registered flags (using DFF w/ enable) - only update when SetFlags=1
	logic neg_reg, zero_reg, ov_reg, co_reg;
	D_FF_enable neg_ff (.q(neg_reg), .d(negative), .reset(reset), .clk(clk), .enable(SetFlags));
	D_FF_enable zero_ff (.q(zero_reg), .d(zero), .reset(reset), .clk(clk), .enable(SetFlags));
	D_FF_enable ov_ff (.q(ov_reg), .d(overflow), .reset(reset), .clk(clk), .enable(SetFlags));
	D_FF_enable co_ff (.q(co_reg), .d(carry_out), .reset(reset), .clk(clk), .enable(SetFlags));
	
	// Instantiates instruction fetch
	instruction_fetch IF (.UncondBr(UncondBr), .BrTaken(BrTaken), .BrReg(BrReg), .BrRegAddr(BrRegAddr),
    .reset(reset), .clk(clk), .instruction(instruction), .unbranchedAddr(unbranchedAddr));
		
	// Instantiates control unit
	control CTL (.instruction(instruction), .negative(neg_reg), .zero(zero_reg), .overflow(ov_reg),
		.carry_out(co_reg), .ALUOp(ALUOp), .Reg2Loc(Reg2Loc), .ALUSrc(ALUSrc), .MemToReg(MemToReg),
		.RegWrite(RegWrite), .MemWrite(MemWrite), .MemRead(MemRead), .BrTaken(BrTaken), .Imm12(Imm12),
		.UncondBr(UncondBr), .SetFlags(SetFlags), .BrLink(BrLink), .BrReg(BrReg));
		
	// Instantiates main datapath
	datapath DP (.instruction(instruction), .ALUOp(ALUOp), .ALUSrc(ALUSrc), .Mem2Reg(MemToReg), .BrLink(BrLink),
		.unbranchAddr(unbranchedAddr), .BrRegAddr(BrRegAddr), .Imm12(Imm12), .Db(Db),
		.Reg2Loc(Reg2Loc), .RegWrite(RegWrite), .MemWrite(MemWrite), .MemRead(MemRead), .clk(clk), .reset(reset), 
		.XferSize(4'd8), .negative(negative), .zero(zero), .overflow(overflow), .carry_out(carry_out));
	
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
		reset = 1; @(posedge clk); @(posedge clk);
		reset = 0; @(posedge clk);
		for (i = 0; i < 50; i++) begin
			@(posedge clk);
		end
		$stop;
	end	
endmodule