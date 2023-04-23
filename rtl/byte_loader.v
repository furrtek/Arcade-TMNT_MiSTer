module byte_loader(
	input clk,
	input en,
	input wein,
	output reg weout,
	output reg lsb
);

// clk	_|'|_|'|_|'|_|'|_|'|_|'|_
// wein 	_____|'''|_______________
// weout	_________|'''''''|_______
// lsb	_____________|'''|_______

always @(posedge clk) begin
	if (en) begin
		if (wein) begin
			lsb <= 1'b0;
			weout <= 1'b1;
		end
		if (weout) begin
			lsb <= ~lsb;
			if (lsb) weout <= 1'b0;
		end
	end else begin
		lsb <= 1'b0;
		weout <= 1'b0;
	end
end

endmodule
