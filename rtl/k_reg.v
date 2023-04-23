`timescale 1ns/1ns

module KREG(
	CLK,
	nCLEAR,
	DIN,
	LOAD,
	DOUT
);

parameter integer width = 4;

input CLK;
input nCLEAR;
input [width-1:0] DIN;
input LOAD;
output reg [width-1:0] DOUT;

always @(posedge CLK or negedge nCLEAR) begin
	if (!nCLEAR) begin
		DOUT <= {width{1'b0}};
	end else begin
		if (LOAD)
			DOUT <= DIN;
	end
end

endmodule
