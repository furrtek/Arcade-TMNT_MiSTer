module LTL(
	input D,
	input nG,
	input nCL,
	output reg Q,
	output XQ
);

always @(*) begin
	if (!nCL) begin
		Q <= 1'b0;
	end else begin
		if (!nG)
			Q <= D;
	end
end

assign XQ = ~Q;

endmodule
