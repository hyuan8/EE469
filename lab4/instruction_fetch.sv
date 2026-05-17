/* This module builds the instruction fetch for the CPU datapath.

	INPUTS:
	- UncondBr:		signal for whether the branch is conditional or unconditional
	- BrTaken:		signal for whether a branch is taken
	- BrReg:			signal for BR instruction
	- reset:			reset signal
	- clk: 			clock

	OUTPUTS
	- BrRegAddr:			address of branched register, used in BR instruction 
	- instruction:			32-bit instruction
	- unbranchedAddr:		unbranched address
*/

module instruction_fetch(
		input logic UncondBr, BrTaken, BrReg, 		// signals from control
		input logic reset, clk,
		input logic [63:0] BrRegAddr,
		output logic [31:0] instruction, 			// 32-bit instruction
		output logic [63:0] unbranchedAddr			// PC + 4
	); 
	
	// Register for program counter (PC), puts current PC into instruction memory
	logic [63:0] newPC, currentPC;
	program_counter pc (.in(newPC), .out(currentPC), .clk, .reset);
	
	// Instruction memory takes currentPC and outputs instruction
	instructmem instruction_memory (.address(currentPC), .instruction(instruction), .clk);
	
	// Sign exenders for CondAddr19 and BrAddr26
	// condOffset: 64-bits for CBZ/CBNZ instructions
	// brOffset: 64-bits for B/BL instructions
	logic [63:0] condOffset, brOffset;
	sign_extender #(.length(19)) extender1 (.in(instruction[23:5]), .out(condOffset));
	sign_extender #(.length(26)) extender2 (.in(instruction[25:0]), .out(brOffset));
	
	// UncondBr Mux: selects which branch addres to use
	logic [63:0] brAddr;
	mux2_1_Nbits #(.length(64)) UncondBrMux (.out(brAddr), .A(condOffset), .B(brOffset), .sel(UncondBr));
	
	// Shifter that multiplies by 4 since each instruction is 4 bytes
	logic [63:0] shiftedAddr; // address after shifting
	shifter shift2 (.value(brAddr), .direction(1'b0), .distance(6'd2), .result(shiftedAddr));
	
	// Adder for branching, adds current PC and branch address (in bytes)
	logic [63:0] branchedAddr; // branched address
	full_adder_64bits branchAddr (.S(branchedAddr), .A(currentPC), .B(shiftedAddr), .Cin(1'b0), .Cout());
	
	// Adder for going down (not branching), adds 4 to current PC
	full_adder_64bits incAddr (.S(unbranchedAddr), .A(currentPC), .B(64'd4), .Cin(1'b0), .Cout());
	
	// BrTaken Mux: selects the next PC source from the branched and unbranched addresses
	logic [63:0] immBranchPC; // PC from immediate branch
	mux2_1_Nbits #(.length(64)) BrTakenMux (.out(immBranchPC), .A(unbranchedAddr), .B(branchedAddr), .sel(BrTaken));
	
	// BrReg Mux: selects next PC from the immediate branch PC or the register value for BR
	mux2_1_Nbits #(.length(64)) BrRegMux (.out(newPC), .A(immBranchPC), .B(BrRegAddr), .sel(BrReg));

endmodule
	