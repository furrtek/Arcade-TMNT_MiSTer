// TMNT arcade core
// Simulation blind schematic copy version
// Sean Gonsalves 2022
`timescale 1ns/100ps

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

assign T1 = 1'b0;

wire [9:0] ATTR_A;
wire [6:0] SPR_PRIO;

wire [6:0] RAM_addr;
wire [6:0] RAM_addr_back;
wire [6:0] RAM_addr_front;
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
wire [2:0] SPR_SIZE;
wire [12:0] SPR_CODE;

wire [3:0] AF53_Q;
wire [3:0] AG27_Q;

wire [3:0] R50_Q;
wire [3:0] S28_Q;

wire [3:0] AG53_Q;
wire [3:0] AG1_Q;
wire [3:0] AM195_Q;
wire [3:0] AN195_Q;
wire [3:0] Y229_Q;
wire [3:0] AD255_Q;
wire [4:0] AB233_Q;

wire [7:0] REG2;
wire [7:0] REG3;
wire L126, L112_XQ;

wire [4:0] R207_Q;
wire [4:0] P233_Q;

// TEST MODE

wire [7:0] TEST_AB;
assign TEST_AB = 8'b10000000;

wire [2:0] TEST_DB;
assign TEST_DB = 3'b001;

// INTERNAL RAM

wire Z95;
wire AB98;
wire VBLANK_SYNC;
assign RAM_A_WE = &{AB98, VBLANK_SYNC, Z95, ATTR_A[2:0] == 3'b001};
assign RAM_B_WE = &{AB98, VBLANK_SYNC, Z95, ATTR_A[2:0] == 3'b010};
assign RAM_C_WE = &{AB98, VBLANK_SYNC, Z95, ATTR_A[2:0] == 3'b011};
assign RAM_D_WE = &{AB98, VBLANK_SYNC, Z95, ATTR_A[2:0] == 3'b100};
assign RAM_E_WE = &{AB98, VBLANK_SYNC, Z95, ATTR_A[2:0] == 3'b101};
assign RAM_F_WE = &{AB98, VBLANK_SYNC, Z95, ATTR_A[2:0] == 3'b110};
assign RAM_G_WE = &{AB98, VBLANK_SYNC, Z95, ATTR_A[2:0] == 3'b111};

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
assign RAM_addr = X148 ? RAM_addr_back : RAM_addr_front;

wire AB84;
reg [7:0] RAM_din_latch;
always @(posedge AB84)
	RAM_din_latch <= OD_in;

assign RAM_din = (RAM_DATA_WR | 1'b0) ? RAM_din_latch : 8'h00;	// Test mode

ram_sim #(8, 7, "") RAMA(RAM_addr, RAM_A_WE, RAM_din, RAM_A_dout);
ram_sim #(8, 7, "") RAMB(RAM_addr, RAM_B_WE, RAM_din, RAM_B_dout);
ram_sim #(8, 7, "") RAMC(RAM_addr, RAM_C_WE, RAM_din, RAM_C_dout);
ram_sim #(8, 7, "") RAMD(RAM_addr, RAM_D_WE, RAM_din, RAM_D_dout);
ram_sim #(8, 7, "") RAME(RAM_addr, RAM_E_WE, RAM_din, RAM_E_dout);
ram_sim #(8, 7, "") RAMF(RAM_addr, RAM_F_WE, RAM_din, RAM_F_dout);
ram_sim #(8, 7, "") RAMG(RAM_addr, RAM_G_WE, RAM_din, RAM_G_dout);


// ADDERS
// A4H B inputs reversed ?
// A2N A inputs reversed ?

assign AN143 = AG27_Q[0] & SPR_YMATCH[0];
wire [4:0] AX101_S;
wire [2:0] AR101_S;
A4H AX101(SPR_YMATCH[0] ? AG1_Q : 4'b0000, SPR_YMATCH[1] ? {AG27_Q[0], AG1_Q[3:1]} : 4'b0000, SPR_YMATCH[1] & AG27_Q[1] & AN143, AX101_S[3:0], AX101_S[4]);
A2N AR101({SPR_YMATCH[1] & AG1_Q[0], SPR_YMATCH[1]}, {SPR_YMATCH[0], 1'b0}, AX101_S[4], AR101_S[1:0], AR101_S[2]);

wire [4:0] AW101_S;
wire [2:0] AP101_S;
A4H AW101({AR101_S[0], AX101_S[3:1]}, SPR_YMATCH[2] ? {AG27_Q[0], AG1_Q[3:1]} : 4'b0000, SPR_YMATCH[2] & AG27_Q[1] & AX101_S[0], AW101_S[3:0], AW101_S[4]);
A2N AP101({SPR_YMATCH[2] & AG1_Q[0], SPR_YMATCH[2]}, AR101_S[2:1], AW101_S[4], AP101_S[1:0], AP101_S[2]);

wire [4:0] AV101_S;
wire [2:0] AP121_S;
A4H AV101({AP101_S[0], AW101_S[3:1]}, SPR_YMATCH[3] ? {AG27_Q[0], AG1_Q[3:1]} : 4'b0000, SPR_YMATCH[3] & AG27_Q[1] & AW101_S[0], AV101_S[3:0], AV101_S[4]);
A2N AP121({SPR_YMATCH[3] & AG1_Q[0], SPR_YMATCH[3]}, AP101_S[2:1], AV101_S[4], AP121_S[1:0], AP121_S[2]);

wire [4:0] AU101_S;
wire [2:0] AN101_S;
A4H AU101({AP121_S[0], AV101_S[3:1]}, SPR_YMATCH[4] ? {AG27_Q[0], AG1_Q[3:1]} : 4'b0000, SPR_YMATCH[4] & AG27_Q[1] & AV101_S[0], AU101_S[3:0], AU101_S[4]);
A2N AN101({SPR_YMATCH[4] & AG1_Q[0], SPR_YMATCH[4]}, AP121_S[2:1], AU101_S[4], AN101_S[1:0], AN101_S[2]);

wire [4:0] AM101_S;
wire [2:0] AL101_S;
A4H AM101({AN101_S[0], AU101_S[3:1]}, SPR_YMATCH[5] ? {AG27_Q[0], AG1_Q[3:1]} : 4'b0000, SPR_YMATCH[5] & AG27_Q[1] & AU101_S[0], AM101_S[3:0], AM101_S[4]);
A2N AL101({SPR_YMATCH[5] & AG1_Q[0], SPR_YMATCH[5]}, AN101_S[2:1], AM101_S[4], AL101_S[1:0], AL101_S[2]);

wire [4:0] AK101_S;
wire [2:0] AJ101_S;
A4H AK101({AL101_S[0], AM101_S[3:1]}, SPR_YMATCH[6] ? {AG27_Q[0], AG1_Q[3:1]} : 4'b0000, SPR_YMATCH[6] & AG27_Q[1] & AM101_S[0], AK101_S[3:0], AK101_S[4]);
A2N AJ101({SPR_YMATCH[6] & AG1_Q[0], SPR_YMATCH[6]}, AL101_S[2:1], AK101_S[4], AJ101_S[1:0], AJ101_S[2]);
assign AL147 = (SPR_YMATCH[1] & AG27_Q[1]) ^ AM101_S[0];	// Is it SPR_YMATCH[7] ?

wire [4:0] AH27_S;
wire [2:0] AH81_S;
A4H AH27({AJ101_S[0], AK101_S[3:1]}, SPR_YMATCH[7] ? {AG27_Q[0], AG1_Q[3:1]} : 4'b0000, SPR_YMATCH[7] & AG27_Q[1] & AK101_S[0], AH27_S[3:0], AH27_S[4]);
A2N AH81({SPR_YMATCH[7] & AG1_Q[0], SPR_YMATCH[7]}, AJ101_S[2:1], AH27_S[4], AH81_S[1:0], AH81_S[2]);
assign AJ141 = (SPR_YMATCH[7] & AG27_Q[1]) ^ AK101_S[0];

wire [3:0] AF27_Q;
KREG AF27(clk_6M, AB1, {AH27_S[2:0], AJ141}, RES_SYNC, AF27_Q);
wire [3:0] AF1_Q;
KREG AF1(clk_6M, AH218, {AH81_COUT, AH81_S[1:0], AH27_S[3]}, RES_SYNC, AF1_Q);

// DELAYS / LATCHES

KREG AN221(clk_6M, AH218, {SPR_CODE[3], SPR_CODE[5], SPR_VFLIP, AL147}, RES_SYNC, AN221_Q);	// TO CHECK
KREG V27(clk_6M, RES_SYNC, {R50_Q[3], S28_Q[0], AB3, S28_Q[2]}, RES_SYNC, V27_Q);	// TO CHECK
KREG S2(clk_6M, R150, {R50_Q[3], S28_Q[0], S28_Q[1], S28_Q[2]}, RES_SYNC, S2_Q);	// TO CHECK
KREG V53(clk_6M, T109, {R50_Q[3], S28_Q[0], S28_Q[1], S28_Q[2]}, RES_SYNC, V53_Q);
KREG V1(clk_6M, T111, {R50_Q[3], S28_Q[0], AB3, S28_Q[2]}, RES_SYNC, V1_Q);	// TO CHECK
KREG AU163(clk_6M, AH218, {AN195_Q[1:0], SPR_SIZE2_DELAY, SPR_CODE[1]}, RES_SYNC, AU163_Q);

wire [3:0] Y2_Q;
KREG Y2(AB84, RES_SYNC, {OD_in[4], OD_in[5], OD_in[6], OD_in[7]}, RES_SYNC, Y2_Q);	// AB84 ? Not clk_6M ?
assign SPR_ACTIVE = Y2_Q[0];
assign SPR_PRIO[6] = Y2_Q[1];
assign SPR_PRIO[5] = Y2_Q[2];
assign SPR_PRIO[4] = Y2_Q[3];

wire [3:0] Y28_Q;
KREG Y28(clk_6M, AH218, {OD_in[0], OD_in[1], OD_in[2], OD_in[3]}, RES_SYNC, Y28_Q);
assign SPR_PRIO[3] = Y28_Q[0];
assign SPR_PRIO[2] = Y28_Q[1];
assign SPR_PRIO[1] = Y28_Q[2];
assign SPR_PRIO[0] = Y28_Q[3];

// ROOT SHEET 2

wire VBLANK, V143, L149, HRST;
reg [7:0] RST_DELAY;
always @(posedge VBLANK or negedge V143) begin
	if (!V143)
		RST_DELAY <= 8'b00000000;
	else
		RST_DELAY <= {RST_DELAY[6:0], V143};
end
assign RST = RST_DELAY[7];

reg [3:0] HRST_DELAY;
always @(posedge clk_6M or negedge L149) begin
	if (!L149)
		HRST_DELAY <= 4'b0000;
	else
		HRST_DELAY <= {HRST_DELAY[2:0], HRST};
end

wire [1:0] TE;
assign TE = 2'b00;

wire A152, ROM_READ;
assign A124 = ~|{OBCS, RDEN, A152, ~(AB[2:0] == 3'd0)};
assign A126 = ~|{~AB[10], OBCS, RDEN, ROM_READ};
assign DB_DIR = ~|{TE[0], A126, A124};

assign nREG0_W = |{~(AB[2:0] == 3'd0), A152, OBCS, WRP};
assign nREG0_R = |{OBCS, RDEN, ~(AB[2:0] == 3'd0), A152};
assign nREG2_W = |{~(AB[2:0] == 3'd2), A152, OBCS, WRP};
assign nREG3_W = |{~(AB[2:0] == 3'd3), A152, OBCS, WRP};
assign nREG4_W = |{~(AB[2:0] == 3'd4), A152, OBCS, WRP};

assign OREG = A152 | OBCS;

assign A152 = |{AB[10:3]};

assign A133 = ~&{AB[10], ~ROM_READ};
assign OD_DIR = |{A133, OBCS, WREN, TE[0]};
assign PIN_OWR = |{A133, OBCS, WRP};

FDE AA1(clk_24M, 1'b1, nRES, AA1_Q, );	// And lots of buffers
assign RES_SYNC = AA1_Q;

// Clocks
FDN AA70(clk_24M, ~^{AA70_XQ, AA51_XQ}, AA1_Q, clk_6M, AA70_XQ);
FDN AA51(clk_24M, AA51_XQ, AA1_Q, clk_12M, AA51_XQ);

FDO AB91(clk_24M, ~clk_6M, AA1_Q, AB91_Q, AB91_XQ);
FDO AB12(~clk_24M, AB91_Q, AA1_Q, , AB12_XQ);
assign AB19 = AB12_XQ & AB91_XQ;	// Test select - Is this the right order ?

FDN AA141(clk_24M, ~^{AA141_Q, ~&{AA51_XQ, AA70_XQ}}, AA1_Q, AA141_Q, AA141_XQ);
FDE AA128(~clk_24M, AA141_XQ, AA1_Q, , Z143);
assign Z139 = ~Z143;

FDO AA121(clk_24M, AA141_XQ, AA1_Q, AA121_Q, AA121_XQ);
FDO AA85(clk_24M, AA121_Q, AA1_Q, AA85_Q, );
FDE AA41(clk_24M, AA85_Q, AA1_Q, , PQ);
FDO AA63(clk_24M, AA85_Q, AA1_Q, , AA63_Q);	// Q or nQ ?
assign AA96 = ~&{AA63_Q, ~AA141_XQ};
assign AA94 = ~&{NRD, AA63_Q, ~AA141_XQ};
assign AA113 = ~&{NRD, ~AA141_XQ, AA121_XQ};
assign AA92 = NRD | AA121_Q;
wire [3:0] AA11_Q;
FDR AA11(clk_24M, {AA92, AA113, AA94, AA96}, RES_SYNC, AA11_Q);
assign AB98 = ~|{AA11_Q[0], TE[0]};
assign WRP = AA11_Q[1];
assign WREN = AA11_Q[2];
assign RDEN = AA11_Q[3];
FDE AA103(clk_24M, AA121_XQ, AA1_Q, , PE);

// 051937 IF 1

FDN AF274(clk_12M, LACH ? ~RAM_C_dout[0] : AF274_XQ, RES_SYNC, AF274_Q, AF274_XQ);
FDN AF253(clk_12M, LACH ? ~RAM_C_dout[1] : AF253_XQ, RES_SYNC, AF253_Q, AF253_XQ);
FDN AE267(clk_12M, LACH ? ~RAM_C_dout[2] : AE267_XQ, RES_SYNC, AE267_Q, AE267_XQ);
FDN AE274(clk_12M, LACH ? ~RAM_C_dout[3] : AE274_XQ, RES_SYNC, AE274_Q, AE274_XQ);
FDN AE49(clk_12M, LACH ? ~RAM_C_dout[4] : AE49_XQ, RES_SYNC, AE49_Q, AE49_XQ);
FDN AE61(clk_12M, LACH ? ~RAM_C_dout[5] : AE61_XQ, RES_SYNC, AE61_Q, AE61_XQ);
FDN AE68(clk_12M, LACH ? ~RAM_C_dout[6] : AE68_XQ, RES_SYNC, AE68_Q, AE68_XQ);
FDN AE85(clk_12M, LACH ? ~RAM_C_dout[7] : AE85_XQ, RES_SYNC, AE85_Q, AE85_XQ);

wire [3:0] AD227_Q;
FDR AD227(clk_12M, {~AF253_Q, ~AF274_Q, SPR_CODE[12:11]}, AA253, AD227_Q);
wire [3:0] AD201_Q;
FDR AD201(clk_12M, {~AE61_Q, ~AE49_Q, ~AE274_Q, ~AE267_Q}, AA253, AD201_Q);
FDO AB194(clk_12M, ~AE68_Q, AA253, , AB194_XQ);
FDO AA192(clk_12M, ~AE85_Q, AA253, , AA192_XQ);

wire [17:0] CA_RENDER;
assign CA_RENDER = {~AD227_Q[3:2], ~AD255_Q, ~Y229_Q, AA192_XQ, AB194_XQ, ~AD201_Q, ~AD227_Q[1:0]};

FDN AF206(clk_12M, LACH ? ~RAM_F_dout[6] : AF206_XQ, RES_SYNC, AF206_Q, AF206_XQ);
assign SPR_SIZE[1] = ~AF206_Q;
FDN AF213(clk_12M, LACH ? ~RAM_F_dout[7] : AF213_XQ, RES_SYNC, AF213_Q, AF213_XQ);
assign SPR_SIZE[2] = ~AF213_Q;

FDN AF221(clk_12M, LACH ? ~RAM_F_dout[4] : AF221_XQ, RES_SYNC, AF221_Q, AF221_XQ);
assign SPR_CODE[12] = ~AF221_Q;
FDN AF228(clk_12M, LACH ? ~RAM_F_dout[5] : AF228_XQ, RES_SYNC, AF228_Q, AF228_XQ);
assign SPR_SIZE[0] = AF228_Q;

assign AD253 = ~&{|{SPR_SIZE[1:0]}, SPR_SIZE[2]};

// ROOT SHEET 4

wire [3:0] N94_Q;
FDR N94(clk_12M, LACH ? {~H121, ~H127, ~K132, ~H95} : N94_Q, N94_Q, );

assign AC277 = OHF ^ AB233_Q[1];
T5A AC256(AG228_Q, AC277, AC277, AC277, ~SPR_SIZE[0], AD253, AC256_OUT);
assign AC273 = OHF ^ AB233_Q[2];
T5A AC268(AG214_Q, AG214_Q, AC273, AC273, ~SPR_SIZE[0], AD253, AC268_OUT);
wire [3:0] Y255_Q;
FDR Y255(clk_12M, {~AC268_OUT, N94_Q[2], ~AC256_OUT, N94_Q[3]}, AA253, Y255_Q);

T5A AC196(AD151, AD151, SPR_HFLIP ^ AB233_Q[3], AD151, ~SPR_SIZE[0], AD253, AC196_OUT);
FDR Y229(clk_12M, {SPR_CODE[6], N94_Q[0], ~AC196_OUT, N94_Q[1]}, AA253, Y229_Q);
FDR AD255(clk_12M, SPR_CODE[10:7], AA253, AD255_Q);

wire [3:0] T208_P;
LT4 T208(D121, AB[9:6], T208_P, );
assign CA[17:4] = ROM_READ ? {REG3[1:0], REG2[7:0], T208_P} : {CA_RENDER[17:16], AD255_Q, Y229_Q, Y255_Q};

FDN AE234(clk_12M, ~LACH ? ~AE234_XQ : RAM_E_dout[4], RES_SYNC, AE234_Q, AE234_XQ);
assign AD151 = ~AE234_Q;

wire T192_XQ, W101_CO, V91;
FDO P94(nREG0_W, DB_IN[4], P101, P94_Q, );
FDO V110(VBLANK, P94_Q, AB1, V110_Q, );
assign V89 = T192_XQ | V110_Q;
FDO V82(clk_6M, V89, AB1, , V82_XQ);
assign V101 = ~&{(W101_CO | V91), (V89 | V82_XQ)};
assign V117 = ~|{VBLANK & V101, TEST_AB[6]};	// What is the normal level of TEST_AB6 ?
FDN V103(clk_6M, V117, V91, VBLANK_SYNC, );

FDO P103(nREG0_W, DB_IN[3], P101, FLIPSCR, nFLIPSCR);


// ROOT SHEET 5

wire [3:0] D94_Q;
FDR D94(nREG0_W, {DB_IN[2:0], DB_IN[5]}, P101, D94_Q);
assign ROM_READ = D94_Q[0];
FDO C101(VBLANK, 1'b1, D94_Q[1], , IRQ);
FDO C121(P1V_NOFLIP, 1'b1, D94_Q[2], , FIRQ);

FDO A94(P4V_NOFLIP, A94_XQ, P101, A94_Q, A94_XQ);
FDO B108(A94_Q, B108_XQ, P101, B108_Q, B108_XQ);
FDO B101(B108_Q, 1'b1, D94_Q[3], , NMI);

C43 AB233(clk_12M, 4'b0000, AB122, clk_6M, X192, AB219, AB233_Q, );		// clk_6M must be delayed !

FDR V229(REG2_W, DB_IN[3:0], X276, REG2[3:0]);
FDR W229(REG2_W, DB_IN[7:4], X276, REG2[7:4]);

FDR V255(REG3_W, DB_IN[3:0], X276, REG3[3:0]);
FDR W255(REG3_W, DB_IN[7:4], X276, REG3[7:4]);

assign OOE = Z139 ? 1'b1 : NRD;

C43 R50(clk_6M, 4'b0100, L112_Q, N121, 1'b1, AB1, R50_Q, R50_CO);
C43 S28(clk_6M, 4'b0000, L112_Q, N121, R50_CO, AB1, S28_Q, );

wire L119_Q, HRST_DELAY1, C94_XQ, T102;	// TODO: HRST_DELAY1
assign C130 = ~&{L119_Q, ~&{C130, HRST_DELAY1}};	// Combinational loop !
assign E141 = ~&{C94_XQ, C130};
assign N121 = &{TEST_AB[7], T102, E141};
C43 W49(clk_6M, 4'b0000, HRST, N121, ~W1_Q[3], AB1, W49_Q, );
C43 W1(clk_6M, 4'b0000, HRST, N121, W49_COUT, AB1, W1_Q, );

assign P1 = ~&{TEST_AB[7], E141, T102};	// And a bunch of inverters

wire W101_QD;
assign RAM_DATA_WR = W101_QD | TEST_AB[6];
assign Z95 = ~&{RAM_DATA_WR, ~SPR_ACTIVE};	// SPR_ACTIVE must be delayed !
assign Z81 = T102 & ~&{Z95, ~&{ATTR_A[2:0]}};
C43 X1(clk_6M, 4'b0000, VBLANK_SYNC, T102, Z81, AB1, ATTR_A[6:3], X1_CO);
C43 W101(clk_6M, 4'b0000, VBLANK_SYNC, T102, X1_CO, VBLANK_SYNC, {W101_QD, ATTR_A[9:7]}, W101_CO);
C43 Z9(clk_6M, 4'b0000, VBLANK_SYNC & Z95, T102, T102, AB1, ATTR_A, );

FDN R36(clk_6M, R141 ? ~R22_XQ : ~R50_Q[0], T109, , R36_XQ);
FDN R29(clk_6M, R141 ? ~R50_Q[2] : ~R36_XQ, T109, , R29_XQ);
FDN R22(clk_6M, R141 ? ~R50_Q[1] : ~R29_XQ, T109, , R22_XQ);

FDN R8(clk_6M, P141 ? ~R8_XQ : ~R50_Q[0], V141, , R8_XQ);
FDN R142(clk_6M, R149 ? ~R142_XQ : ~R50_Q[0], T111, , R142_XQ);
FDN R108(clk_6M, R115 ? ~R108_XQ : ~R50_Q[0], R150, , R108_XQ);

assign AH189 = ~|{AF1_Q[3:2]};
assign AH187 = ~|{AF27_Q[0], AF1_Q[3:2]};
assign AS179 = ~&{|{AU163_Q[3:2]}, AU163_Q[1]};	// To check
assign AJ180 = ~AS179;

// Triggers on some values of AU163_Q
assign AT180 = (^{AU163_Q[3:2]} | ~AU163_Q[1]) & (~&{~AU163_Q[1], AU163_Q[2]});

// Half KREGs
FDN R101(clk_6M, R149 ? ~R50_Q[2] : R101_XQ, T111, , R101_XQ);
FDN R43(clk_6M, R149 ? ~R50_Q[1] : R43_XQ, T111, , R43_XQ);

FDN R15(clk_6M, P141 ? ~R50_Q[2] : R15_XQ, V141, , R15_XQ);
FDN R1(clk_6M, P141 ? ~R50_Q[1] : R1_XQ, V141, , R1_XQ);

FDN S92(clk_6M, R115 ? ~R50_Q[2] : S92_XQ, R150, , S92_XQ);
FDN S85(clk_6M, R115 ? ~R50_Q[1] : S85_XQ, R150, , S85_XQ);

assign OA_out = Z139 ? ATTR_A : AB[9:0];

// MISC

assign AH193 = AN221_Q[1] ^ AF27_Q[0];
T5A AP183(AU163_Q[0], AH193, AH193, AH193, AT180, AS179, AP183_OUT);	// TODO: AP183_OUT
assign AH197 = AN221_Q[1] ^ AF1_Q[3];
T5A AP171(AN221_Q[3], AN221_Q[3], AH197, AH197, AT180, AS179, AP171_OUT);
T5A AP166(AN221_Q[2], AN221_Q[2], AN221_Q[1] ^ AF1_Q[2], AN221_Q[2], AT180, AS179, AP166_OUT);	// TODO: AP166_OUT
T5A AP176(AH187, AH189, 1'b1, ~AF1_Q[2], AT180, AS179, AP176_OUT);	// TODO: AP176_OUT
assign AD134 = ~&{|{TEST_DB[1], {AF1_Q[1:0], AN195_Q[3]}, AP176_OUT}, TEST_DB[0]};

wire M116, J148, B94_XQ, B115_XQ, B122_XQ;
assign B141 = ~|{&{~M116, J148, B115_XQ}, &{~M116, ~J148, B94_XQ}, &{~J148, M116, 1'b1}};
FDN B94(clk_6M, B141, L149, , B94_XQ);
assign B129 = ~|{&{~M116, J148, B122_XQ}, &{~M116, ~J148, B115_XQ}, &{~J148, M116, B94_XQ}};
FDN B115(clk_6M, B129, L149, , B115_XQ);
assign C115 = ~|{&{~M116, ~J148, C94_XQ}, &{~J148, M116, B122_XQ}};
FDN C94(clk_6M, C115, L149, , C94_XQ);
assign C108 = ~|{&{~M116, J148, C94_XQ}, &{~M116, ~J148, B122_XQ}, &{~J148, M116, 1'b1}};
FDN B122(clk_6M, C108, L149, , B122_XQ);

FDO J130(clk_6M, L119_Q & ~&{~J121, J120}, L149, J130_Q);
FDO J108(clk_6M, HEND & P1H, L149, J108_Q);
FDO J101(clk_6M, J108_Q, L149, J101_XQ);

assign E138 = |{C94_XQ, B122_XQ, B115_XQ, B94_XQ};
assign J120 = ~&{J130_Q, J101_XQ};

assign J121 = &{P1H, E138, V91, J120};
assign AB122 = ~J120 & LACH;
assign J150 = J121 & P1H;
assign M118 = L126 | J121;
assign J148 = J150 | L112_XQ;

// ROOT SHEET 6

wire [3:0] P126_OUT;
DE2 P126(P38, P110, P126_OUT);
assign P121 = &{T102, AD134, V91, ~C94_XQ};
assign M116 = P121 | L112_XQ;
assign P133 = ~P121 | P126_OUT[0];
assign P131 = ~P121 | P126_OUT[1];
assign P137 = ~P121 | P126_OUT[2];
assign P135 = ~P121 | P126_OUT[3];

FDN K141(clk_6M, K150 ? K141_XQ : AE145, K148, , K141_XQ);

wire [3:0] J115_OUT;
DE2 J115(L126, L101, J115_OUT);

FDN F94(clk_6M, F117 ? F94_XQ : AE145, F141, , F94_XQ);
FDN G143(clk_6M, G150 ? G143_XQ : AE145, F152, , G143_XQ);

FDO L94(clk_6M, HRST_DELAY[3], L149, L94_Q, );
FDO L112(clk_6M, L94_Q, L149, L112_Q, L112_XQ);
FDO L119(clk_6M, L112_Q, L119_Q, );

FDN F145(clk_6M, P135 ? F145_XQ : AE145, F143, , F145_XQ);

FDN J94(clk_6M, K150 ? AE102 : J94_XQ, K148, , J94_XQ);
FDN J141(clk_6M, K150 ? AE106 : J141_XQ, K148, , J141_XQ);

FDN G121(clk_6M, G150 ? AE102 : G121_XQ, F152, , G121_XQ);
FDN G128(clk_6M, G150 ? AE106 : G128_XQ, F152, , G128_XQ);

FDN F101(clk_6M, F117 ? AH27_S[1] : F101_XQ, F141, , F101_XQ);
FDN F108(clk_6M, F117 ? AH27_S[2] : F108_XQ, F141, , F108_XQ);

FDN F125(clk_6M, F139 ? AE106 : F125_XQ, F143, , F125_XQ);
FDN F132(clk_6M, F139 ? AE102 : F132_XQ, F143, , F132_XQ);

U24 H133({F94_XQ, J115_OUT[0]}, {G143_XQ, J115_OUT[1]}, {L119_Q, J115_OUT[2]}, {J115_OUT[3], F145_XQ}, H133_OUT);	// To check L119_Q
U24 H113({J94_XQ, J115_OUT[0]}, {G121_XQ, J115_OUT[1]}, {F101_XQ, J115_OUT[2]}, {F125_XQ, J115_OUT[3]}, H113_OUT);
U24 H145({J141_XQ, J115_OUT[0]}, {G128_XQ, J115_OUT[1]}, {F108_XQ, J115_OUT[2]}, {F132_XQ, J115_OUT[3]}, H145_OUT);

FDN N126(clk_12M, ~LACH ? ~H133_OUT : ~N126_XQ, N136, N126_Q, N126_XQ);

// Half KREGs
FDN M145(clk_12M, ~LACH ? ~H145_OUT : ~M145_XQ, N136, M145_Q, M145_XQ);
FDN M132(clk_12M, ~LACH ? ~H113_OUT : ~M132_XQ, N136, M132_Q, M132_XQ);

FDN AH273(clk_12M, ~LACH ? ~RAM_A_dout[0] : ~AH273_XQ, AB1, AH273_Q, AH273_XQ);
assign HP[8] = ~AH273_Q;
FDN AG267(clk_12M, ~LACH ? ~RAM_A_dout[1] : ~AG267_XQ, AB1, AG267_Q, AG267_XQ);
assign SPR_FLIP = ~AG267_Q;

wire [3:0] Z251_Q;
FDR Z251(clk_12M, {SPR_HFLIP ^ AB233_Q[0], M145_Q, M132_Q, N126_Q}, AA253, Z251_Q);
FDO C131(nREG0_W, DB_IN[6], P101, C131_Q);
assign D121 = ~|{C131_Q, &{PE, AB84, AB[10], ~OBCS}};
wire [3:0] T227_OUT;
LT4 T227(D121, AB[5:2], T227_OUT);
assign CA[3:0] = ~ROM_READ ? T227_OUT : Z251_Q;

// ROOT SHEET 7
// ROOT SHEET 8
// ROOT SHEET 9

// H/V COUNTERS

reg [7:0] DELAY_HVIN;
always @(posedge clk_6M or negedge V143) begin
	if (!V143) begin
		DELAY_HVIN <= 8'h00;
	end else begin
		DELAY_HVIN <= {DELAY_HVIN[6:0], ~HVIN};
	end
end

wire P128H, P256H;
assign S199 = TEST_AB[1] | R207_Q[4];
assign T258 = &{S199, P128H, P256H};
assign HRST = ~|{T258, T1};
FDO T121(clk_6M, PE, V143, P1H, T102);
assign X192 = ~|{T102, HEND};
FDO T247(clk_6M, ~|{DELAY_HVIN[7], (T258 ^ P1V_NOFLIP)}, P1V_NOFLIP, );
assign T128 = TEST_AB[0] | P1H;
C43 R207(clk_6M, 4'b0000, HRST, T128, T128, V143, R207_Q);
C43 P233(clk_6M, 4'b0001, HRST, S199, S199, V143, P233_Q);
assign P32H = P233_Q[0];
assign P64H = P233_Q[1];
assign P128H = P233_Q[2];
assign P256H = P233_Q[3];

wire [4:0] S233_Q;
C43 S233(clk_6M, 4'b1100, HVOT, P1V_NOFLIP | TEST_AB[2], (P1V_NOFLIP & T258) | TEST_AB[2], V143, S233_Q);
wire [4:0] T53_Q;
C43 T53(clk_6M, 4'b0111, HVOT, P1V_NOFLIP | TEST_AB[5], S233_Q[4] | TEST_AB[3], V143, T53_Q);
FDO T192(S233_Q[3], &{T53_Q[2:0]}, V143, VBLANK, T192_XQ);
assign P1V = P1V_NOFLIP ^ FLIPSCR;
assign P2V = S233_Q[0] ^ FLIPSCR;
assign P4V_NOFLIP = S233_Q[1];
assign P4V = P4V_NOFLIP ^ FLIPSCR;
assign P8V = S233_Q[2] ^ FLIPSCR;
assign P16V = S233_Q[3] ^ FLIPSCR;
assign P32V = T53_Q[0] ^ FLIPSCR;
assign P64V = T53_Q[1] ^ FLIPSCR;
assign P128V = T53_Q[2] ^ FLIPSCR;
assign HVOT = ~|{T53_Q[4], T1};


// ROOT SHEET 12

wire [3:0] AK195_Q;
KREG AK195(clk_6M, P1, AH218, RAM_B_dout[7:4], AK195_Q);
wire [3:0] AH221_Q;
KREG AH221(clk_6M, HRST_DELAY1, AH218, {P1V, P2V, P4V, P8V}, AH221_Q);
wire [4:0] AJ191_S;
A4H AJ191(AH221_Q, AK195_Q, ~FLIPSCR, AJ191_S);
KREG AW163(clk_6M, P1, AH218, AJ191_S[3:0], SPR_YMATCH[3:0]);

wire [3:0] AK221_Q;
KREG AK221(clk_6M, P1, AH218, RAM_B_dout[3:0], AK221_Q);
wire [3:0] AM221_Q;
KREG AM221(clk_6M, HRST_DELAY1, AH218, {P16V, P32V, P64V, P128V}, AM221_Q);
wire [4:0] AL191_S;
A4H AL191(AM221_Q, AK221_Q, AJ191_S[4], AL191_S);
KREG AH1(clk_6M, P1, AH218, AL191_S[3:0], SPR_YMATCH[7:4]);

// SPR Y ZOOM

// Half KREGs
FDN AG274(clk_12M, ~LACH ? ~RAM_A_dout[2] : ~AG274_XQ, AB1, AG274_Q, AG274_XQ);
FDN AF267(clk_12M, ~LACH ? ~RAM_A_dout[3] : ~AF267_XQ, AB1, AF267_Q, AF267_XQ);

FDN AE1(clk_12M, ~LACH ? ~RAM_A_dout[4] : ~AE1_XQ, AB1, AE1_Q, AE1_XQ);
FDN AE8(clk_12M, ~LACH ? ~RAM_A_dout[5] : ~AE8_XQ, AB1, AE8_Q, AE8_XQ);

FDN AE21(clk_12M, ~LACH ? ~RAM_A_dout[6] : ~AE21_XQ, AB1, AE21_Q, AE21_XQ);
FDN AE28(clk_12M, ~LACH ? ~RAM_A_dout[7] : ~AE28_XQ, AB1, AE28_Q, AE28_XQ);

wire [5:0] ADD_A;
wire [5:0] ADD_B;
wire [6:0] ADD_OUT;
wire [3:0] AD1_Q;
FDO AC128(clk_12M, ADD_OUT[0], AB1, AC128_Q, );
FDO AC141(clk_12M, ADD_OUT[1], AB1, AC141_Q, );
FDO AC121(clk_12M, ADD_OUT[2], AB1, AC121_Q, );
FDR AD1(clk_12M, {ADD_OUT[3], ADD_OUT[4], ADD_OUT[5], ADD_OUT[6]}, AB1, AD1_Q);
assign CARY = AD1_Q[0];

wire M94_XQ;
assign ADD_A = M94_XQ ? {AD1_Q[1], AD1_Q[2], AD1_Q[3], AC121_Q, AC141_Q, AC128_Q} : 6'b000000;
assign ADD_B = {~AE28_Q, ~AE21_Q, ~AE8_Q, ~AE1_Q, ~AF267_Q, ~AG274_Q};
assign ADD_OUT = ADD_A + ADD_B;

// RAM REGISTERS

// SPR ZOOM Y
KREG AF53(clk_6M, P1, AH218, {RAM_D_dout[0], RAM_D_dout[1], RAM_D_dout[2], RAM_D_dout[3]}, AF53_Q);	// TODO
KREG AG27(clk_6M, P1, AH218, {AF53_Q[3] ^ AL191_CO, AF53_Q[2:0]}, AG27_Q);

KREG AG53(clk_6M, P1, AH218, {RAM_D_dout[4], RAM_D_dout[5], RAM_D_dout[6], RAM_D_dout[7]}, AG53_Q);	// TODO
KREG AG1(clk_6M, P1, AH218, AG53_Q, AG1_Q);
KREG AM195(clk_6M, P1, AH218, {W1_Q[3], VBLANK_SYNC, RAM_F_dout[2:1]}, AM195_Q);
KREG AN195(clk_6M, P1, AH218, {~&{AG27_Q[3], AN195_Q[2]}, ~&{AM195_Q[3:2]}, AM195_Q[1:0]}, AN195_Q);

// SPR TILE CODE

wire [3:0] AX163_Q;
KREG AX163(clk_6M, P1, AH218, {RAM_G_dout[0], RAM_E_dout[1], RAM_E_dout[3], RAM_E_dout[5]}, AX163_Q);	// TODO: Check
wire [3:0] AV163_Q;
KREG AV163(clk_6M, P1, AH218, AX163_Q, AV163_Q);
assign SPR_CODE[5] = AV163_Q[0];
assign SPR_CODE[3] = AV163_Q[1];
assign SPR_CODE[1] = AV163_Q[2];
assign SPR_SIZE2_DELAY = AV163_Q[3];

// Half KREGs
FDN AF167(clk_12M, ~LACH ? ~RAM_E_dout[6] : ~AF167_XQ, AB1, AF167_Q, AF167_XQ);
assign SPR_CODE[6] = AF167_Q;
FDN AF174(clk_12M, ~LACH ? ~RAM_E_dout[7] : ~AF174_XQ, AB1, AF174_Q, AF174_XQ);
assign SPR_CODE[7] = AF174_Q;

FDN AG228(clk_12M, ~LACH ? ~RAM_E_dout[0] : ~AG228_XQ, AB1, AG228_Q, AG228_XQ);
FDN AG214(clk_12M, ~LACH ? ~RAM_E_dout[2] : ~AG214_XQ, AB1, AG214_Q, AG214_XQ);


// ROOT SHEET 14

assign L141 = clk_6M & J121;	// clk_6M must be delayed !
FDO M108(clk_12M, L141, M108_Q, LACH, );	// And a bunch of inverters
FDO M101(clk_12M, M108_Q, L149, M101_Q, );
FDO M94(clk_12, M101_Q, L149, , M94_XQ);

// RAM sequencing stuff
assign Y70 = ~&{~&{VBLANK_SYNC, ~TE[0]}, ~&{V91, ~AA141_Q, ~L101, ~TE[0]}};
assign Y72 = ~Y70;
assign X148 = ~&{~&{VBLANK_SYNC, ~TE[0]}, ~&{V91, ~AA141_Q, L101, ~TE[0]}};
assign Y141 = ~X148;
assign Y81 = ~&{~&{RAM_DATA_WR, VBLANK_SYNC, ~TE[0]}, ~&{V91, AA141_Q, ~TE[0]}, ~&{V91, ~AA141_Q, L126, ~TE[0]}};
assign Y73 = ~Y81;

endmodule
