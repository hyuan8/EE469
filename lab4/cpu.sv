`timescale 1ns/10ps

module cpu (input logic clk, reset);
	logic [31:0] instruction_IF;
	logic [63:0] currentPC, PC_plus4_IF, newPC;
	logic [63:0] immBranchPC;
	logic flush;

	program_counter PC (.in(newPC), .out(currentPC), .clk(clk), .reset(reset));

	full_adder_64bits PC_4 (.S(PC_plus4_IF), .A(currentPC), .B(64'd4), .Cin(1'b0), .Cout());

	instructmem instruction_memory (.address(currentPC), .instruction(instruction_IF), .clk);

	logic BrTaken_EX, BrReg_EX;
	logic [63:0] branchedAddr_EX;
	logic [63:0] ForwardB_out;

	logic BrTaken_EX2;
	mux2_1_Nbits #(.length(64)) BrTakenMux (.out(immBranchPC), .B(branchedAddr_EX), .A(PC_plus4_IF), .sel(BrTaken_EX2));
	
	
	mux2_1_Nbits #(.length(64)) BrRegMux (.out(newPC), .A(immBranchPC), .B(ForwardB_out), .sel(BrReg_EX));

	or #0.05 fl (flush, BrTaken_EX, BrReg_EX, BrTaken_EX_final);

	
	//if/id reg
	logic [31:0] instruction_ID;
	logic [63:0] PC_plus4_ID;
	logic [63:0] currentPC_ID;
	IF_ID_reg IF_ID (.clk(clk), .reset(reset), .flush(flush), .instruction(instruction_IF), .PC(PC_plus4_IF), .instruction_out(instruction_ID), .PC_out(PC_plus4_ID), .currentPC(currentPC), .currentPC_out(currentPC_ID));
	
	
	//instruction decode
	logic [2:0] ALUOp_ID;
	logic ALUSrc_ID, MemToReg_ID, Reg2Loc_ID, RegWrite_ID, MemWrite_ID, MemRead_ID;
	logic	UncondBr_ID, BrTaken_ID, SetFlags_ID;
	logic BrLink_ID, BrReg_ID, Imm12_ID;

	logic [4:0] Rd_ID, Rm_ID, Rn_ID;
	assign Rd_ID = instruction_ID[4:0];
	assign Rm_ID = instruction_ID[20:16];
	assign Rn_ID = instruction_ID[9:5];
	
	
	logic neg_reg, zero_reg, ov_reg, co_reg;
	logic forward_neg, forward_zero, forward_ov, forward_co;
	logic negative_EX, zero_EX, overflow_EX, carry_out_EX;
	logic [63:0] Db_ID;
	logic isCBZ_ID, isCBZ_EX;
	logic cbz_zero;
	
	control CTL (.instruction(instruction_ID), .negative(forward_neg), .zero(forward_zero), .overflow(forward_ov),
		.carry_out(forward_co), .ALUOp(ALUOp_ID), .Reg2Loc(Reg2Loc_ID), .ALUSrc(ALUSrc_ID), .MemToReg(MemToReg_ID),
		.RegWrite(RegWrite_ID), .MemWrite(MemWrite_ID), .MemRead(MemRead_ID), .BrTaken(BrTaken_ID), .Imm12(Imm12_ID),
		.UncondBr(UncondBr_ID), .SetFlags(SetFlags_ID), .BrLink(BrLink_ID), .BrReg(BrReg_ID), .ALUzero(zero_EX), .Db(Db_ID),
		.isCBZ(isCBZ_ID)); //raw zero for ALU comes from ex stage
	
	
	//mux to choose if second register is from memory or from instruction
	logic [4:0] Ab_ID;
	mux2_1_Nbits #(.length(5)) Reg2LocMux (.out(Ab_ID), .A(Rd_ID), .B(Rm_ID), .sel(Reg2Loc_ID));
	
	//sign extend for DAddr9, zero extend for ADDI 
	logic [63:0] imm9_ID, imm12_ID;
	sign_extender #(.length(9)) extender9 (.in(instruction_ID[20:12]), .out(imm9_ID));
	zero_extender #(.length(12)) extender12 (.in(instruction_ID[21:10]), .out(imm12_ID));
	
	// condOffset: 64-bits for CBZ/CBNZ instructions
	// brOffset: 64-bits for B/BL instructions
	logic [63:0] condOffset_ID, brOffset_ID;
	sign_extender #(.length(19)) extender1 (.in(instruction_ID[23:5]), .out(condOffset_ID));
	sign_extender #(.length(26)) extender2 (.in(instruction_ID[25:0]), .out(brOffset_ID));
	
	logic [63:0] Da_ID;
	logic [4:0] Rd_WB;
	logic RegWrite_WB;
	logic [63:0] Dw_WB;
	regfile register (.ReadData1(Da_ID), .ReadData2(Db_ID), .WriteData(Dw_WB), 
				.ReadRegister1(Rn_ID), .ReadRegister2(Ab_ID), .WriteRegister(Rd_WB), .RegWrite(RegWrite_WB), .clk(clk));
	

	
	//id/ex reg
	logic RegWrite_EX, MemWrite_EX, MemRead_EX, MemToReg_EX;
	logic ALUSrc_EX, SetFlags_EX, BrLink_EX, Imm12_EX;
	logic UncondBr_EX;
	logic [2:0] ALUOp_EX;
	logic [63:0] Da_EX, Db_EX;
	logic [4:0] Rn_EX, Rm_EX, Rd_EX, Ab_EX;
	logic [63:0] imm9_EX, imm12_EX, PC_plus4_EX;
	logic [63:0] currentPC_EX;
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
	.brOffset_out(brOffset_EX), .Ab(Ab_ID), .Ab_out(Ab_EX), .currentPC(currentPC_ID), .currentPC_out(currentPC_EX),
	.isCBZ(isCBZ_ID), .isCBZ_out(isCBZ_EX));
	
	

	
	//execute stage
	logic [63:0] brAddr_EX, shiftedAddr_EX;
	logic [4:0] WriteReg_EX;

	mux2_1_Nbits #(.length(64)) UncondBrMux (.out(brAddr_EX), .A(condOffset_EX), .B(brOffset_EX), .sel(UncondBr_EX));
	shifter shift2 (.value(brAddr_EX), .direction(1'b0), .distance(6'd2), .result(shiftedAddr_EX));
	full_adder_64bits branchAddr (.S(branchedAddr_EX), .A(currentPC_EX), .B(shiftedAddr_EX), .Cin(1'b0), .Cout());

	logic [63:0] final_imm_EX;
	mux2_1_Nbits #(.length(64)) FinalImmMux (.out(final_imm_EX), .A(imm9_EX), .B(imm12_EX), .sel(Imm12_EX));
	
	logic RegWrite_MEM;
	logic [4:0] Rd_MEM;
	logic [63:0] ALUOut_MEM;
	logic [1:0] ForwardA, ForwardB;
	forwarding_unit FU (.Rn_EX(Rn_EX), .Ab_EX(Ab_EX), .Rd_MEM(Rd_MEM), .Rd_WB(Rd_WB), .RegWrite_MEM(RegWrite_MEM),
		.RegWrite_WB(RegWrite_WB), .ForwardA(ForwardA), .ForwardB(ForwardB));
	
	
	logic [63:0] ForwardA_out;
	mux4_1_Nbits #(.length(64)) ForwardAMux (.out(ForwardA_out), .A(Da_EX), .B(ALUOut_MEM), .C(Dw_WB), .D(64'd0), .sel(ForwardA));
	mux4_1_Nbits #(.length(64)) ForwardBMux (.out(ForwardB_out), .A(Db_EX), .B(ALUOut_MEM), .C(Dw_WB), .D(64'd0), .sel(ForwardB));
	
	mux2_1 CBZMux (.out(BrTaken_EX2), .i({zero_EX, BrTaken_EX}), .sel(isCBZ_EX));
	
	// ALUSrc Mux: selects ALUB input
	logic [63:0] ALUB_EX; // second ALU input
	mux2_1_Nbits #(.length(64)) ALUSrcMux (.out(ALUB_EX), .A(ForwardB_out), .B(final_imm_EX), .sel(ALUSrc_EX));
	
	logic [63:0] ALUOut_EX;
	alu ALU (.A(ForwardA_out), .B(ALUB_EX), .cntrl(ALUOp_EX), .result(ALUOut_EX), .negative(negative_EX), .zero(zero_EX), .overflow(overflow_EX), .carry_out(carry_out_EX));
	
	//BrLink mux to choose which register to write to if BrLink is true
	mux2_1_Nbits #(.length(5)) BrLinkRegMux (.out(WriteReg_EX), .A(Rd_EX), .B(5'd30), .sel(BrLink_EX));
	
	
	
	//ex/mem reg
	logic MemWrite_MEM, MemRead_MEM, BrLink_MEM, BrReg_MEM, BrTaken_MEM;
	logic [63:0] Db_MEM, Dout_MEM;
	logic [63:0] branchedAddr_MEM;
	logic [63:0] BrRegAddr_MEM;
	logic [63:0] PC_plus4_MEM;
	logic SetFlags_MEM;
	logic negative_MEM, zero_MEM, overflow_MEM, carry_out_MEM;
	
	
	EX_MEM_reg EX_MEM (.clk(clk), .reset(reset), .RegWrite(RegWrite_EX), .MemWrite(MemWrite_EX), .MemRead(MemRead_EX), .MemToReg(MemToReg_EX), .BrLink(BrLink_EX), .BrTaken(BrTaken_EX), .BrReg(BrReg_EX), .branchedAddr(branchedAddr_EX),
		.ALU_operation(ALUOut_EX), .Db(ForwardB_out), .Rd(WriteReg_EX), .setFlags(SetFlags_EX), .negative(negative_EX), .zero(zero_EX), .overflow(overflow_EX), .carry_out(carry_out_EX), .BrRegAddr(ForwardB_out), .RegWrite_out(RegWrite_MEM), .MemWrite_out(MemWrite_MEM), 
		.MemRead_out(MemRead_MEM), .MemToReg_out(MemToReg_MEM), .BrLink_out(BrLink_MEM), .BrReg_out(BrReg_MEM), .ALU_operation_out(ALUOut_MEM), .Db_out(Db_MEM), .Rd_out(Rd_MEM), .setFlags_out(SetFlags_MEM), .negative_out(negative_MEM), 
		.zero_out(zero_MEM), .overflow_out(overflow_MEM), .carry_out_out(carry_out_MEM), .BrTaken_out(BrTaken_MEM), .branchedAddr_out(branchedAddr_MEM), .BrRegAddr_out(BrRegAddr_MEM),
		.PC_plus4(PC_plus4_EX), .PC_plus4_out(PC_plus4_MEM));
	

	//mem stage
	datamem DataMemory (.address(ALUOut_MEM), .write_enable(MemWrite_MEM), .read_enable(MemRead_MEM), 
				.write_data(Db_MEM), .clk(clk), .xfer_size(4'd8), .read_data(Dout_MEM));
				
				
				
				
	
	//mem/wb reg
	logic MemToReg_WB, BrLink_WB;
	logic [63:0] ALUOut_WB, DataMem_WB;
	logic [63:0] PC_plus4_WB;
	MEM_WB_reg MEM_WB (.clk(clk), .reset(reset), .RegWrite(RegWrite_MEM), .MemToReg(MemToReg_MEM), .BrLink(BrLink_MEM), .ALU_operation(ALUOut_MEM), .dataMem(Dout_MEM), .Rd(Rd_MEM),
	.RegWrite_out(RegWrite_WB), .MemToReg_out(MemToReg_WB), .BrLink_out(BrLink_WB), .ALU_operation_out(ALUOut_WB), .dataMem_out(DataMem_WB), .Rd_out(Rd_WB),
	.PC_plus4(PC_plus4_MEM), .PC_plus4_out(PC_plus4_WB));
	
	
	

	//wb stage
//	mux2_1_Nbits #(.length(64)) MemToRegMux (.out(Dw_WB), .A(ALUOut_WB), .B(DataMem_WB), .sel(MemToReg_WB));
	
	logic [63:0] ALUOrMem_WB;
	mux2_1_Nbits #(.length(64)) MemToRegMux (.out(ALUOrMem_WB), .A(ALUOut_WB), .B(DataMem_WB), .sel(MemToReg_WB));
	mux2_1_Nbits #(.length(64)) BrLinkWBMux (.out(Dw_WB), .A(ALUOrMem_WB), .B(PC_plus4_WB), .sel(BrLink_WB));
	
	
	//use mem stage flags to create saved flags 
	flag_register FR (.clk(clk), .reset(reset), .enable(SetFlags_MEM), 
		.negative(negative_MEM), .zero(zero_MEM), .overflow(overflow_MEM), .carry_out(carry_out_MEM), 
		.negative_out(neg_reg), .zero_out(zero_reg), .overflow_out(ov_reg), .carry_out_out(co_reg));
		
	logic mem_or_saved_neg, mem_or_saved_zero, mem_or_saved_ov, mem_or_saved_co;

	mux2_1 negMemMux  (.out(mem_or_saved_neg),  .i({negative_MEM,  neg_reg}),   .sel(SetFlags_MEM));
	mux2_1 zeroMemMux (.out(mem_or_saved_zero), .i({zero_MEM,      zero_reg}),  .sel(SetFlags_MEM));
	mux2_1 ovMemMux   (.out(mem_or_saved_ov),   .i({overflow_MEM,  ov_reg}),    .sel(SetFlags_MEM));
	mux2_1 coMemMux   (.out(mem_or_saved_co),   .i({carry_out_MEM, co_reg}),    .sel(SetFlags_MEM));

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
		for (i = 0; i < 600; i++) begin
			@(posedge clk);
		end
		$stop;
	end	
endmodule