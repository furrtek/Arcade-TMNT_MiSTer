`timescale 1ns/1ns

module KREG(
	input CLK,
	input CLEAR,
	input [3:0] DIN,
	input LOAD,
	output reg [3:0] DOUT
);

	always @(posedge CLK or negedge CLEAR) begin
		if (!CLEAR) begin
			DOUT <= 4'b0000;
		end else begin
			if (LOAD)
				DOUT <= DIN;
		end
	end

endmodule
