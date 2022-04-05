`timescale 1ns/100ps

module A2N(
	input [1:0] A,
	input [1:0] B,
	input CIN,
	output [1:0] S,
	output CO
);

assign {CO, S} = A + B + CIN;

endmodule
