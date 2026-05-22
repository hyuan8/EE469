`timescale 1ns/10ps

// Forwarding unit for pipelined CPU.
module forwarding_unit (
	input logic [4:0] Rn_EX, Ab_EX,			// Execute source registers
	input logic [4:0] Rd_MEM, Rd_WB,			// MEM and WB destination registers
	input logic RegWrite_MEM, RegWrite_WB,	// enable signals for MEM and WB
	output logic [1:0] ForwardA, ForwardB	// Mux select lines for forwarding
);
	
	always_comb begin
		// ForwardA logic for ALU input A
		// EX/MEM hazard: forward ALU result from MEM stage
		if (RegWrite_MEM && (Rd_MEM == Rn_EX) && (Rd_MEM != 5'd31)) begin
			ForwardA = 2'b01; 
		end
		// MEM/WB hazard: forward WB data, MEM takes priority if they match
		else if (RegWrite_WB && (Rd_WB != 5'd31) && (Rd_WB == Rn_EX) &&
				(~RegWrite_MEM || (Rd_MEM != Rn_EX) || (Rd_MEM == 5'd31))) begin
			ForwardA = 2'b10; 
		end
		// No hazard
		else begin
			ForwardA = 2'b00; 
		end
		
		// ForwardB logic for ALU input B
		// EX/MEM hazard: forward ALU result from MEM stage
		if (RegWrite_MEM && (Rd_MEM == Ab_EX) && (Rd_MEM != 5'd31)) begin
			ForwardB = 2'b01; 
		end
		// MEM/WB hazard: forward WB data, MEM takes priority if they match
		else if (RegWrite_WB && (Rd_WB != 5'd31) && (Rd_WB == Ab_EX)  &&
				(~RegWrite_MEM || (Rd_MEM != Ab_EX) || (Rd_MEM == 5'd31))) begin 
			ForwardB = 2'b10; 
		end
		// No hazard
		else begin
			ForwardB = 2'b00; 
		end
	end
	
endmodule

// Testbench for forwarding unit.
module forwarding_unit_tb();

	logic [4:0] Rn_EX, Ab_EX;		
	logic [4:0] Rd_MEM, Rd_WB;		
	logic RegWrite_MEM, RegWrite_WB;
	logic [1:0] ForwardA, ForwardB;
	
	forwarding_unit dut (.*);
	
	initial begin
	
	// No hazard
	Rn_EX = 5'd1; Ab_EX = 5'd2; Rd_MEM = 5'd3; Rd_WB = 5'd4;
	RegWrite_MEM = 1'b1; RegWrite_WB = 1'b1;
	#10;
	
	// EX/MEM hazard on A
	Rn_EX = 5'd5; Ab_EX = 5'd2; Rd_MEM = 5'd5; Rd_WB = 5'd4;
	RegWrite_MEM = 1'b1; RegWrite_WB = 1'b1;
	#10;
	
	// MEM/WB hazard on B
	Rn_EX = 5'd1; Ab_EX = 5'd4; Rd_MEM = 5'd3; Rd_WB = 5'd4;
	RegWrite_MEM = 1'b1; RegWrite_WB = 1'b1;
	#10;
	
	// Double hazard on A
	Rn_EX = 5'd1; Ab_EX = 5'd2; Rd_MEM = 5'd6; Rd_WB = 5'd6;
	RegWrite_MEM = 1'b1; RegWrite_WB = 1'b1;
	#10;

	// Ignore RegWrite
	Rn_EX = 5'd7; Ab_EX = 5'd2; Rd_MEM = 5'd7; Rd_WB = 5'd4;
	RegWrite_MEM = 1'b0; RegWrite_WB = 1'b1;
	#10;
	
	// XZR
	Rn_EX = 5'd31; Ab_EX = 5'd31; Rd_MEM = 5'd31; Rd_WB = 5'd31;
	RegWrite_MEM = 1'b1; RegWrite_WB = 1'b1;
	#10;
	
	$stop;
	end
	
endmodule
