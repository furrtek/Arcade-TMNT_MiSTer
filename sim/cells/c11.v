// Fujitsu AV cell
// Flip-Flop for Counter
// furrtek 2022

`timescale 1ns/100ps

module C11(
	input CK,
	input D,
	input L,
	input nCL,
	input TG,
	output reg Q,
	output XQ
);

always @(posedge CK or posedge ~nCL) begin
	if (!nCL) begin
		Q <= 1'b0;		// Clear
	end else begin
		if (L)
			Q <= D;		// Load
		else
			if (TG)
				Q <= ~Q;	// Toggle
	end
end
	
assign XQ = ~Q;

endmodule
