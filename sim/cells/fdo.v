module FDO(
	input CK,
	input D,
	input nR,
	output reg Q,
	output nQ
);

always @(posedge CK or negedge nR) begin
	if (!nR)
		Q <= 0;
	else
		Q <= D;
end

assign nQ = ~Q;

endmodule
