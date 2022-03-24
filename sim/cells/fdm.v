module FDM(
	input CK,
	input D,
	output reg Q,
	output nQ
);

always @(posedge CK)
		Q <= D;

assign nQ = ~Q;

endmodule
