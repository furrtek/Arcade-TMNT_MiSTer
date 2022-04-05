module RAM1(
	input [7:0] addr,
	input en,
	input we,
	input din,
	output dout);
	
reg data[0:255];

always @(*) begin
	if (we & en)
		data[addr] <= din;
end

	assign dout = data[addr];

endmodule
