`timescale 1ns/100ps

module T5A(
	input [1:0] A,
	input [1:0] B,
	input S2, S6,
	output X
);

wire mux_A = S2 ? A[0] : A[1];
wire mux_B = S2 ? B[0] : B[1];
assign X = S6 ? ~mux_A : ~mux_B;

endmodule
