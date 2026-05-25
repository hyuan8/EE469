`timescale 1ns/10ps

/* Detects load-use hazards: LDUR in EX where destination register matches source register of instruction in ID */

/* Assert stall for one cycle:
- PC is frozen (re-fetches same instruction)
- IF/ID is frozen (same instruction stays in ID)
- ID/EX is flushed (NOP bubble inserted into EX) */

module hazard_detection_unit (
	input logic MemRead_EX,
	input logic [4:0] Rd_EX,
	input logic [4:0] Rn_ID,
	input logic [4:0] Ab_ID,
	output logic stall
);

	// From slides: ID/EX MemRead & ((ID/EX Rd = IF/ID Rn) | (ID/EX Rd = IF/ID Rm));
	// Condition: stall = MemRead_EX & (Rd_EX != 31) & (Rd_EX == Rn_ID | Rd_EX == Ab_ID)

	// XNOR compares each bit of Rd_EX to Rn_ID and Ab_ID, checks if they are equal
	// If equal,
	logic [4:0] eq_rn, eq_ab;
	genvar b;
	generate
		for (b = 0; b < 5; b++) begin : eq_bits
			xnor #0.05 xnor_rn (eq_rn[b], Rd_EX[b], Rn_ID[b]);
			xnor #0.05 xnor_ab (eq_ab[b], Rd_EX[b], Ab_ID[b]);
		end
	endgenerate

	// Rd_EX == RN_ID, Rd_EX == Ab_ID
	logic eq_rn_1, eq_rn_all;
	logic eq_ab_1, eq_ab_all;
	and #0.05 eq_rn_gate_1 (eq_rn_1,  eq_rn[0], eq_rn[1], eq_rn[2]);
	and #0.05 eq_rn_gate_2 (eq_rn_all, eq_rn_1, eq_rn[3], eq_rn[4]);
	and #0.05 eq_ab_gate_1 (eq_ab_1,  eq_ab[0], eq_ab[1], eq_ab[2]);
	and #0.05 eq_ab_gate_2 (eq_ab_all, eq_ab_1, eq_ab[3], eq_ab[4]);

	// Rd_EX != 31
	logic x31_1, x31_2, not_x31;
	and #0.05 x31_gate_1 (x31_1,  Rd_EX[0], Rd_EX[1], Rd_EX[2]);
	and #0.05 x31_gate_2 (x31_2,  x31_lo, Rd_EX[3], Rd_EX[4]);
	not #0.05 x31_not (not_x31, x31_2);

	// Rd_EX == RN_ID | Rd_EX == Ab_ID
	logic rn_or_ab;
	or #0.05 or0 (rn_or_ab, eq_rn_all, eq_ab_all);

	// stall = MemRead_EX & (Rd_EX != 31) & (Rd_EX == RN_ID | Rd_EX == Ab_ID)
	and #0.05 and0 (stall, MemRead_EX, not_x31, rn_or_ab);

endmodule
