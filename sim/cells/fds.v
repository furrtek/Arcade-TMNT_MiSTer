`timescale 1ns/100ps

module FDS(
	input CK,
	input [3:0] D,
	output reg [3:0] Q = 4'd0
);

	always @(posedge CK)
		Q <= #1 D;

endmodule
