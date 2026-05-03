module instruction_fetch(
	input logic UncondBr, BrTaken, // signals from control
	input logic reset, clk,
	output logic [31:0] instruction, // 32-bit instruction
	output logic [63:0] unbranchedAddr); // PC + 4
	
	// Register for program counter (PC)
	// puts current PC into instruction memory
	logic [63:0] newPC, currentPC;
	program_counter pc (.in(newPC), .out(currentPC), .clk, .reset);
	
	// Instruction memory
	instructmem instruction_memory (.address(currentPC), .instruction(instruction), .clk);
	
	// Sign exenders for condAddr19 and BrAddr26
	logic [63:0] condOffset, brOffset;
	sign_extender #(.length(19)) extender1 (.in(instruction[23:5]), .out(condOffset));
	sign_extender #(.length(26)) extender2 (.in(instruction[25:0]), .out(brOffset));
	
	// UncondBr Mux
	logic [63:0] brAddr;
	mux2_1_Nbits #(.length(64)) UncondBrMux (.out(brAddr), .A(condOffset), .B(brOffset), .sel(UncondBr));
	
	// Shifter that multiplies by 4
	logic [63:0] shiftedAddr;
	shifter shift2 (.value(brAddr), .direction(1'b0), .distance(6'd2), .result(shiftedAddr));
	
	// Adder for branching
	logic [63:0] branchedAddr;
	full_adder_64bits branchAddr (.result(branchedAddr), .A(currentPC), .B(shiftedAddr), .Cin(1'b0), .Cout());
	
	// Adder for going down (not branching)
	full_adder_64bits incAddr (.result(unbranchedAddr), .A(currentPC), .B(64'd4), .Cin(1'b0), .Cout());
	
	// BrTaken Mux
	mux2_1_Nbits #(.length(64)) BrTakenMux (.out(newPC), .A(unbranchedAddr), .B(branchedAddr), .sel(BrTaken));

endmodule
	