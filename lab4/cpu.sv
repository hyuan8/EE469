`timescale 1ns/10ps

module cpu (input logic clk, reset);

	// IF stage signals
	logic [31:0] instruction_IF;
	logic [63:0] currentPC, PC_plus4_IF, newPC;
	logic [63:0] immBranchPC;
	logic flush;
	
	// ID stage signals
	logic [31:0] instruction_ID;
	logic [63:0] PC_plus4_ID;
	logic [63:0] currentPC_ID;
	logic ALUSrc_ID, MemToReg_ID, Reg2Loc_ID, RegWrite_ID, MemWrite_ID, MemRead_ID;
	logic	UncondBr_ID, BrTaken_ID, SetFlags_ID, BrLink_ID, BrReg_ID, Imm12_ID, isCBZ_ID;
	logic [2:0] ALUOp_ID;
	logic [63:0] imm9_ID, imm12_ID;
	logic [4:0] Rd_ID, Rm_ID, Rn_ID, Ab_ID;
	logic [63:0] Da_ID, Db_ID;
	logic [63:0] condOffset_ID, brOffset_ID;

	// EX stage signals
	logic BrTaken_EX, BrReg_EX, BrTaken_EX2;
	logic RegWrite_EX, MemWrite_EX, MemRead_EX, MemToReg_EX;
	logic ALUSrc_EX, SetFlags_EX, BrLink_EX, Imm12_EX, UncondBr_EX, isCBZ_EX;
	logic [2:0] ALUOp_EX;
	logic [63:0] imm9_EX, imm12_EX;
	logic [4:0] Rn_EX, Rm_EX, Rd_EX, Ab_EX;
	logic [63:0] Da_EX, Db_EX;
	logic [63:0] currentPC_EX, PC_plus4_EX;
	logic [63:0] condOffset_EX, brOffset_EX;
	logic [63:0] branchedAddr_EX, brAddr_EX, shiftedAddr_EX;
	logic [4:0] WriteReg_EX;
	logic [63:0] final_imm_EX;
	logic [63:0] ALUB_EX;
	logic [63:0] ALUOut_EX;
	logic negative_EX, zero_EX, overflow_EX, carry_out_EX;
	logic [1:0] ForwardA, ForwardB;
	logic [63:0] ForwardA_out, ForwardB_out;
	logic forward_neg, forward_zero, forward_ov, forward_co;
	
	// MEM stage signals
	logic RegWrite_MEM, MemWrite_MEM, MemRead_MEM, BrLink_MEM, BrReg_MEM, BrTaken_MEM;
	logic [4:0] Rd_MEM;
	logic [63:0] Db_MEM, Dout_MEM;
	logic [63:0] ALUOut_MEM;
	logic [63:0] branchedAddr_MEM, BrRegAddr_MEM;
	logic [63:0] PC_plus4_MEM;
	logic SetFlags_MEM;
	logic negative_MEM, zero_MEM, overflow_MEM, carry_out_MEM;
	logic neg_reg, zero_reg, ov_reg, co_reg;
	logic mem_or_saved_neg, mem_or_saved_zero, mem_or_saved_ov, mem_or_saved_co;
	
	// WB stage signals
	logic RegWrite_WB, MemToReg_WB, BrLink_WB;
	logic [4:0] Rd_WB;
	logic [63:0] Dw_WB;
	logic [63:0] ALUOut_WB, DataMem_WB;
	logic [63:0] PC_plus4_WB;
	logic [63:0] ALUOrMem_WB;
	
	assign Rd_ID = instruction_ID[4:0];
	assign Rm_ID = instruction_ID[20:16];
	assign Rn_ID = instruction_ID[9:5];

	// ==== INSTRUCTION FETCH (IF) STAGE ====
	
	// Program Counter
	program_counter PC (.in(newPC), .out(currentPC), .clk(clk), .reset(reset));

	// Increment PC by 4
	full_adder_64bits PC_4 (.S(PC_plus4_IF), .A(currentPC), .B(64'd4), .Cin(1'b0), .Cout());
	
	// Instruction memory
	instructmem instruction_memory (.address(currentPC), .instruction(instruction_IF), .clk);

	// BrTaken Mux
	mux2_1_Nbits #(.length(64)) BrTakenMux (.out(immBranchPC), .B(branchedAddr_EX), .A(PC_plus4_IF), .sel(BrTaken_EX2));
	
	// BrReg Mux
	mux2_1_Nbits #(.length(64)) BrRegMux (.out(newPC), .A(immBranchPC), .B(ForwardB_out), .sel(BrReg_EX));

	// Flush logic flushes IF/ID if a branch is taken
	or #0.05 fl (flush, BrTaken_EX2, BrReg_EX, BrTaken_EX_final);

	
	// IF/ID register
	IF_ID_reg IF_ID (.clk(clk), .reset(reset), .flush(flush), 
			.instruction(instruction_IF), .instruction_out(instruction_ID),
			.PC(PC_plus4_IF), .PC_out(PC_plus4_ID), 
			.currentPC(currentPC), .currentPC_out(currentPC_ID));
	
	// ==== INSTRUCTION DECODE (ID) ====
	
	// Decode instructions and update control signals
	control CTL (.instruction(instruction_ID), .negative(forward_neg), .zero(forward_zero), .overflow(forward_ov),
			.carry_out(forward_co), .ALUOp(ALUOp_ID), .Reg2Loc(Reg2Loc_ID), .ALUSrc(ALUSrc_ID), .MemToReg(MemToReg_ID),
			.RegWrite(RegWrite_ID), .MemWrite(MemWrite_ID), .MemRead(MemRead_ID), .BrTaken(BrTaken_ID), .Imm12(Imm12_ID),
			.UncondBr(UncondBr_ID), .SetFlags(SetFlags_ID), .BrLink(BrLink_ID), .BrReg(BrReg_ID), .ALUzero(zero_EX), 
			.Db(Db_ID), .isCBZ(isCBZ_ID)); // raw zero for ALU comes from EX stage
	
	
	// Reg2Loc Mux: chooses if second register is from memory or from instruction
	mux2_1_Nbits #(.length(5)) Reg2LocMux (.out(Ab_ID), .A(Rd_ID), .B(Rm_ID), .sel(Reg2Loc_ID));
	
	// Sign extender for DAddr9, zero extender for ADDI 
	sign_extender #(.length(9)) extender9 (.in(instruction_ID[20:12]), .out(imm9_ID));
	zero_extender #(.length(12)) extender12 (.in(instruction_ID[21:10]), .out(imm12_ID));
	
	// Branch offset sign extenders
	// condOffset: 64-bits for CBZ/CBNZ instructions
	// brOffset: 64-bits for B/BL instructions
	sign_extender #(.length(19)) extender1 (.in(instruction_ID[23:5]), .out(condOffset_ID));
	sign_extender #(.length(26)) extender2 (.in(instruction_ID[25:0]), .out(brOffset_ID));
	
	// Register file
	regfile register (.ReadData1(Da_ID), .ReadData2(Db_ID), .WriteData(Dw_WB), 
			.ReadRegister1(Rn_ID), .ReadRegister2(Ab_ID), .WriteRegister(Rd_WB), .RegWrite(RegWrite_WB), .clk(clk));
	
	// ID/EX register
	ID_EX_reg ID_EX (.clk(clk), .reset(reset), 
			.RegWrite(RegWrite_ID), .RegWrite_out(RegWrite_EX),
			.MemWrite(MemWrite_ID), .MemWrite_out(MemWrite_EX),
			.MemRead(MemRead_ID), .MemRead_out(MemRead_EX),
			.MemToReg(MemToReg_ID), .MemToReg_out(MemToReg_EX), 
			.UncondBr(UncondBr_ID), .UncondBr_out(UncondBr_EX),
			.BrTaken(BrTaken_ID), .BrTaken_out(BrTaken_EX),
			.ALUSrc(ALUSrc_ID), .ALUSrc_out(ALUSrc_EX),
			.SetFlags(SetFlags_ID), .SetFlags_out(SetFlags_EX),
			.BrLink(BrLink_ID), .BrLink_out(BrLink_EX),
			.Imm12(Imm12_ID), .Imm12_out(Imm12_EX),
			.BrReg(BrReg_ID), .BrReg_out(BrReg_EX),
			.ALUOp(ALUOp_ID), .ALUOp_out(ALUOp_EX),
			.Da(Da_ID), .Da_out(Da_EX),
			.Db(Db_ID), .Db_out(Db_EX),
			.Ab(Ab_ID), .Ab_out(Ab_EX),
			.Rn(Rn_ID), .Rn_out(Rn_EX),
			.Rm(Rm_ID), .Rm_out(Rm_EX),
			.Rd(Rd_ID), .Rd_out(Rd_EX),
			.imm9(imm9_ID), .imm9_out(imm9_EX),
			.imm12(imm12_ID),	.imm12_out(imm12_EX), 
			.PC_plus4(PC_plus4_ID), .PC_plus4_out(PC_plus4_EX),
			.condOffset(condOffset_ID), .condOffset_out(condOffset_EX), 
			.brOffset(brOffset_ID), .brOffset_out(brOffset_EX),
			.currentPC(currentPC_ID), .currentPC_out(currentPC_EX),
			.isCBZ(isCBZ_ID), .isCBZ_out(isCBZ_EX));
				
	
	// ==== EXECUTE (EX) ====
	
	// Select branch offset, shift, and add to PC
	mux2_1_Nbits #(.length(64)) UncondBrMux (.out(brAddr_EX), .A(condOffset_EX), .B(brOffset_EX), .sel(UncondBr_EX));
	shifter shift2 (.value(brAddr_EX), .direction(1'b0), .distance(6'd2), .result(shiftedAddr_EX));
	full_adder_64bits branchAddr (.S(branchedAddr_EX), .A(currentPC_EX), .B(shiftedAddr_EX), .Cin(1'b0), .Cout());

	// Selects immediate for ALU: imm9 (LDUR/STUR) or imm12 (ADDI/SUBI)
	mux2_1_Nbits #(.length(64)) FinalImmMux (.out(final_imm_EX), .A(imm9_EX), .B(imm12_EX), .sel(Imm12_EX));
	
	// Forwarding unit: resolves EX/MEM and MEM/WB data hazards
	forwarding_unit FU (.Rn_EX(Rn_EX), .Ab_EX(Ab_EX), .Rd_MEM(Rd_MEM), .Rd_WB(Rd_WB), 
			.RegWrite_MEM(RegWrite_MEM), .RegWrite_WB(RegWrite_WB), .ForwardA(ForwardA), .ForwardB(ForwardB));
	
	// Forward muxes: selects between register files, MEM ALU result, or WB writeback data
	mux4_1_Nbits #(.length(64)) ForwardAMux (.out(ForwardA_out), .A(Da_EX), .B(ALUOut_MEM), .C(Dw_WB), .D(64'd0), .sel(ForwardA));
	mux4_1_Nbits #(.length(64)) ForwardBMux (.out(ForwardB_out), .A(Db_EX), .B(ALUOut_MEM), .C(Dw_WB), .D(64'd0), .sel(ForwardB));
	
	// CBZ override: replaces BrTaken with ALU zero flag
	mux2_1 CBZMux (.out(BrTaken_EX2), .i({zero_EX, BrTaken_EX}), .sel(isCBZ_EX));
	
	// ALUSrc Mux: selects ALUB input
	mux2_1_Nbits #(.length(64)) ALUSrcMux (.out(ALUB_EX), .A(ForwardB_out), .B(final_imm_EX), .sel(ALUSrc_EX));
	
	// ALU: performs arithmetic/logic operations
	alu ALU (.A(ForwardA_out), .B(ALUB_EX), .cntrl(ALUOp_EX), .result(ALUOut_EX), .negative(negative_EX), .zero(zero_EX), .overflow(overflow_EX), .carry_out(carry_out_EX));
	
	//BrLink mux to chooses which register to write to if BrLink is true
	mux2_1_Nbits #(.length(5)) BrLinkRegMux (.out(WriteReg_EX), .A(Rd_EX), .B(5'd30), .sel(BrLink_EX));
	
	// EX/MEM register
	
	EX_MEM_reg EX_MEM (.clk(clk), .reset(reset), 
			.RegWrite(RegWrite_EX), .RegWrite_out(RegWrite_MEM),
			.MemWrite(MemWrite_EX), .MemWrite_out(MemWrite_MEM), 
			.MemRead(MemRead_EX), .MemRead_out(MemRead_MEM),
			.MemToReg(MemToReg_EX), .MemToReg_out(MemToReg_MEM),
			.BrLink(BrLink_EX), .BrLink_out(BrLink_MEM),
			.BrTaken(BrTaken_EX), .BrTaken_out(BrTaken_MEM),
			.BrReg(BrReg_EX), .BrReg_out(BrReg_MEM),
			.branchedAddr(branchedAddr_EX), .branchedAddr_out(branchedAddr_MEM),
			.ALU_operation(ALUOut_EX), .ALU_operation_out(ALUOut_MEM),
			.Db(ForwardB_out), .Db_out(Db_MEM),
			.Rd(WriteReg_EX), .Rd_out(Rd_MEM),
			.setFlags(SetFlags_EX), .setFlags_out(SetFlags_MEM),
			.negative(negative_EX), .negative_out(negative_MEM), 
			.zero(zero_EX), .zero_out(zero_MEM),
			.overflow(overflow_EX), .overflow_out(overflow_MEM),
			.carry_out(carry_out_EX), .carry_out_out(carry_out_MEM),
			.BrRegAddr(ForwardB_out),  .BrRegAddr_out(BrRegAddr_MEM),
			.PC_plus4(PC_plus4_EX), .PC_plus4_out(PC_plus4_MEM));
	

	// ==== Memory (MEM) ====
	
	// Data memory: reads (LDUR) or writes (STUR) 8 bytes at ALU-computed address
	datamem DataMemory (.address(ALUOut_MEM), .write_enable(MemWrite_MEM), .read_enable(MemRead_MEM), 
			.write_data(Db_MEM), .clk(clk), .xfer_size(4'd8), .read_data(Dout_MEM));
				
	// MEM/WB register
	MEM_WB_reg MEM_WB (.clk(clk), .reset(reset), .RegWrite(RegWrite_MEM), .MemToReg(MemToReg_MEM), .BrLink(BrLink_MEM), .ALU_operation(ALUOut_MEM), .dataMem(Dout_MEM), .Rd(Rd_MEM),
			.RegWrite_out(RegWrite_WB), .MemToReg_out(MemToReg_WB), .BrLink_out(BrLink_WB), .ALU_operation_out(ALUOut_WB), .dataMem_out(DataMem_WB), .Rd_out(Rd_WB),
			.PC_plus4(PC_plus4_MEM), .PC_plus4_out(PC_plus4_WB));
	
	// ==== Write Back (WB) ====
	
	// MemToReg Mux: selects between ALU result and memory read data
	mux2_1_Nbits #(.length(64)) MemToRegMux (.out(ALUOrMem_WB), .A(ALUOut_WB), .B(DataMem_WB), .sel(MemToReg_WB));
	
	// BrLink override: write PC+4 (return address) to X30 instead of ALU/MEM result
	mux2_1_Nbits #(.length(64)) BrLinkWBMux (.out(Dw_WB), .A(ALUOrMem_WB), .B(PC_plus4_WB), .sel(BrLink_WB));
	
	// ==== Flag registers and forwarding ====
	
	//use mem stage flags to create saved flags 
	flag_register FR (.clk(clk), .reset(reset), .enable(SetFlags_MEM), 
			.negative(negative_MEM), .zero(zero_MEM), .overflow(overflow_MEM), .carry_out(carry_out_MEM), 
			.negative_out(neg_reg), .zero_out(zero_reg), .overflow_out(ov_reg), .carry_out_out(co_reg));
		
	// MEM-stage flag muxes: if SetFlags during MEM, use live flags, otherwise use saved flags
	mux2_1 negMemMux  (.out(mem_or_saved_neg),  .i({negative_MEM,  neg_reg}),   .sel(SetFlags_MEM));
	mux2_1 zeroMemMux (.out(mem_or_saved_zero), .i({zero_MEM,      zero_reg}),  .sel(SetFlags_MEM));
	mux2_1 ovMemMux   (.out(mem_or_saved_ov),   .i({overflow_MEM,  ov_reg}),    .sel(SetFlags_MEM));
	mux2_1 coMemMux   (.out(mem_or_saved_co),   .i({carry_out_MEM, co_reg}),    .sel(SetFlags_MEM));

	// EX-stage flag muxes: if SetFlags during EX, forward raw EX flags, otherwise use saved MEM/saved flags
	mux2_1 negExMux   (.out(forward_neg),       .i({negative_EX,  mem_or_saved_neg}),  .sel(SetFlags_EX));
	mux2_1 zeroExMux  (.out(forward_zero),      .i({zero_EX,      mem_or_saved_zero}), .sel(SetFlags_EX));
	mux2_1 ovExMux    (.out(forward_ov),        .i({overflow_EX,  mem_or_saved_ov}),   .sel(SetFlags_EX));
	mux2_1 coExMux    (.out(forward_co),        .i({carry_out_EX, mem_or_saved_co}),   .sel(SetFlags_EX));
			
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
		reset = 1; repeat(8) @(posedge clk);
		reset = 0; @(posedge clk);
		for (i = 0; i < 60; i++) begin
			@(posedge clk);
		end
		$stop;
	end	
endmodule