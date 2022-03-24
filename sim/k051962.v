// TMNT arcade core
// Simulation blind schematic copy version
// Sean Gonsalves 2022
`timescale 1ns/100ps

module k051962 (
	input nRES,
	output rst,
	input clk_24M,
	
	output clk_6M, clk_12M,
	
	output [11:0] DSA,
	output [11:0] DSB,
	output [7:0] DFI,
	
	output NSAC,
	output NSBC,
	output NFIC
);

assign NSAC = 0;
assign NSBC = 0;
assign NFIC = 0;

assign DSA = 12'd0;
assign DSB = 12'd0;
assign DFI = 8'd0;

// Clocks

FDE BB8(clk_24M, 1'b1, nRES, RES_SYNC, );

FDN Z4(clk_24M, Z4_nQ, RES_SYNC, clk_12M, Z4_nQ);

FDN Z47(clk_24M, ~^{Z47_nQ, Z4_nQ}, RES_SYNC, clk_6M, Z47_nQ);

FDG Z68(clk_24M, clk_6M, RES_SYNC, , T61);

FDN Z19(clk_24M, ~^{Z19_Q, ~&{Z47_nQ, Z4_nQ}}, RES_SYNC, Z19_Q, );

endmodule
