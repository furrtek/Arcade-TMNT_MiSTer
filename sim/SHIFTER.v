module SHIFTER(
	input CLK,
	input [1:0] SEL,
	input [3:0] DIN,
	output [3:0] DOUT
);

T34 MUX1({1'b0, SEL[1], ~SEL[0]}, {~SEL[0], ~SEL[1], DIN[3]}, {SEL[0], ~SEL[1], DOUT[1]}, {SEL[0], SEL[1], DOUT[0]});
T34 MUX2({DOUT[0], SEL[1], ~SEL[0]}, {~SEL[0], ~SEL[1], DIN[2]}, {SEL[0], ~SEL[1], DOUT[2]}, {SEL[0], SEL[1], DOUT[1]});
T34 MUX3({DOUT[1], SEL[1], ~SEL[0]}, {~SEL[0], ~SEL[1], DIN[1]}, {SEL[0], ~SEL[1], DOUT[3]}, {SEL[0], SEL[1], DOUT[2]});
T34 MUX4({DOUT[2], SEL[1], ~SEL[0]}, {~SEL[0], ~SEL[1], DIN[0]}, {SEL[0], ~SEL[1], 1'b0}, {SEL[0], SEL[1], DOUT[3]});
FDS RG(CLK, {~MUX4, ~MUX3, ~MUX2, ~MUX1}, DOUT);

endmodule
