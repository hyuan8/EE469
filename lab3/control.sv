/* This module builds the control unit for the CPU.

	INPUTS:
	- instruction: 32-bit instruction
	- negative, zero, overflow, carry_out: flags from ALU operations

	OUTPUTS:
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
*/

module control(
		input logic [31:0] instruction,
		input logic negative, zero, overflow, carry_out,
		output logic [2:0] ALUOp,
		output logic Reg2Loc, ALUSrc, MemToReg
		output logic RegWrite, MemWrite, MemRead, BrTaken, UncondBr
		output logic BrLink, BrReg, Imm12, SetFlags
	);  
	
	// ALU Operations
	// 000:			result = B			value of overflow and carry_out unimportant
	// 010:			result = A + B
	// 011:			result = A - B
	
	// Requirements: ADDI, ADDS, B Imm26, B.LT, BL Imm26, BR, CBZ, LDUR, SUR, SUBS
		
	localparam [10:0] 
		ADDI  = 11'b1001000100?,	// Add immediate
		ADDS  = 11'b10101011000,	// Add and set flags
		B     = 11'b000101?????,	// unconditional branch (B Imm26)
		B_LT  = 11'b01010100???,	// Branch if less than
		BL    = 11'b100101?????,	// Branch with link (BL Imm26)
		BR    = 11'b11010110000,	// Branch to register
		LDUR  = 11'b11111000010,	// Load from memory
		STUR  = 11'b11111000000,	// Store to memory
		SUBS  = 11'b11101011000,	// Subtract and set flags
		CBZ   = 11'b10110100???;	// Compare and branch if zero
	
	// Combinational logic
	always_comb begin 
			Reg2Loc 	= 	1'b0;
			ALUSrc 	= 	1'b0;
			MemToReg = 	1'b0;
			RegWrite = 	1'b0;
			MemWrite = 	1'b0;
			MemRead 	= 	1'b0;
			BrTaken 	= 	1'b0;
			UncondBr = 	1'b0;
			SetFlags = 	1'b0;
			ALUOp 	= 	3'b010; // Add
			BrLink 	= 	1'b0;
			Imm12 	= 	1'b0;
			BrReg 	= 	1'b0;
		
		casez (instruction[31:21])
		
			ADDI: begin
				Reg2Loc 	= 1'bx;
				ALUSrc 	= 1'b1;
				MemToReg = 1'b0;
				RegWrite = 1'b1;
				MemWrite = 1'b0;
				MemRead 	= 1'b0;
				BrTaken 	= 1'b0;
				UncondBr = 1'bx;
				SetFlags = 1'b0;
				ALUOp 	= 3'b010; // Add
				BrLink 	= 1'b0;
				Imm12 	= 1'b1;
				BrReg 	= 1'b0;
			end
			
			ADDS: begin
				Reg2Loc 	= 	1'b1;
				ALUSrc 	= 	1'b0;
				MemToReg = 	1'b0;
				RegWrite = 	1'b1;
				MemWrite = 	1'b0;
				MemRead 	= 	1'b0;
				BrTaken 	= 	1'b0;
				UncondBr = 	1'bx;
				SetFlags = 	1'b1;
				ALUOp	 	= 	3'b010; // Add
				BrLink 	= 	1'b0;
				Imm12 	= 	1'b0;
				BrReg 	= 	1'b0; 
			end
			
			SUBS: begin
				Reg2Loc 	= 	1'b1;
				ALUSrc 	= 	1'b0;
				MemToReg = 	1'b0;
				RegWrite = 	1'b1;
				MemWrite = 	1'b0;
				MemRead 	= 	1'b0;
				BrTaken 	= 	1'b0;
				UncondBr = 	1'bx;
				SetFlags = 	1'b1;
				ALUOp 	= 	3'b011; // Subtract
				BrLink 	= 	1'b0;
				Imm12 	= 	1'b0;
				BrReg 	= 	1'b0;	
			end
				
			LDUR: begin
				Reg2Loc 	= 	1'bx;
				ALUSrc 	= 	1'b1;
				MemToReg = 	1'b1;
				RegWrite = 	1'b1;
				MemWrite = 	1'b0;
				MemRead 	= 	1'b1;
				BrTaken 	= 	1'b0;
				UncondBr = 	1'bx;
				SetFlags = 	1'b0;
				ALUOp 	= 	3'b010; // Subtract
				BrLink 	= 	1'b0;
				Imm12 	= 	1'b0;
				BrReg 	= 	1'b0;
			end
			
			STUR: begin
				Reg2Loc 	= 	1'b0;
				ALUSrc 	= 	1'b1;
				MemToReg = 	1'bx;
				RegWrite = 	1'b0;
				MemWrite = 	1'b1;
				MemRead 	= 	1'b0;
				BrTaken 	= 	1'b0;
				UncondBr = 	1'bx;
				SetFlags = 	1'b0;
				ALUOp 	= 	3'b010; // Subtract
				BrLink 	= 	1'b0;
				Imm12 	= 	1'b0;
				BrReg 	= 	1'b0;
			end
			
			CBZ: begin
				Reg2Loc 	= 	1'b0;
				ALUSrc 	= 	1'b0;
				MemToReg = 	1'bx;
				RegWrite = 	1'b0;
				MemWrite = 	1'b0;
				MemRead 	= 	1'b0;
				BrTaken 	= 	zero;
				UncondBr = 	1'b0;
				SetFlags = 	1'b0;
				ALUOp 	= 	3'b000; 
				BrLink 	= 	1'b0;
				Imm12 	= 	1'b0;
				BrReg 	= 	1'b0;
			end
			
			B: begin
				Reg2Loc 	= 	1'bx;
				ALUSrc 	= 	1'bx;
				MemToReg = 	1'bx;
				RegWrite = 	1'b0;
				MemWrite = 	1'b0;
				MemRead 	= 	1'b0;
				BrTaken 	= 	1'b1;
				UncondBr = 	1'b1;
				SetFlags = 	1'b0;
				ALUOp 	=	3'bxxx; 
				BrLink 	= 	1'b0;
				Imm12 	= 	1'b0;
				BrReg 	= 	1'b0;
			end
			
			B_LT: begin
				Reg2Loc 	= 	1'bx;
				ALUSrc 	= 	1'bx;
				MemToReg = 	1'bx;
				RegWrite = 	1'b0;
				MemWrite = 	1'b0;
				MemRead 	= 	1'b0;
				BrTaken 	= 	(negative != overflow);
				UncondBr = 	1'b0;
				SetFlags = 	1'b0;
				ALUOp 	= 	3'bxxx; 
				BrLink 	= 	1'b0;
				Imm12 	= 	1'b0;
				BrReg 	= 	1'b0;
			end
			
			BL: begin
				Reg2Loc 	= 	1'bx;
				ALUSrc 	= 	1'bx;
				MemToReg = 	1'b0;
				RegWrite = 	1'b1;
				MemWrite = 	1'b0;
				MemRead 	= 	1'b0;
				BrTaken 	= 	1'b1;
				UncondBr = 	1'b1;
				SetFlags = 	1'b0;
				ALUOp 	= 	3'bxxx; 
				BrLink 	= 	1'b1;
				Imm12 	= 	1'b0;
				BrReg 	= 	1'b0;
			end
			
			BR: begin
				Reg2Loc 	= 	1'bx;
				ALUSrc 	= 	1'bx;
				MemToReg = 	1'bx;
				RegWrite = 	1'b0;
				MemWrite = 	1'b0;
				MemRead 	= 	1'b0;
				BrTaken 	= 	1'b1;
				UncondBr = 	1'b1;
				SetFlags = 	1'b0;
				ALUOp 	= 	3'bxxx; 
				BrLink 	= 	1'b0;
				Imm12 	= 	1'b0;
				BrReg 	= 	1'b1;
			end
			
		endcase
	end
	
endmodule
	
			
				
			