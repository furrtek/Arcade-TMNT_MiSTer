module T34(
	input [2:0] A,
	input [2:0] B,
	input [2:0] C,
	input [2:0] D,
	output X
);

assign X = ~|{&{A}, &{B}, &{C}, &{D}};

endmodule
