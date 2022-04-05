// TMNT arcade core
// Simulation blind schematic copy version
// Sean Gonsalves 2022
`timescale 1ns/100ps

module k051962 (
	input nRES,
	output RST,
	input clk_24M,
	
	output clk_6M, clk_12M,
	output P1H,
	
	input CRCS,
	input BEN,
	input RMRD,	// Unused, only used on the real chip to set the DB pins direction
	input ZA1H, ZA2H, ZA4H,	// Plane A fine scroll
	input ZB1H, ZB2H, ZB4H,	// Plane B fine scroll
	input [7:0] COL,			// Tile COL attribute bits
	
	input [31:0] VC,	// GFX ROM data
	
	// Layers
	output reg [11:0] DSA,
	output reg [11:0] DSB,
	output reg [7:0] DFI,
	
	output NSAC,
	output NSBC,
	output NFIC,
	
	// Video sync and blanking
	output NVBK,
	output NHBK,
	output OHBK,
	output NVSY,
	output NHSY,
	output NCSY,
	
	// CPU interface
	input [7:0] DB_IN,
	output reg [7:0] DB_OUT,
	input [1:0] AB,
	
	output DB_DIR
);

wire [3:0] Z99_Q;
wire [3:0] AA108_Q;

// TIMING GEN

FDE BB8(clk_24M, 1'b1, nRES, RES_SYNC, );

FDN Z4(clk_24M, Z4_nQ, RES_SYNC, clk_12M, Z4_nQ);
FDN Z47(clk_24M, ~^{Z47_nQ, Z4_nQ}, RES_SYNC, clk_6M, Z47_nQ);
FDG Z68(clk_24M, clk_6M, RES_SYNC, , T61);
FDN Z19(clk_24M, ~^{Z19_Q, ~&{Z47_nQ, Z4_nQ}}, RES_SYNC, Z19_Q, );

assign V154 = ~&{P1H, Z99_Q[1:0]};
assign X80 = ~&{P1H, ~Z99_Q[1:0]};
assign X78 = ~&{P1H, Z99_Q[1], ~Z99_Q[0]};

FDG AA86(T70, AA102 & (OHBK | (Z99_COUT & AA108_Q[1])), RES_SYNC, OHBK, AA86_nQ);
FDN Z81(Z99_Q[3], ~&{AA86_nQ, Z80}, Z81_Q);
FDN Z88(Z99_Q[2], Z81_Q, RES_SYNC, Z88_Q);
FDN Y86(Z99_Q[0], Z88_Q, RES_SYNC, NHSY);

FDG Y100(T70, Y151, RES_SYNC, Y100_Q);
FDG AA77(Y100_Q, OHBK, RES_SYNC, NHBK);

FDG BB87(T70, ~^{BB87_nQ, AA105}, RES_SYNC, BB87_Q, BB87_nQ);
assign AA105 = &{Z99_COUT, AA108_Q[3:2]};
assign AA102 = ~AA105;
assign BB101 = BB87_Q;	// Ignore test mode
assign BB103 = AA105 & BB87_Q;

// H counters
C43 Z99(T70, 4'b0000, AA102, Y147, Y147, RES_SYNC, Z99_Q, Z99_COUT);
C43 AA108(T70, 4'b0001, AA102, Z99_COUT, Z99_COUT, RES_SYNC, AA108_Q, );
assign Z80 = ~AA108_Q[1];

// V counters
wire [3:0] BB105_Q;
C43 BB105(T70, 4'b1100, ~CC107_COUT, BB101, BB103, RES_SYNC, BB105_Q, BB105_COUT);
wire [3:0] CC107_Q;
C43 CC107(T70, 4'b0111, ~CC107_COUT, BB101, BB105_COUT, RES_SYNC, CC107_Q, CC107_COUT);

FDG CC87(BB105_Q[3], &{CC107_Q[2:0]}, 1'b1, BB78, NVBK);
LTL CC98(CC107_Q[3], NHSY, RES_SYNC, NVSY);
assign NCSY = NVSY & NHSY;


// ROM READBACK MUX

always @(*) begin
	case(AB)
		2'd0: DB_OUT <= VC[7:0];
		2'd1: DB_OUT <= VC[15:8];
		2'd2: DB_OUT <= VC[23:16];
		2'd3: DB_OUT <= VC[31:24];
	endcase
end


// SCROLLING

reg [7:0] RES_delay;
always @(posedge BB78 or negedge RES_SYNC) begin
	if (!RES_SYNC)
		RES_delay <= 8'h00;
	else
		RES_delay <= {RES_delay[6:0], 1'b1};
end
assign RST = RES_delay[7];

FDG S77(BEN, DB_IN[0], BB7, S77_Q);
FDG S86(BEN, DB_IN[1], BB7, S86_Q);

FDM J61(L67, H13 ? ~J61_nQ : COL[0], , J61_nQ);
FDM K83(L106, K153 ? ~K83_nQ : J61_nQ, , K83_nQ);

FDM M61(M69, M52 ? ~M61_nQ : COL[0], , M61_nQ);

assign P87 = ~&{S86_Q, K83_nQ} ^ S77_Q;
assign S102 = ~&{S86_Q, M61_nQ} ^ S77_Q;
assign S106 = ~&{S86_Q, DSA[10]} ^ S77_Q;

assign L77 = ~&{ZB1H, ZB2H, ZB4H};
assign L79 = ZB4H ^ P87;
assign L83 = ZB2H ^ P87;
assign L87 = ZB1H ^ P87;

assign T19 = ~&{ZA1H, ZA2H, ZA4H};
assign T15 = ZA4H ^ S106;
assign T11 = ZA2H ^ S106;
assign T7 = ZA1H ^ S106;

FDG Z59(clk_24M, Z19_Q, RES_SYNC, Z59_Q);
FDG Y77(T70, Z59_Q, BB7, Y77_Q);
assign P1H = Y77_Q;

FDG X116(Z99_Q[0], Z99_Q[1], BB7, X116_Q);
assign X102 = P1H ^ S102;
assign X108 = X116_Q ^ S102;
assign X112 = ~Z99_Q[0] ^ S102;

assign Y151 = Y77_Q & Z99_Q[2] & ~|{Z99_Q[1:0]};

// Layer A 8-pixel row color delay
// VC[31:24]: Color bits 3
// VC[23:16]: Color bits 2
// VC[15:8]: Color bits 1
// VC[7:0]: Color bits 0
reg [31:0] LA_DELAY_A;
reg [31:0] LA_DELAY_B;
reg [31:0] LA_DELAY_C;
always @(posedge T70) begin
	if (!X78) LA_DELAY_A <= VC;
	if (!V154) LA_DELAY_B <= LA_DELAY_A;
	if (!T19) LA_DELAY_C <= LA_DELAY_B;
end

// Select pixel depending on fine X scroll
reg [3:0] LA_COLOR;
always @(*) begin
	case({T15, T11, T7})
		3'd0: LA_COLOR <= {LA_DELAY_C[24], LA_DELAY_C[16], LA_DELAY_C[8], LA_DELAY_C[0]};
		3'd1: LA_COLOR <= {LA_DELAY_C[25], LA_DELAY_C[17], LA_DELAY_C[9], LA_DELAY_C[1]};
		3'd2: LA_COLOR <= {LA_DELAY_C[26], LA_DELAY_C[18], LA_DELAY_C[10], LA_DELAY_C[2]};
		3'd3: LA_COLOR <= {LA_DELAY_C[27], LA_DELAY_C[19], LA_DELAY_C[11], LA_DELAY_C[3]};
		3'd4: LA_COLOR <= {LA_DELAY_C[28], LA_DELAY_C[20], LA_DELAY_C[12], LA_DELAY_C[4]};
		3'd5: LA_COLOR <= {LA_DELAY_C[29], LA_DELAY_C[21], LA_DELAY_C[13], LA_DELAY_C[5]};
		3'd6: LA_COLOR <= {LA_DELAY_C[30], LA_DELAY_C[22], LA_DELAY_C[14], LA_DELAY_C[6]};
		3'd7: LA_COLOR <= {LA_DELAY_C[31], LA_DELAY_C[23], LA_DELAY_C[15], LA_DELAY_C[7]};
	endcase
end

// Layer A palette delay
reg [7:0] LA_PAL_DELAY_A;
reg [7:0] LA_PAL_DELAY_B;
reg [3:0] LA_PAL_DELAY_C;
always @(posedge T70) begin
	if (!X78) LA_PAL_DELAY_A <= COL;
	if (!V154) LA_PAL_DELAY_B <= LA_PAL_DELAY_A;
	if (!T19) begin
		DSA[11:8] <= LA_PAL_DELAY_B[3:0];
		LA_PAL_DELAY_C <= LA_PAL_DELAY_B[7:4];
	end
end

always @(*) begin
	if (!T61) DSA[7:4] <= LA_PAL_DELAY_C;
end


// Layer B 8-pixel row color delay
// VC[31:24]: Color bits 3
// VC[23:16]: Color bits 2
// VC[15:8]: Color bits 1
// VC[7:0]: Color bits 0
reg [31:0] LB_DELAY_A;
reg [31:0] LB_DELAY_B;
always @(posedge T70) begin
	if (!V154) LB_DELAY_A <= VC;
	if (!L77) LB_DELAY_B <= LB_DELAY_A;
end

// Select pixel depending on fine X scroll
reg [3:0] LB_COLOR;
always @(*) begin
	case({L79, L83, L87})
		3'd0: LB_COLOR <= {LB_DELAY_B[24], LB_DELAY_B[16], LB_DELAY_B[8], LB_DELAY_B[0]};
		3'd1: LB_COLOR <= {LB_DELAY_B[25], LB_DELAY_B[17], LB_DELAY_B[9], LB_DELAY_B[1]};
		3'd2: LB_COLOR <= {LB_DELAY_B[26], LB_DELAY_B[18], LB_DELAY_B[10], LB_DELAY_B[2]};
		3'd3: LB_COLOR <= {LB_DELAY_B[27], LB_DELAY_B[19], LB_DELAY_B[11], LB_DELAY_B[3]};
		3'd4: LB_COLOR <= {LB_DELAY_B[28], LB_DELAY_B[20], LB_DELAY_B[12], LB_DELAY_B[4]};
		3'd5: LB_COLOR <= {LB_DELAY_B[29], LB_DELAY_B[21], LB_DELAY_B[13], LB_DELAY_B[5]};
		3'd6: LB_COLOR <= {LB_DELAY_B[30], LB_DELAY_B[22], LB_DELAY_B[14], LB_DELAY_B[6]};
		3'd7: LB_COLOR <= {LB_DELAY_B[31], LB_DELAY_B[23], LB_DELAY_B[15], LB_DELAY_B[7]};
	endcase
end

// Layer B palette delay
reg [7:0] LB_PAL_DELAY_A;
reg [3:0] LB_PAL_DELAY_B;
always @(posedge T70) begin
	if (!V154) LB_PAL_DELAY_A <= COL;
	if (!L77) begin
		DSB[11:8] <= LB_PAL_DELAY_A[3:0];
		LB_PAL_DELAY_B <= LB_PAL_DELAY_A[7:4];
	end
end

// Where's COL0 on the schematics ?
always @(*) begin
	if (!T61) DSB[7:4] <= LB_PAL_DELAY_B;
end


// Layer Fix 8-pixel row color delay
// VC[31:24]: Color bits 3
// VC[23:16]: Color bits 2
// VC[15:8]: Color bits 1
// VC[7:0]: Color bits 0
reg [31:0] LF_DELAY_A;
always @(posedge T70) begin
	if (!X80) LF_DELAY_A <= VC;
end

// Select pixel
reg [3:0] LF_COLOR;
always @(*) begin
	case({X108, X112, X102})
		3'd0: LF_COLOR <= {LF_DELAY_A[24], LF_DELAY_A[16], LF_DELAY_A[8], LF_DELAY_A[0]};
		3'd1: LF_COLOR <= {LF_DELAY_A[25], LF_DELAY_A[17], LF_DELAY_A[9], LF_DELAY_A[1]};
		3'd2: LF_COLOR <= {LF_DELAY_A[26], LF_DELAY_A[18], LF_DELAY_A[10], LF_DELAY_A[2]};
		3'd3: LF_COLOR <= {LF_DELAY_A[27], LF_DELAY_A[19], LF_DELAY_A[11], LF_DELAY_A[3]};
		3'd4: LF_COLOR <= {LF_DELAY_A[28], LF_DELAY_A[20], LF_DELAY_A[12], LF_DELAY_A[4]};
		3'd5: LF_COLOR <= {LF_DELAY_A[29], LF_DELAY_A[21], LF_DELAY_A[13], LF_DELAY_A[5]};
		3'd6: LF_COLOR <= {LF_DELAY_A[30], LF_DELAY_A[22], LF_DELAY_A[14], LF_DELAY_A[6]};
		3'd7: LF_COLOR <= {LF_DELAY_A[31], LF_DELAY_A[23], LF_DELAY_A[15], LF_DELAY_A[7]};
	endcase
end

// Layer Fix palette delay
reg [3:0] LF_PAL_DELAY_A;
always @(posedge T70) begin
	if (!X80) LF_PAL_DELAY_A <= COL[7:4];
end

// Where's COL0 on the schematics ?
always @(*) begin
	if (!T61) DFI[7:4] <= LF_PAL_DELAY_A;
end


// OUTPUT LATCHES

always @(*) begin
	if (!T61) begin
		DSA[3:0] <= LA_COLOR;
		DSB[3:0] <= LB_COLOR;
		DFI[3:0] <= LF_COLOR;
	end
end
assign NSAC = |{LA_COLOR};
assign NSBC = |{LB_COLOR};
assign NFIC = |{LF_COLOR};

assign DB_DIR = ~&{~CRCS, RMRD};

endmodule
