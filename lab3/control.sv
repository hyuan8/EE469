module control(instruction, ALUOp, Reg2LOC, ALUSrc, MemToReg, RegWrite, MemWrite, BrTaken, UncondBr, SetFlags);

	input logic [31:0] instruction;
	input logic negative, zero, overflow, carry_out;
	output logic [2:0] ALUOp;
	output logic Reg2LOC, ALUSrc, MemToReg; // used in muxes
	output logic RegWrite, MemWrite, BrTaken, UncondBr, SetFlags; // There may be more
	
	// ALU Operations
	// 000:			result = B						value of overflow and carry_out unimportant
	// 010:			result = A + B
	// 011:			result = A - B
	// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
	// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
	// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant
	
	// ADDI, ADDS, B Imm26, B.LT, BL Imm26, BR, CBZ, LDUR, SUR, SUBS
	localparam [10:0] 
		ADDI 	= 11'b1001000100x, // Add immediate
		ADDS 	= 11'b10101011000, // Add and set flags
		B 		= 11'b000101xxxxx, // unconditional branch (B Imm26)
		B_LT 	= 11'b01010100xxx, // Branch if less than
		BL 	= 11'b100101xxxxx, // Branch with link (BL Imm26)
		BR 	= 11'b11010110000, // Branch to register
		LDUR 	= 11'b11111000010, // Load from memory
		STUR 	= 11'b11111000000, // Store to memory
		SUBS 	= 11'b11101011000, // Subtract and set flags
		CBZ 	= 11'b10110100xxx; // Compare and branch if zero
	
	always_comb begin // NEED TO FIX
		case (instruction[31:21])
		
			ADDI: begin
				Reg2LOC = 	1'bx;
				ALUSrc = 	1'b1;
				MemToReg = 	1'b0;
				RegWrite = 	1'b1;
				MemWrite = 	1'b0;
				BrTaken = 	1'b0;
				UncondBr = 	1'bx;
				ALUOp = 		3'b010; // Add
			end
			
			ADDS: begin
				Reg2LOC = 	1'b1;
				ALUSrc = 	1'b0;
				MemToReg = 	1'b0;
				RegWrite = 	1'b1;
				MemWrite = 	1'b0;
				BrTaken = 	1'b0;
				UncondBr = 	1'bx;
				ALUOp = 		3'b010; // Add
			end
			
			ADDS: begin
				Reg2LOC = 	1'b1;
				ALUSrc = 	1'b0;
				MemToReg = 	1'b0;
				RegWrite = 	1'b1;
				MemWrite = 	1'b0;
				BrTaken = 	1'b0;
				UncondBr = 	1'bx;
				ALUOp = 		3'b010; // Add
			end
		
		endcase
	end
	
endmodule
	
			
				
			