// Fujitsu AV cell
// 4:1 Selector
// furrtek 2022

`timescale 1ns/100ps

// Terminals and polarities checked ok
// S4 ignored because it's always connected to S1 (~S2) ?
// See fujitsu_av_cells.svg for cell trace

module T5A(
	input A1, A2,
	input B1, B2,
	input S2, S6,
	output X
);

wire mux_A = S2 ? A1 : A2;
wire mux_B = ~S2 ? B1 : B2;
assign X = S6 ? ~mux_A : ~mux_B;	// tmax = 3.3ns

endmodule
