`timescale 1ns/100ps

module A4H(
	input [3:0] A,
	input [3:0] B,
	input CIN,
	output [3:0] S,
	output CO
);

assign {CO, S} = A + B + CIN;

endmodule
