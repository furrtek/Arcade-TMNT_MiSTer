module FDN(
	input CK,
	input D,
	input nS,
	output reg Q,
	output nQ
);

always @(posedge CK or negedge nS) begin
	if (!nS)
		Q <= 1;
	else
		Q <= D;
end

assign nQ = ~Q;

endmodule
