`timescale 1ns/100ps

module BD3(
	input INPT,
	output OUTPT
);

	assign #5 OUTPT = INPT;

endmodule
