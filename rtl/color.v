module TMNTColor
(
	input [8:0] CD,
	input SHADOW,
	input NCBLK,
	input COLCS,
	output [5:0] RED_OUT,
	output [5:0] GREEN_OUT,
	output [5:0] BLUE_OUT
);

	reg [12:0] C_REG;
	reg [10:0] CR;
	wire [7:0] RAM_DOUT_LOW;
	wire [7:0] RAM_DOUT_HIGH;
	reg [15:0] COL;
	wire [15:0] COL_OUT;
	wire [5:0] RED;
	wire [5:0] GREEN;
	wire [5:0] BLUE;
	
	always @(posedge V6M)
		C_REG <= {C_REG[11], SHADOW, NCBLK, CD};
	
	assign {nCOE, CR} = COLCS ? {1'b0, 1'b0, C_REG[9:0]} : {NREAD, AB[12:2]};

	RAM RAM_PAL_LOW(
		.A(CR),
		.DIN(D[7:0]),
		.DOUT(RAM_DOUT_LOW),
		.WR(~AB[1] & ~COLCS & ~NLWR)
	);
	RAM RAM_PAL_HIGH(
		.A(CR),
		.DIN(D[7:0]),
		.DOUT(RAM_DOUT_HIGH),
		.WR(AB[1] & ~COLCS & ~NLWR)
	);
	assign D[7:0] = ~NREAD ? (~NREAD & ~AB[0]) ? RAM_DOUT_LOW : RAM_DOUT_HIGH : 8'bzzzzzzzz;
	
	always @(posedge V6M)
		COL <= RAM_DOUT;
	
	assign RED = {COL[12:8], COL[7]};
	assign GREEN = {COL[1:0], COL[15:13], COL[7]};
	assign BLUE = {COL[6:2], COL[7]};
	
	assign RED_OUT = SHADOW ? RED : {1'b0, RED};
	assign GREEN_OUT = SHADOW ? GREEN : {1'b0, GREEN};
	assign BLUE_OUT = SHADOW ? BLUE : {1'b0, BLUE};
	
endmodule
