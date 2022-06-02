// TMNT arcade core
// Simulation blind schematic copy version
// Sean Gonsalves 2022
`timescale 1ns/1ns

// TODO: Why is there a OA_in (external sprite RAM address bus) ? Get rid of it if it's for a test mode.

module k051960 (
	input nRES,
	output RST,
	input clk_24M,

	output P1H,
	output P2H,
	
	input HVIN,
	output HVOT,
	
	output PQ, PE,

	output WRP, WREN, RDEN,
	input NRD, OBCS,

	input [10:0] AB,
	
	output [7:0] DB_OUT,
	input [7:0] DB_IN,
	
	output OHF, OREG, HEND, LACH, CARY,

	output [8:0] HP,
	output [7:0] OC,

	output [17:0] CA,

	input [9:0] OA_in,
	output [9:0] OA_out,
	output OWR, OOE,
	input [7:0] OD_in,
	output [7:0] OD_out,
	
	output IRQ, FIRQ, NMI,
	
	output clk_6M, clk_12M,
	
	output DB_DIR
);

wire [8:0] PXH;
wire [7:0] ROW;

wire [9:0] ATTR_A;
wire [6:0] SPR_PRIO;

wire [7:0] RAM_din;

wire [7:0] RAM_A_dout;
wire [7:0] RAM_B_dout;
wire [7:0] RAM_C_dout;
wire [7:0] RAM_D_dout;
wire [7:0] RAM_E_dout;
wire [7:0] RAM_F_dout;
wire [7:0] RAM_G_dout;

wire [3:0] AN221_Q;
wire [3:0] V27_Q;
wire [3:0] S2_Q;
wire [3:0] V53_Q;
wire [3:0] V1_Q;
wire [3:0] AU163_Q;

wire [3:0] W49_Q;
wire [3:0] W1_Q;

wire RAM_DATA_WR;

wire [7:0] SPR_YMATCH;
reg [2:0] SPR_SIZE;
wire [12:0] SPR_CODE;

wire [3:0] R50_Q;
wire [3:0] S28_Q;

reg [3:0] AM195_Q;
reg [3:0] AN195_Q;
wire [3:0] Y229_Q;
wire [3:0] AD255_Q;
wire [4:0] AB233_Q;

wire [7:0] REG2;
wire [7:0] REG3;
wire [1:0] REG4;
wire L126_Q, L112_XQ;

reg [5:0] SPR_ATTR_ZY_DELAY;
reg SPR_Y8, SPR_VFLIP;

// Reset input sync
FDE AA1(clk_24M, 1'b1, nRES, RES_SYNC, );

// Clocks

FDN AA70(clk_24M, ~^{AA70_XQ, AA51_XQ}, RES_SYNC, clk_6M, AA70_XQ);
FDN AA51(clk_24M, AA51_XQ, RES_SYNC, clk_12M, AA51_XQ);

FDO AB91(clk_24M, ~clk_6M, RES_SYNC, AB91_Q, AB91_XQ);
FDO AB12(~clk_24M, AB91_Q, RES_SYNC, , AB12_XQ);
assign AB19 = AB12_XQ & AB91_XQ;

FDN AA141(clk_24M, ~^{AA141_Q, ~&{AA51_XQ, AA70_XQ}}, RES_SYNC, AA141_Q, AA141_XQ);
FDE AA128(~clk_24M, AA141_XQ, RES_SYNC, Z143, );
assign Z139 = ~Z143;

FDO AA121(clk_24M, AA141_XQ, RES_SYNC, AA121_Q, AA121_XQ);
FDO AA85(clk_24M, AA121_Q, RES_SYNC, AA85_Q, );
FDE AA41(clk_24M, AA85_Q, RES_SYNC, PQ, );
FDO AA63(clk_24M, AA85_Q, RES_SYNC, AA63_Q, );
assign AA96 = ~&{AA63_Q, AA121_XQ};
assign AA94 = ~&{NRD, AA63_Q, AA121_XQ};
assign AA113 = ~&{NRD, ~AA141_XQ, AA121_XQ};
assign AA92 = NRD | AA121_Q;

wire [3:0] AA11_Q;
FDR AA11(clk_24M, {AA92, AA113, AA94, AA96}, RES_SYNC, AA11_Q);

// M6809 stuff
assign AB98 = ~AA11_Q[0];
assign WRP = AA11_Q[1];
assign WREN = AA11_Q[2];
assign RDEN = AA11_Q[3];

FDE AA103(clk_24M, ~AA141_XQ, RES_SYNC, PE, );


// H/V COUNTERS

// H counter
// 9-bit counter, resets to 9'h020 after 9'h19F, effectively counting 384 pixels
FDO T121(clk_6M, PE, RES_SYNC, PXH[0], );
C43 R207(clk_6M, 4'b0000, HRST, PXH[0], PXH[0], RES_SYNC, PXH[4:1], R207_COUT);
C43 P233(clk_6M, 4'b0001, HRST, R207_COUT, R207_COUT, RES_SYNC, PXH[8:5], );
assign P1H = PXH[0];
assign LINE_END = &{R207_COUT, PXH[8:7]};
assign HRST = ~LINE_END;

// HVIN sync
reg [7:0] DELAY_HVIN;
always @(posedge clk_6M or negedge RES_SYNC) begin
	if (!RES_SYNC) begin
		DELAY_HVIN <= 8'h00;
	end else begin
		DELAY_HVIN <= {DELAY_HVIN[6:0], ~HVIN};
	end
end

// V counter
// 9-bit counter, resets to 9'h0F8 after 9'h1FF, effectively counting 264 raster lines
wire [8:0] ROW_RAW;
FDO T247(clk_6M, ~|{DELAY_HVIN[7], ~^{LINE_END, ROW_RAW[0]}}, RES_SYNC, ROW_RAW[0], );

C43 S233(clk_6M, 4'b1100, ~T53_COUT, ROW_RAW[0], LINE_END & ROW_RAW[0], RES_SYNC, ROW_RAW[4:1], S233_COUT);
C43 T53(clk_6M, 4'b0111, ~T53_COUT, ROW_RAW[0], S233_COUT, RES_SYNC, ROW_RAW[8:5], T53_COUT);
assign HVOT = ~T53_COUT;

wire FLIP_SCREEN;
assign ROW = {ROW_RAW[7:0]} ^ {8{FLIP_SCREEN}};

// Trigger vblank at line 9h'1F8
FDO T192(ROW_RAW[4], &{ROW_RAW[7:4]}, RES_SYNC, VBLANK, );


// Sprite RAM CPU read
wire VBLANK_SYNC;
wire [3:0] AD121_P;
wire [3:0] AE121_P;
LT4 AD121(AA141_XQ, OD_in[3:0], AD121_P, );
LT4 AE121(AA141_XQ, OD_in[7:4], AE121_P, );

assign AB84 = ~AA141_XQ;

// Select between reg 0 read and sprite RAM read
wire nREG0_R;
assign DB_OUT[0] = nREG0_R ? AD121_P[0] : ~VBLANK_SYNC;
assign DB_OUT[3:1] = AD121_P[3:1];
assign DB_OUT[7:4] = AE121_P;

// Sprite RAM data bus output is always = CPU bus input
assign OD_out = DB_IN;


// INTERNAL RAM

// Internal RAM WEs
wire Z95;
assign RAM_A_WE = &{AB98, VBLANK_SYNC, Z95, ATTR_A[2:0] == 3'b110};
assign RAM_B_WE = &{AB98, VBLANK_SYNC, Z95, ATTR_A[2:0] == 3'b101};
assign RAM_C_WE = &{AB98, VBLANK_SYNC, Z95, ATTR_A[2:0] == 3'b011};
assign RAM_D_WE = &{AB98, VBLANK_SYNC, Z95, ATTR_A[2:0] == 3'b100};
assign RAM_E_WE = &{AB98, VBLANK_SYNC, Z95, ATTR_A[2:0] == 3'b010};
assign RAM_F_WE = &{AB98, VBLANK_SYNC, Z95, ATTR_A[2:0] == 3'b001};
assign RAM_G_WE = &{AB98, VBLANK_SYNC, Z95, ATTR_A[2:0] == 3'b111};

// Internal RAM address - 8-to-1 bus mux
wire [6:0] RAM_addr;
wire [6:0] RAM_addr_back;
wire [6:0] RAM_addr_front;
// Group of T5As
wire Y72, Y81, R36_XQ, R101_XQ, R22_XQ, R43_XQ, R142_XQ;
/*
assign RAM_addr_back[6] = Y72 ? Y81 ? OA_in[9] : W1_Q[2] : Y81 ? V53_Q[0] : V1_Q[0];	// Swap ?
assign RAM_addr_back[5] = Y72 ? Y81 ? OA_in[8] : W1_Q[1] : Y81 ? V53_Q[1] : V1_Q[1];	// Swap ?
assign RAM_addr_back[4] = Y72 ? Y81 ? OA_in[7] : W1_Q[0] : Y81 ? V53_Q[2] : V1_Q[2];	// Swap ?
assign RAM_addr_back[3] = Y72 ? Y81 ? OA_in[6] : W49_Q[3] : Y81 ? V53_Q[3] : V1_Q[3];	// Swap ?
assign RAM_addr_back[2] = Y72 ? Y81 ? OA_in[5] : W49_Q[2] : Y81 ? R36_XQ : R101_XQ;	// Swap ?
assign RAM_addr_back[1] = Y72 ? Y81 ? OA_in[4] : W49_Q[1] : Y81 ? R22_XQ : R43_XQ;	// Swap ?
assign RAM_addr_back[0] = Y72 ? Y81 ? OA_in[3] : W49_Q[0] : Y81 ? R22_XQ : R142_XQ;	// Swap ?
*/
T5A X61(OA_in[9], W1_Q[2], V1_Q[0], V53_Q[0], Y73, Y72, RAM_addr_back[6]);
T5A X49(OA_in[8], W1_Q[1], V1_Q[1], V53_Q[1], Y73, Y72, RAM_addr_back[5]);
T5A X54(OA_in[7], W1_Q[0], V1_Q[2], V53_Q[2], Y73, Y72, RAM_addr_back[4]);
T5A X81(OA_in[6], W49_Q[3], V1_Q[3], V53_Q[3], Y73, Y72, RAM_addr_back[3]);
T5A X66(OA_in[5], W49_Q[2], R101_XQ, R36_XQ, Y73, Y72, RAM_addr_back[2]);
T5A X71(OA_in[4], W49_Q[1], R43_XQ, R22_XQ, Y73, Y72, RAM_addr_back[1]);
T5A X91(OA_in[3], W49_Q[0], R142_XQ, R22_XQ, Y73, Y72, RAM_addr_back[0]);

// Group of T5As
wire S92_XQ, R15_XQ, S85_XQ, R1_XQ, R108_XQ, R8_XQ;
/*assign RAM_addr_front[6] = Y72 ? Y81 ? S2_Q[0] : V27_Q[0] : Y81 ? ATTR_A[9] : SPR_PRIO[6];	// Swap ?
assign RAM_addr_front[5] = Y72 ? Y81 ? S2_Q[1] : V27_Q[1] : Y81 ? ATTR_A[8] : SPR_PRIO[5];	// Swap ?
assign RAM_addr_front[4] = Y72 ? Y81 ? S2_Q[2] : V27_Q[2] : Y81 ? ATTR_A[7] : SPR_PRIO[4];	// Swap ?
assign RAM_addr_front[3] = Y72 ? Y81 ? S2_Q[3] : V27_Q[3] : Y81 ? ATTR_A[6] : SPR_PRIO[3];	// Swap ?
assign RAM_addr_front[2] = Y72 ? Y81 ? S92_XQ : R15_XQ : Y81 ? ATTR_A[5] : SPR_PRIO[2];	// Swap ?
assign RAM_addr_front[1] = Y72 ? Y81 ? S85_XQ : R1_XQ : Y81 ? ATTR_A[4] : SPR_PRIO[1];	// Swap ?
assign RAM_addr_front[0] = Y72 ? Y81 ? R108_XQ : R8_XQ : Y81 ? ATTR_A[3] : SPR_PRIO[0];	// Swap ?*/
T5A X101(S2_Q[0], V27_Q[0], SPR_PRIO[6], ATTR_A[9], Y73, Y72, RAM_addr_front[6]);
T5A X106(S2_Q[1], V27_Q[1], SPR_PRIO[5], ATTR_A[8], Y73, Y72, RAM_addr_front[5]);
T5A X86(S2_Q[2], V27_Q[2], SPR_PRIO[4], ATTR_A[7], Y73, Y72, RAM_addr_front[4]);
T5A X126(S2_Q[3], V27_Q[3], SPR_PRIO[3], ATTR_A[6], Y73, Y72, RAM_addr_front[3]);
T5A X131(S92_XQ, R15_XQ, SPR_PRIO[2], ATTR_A[5], Y73, Y72, RAM_addr_front[2]);
T5A X121(S85_XQ, R1_XQ, SPR_PRIO[1], ATTR_A[4], Y73, Y72, RAM_addr_front[1]);
T5A X111(R108_XQ, R8_XQ, SPR_PRIO[0], ATTR_A[3], Y73, Y72, RAM_addr_front[0]);

wire X148;
// Group of T2Ds
assign RAM_addr = X148 ? ~RAM_addr_back : ~RAM_addr_front;


// Sprite RAM reg to feed internal RAM
reg [7:0] RAM_din_latch;
always @(posedge AB84)
	RAM_din_latch <= OD_in;

assign RAM_din = RAM_DATA_WR ? RAM_din_latch : 8'h00;

ram_sim #(8, 7, "") RAMA(RAM_addr, ~RAM_A_WE, 1'b0, RAM_din, RAM_A_dout);
ram_sim #(8, 7, "") RAMB(RAM_addr, ~RAM_B_WE, 1'b0, RAM_din, RAM_B_dout);
ram_sim #(8, 7, "") RAMC(RAM_addr, ~RAM_C_WE, 1'b0, RAM_din, RAM_C_dout);
ram_sim #(8, 7, "") RAMD(RAM_addr, ~RAM_D_WE, 1'b0, RAM_din, RAM_D_dout);
ram_sim #(8, 7, "") RAME(RAM_addr, ~RAM_E_WE, 1'b0, RAM_din, RAM_E_dout);
ram_sim #(8, 7, "") RAMF(RAM_addr, ~RAM_F_WE, 1'b0, RAM_din, RAM_F_dout);
ram_sim #(8, 7, "") RAMG(RAM_addr, ~RAM_G_WE, 1'b0, RAM_din, RAM_G_dout);


// ADDERS
// A4H B inputs reversed ?
// A2N A inputs reversed ?

assign AN143 = SPR_ATTR_ZY_DELAY[1] & SPR_YMATCH[0];
wire [6:0] AX101_S;
wire [2:0] AR101_S;
A4H AX101(SPR_YMATCH[0] ? SPR_ATTR_ZY_DELAY[5:2] : 4'b0000, SPR_YMATCH[1] ? SPR_ATTR_ZY_DELAY[4:1] : 4'b0000, SPR_YMATCH[1] & SPR_ATTR_ZY_DELAY[0] & AN143, AX101_S[3:0], AX101_S[4]);
A2N AR101({SPR_YMATCH[1], SPR_YMATCH[1] & SPR_ATTR_ZY_DELAY[5]}, {1'b0, SPR_YMATCH[0]}, AX101_S[4], AR101_S[1:0], AR101_S[2]);

wire [4:0] AW101_S;
wire [2:0] AP101_S;
A4H AW101({AR101_S[0], AX101_S[3:1]}, SPR_YMATCH[2] ? SPR_ATTR_ZY_DELAY[4:1] : 4'b0000, SPR_YMATCH[2] & SPR_ATTR_ZY_DELAY[0] & AX101_S[0], AW101_S[3:0], AW101_S[4]);
A2N AP101({SPR_YMATCH[2], SPR_YMATCH[2] & SPR_ATTR_ZY_DELAY[5]}, AR101_S[2:1], AW101_S[4], AP101_S[1:0], AP101_S[2]);

wire [4:0] AV101_S;
wire [2:0] AP121_S;
A4H AV101({AP101_S[0], AW101_S[3:1]}, SPR_YMATCH[3] ? SPR_ATTR_ZY_DELAY[4:1] : 4'b0000, SPR_YMATCH[3] & SPR_ATTR_ZY_DELAY[0] & AW101_S[0], AV101_S[3:0], AV101_S[4]);
A2N AP121({SPR_YMATCH[3], SPR_YMATCH[3] & SPR_ATTR_ZY_DELAY[5]}, AP101_S[2:1], AV101_S[4], AP121_S[1:0], AP121_S[2]);

wire [4:0] AU101_S;
wire [2:0] AN101_S;
A4H AU101({AP121_S[0], AV101_S[3:1]}, SPR_YMATCH[4] ? SPR_ATTR_ZY_DELAY[4:1] : 4'b0000, SPR_YMATCH[4] & SPR_ATTR_ZY_DELAY[0] & AV101_S[0], AU101_S[3:0], AU101_S[4]);
A2N AN101({SPR_YMATCH[4], SPR_YMATCH[4] & SPR_ATTR_ZY_DELAY[5]}, AP121_S[2:1], AU101_S[4], AN101_S[1:0], AN101_S[2]);

wire [4:0] AM101_S;
wire [2:0] AL101_S;
A4H AM101({AN101_S[0], AU101_S[3:1]}, SPR_YMATCH[5] ? SPR_ATTR_ZY_DELAY[4:1] : 4'b0000, SPR_YMATCH[5] & SPR_ATTR_ZY_DELAY[0] & AU101_S[0], AM101_S[3:0], AM101_S[4]);
A2N AL101({SPR_YMATCH[5], SPR_YMATCH[5] & SPR_ATTR_ZY_DELAY[5]}, AN101_S[2:1], AM101_S[4], AL101_S[1:0], AL101_S[2]);

wire [4:0] AK101_S;
wire [2:0] AJ101_S;
A4H AK101({AL101_S[0], AM101_S[3:1]}, SPR_YMATCH[6] ? SPR_ATTR_ZY_DELAY[4:1] : 4'b0000, SPR_YMATCH[6] & SPR_ATTR_ZY_DELAY[0] & AM101_S[0], AK101_S[3:0], AK101_S[4]);
A2N AJ101({SPR_YMATCH[6], SPR_YMATCH[6] & SPR_ATTR_ZY_DELAY[5]}, AL101_S[2:1], AK101_S[4], AJ101_S[1:0], AJ101_S[2]);
assign AL147 = (SPR_YMATCH[6] & SPR_ATTR_ZY_DELAY[0]) ^ AM101_S[0];	// Is it SPR_YMATCH[7] ?

wire [4:0] AH27_S;
wire [2:0] AH81_S;
A4H AH27({AJ101_S[0], AK101_S[3:1]}, SPR_YMATCH[7] ? SPR_ATTR_ZY_DELAY[4:1] : 4'b0000, SPR_YMATCH[7] & SPR_ATTR_ZY_DELAY[0] & AK101_S[0], AH27_S[3:0], AH27_S[4]);
A2N AH81({SPR_YMATCH[7], SPR_YMATCH[7] & SPR_ATTR_ZY_DELAY[5]}, AJ101_S[2:1], AH27_S[4], AH81_S[1:0], AH81_S[2]);
assign AJ141 = (SPR_YMATCH[7] & SPR_ATTR_ZY_DELAY[0]) ^ AK101_S[0];

wire [3:0] AF27_Q;
KREG AF27(clk_6M, RES_SYNC, {AH27_S[2:0], AJ141}, ~P1, AF27_Q);
wire [3:0] AF1_Q;
KREG AF1(clk_6M, RES_SYNC, {AH81_COUT, AH81_S[1:0], AH27_S[3]}, ~P1, AF1_Q);


// DELAYS / LATCHES
// TODO: Document these

KREG AN221(clk_6M, RES_SYNC, {SPR_CODE[3], SPR_CODE[5], SPR_VFLIP, AL147}, ~P1, {AN221_Q[3:2], SPR_VFLIP_LAT, AN221_Q[0]});	// TO CHECK
KREG V27(clk_6M, RES_SYNC, {R50_Q[3], S28_Q[0], AB3, S28_Q[2]}, ~P135, V27_Q);	// TO CHECK
KREG S2(clk_6M, RES_SYNC, {R50_Q[3], S28_Q[0], S28_Q[1], S28_Q[2]}, ~P137, S2_Q);	// TO CHECK
KREG V53(clk_6M, RES_SYNC, {R50_Q[3], S28_Q[0], S28_Q[1], S28_Q[2]}, ~P133, V53_Q);
KREG V1(clk_6M, RES_SYNC, {R50_Q[3], S28_Q[0], AB3, S28_Q[2]}, ~P131, V1_Q);	// TO CHECK
KREG AU163(clk_6M, RES_SYNC, {AN195_Q[1:0], SPR_SIZE2_DELAY, SPR_CODE[1]}, ~P1, AU163_Q);

// Get sprite priority and active flag from sprite RAM
assign Y133 = ~|{ATTR_A[2:0]};
KREG Y2(AB84, RES_SYNC, OD_in[7:4], Y133, {SPR_ACTIVE, SPR_PRIO[6:4]});
KREG Y28(AB84, RES_SYNC, OD_in[3:0], Y133, SPR_PRIO[3:0]);

// TODO: These all catch {AE110, AD102, AD82, AD101} at different times
wire [3:0] K94_Q;
wire [3:0] G95_Q;
wire [3:0] D124_Q;
wire [3:0] E95_Q;
KREG K94(clk_6M, RES_SYNC, {AE110, ~AP183_OUT, ~AP171_OUT, ~AP166_OUT}, ~P133, K94_Q);
KREG G95(clk_6M, RES_SYNC, {AE110, ~AP183_OUT, ~AP171_OUT, ~AP166_OUT}, ~P131, G95_Q);
KREG D124(clk_6M, RES_SYNC, {AE110, ~AP183_OUT, ~AP171_OUT, ~AP166_OUT}, ~P137, D124_Q);
KREG E95(clk_6M, RES_SYNC, {AE110, ~AP183_OUT, ~AP171_OUT, ~AP166_OUT}, ~P135, E95_Q);

// ROOT SHEET 2

// 8-frame delay for RES -> RST
reg [7:0] RES_delay;
always @(posedge VBLANK or negedge RES_SYNC) begin
	if (!RES_SYNC)
		RES_delay <= 8'h00;
	else
		RES_delay <= {RES_delay[6:0], RES_SYNC};
end
assign RST = RES_delay[7];

reg [3:0] HRST_delay;
always @(posedge clk_6M or negedge RES_SYNC) begin
	if (!RES_SYNC)
		HRST_delay <= 4'b0000;
	else
		HRST_delay <= {HRST_delay[2:0], HRST};
end

FDO L94(clk_6M, HRST_delay[3], RES_SYNC, L94_Q, );
FDO L112(clk_6M, L94_Q, RES_SYNC, L112_Q, L112_XQ);
FDO L119(clk_6M, L112_Q, L119_Q, );

wire ROM_READ;
assign A152 = |{AB[10:3]};
assign A124 = ~|{OBCS, RDEN, A152, ~(AB[2:0] == 3'd0)};
assign A126 = ~|{~AB[10], OBCS, RDEN, ROM_READ};
assign DB_DIR = ~|{A126, A124};

assign OREG = A152 | OBCS;

assign A133 = ~&{AB[10], ~ROM_READ};
assign OD_DIR = |{A133, OBCS, WREN};
assign OWR = |{A133, OBCS, WRP};



// 051937 IF 1

wire [17:4] CA_RENDER;

// Sprite color attribute
reg [7:0] SPR_COL;
reg [7:0] SPR_COL_DELAY;
reg [3:2] AD227_Q;
/*FDN AF274(clk_12M, LACH ? ~RAM_C_dout[0] : AF274_XQ, RES_SYNC, AF274_Q, AF274_XQ);
FDN AF253(clk_12M, LACH ? ~RAM_C_dout[1] : AF253_XQ, RES_SYNC, AF253_Q, AF253_XQ);
FDN AE267(clk_12M, LACH ? ~RAM_C_dout[2] : AE267_XQ, RES_SYNC, AE267_Q, AE267_XQ);
FDN AE274(clk_12M, LACH ? ~RAM_C_dout[3] : AE274_XQ, RES_SYNC, AE274_Q, AE274_XQ);
FDN AE49(clk_12M, LACH ? ~RAM_C_dout[4] : AE49_XQ, RES_SYNC, AE49_Q, AE49_XQ);
FDN AE61(clk_12M, LACH ? ~RAM_C_dout[5] : AE61_XQ, RES_SYNC, AE61_Q, AE61_XQ);
FDN AE68(clk_12M, LACH ? ~RAM_C_dout[6] : AE68_XQ, RES_SYNC, AE68_Q, AE68_XQ);
FDN AE85(clk_12M, LACH ? ~RAM_C_dout[7] : AE85_XQ, RES_SYNC, AE85_Q, AE85_XQ);*/
always @(posedge clk_12M or negedge RES_SYNC) begin
	if (!RES_SYNC) begin
		SPR_COL <= 8'h00;
		SPR_COL_DELAY <= 8'h00;
	end else begin
		if (!LACH) begin
			SPR_COL <= RAM_C_dout;
			SPR_COL_DELAY <= SPR_COL;
			
			// Not related but uses same cell
			AD227_Q[3:2] <= SPR_CODE[12:11];
		end
	end
end

assign CA_RENDER[17:16] = AD227_Q[3:2];

assign OC = ROM_READ ? {REG4, REG3[7:2]} : SPR_COL_DELAY;

/*FDO AA192(clk_12M, ~AE85_Q, RES_SYNC, , AA192_XQ);
wire [3:0] AD227_Q;
FDR AD227(clk_12M, {~AF253_Q, ~AF274_Q, SPR_CODE[12:11]}, RES_SYNC, AD227_Q);
wire [3:0] AD201_Q;
FDR AD201(clk_12M, {~AE61_Q, ~AE49_Q, ~AE274_Q, ~AE267_Q}, RES_SYNC, AD201_Q);
FDO AB194(clk_12M, ~AE68_Q, RES_SYNC, , AB194_XQ);*/


// RAM F LATCH

/*FDN AF206(clk_12M, LACH ? ~RAM_F_dout[6] : ~AF206_XQ, RES_SYNC, AF206_Q, AF206_XQ);
assign SPR_SIZE[1] = ~AF206_Q;
FDN AF213(clk_12M, LACH ? ~RAM_F_dout[7] : ~AF213_XQ, RES_SYNC, AF213_Q, AF213_XQ);
assign SPR_SIZE[2] = ~AF213_Q;
FDN AF221(clk_12M, LACH ? ~RAM_F_dout[4] : ~AF221_XQ, RES_SYNC, AF221_Q, AF221_XQ);
assign SPR_CODE[12] = ~AF221_Q;
FDN AF228(clk_12M, LACH ? ~RAM_F_dout[5] : ~AF228_XQ, RES_SYNC, AF228_Q, AF228_XQ);
assign SPR_SIZE[0] = AF228_Q;*/
reg [4:0] SPR_CODE_REG;
always @(posedge clk_12M or negedge RES_SYNC) begin
	if (!RES_SYNC) begin
		{SPR_SIZE, SPR_CODE_REG} <= 8'h00;
	end else begin
		if (!LACH)
			{SPR_SIZE, SPR_CODE_REG} <= RAM_F_dout;
	end
end

assign SPR_CODE[12:8] = SPR_CODE_REG;
assign SPR_W64P = &{|{SPR_SIZE[1], ~SPR_SIZE[0]}, SPR_SIZE[2]};


// ROM ADDRESS GEN 2

FDN K141(clk_6M, ~P133 ? AE145 : ~K141_XQ, RES_SYNC, , K141_XQ);
FDN G143(clk_6M, ~P131 ? AE145 : ~G143_XQ, RES_SYNC, , G143_XQ);
FDN F94(clk_6M, ~P137 ? AE145 : ~F94_XQ, RES_SYNC, , F94_XQ);
FDN F145(clk_6M, ~P135 ? AE145 : ~F145_XQ, RES_SYNC, , F145_XQ);

FDN J141(clk_6M, ~P133 ? AE106 : ~J141_XQ, RES_SYNC, , J141_XQ);
FDN G128(clk_6M, ~P131 ? AE106 : ~G128_XQ, RES_SYNC, , G128_XQ);
FDN F108(clk_6M, ~P137 ? AH27_S[2] : ~F108_XQ, RES_SYNC, , F108_XQ);	// TODO: Check AH27_S[2], is it AE106 ?
FDN F132(clk_6M, ~P135 ? AE106 : ~F132_XQ, RES_SYNC, , F132_XQ);

FDN J94(clk_6M, ~P133 ? AE102 : ~J94_XQ, RES_SYNC, , J94_XQ);
FDN G121(clk_6M, ~P131 ? AE102 : ~G121_XQ, RES_SYNC, , G121_XQ);
FDN F101(clk_6M, ~P137 ? AH27_S[1] : ~F101_XQ, RES_SYNC, , F101_XQ);	// TODO: Check AH27_S[1], is it AE102 ?
FDN F125(clk_6M, ~P135 ? AE102 : ~F125_XQ, RES_SYNC, , F125_XQ);

FDN N126(clk_12M, ~LACH ? ~H133_OUT : ~N126_XQ, RES_SYNC, N126_Q, N126_XQ);

// Half KREGs
FDN M145(clk_12M, ~LACH ? ~H145_OUT : ~M145_XQ, RES_SYNC, M145_Q, M145_XQ);
FDN M132(clk_12M, ~LACH ? ~H113_OUT : ~M132_XQ, RES_SYNC, M132_Q, M132_XQ);


FDN AH273(clk_12M, ~LACH ? ~RAM_A_dout[0] : ~AH273_XQ, AB1, AH273_Q, AH273_XQ);
assign HP[8] = ~AH273_Q;
FDN AG267(clk_12M, ~LACH ? ~RAM_A_dout[1] : ~AG267_XQ, AB1, AG267_Q, AG267_XQ);
assign SPR_FLIP = ~AG267_Q;

wire C131_Q;
wire [3:0] Z251_Q;
FDR Z251(clk_12M, {SPR_HFLIP ^ AB233_Q[0], M145_Q, M132_Q, N126_Q}, RES_SYNC, Z251_Q);
assign D121 = ~|{C131_Q, &{PE, AB84, AB[10], ~OBCS}};

wire [3:0] T227_OUT;
LT4 T227(D121, AB[5:2], T227_OUT);
assign CA[3:0] = ~ROM_READ ? T227_OUT : Z251_Q;

wire [3:0] J115_OUT;
DE2 J115(L101_Q, L126_Q, J115_OUT);

// TODO: These are all 4-to-1 muxes
U24 H133({F94_XQ, J115_OUT[0]}, {G143_XQ, J115_OUT[1]}, {L119_Q, J115_OUT[2]}, {J115_OUT[3], F145_XQ}, H133_OUT);	// To check L119_Q
U24 H113({J94_XQ, J115_OUT[0]}, {G121_XQ, J115_OUT[1]}, {F101_XQ, J115_OUT[2]}, {F125_XQ, J115_OUT[3]}, H113_OUT);
U24 H145({J141_XQ, J115_OUT[0]}, {G128_XQ, J115_OUT[1]}, {F108_XQ, J115_OUT[2]}, {F132_XQ, J115_OUT[3]}, H145_OUT);
U24 H95({K94_Q[0], J115_OUT[0]}, {G95_Q[0], J115_OUT[1]}, {D124_Q[0], J115_OUT[2]}, {E95_Q[0], J115_OUT[3]}, H95_OUT);
U24 K132({K94_Q[1], J115_OUT[0]}, {G95_Q[1], J115_OUT[1]}, {D124_Q[1], J115_OUT[2]}, {E95_Q[1], J115_OUT[3]}, K132_OUT);
U24 H127({K94_Q[2], J115_OUT[0]}, {G95_Q[2], J115_OUT[1]}, {D124_Q[2], J115_OUT[2]}, {E95_Q[2], J115_OUT[3]}, H127_OUT);
U24 H121({K94_Q[3], J115_OUT[0]}, {G95_Q[3], J115_OUT[1]}, {D124_Q[3], J115_OUT[2]}, {E95_Q[3], J115_OUT[3]}, H121_OUT);


wire [3:0] N94_Q;
FDR N94(clk_12M, ~LACH ? {~H121_OUT, ~H127_OUT, ~K132_OUT, ~H95_OUT} : N94_Q, RES_SYNC, N94_Q);

assign AC277 = OHF ^ AB233_Q[1];
T5A AC256(SPR_CODE[0], AC277, AC277, AC277, ~SPR_SIZE[0], ~SPR_W64P, AC256_OUT);
assign AC273 = OHF ^ AB233_Q[2];
T5A AC268(SPR_CODE[2], ~AG214_Q, AC273, AC273, ~SPR_SIZE[0], ~SPR_W64P, AC268_OUT);
wire [3:0] Y255_Q;
FDR Y255(clk_12M, {~AC268_OUT, N94_Q[2], ~AC256_OUT, N94_Q[3]}, RES_SYNC, Y255_Q);

T5A AC196(SPR_CODE[4], SPR_CODE[4], SPR_HFLIP ^ AB233_Q[3], SPR_CODE[4], ~SPR_SIZE[0], ~SPR_W64P, AC196_OUT);


FDR AD255(clk_12M, SPR_CODE[10:7], RES_SYNC, AD255_Q);
FDR Y229(clk_12M, {SPR_CODE[6], N94_Q[0], ~AC196_OUT, N94_Q[1]}, RES_SYNC, Y229_Q);

assign CA_RENDER[15:4] = {AD255_Q, Y229_Q, Y255_Q};

wire [7:4] CA_CPU;
LT4 T208(D121, AB[9:6], CA_CPU, );

assign CA[17:4] = ROM_READ ? {REG3[1:0], REG2[7:0], CA_CPU} : CA_RENDER;


wire W101_CO;
FDO V110(VBLANK, P94_Q, RES_SYNC, V110_Q, );
assign V89 = ~VBLANK | V110_Q;
FDO V82(clk_6M, V89, RES_SYNC, , V82_XQ);
assign V101 = ~&{(W101_CO | ~VBLANK_SYNC), (V89 | V82_XQ)};
assign V117 = ~&{VBLANK & V101};
FDN V103(clk_6M, V117, RES_SYNC, , VBLANK_SYNC);


// REGISTERS

assign nREG0_W = |{~(AB[2:0] == 3'd0), A152, OBCS, WRP};
assign nREG0_R = |{OBCS, RDEN, ~(AB[2:0] == 3'd0), A152};
assign nREG2_W = |{~(AB[2:0] == 3'd2), A152, OBCS, WRP};
assign nREG3_W = |{~(AB[2:0] == 3'd3), A152, OBCS, WRP};
assign nREG4_W = |{~(AB[2:0] == 3'd4), A152, OBCS, WRP};

// Reg 0
wire [3:0] D94_Q;
FDR D94(nREG0_W, {DB_IN[2:0], DB_IN[5]}, RES_SYNC, D94_Q);
assign ROM_READ = D94_Q[0];
FDO C131(nREG0_W, DB_IN[6], RES_SYNC, C131_Q);
FDO P94(nREG0_W, DB_IN[4], RES_SYNC, P94_Q, );
FDO P103(nREG0_W, DB_IN[3], RES_SYNC, FLIP_SCREEN, );

// Reg 2
FDR V229(nREG2_W, DB_IN[3:0], RES_SYNC, REG2[3:0]);
FDR W229(nREG2_W, DB_IN[7:4], RES_SYNC, REG2[7:4]);

// Reg 3
FDR V255(nREG3_W, DB_IN[3:0], RES_SYNC, REG3[3:0]);
FDR W255(nREG3_W, DB_IN[7:4], RES_SYNC, REG3[7:4]);

// Reg 4
FDO W194(nREG4_W, DB_IN[0], RES_SYNC, REG4[0], );
FDO V214(nREG4_W, DB_IN[1], RES_SYNC, REG4[1], );

assign OOE = Z139 ? NRD : 1'b0;


// VRAM I/O

FDO A94(ROW_RAW[2], ~A94_Q, RES_SYNC, A94_Q, );
FDO B108(A94_Q, ~B108_Q, RES_SYNC, B108_Q, );

// Interrupt flags
FDO C101(VBLANK, 1'b1, D94_Q[1], , IRQ);
FDO C121(ROW_RAW[0], 1'b1, D94_Q[2], , FIRQ);
FDO B101(B108_Q, 1'b1, D94_Q[3], , NMI);

// Sprite tile width counter
T5A AC232(AB233_Q[0], &{AB233_Q[1:0]}, &{AB233_Q[3:0]}, &{AB233_Q[2:0]}, ~SPR_SIZE[0], ~SPR_W64P, AC232_X);
assign HEND = ~AC232_X;
assign X192 = ~|{~PXH[0], HEND};
C43 AB233(clk_12M, 4'b0000, AB122, ~clk_6M, X192, RES_SYNC, AB233_Q, );		// clk_6M must be delayed !


// Unknown counters
C43 R50(clk_6M, 4'b0100, L112_Q, N121, 1'b1, RES_SYNC, R50_Q, R50_CO);
C43 S28(clk_6M, 4'b0000, L112_Q, N121, R50_CO, RES_SYNC, S28_Q, );

// Weird rotator with preset thing
FDN R29(clk_6M, ~P133 ? ~R50_Q[2] : ~R36_XQ, RES_SYNC, , R29_XQ);
FDN R22(clk_6M, ~P133 ? ~R50_Q[1] : ~R29_XQ, RES_SYNC, , R22_XQ);
FDN R36(clk_6M, ~P133 ? ~R50_Q[0] : ~R22_XQ, RES_SYNC, , R36_XQ);

FDN R8(clk_6M, ~P135 ? ~R50_Q[0] : ~R8_XQ, RES_SYNC, , R8_XQ);
FDN R142(clk_6M, ~P131 ? ~R50_Q[0] : ~R142_XQ, RES_SYNC, , R142_XQ);
FDN R108(clk_6M, ~P137 ? ~R50_Q[0] : ~R108_XQ, RES_SYNC, , R108_XQ);


// Unknown counters
wire C94_XQ;
assign C130 = ~&{L119_Q, ~&{C130, HRST_delay[1]}};	// Combinational loop !
assign E141 = ~&{C94_XQ, C130};
assign N121 = &{~PXH[0], E141};
C43 W49(clk_6M, 4'b0000, HRST, N121, ~W1_Q[3], RES_SYNC, W49_Q, W49_COUT);
C43 W1(clk_6M, 4'b0000, HRST, N121, W49_COUT, RES_SYNC, W1_Q, );

assign P1 = ~&{E141, ~PXH[0]};	// And a bunch of inverters


// VRAM copy counter - Sprite #
wire W101_QD;
assign RAM_DATA_WR = W101_QD;
assign Z95 = ~&{RAM_DATA_WR, ~SPR_ACTIVE};	// SPR_ACTIVE must be delayed !
assign Z81 = ~PXH[0] & ~&{Z95, ~&{ATTR_A[2:0]}};
C43 X1(clk_6M, 4'b0000, VBLANK_SYNC, ~PXH[0], Z81, RES_SYNC, ATTR_A[6:3], X1_CO);
C43 W101(clk_6M, 4'b0000, VBLANK_SYNC, ~PXH[0], X1_CO, VBLANK_SYNC, {W101_QD, ATTR_A[9:7]}, W101_CO);

// VRAM copy counter - Attr #
wire [3:0] Z9_Q;
C43 Z9(clk_6M, 4'b0000, VBLANK_SYNC & Z95, ~PXH[0], ~PXH[0], RES_SYNC, Z9_Q, );
assign ATTR_A[2:0] = Z9_Q[2:0];

// Select between CPU and render access to sprite RAM
assign OA_out = Z139 ? AB[9:0] : ATTR_A;


assign AH189 = ~|{AF1_Q[3:2]};
assign AH187 = ~|{AF27_Q[0], AF1_Q[3:2]};
assign AS179 = ~&{|{AU163_Q[3:2]}, AU163_Q[1]};	// To check
assign AJ180 = ~AS179;

// Triggers on some values of AU163_Q
assign AT180 = (^{AU163_Q[3:2]} | ~AU163_Q[1]) & (~&{~AU163_Q[1], AU163_Q[2]});

// Half KREGs
FDN R101(clk_6M, ~P131 ? ~R50_Q[2] : R101_XQ, RES_SYNC, , R101_XQ);
FDN R43(clk_6M, ~P131 ? ~R50_Q[1] : R43_XQ, RES_SYNC, , R43_XQ);

FDN R15(clk_6M, ~P135 ? ~R50_Q[2] : R15_XQ, RES_SYNC, , R15_XQ);
FDN R1(clk_6M, ~P135 ? ~R50_Q[1] : R1_XQ, RES_SYNC, , R1_XQ);

FDN S92(clk_6M, ~P137 ? ~R50_Q[2] : S92_XQ, RES_SYNC, , S92_XQ);
FDN S85(clk_6M, ~P137 ? ~R50_Q[1] : S85_XQ, RES_SYNC, , S85_XQ);


// MISC

assign AE110 = SPR_VFLIP_LAT ^ AF27_Q[1];
assign AE106 = SPR_VFLIP_LAT ^ AF27_Q[2];
assign AE102 = SPR_VFLIP_LAT ^ AF27_Q[3];
assign AE145 = SPR_VFLIP_LAT ^ AN221_Q[0];

assign AH193 = SPR_VFLIP_LAT ^ AF27_Q[0];
T5A AP183(AU163_Q[0], AH193, AH193, AH193, AT180, AS179, AP183_OUT);

assign AH197 = SPR_VFLIP_LAT ^ AF1_Q[3];
T5A AP171(AN221_Q[3], AN221_Q[3], AH197, AH197, AT180, AS179, AP171_OUT);

assign AK177 = SPR_VFLIP_LAT ^ AF1_Q[2];
T5A AP166(AN221_Q[2], AN221_Q[2], AK177, AN221_Q[2], AT180, AS179, AP166_OUT);

T5A AP176(AH187, AH189, 1'b1, ~AF1_Q[2], AT180, AS179, AP176_OUT);
assign AD134 = ~|{AF1_Q[1:0], AN195_Q[3], AP176_OUT};


// TODO: Document this
wire M116, J148, B94_XQ, B115_XQ, B122_XQ;
assign B141 = ~|{&{~M116, J148, B115_XQ}, &{~M116, ~J148, B94_XQ}, &{~J148, M116, 1'b1}};
FDN B94(clk_6M, B141, RES_SYNC, , B94_XQ);
assign B129 = ~|{&{~M116, J148, B122_XQ}, &{~M116, ~J148, B115_XQ}, &{~J148, M116, B94_XQ}};
FDN B115(clk_6M, B129, RES_SYNC, , B115_XQ);
assign C115 = ~|{&{~M116, ~J148, C94_XQ}, &{~J148, M116, B122_XQ}};
FDN C94(clk_6M, C115, RES_SYNC, , C94_XQ);
assign C108 = ~|{&{~M116, J148, C94_XQ}, &{~M116, ~J148, B122_XQ}, &{~J148, M116, 1'b1}};
FDN B122(clk_6M, C108, RES_SYNC, , B122_XQ);

FDO J130(clk_6M, L119_Q & ~&{~J121, J120}, RES_SYNC, J130_Q);
FDO J108(clk_6M, HEND & P1H, RES_SYNC, J108_Q);
FDO J101(clk_6M, J108_Q, RES_SYNC, J101_XQ);

assign E138 = |{C94_XQ, B122_XQ, B115_XQ, B94_XQ};
assign J120 = ~&{J130_Q, J101_XQ};

assign J121 = &{P1H, E138, ~VBLANK_SYNC, J120};
assign AB122 = ~J120 & LACH;
assign J150 = J121 & P1H;
assign M118 = L126_Q | J121;
assign J148 = J150 | L112_XQ;

C11 L126(clk_6M, 1'b0, L112_XQ, RES_SYNC, J121, L126_Q, );
C11 L101(clk_6M, 1'b0, L112_XQ, RES_SYNC, M118, L101_Q, );

C11 P110(clk_6M, 1'b0, L112_XQ, RES_SYNC, P38_Q & P121, P110_Q, );
C11 P38(clk_6M, 1'b0, L112_XQ, RES_SYNC, P121, P38_Q, );

wire [3:0] P126_OUT;
DE2 P126(P110_Q, P38_Q, P126_OUT);
assign P121 = &{~PXH[0], AD134, ~VBLANK_SYNC, ~C94_XQ};
assign M116 = P121 | L112_XQ;
assign P133 = ~P121 | P126_OUT[0];
assign P131 = ~P121 | P126_OUT[1];
assign P137 = ~P121 | P126_OUT[2];
assign P135 = ~P121 | P126_OUT[3];



// ATTR LATCHES

// Sprite Y position check
wire [7:0] SPR_ATTR_Y;
KREG AK221(clk_6M, RES_SYNC, RAM_B_dout[7:4], ~P1, SPR_ATTR_Y[7:4]);
KREG AK195(clk_6M, RES_SYNC, RAM_B_dout[3:0], ~P1, SPR_ATTR_Y[3:0]);

wire [7:0] ROW_REG;
KREG AM221(clk_6M, RES_SYNC, ROW[7:4], ~HRST_delay[1], ROW_REG[7:4]);
KREG AH221(clk_6M, RES_SYNC, ROW[3:0], ~HRST_delay[1], ROW_REG[3:0]);

wire [4:0] AJ191_S;
wire [4:0] AL191_S;
A4H AL191(ROW_REG[7:4], SPR_ATTR_Y[7:4], AJ191_S[4], AL191_S[3:0], AL191_S[4]);
A4H AJ191(ROW_REG[3:0], SPR_ATTR_Y[3:0], ~FLIP_SCREEN, AJ191_S[3:0], AJ191_S[4]);

KREG AH1(clk_6M, RES_SYNC, AL191_S[3:0], ~P1, SPR_YMATCH[7:4]);
KREG AW163(clk_6M, RES_SYNC, AJ191_S[3:0], ~P1, SPR_YMATCH[3:0]);

// Sprite X zoom and accumulator
reg [5:0] SPR_ATTR_ZX;

// Half KREGs
/*FDN AE28(clk_12M, ~LACH ? ~RAM_A_dout[7] : AE28_Q, AB1, AE28_Q, );
FDN AE21(clk_12M, ~LACH ? ~RAM_A_dout[6] : AE21_Q, AB1, AE21_Q, );
FDN AE8(clk_12M, ~LACH ? ~RAM_A_dout[5] : AE8_Q, AB1, AE8_Q, );
FDN AE1(clk_12M, ~LACH ? ~RAM_A_dout[4] : AE1_Q, AB1, AE1_Q, );
FDN AF267(clk_12M, ~LACH ? ~RAM_A_dout[3] : AF267_Q, AB1, AF267_Q, );
FDN AG274(clk_12M, ~LACH ? ~RAM_A_dout[2] : AG274_Q, AB1, AG274_Q, );*/
always @(posedge clk_12M or negedge RES_SYNC) begin
	if (!RES_SYNC) begin
		SPR_ATTR_ZX <= 6'h00;
	end else begin
		if (!LACH)
			SPR_ATTR_ZX <= RAM_A_dout[7:2];
	end
end

// Accumulator
reg [6:0] SPR_ZX_ACC;
/*wire [6:0] ADD_OUT;
wire [5:0] ADD_A;
wire [5:0] ADD_B;
wire [3:0] AD1_Q;
FDO AC128(clk_12M, ADD_OUT[0], AB1, AC128_Q, );
FDO AC141(clk_12M, ADD_OUT[1], AB1, AC141_Q, );
FDO AC121(clk_12M, ADD_OUT[2], AB1, AC121_Q, );
FDR AD1(clk_12M, {ADD_OUT[3], ADD_OUT[4], ADD_OUT[5], ADD_OUT[6]}, AB1, AD1_Q);*/
wire M94_XQ;
always @(posedge clk_12M or negedge RES_SYNC) begin
	if (!RES_SYNC) begin
		SPR_ZX_ACC <= 7'h00;
	end else begin
		SPR_ZX_ACC <= M94_XQ ? ({1'b0, SPR_ATTR_ZX} + SPR_ZX_ACC) : {1'b0, SPR_ATTR_ZX};
	end
end
assign CARY = SPR_ZX_ACC[6];


// RAM REGISTERS

// Sprite Y zoom
reg [7:0] SPR_ATTR_ZY;
/*KREG AG53(clk_6M, P1, RES_SYNC, {RAM_D_dout[4], RAM_D_dout[5], RAM_D_dout[6], RAM_D_dout[7]}, AG53_Q);	// TODO
KREG AF53(clk_6M, P1, RES_SYNC, {RAM_D_dout[0], RAM_D_dout[1], RAM_D_dout[2], RAM_D_dout[3]}, AF53_Q);	// TODO
KREG AG27(clk_6M, P1, RES_SYNC, {AF53_Q[3] ^ AL191_CO, AF53_Q[2:0]}, AG27_Q);
KREG AG1(clk_6M, P1, RES_SYNC, AG53_Q, AG1_Q);*/
always @(posedge clk_6M or negedge RES_SYNC) begin
	if (!RES_SYNC) begin
		SPR_ATTR_ZY <= 8'h00;
		
		SPR_Y8 <= 1'b0;
		SPR_VFLIP <= 1'b0;
		SPR_ATTR_ZY_DELAY <= 6'h00;
		
		AM195_Q <= 4'h0;
		AN195_Q <= 4'h0;
	end else begin
		if (!P1) begin
			SPR_ATTR_ZY <= RAM_D_dout;
			
			SPR_Y8 <= SPR_ATTR_ZY[0] ^ AL191_S[4];
			SPR_VFLIP <= SPR_ATTR_ZY[1];
			SPR_ATTR_ZY_DELAY <= SPR_ATTR_ZY[7:2];
			
			AM195_Q <= {W1_Q[3], VBLANK_SYNC, RAM_F_dout[6:5]};	// Part of sprite size attribute
			AN195_Q <= {~&{SPR_Y8, AN195_Q[2]}, ~&{AM195_Q[3:2]}, AM195_Q[1:0]};
		end
	end
end

// Sprite tile code
wire [3:0] AX163_Q;
wire [3:0] AV163_Q;
// TODO: Are these clk_12M or clk_6M ?
KREG AX163(clk_6M, RES_SYNC, {RAM_F_dout[7], RAM_E_dout[1], RAM_E_dout[3], RAM_E_dout[5]}, ~P1, AX163_Q);	// TODO: Check
KREG AV163(clk_6M, RES_SYNC, AX163_Q, ~P1, AV163_Q);
assign SPR_CODE[5] = AV163_Q[0];
assign SPR_CODE[3] = AV163_Q[1];
assign SPR_CODE[1] = AV163_Q[2];
assign SPR_SIZE2_DELAY = AV163_Q[3];

// Half KREGs - TODO: Are these clk_12M or clk_6M ?
FDN AF167(clk_12M, ~LACH ? ~RAM_E_dout[6] : AF167_Q, RES_SYNC, AF167_Q, );
assign SPR_CODE[6] = ~AF167_Q;
FDN AF174(clk_12M, ~LACH ? ~RAM_E_dout[7] : AF174_Q, RES_SYNC, AF174_Q, );
assign SPR_CODE[7] = ~AF174_Q;
FDN AG228(clk_12M, ~LACH ? ~RAM_E_dout[0] : AG228_Q, RES_SYNC, AG228_Q, );
assign SPR_CODE[0] = ~AG228_Q;
FDN AG214(clk_12M, ~LACH ? ~RAM_E_dout[2] : AG214_Q, RES_SYNC, AG214_Q, );
assign SPR_CODE[2] = ~AG214_Q;

FDN AE234(clk_12M, ~LACH ? ~RAM_E_dout[4] : AE234_Q, RES_SYNC, AE234_Q, );
assign SPR_CODE[4] = ~AE234_Q;

// Sprite X position - Passed directly to k051937
reg [7:0] SPR_ATTR_X;
always @(posedge clk_12M or negedge RES_SYNC) begin
	if (!RES_SYNC) begin
		SPR_ATTR_X <= 8'h00;
	end else begin
		if (!LACH)
			SPR_ATTR_X <= RAM_G_dout;
	end
end
assign HP[7:0] = SPR_ATTR_X;


// SEQUENCING

assign L141 = clk_6M & J121;	// TODO: clk_6M must be delayed !
// This is a 3-stage delay
FDO M108(clk_12M, L141, RES_SYNC, LACH, );
FDO M101(clk_12M, M108_Q, RES_SYNC, M101_Q, );
FDO M94(clk_12M, M101_Q, RES_SYNC, , M94_XQ);

// RAM sequencing stuff
assign Y70 = ~&{~VBLANK_SYNC, ~&{~VBLANK_SYNC, ~AA141_Q, ~L101_Q}};
assign Y72 = ~Y70;
assign Y141 = ~&{~VBLANK_SYNC, ~&{~VBLANK_SYNC, ~AA141_Q, L101_Q}};
assign X148 = ~Y141;
assign Y81 = ~&{~&{RAM_DATA_WR, VBLANK_SYNC}, ~&{~VBLANK_SYNC, AA141_Q}, ~&{~VBLANK_SYNC, ~AA141_Q, L126_Q}};
assign Y73 = ~Y81;

endmodule
