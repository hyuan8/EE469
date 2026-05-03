module instruction_fetch()

	input logic [63:0] inputBits;
	input logic [1:0] UncondBr, BrTaken;
	input logic reset, clk;
	
	output logic [31:0] instruction;
	output logic [63:0] unbranchedAddr;
	
	// Register for program counter (PC)
	// puts current PC into instruction memory
	logic [63:0] newPC, currentPC;
	program_counter pc (.in(newPC), .out(currentPC), .clk, .reset);
	
	// Instruction memory
	instructmem instruction_memory (.address(inputBits), .instruction(instruction), .clk));
	
	// Sign exenders for CondAddr19 and BrAddr26
	sign_extender #(.N(19)) condAddr (.in(Instruction[23:5]), .out(condAddr));
	sign_extender #(.N(26)) BrAddr (.in(Instruction[25:0]), .out(uncondAddr));
	
	// Mux taking UncondBr
	logic [63:0] brAddr;
	mux2_1_64bits (.out(brAddr), .A(condAddr), .B(uncondAddr), .sel(UncondBr));
	
	// Shifter that multiplies by 4
	logic [63:0] shiftedAddr;
	shifter shift2 (.value(brAddr), .direction(6'd2), .distance(2'b10), .result(shiftedAddr));
	
	// Adder for branching
	logic [63:0] branchedAddr;
	full_adder_64bits branchAddr (.result(branchedAddr), .A(currentPC), .B(shiftedAddr), .Cin(1'b0), .Cout());
	
	// Adder for going down (not branching)
	full_adder_64bits incAddr (.result(unbranchedAddr), .A(currentPC), .B(64'd4), .Cin(1'b0), .Cout());
	
	// Mux to determine whether or not to branch
	mux2_1_Nbits #(.length(64)) choosePC (.out(brAddr), .A(condAddr), .B(uncondAddr), .sel(BrTaken));

endmodule
	
	