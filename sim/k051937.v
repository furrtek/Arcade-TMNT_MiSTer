// TMNT arcade core
// Simulation blind schematic copy version
// Sean Gonsalves 2022
`timescale 1ns/1ns

module k051937 (
	input nRES,
	input clk_24M,

	output P1H,
	output P2H,
	
	input HVIN,
	output HVOT,
	
	input NRD, OBCS,
	
	input [2:0] AB,
	input AB10,
	
	output [7:0] DB_OUT,
	input [7:0] DB_IN,
	
	output NCSY, NVSY, NHSY,
	output NCBK, NVBK, NHBK,
	
	output SHAD, NCO0, PCOF,
	output [11:0] OB,

	input [7:0] CD0,
	input [7:0] CD1,
	input [7:0] CD2,
	input [7:0] CD3,
	
	output [3:0] CAW,

	input [7:0] OC,
	input [8:0] HP,
	
	input CARY, LACH, HEND, OREG, OHF,
	
	output DB_DIR
);

wire nHVIN_DELAY, F103_Q, AN106_Q, AL36, AV104;
wire AR71, AR104_Q, AH64, PAIR, nPAIR, AR135_XQ;
wire AR128_Q, AR128_XQ, AR135_Q, AR104_XQ;

wire [3:0] SH1_OUT;	// 3 ODD
wire [3:0] SH2_OUT;	// 2 ODD
wire [3:0] SH3_OUT;	// 1 ODD
wire [3:0] SH4_OUT;	// 0 ODD
wire [3:0] SH5_OUT;	// 3 EVEN
wire [3:0] SH6_OUT;	// 2 EVEN
wire [3:0] SH7_OUT;	// 1 EVEN
wire [3:0] SH8_OUT;	// 0 EVEN
wire [3:0] nROMRD;
wire nROMRDEN;

wire RAM_C_DOUT;
wire RAM_D_DOUT;
wire RAM_G_DOUT;
wire RAM_H_DOUT;
wire [11:0] RAM_A_DOUT;
wire [11:0] RAM_B_DOUT;
wire [11:0] RAM_E_DOUT;
wire [11:0] RAM_F_DOUT;
wire [7:0] RAM_ABCD_A;
wire [7:0] RAM_EFGH_A;
wire [11:0] RAM_A_DIN;
wire [11:0] RAM_B_DIN;
wire [11:0] RAM_E_DIN;
wire [11:0] RAM_F_DIN;

ram_sim #(12, 8, "") RAMA(RAM_ABCD_A, ~RAM_A_WE, RAM_ABCD_EN, RAM_A_DIN, RAM_A_DOUT);
ram_sim #(12, 8, "") RAMB(RAM_ABCD_A, ~RAM_B_WE, RAM_ABCD_EN, RAM_B_DIN, RAM_B_DOUT);
ram_sim #(1, 8, "") RAMC(RAM_ABCD_A, ~RAM_C_WE, RAM_ABCD_EN, RAM_C_DIN, RAM_C_DOUT);
ram_sim #(1, 8, "") RAMD(RAM_ABCD_A, ~RAM_D_WE, RAM_ABCD_EN, RAM_D_DIN, RAM_D_DOUT);

ram_sim #(12, 8, "") RAME(RAM_EFGH_A, ~RAM_E_WE, RAM_EFGH_EN, RAM_E_DIN, RAM_E_DOUT);
ram_sim #(12, 8, "") RAMF(RAM_EFGH_A, ~RAM_F_WE, RAM_EFGH_EN, RAM_F_DIN, RAM_F_DOUT);
ram_sim #(1, 8, "") RAMG(RAM_EFGH_A, ~RAM_G_WE, RAM_EFGH_EN, RAM_G_DIN, RAM_G_DOUT);
ram_sim #(1, 8, "") RAMH(RAM_EFGH_A, ~RAM_H_WE, RAM_EFGH_EN, RAM_H_DIN, RAM_H_DOUT);

// DEBUG
/*always @(*) begin
	if (RAM_A_WE & ~RAM_ABCD_EN) begin
		$display("Writing to 051937 RAMA !");
		$stop;
	end
end*/

// CLOCK & VIDEO SYNC

// Reset input sync
FDE AS24(clk_24M, 1'b1, nRES, RES_SYNC, );

// Clocks
FDN AS44(clk_24M, nclk_12M, RES_SYNC, clk_12M, nclk_12M);
FDN AS51(clk_24M, ~^{nclk_12M, nclk_6M}, RES_SYNC, clk_6M, nclk_6M);
FDN AT130(clk_24M, ~^{clk_3M, ~&{nclk_6M, nclk_12M}}, RES_SYNC, clk_3M, nclk_3M);


wire [8:0] PXH;

// NHSY generation
wire D89, F110_XQ;
assign H91 = ~&{(~NHSY | ~D89), (PXH[5] | D89)};
assign NCBK = F110_XQ & F103_Q;
FDN F89(clk_6M, H91, RES_SYNC & ~F103_Q, NHSY, );

// H/V COUNTERS

FDE AS65(clk_24M, clk_3M, RES_SYNC, AS65_Q, );	// = PE

// H counter
// 9-bit counter, resets to 9'h020 after 9'h19F, effectively counting 384 pixels
FDO K89(clk_6M, AS65_Q, RES_SYNC, PXH[0], );
C43 C89(clk_6M, 4'b0000, nNEW_LINE, PXH[0], PXH[0], RES_SYNC, PXH[4:1], C89_COUT);
C43 E93(clk_6M, 4'b0001, nNEW_LINE, C89_COUT, C89_COUT, RES_SYNC, PXH[8:5], );
assign P1H = PXH[0];
assign P2H = PXH[1];

assign G137 = &{C89_COUT, PXH[8:7]};
assign nNEW_LINE = ~|{G137, nHVIN_DELAY};
assign D89 = ~&{~PXH[4], PXH[3:0]};

wire [8:0] ROW;

// V counter
// 9-bit counter, resets to 9'h0F8 after 9'h1FF, effectively counting 264 raster lines
FDO F117(clk_6M, ~|{(~ROW[0] ^ G137), nHVIN_DELAY}, RES_SYNC, ROW[0], );
C43 B90(clk_6M, 4'b1100, HVOT, ROW[0], G137 & ROW[0], RES_SYNC, ROW[4:1], B90_CO);
C43 A89(clk_6M, 4'b0111, HVOT, ROW[0], B90_CO, RES_SYNC, ROW[8:5], A89_CO);

FDO F110(ROW[8], &{ROW[3:1]}, RES_SYNC, , F110_XQ);	// B138
LTL F132(ROW[4], NHSY, RES_SYNC, NVSY, );

assign NCSY = &{NVSY, NHSY};
assign HVOT = ~|{A89_CO, nHVIN_DELAY};


wire [3:0] AP4_Q;
C43 AP4(clk_12M, {3'b000, HP[0]}, AR44_Q, CARY, CARY, nRES, AP4_Q, );


FDM AR33(clk_12M, CARY, AR33_Q, );
FDM AN93(clk_12M, ~&{AP4_Q[0], AR33_Q}, AN93_Q, );	// AR76
FDM AM104(clk_12M, AN93_Q, AM104_Q, );


assign H137 = nNEW_LINE & (F103_Q | (PXH[6] & C89_COUT));
FDO F103(clk_6M, H137, RES_SYNC, F103_Q, );


assign AT137 = clk_24M;	// AT137 must be used for delaying M24 !
FDM AV96(~AT137, clk_12M, AV96_Q, );
assign AV139 = ~&{AT137, AV96_Q};

wire AN106_XQ;
assign AM1 = ~|{AV139, (AN106_Q & ~clk_6M)};
assign AK13 = AM1;	// Must be delayed !
assign #1 RAM_EFGH_EN = ~AM1;		// Test mode ignored

assign AM12 = ~|{AV139, (AN106_XQ & ~clk_6M)};
assign AJ1 = AM12;	// Must be delayed !
assign #1 RAM_ABCD_EN = ~AM12;	// Test mode ignored


assign DB_OUT[0] = &{(CD0[0]|nROMRD[0]), (CD1[0]|nROMRD[1]), (CD2[0]|nROMRD[2]), (CD3[0]|nROMRD[3])};
assign DB_OUT[1] = &{(CD0[1]|nROMRD[0]), (CD1[1]|nROMRD[1]), (CD2[1]|nROMRD[2]), (CD3[1]|nROMRD[3])};
assign DB_OUT[2] = &{(CD0[2]|nROMRD[0]), (CD1[2]|nROMRD[1]), (CD2[2]|nROMRD[2]), (CD3[2]|nROMRD[3])};
assign DB_OUT[3] = &{(CD0[3]|nROMRD[0]), (CD1[3]|nROMRD[1]), (CD2[3]|nROMRD[2]), (CD3[3]|nROMRD[3])};
assign DB_OUT[4] = &{(CD0[4]|nROMRD[0]), (CD1[4]|nROMRD[1]), (CD2[4]|nROMRD[2]), (CD3[4]|nROMRD[3])};
assign DB_OUT[5] = &{(CD0[5]|nROMRD[0]), (CD1[5]|nROMRD[1]), (CD2[5]|nROMRD[2]), (CD3[5]|nROMRD[3])};
assign DB_OUT[6] = &{(CD0[6]|nROMRD[0]), (CD1[6]|nROMRD[1]), (CD2[6]|nROMRD[2]), (CD3[6]|nROMRD[3])};
assign DB_OUT[7] = &{(CD0[7]|nROMRD[0]), (CD1[7]|nROMRD[1]), (CD2[7]|nROMRD[2]), (CD3[7]|nROMRD[3])};


assign AAD112 = ~&{AL36, ~AB[1], ~AB[0]};
assign AAD114 = ~&{AL36, ~AB[1], AB[0]};
assign AAD116 = ~&{AL36, AB[1], ~AB[0]};
assign AAD104 = ~&{AL36, AB[1], AB[0]};

assign AL36 = AB10 & ~|{nROMRDEN, OBCS};
assign CAW[0] = AV104 | AAD112;
assign CAW[1] = AV104 | AAD114;
assign CAW[2] = AV104 | AAD116;
assign CAW[3] = AV104 | AAD104;

assign AAC92 = ~|{NRD, OREG, ~AB[2]};
assign nROMRD[0] = AAD112 & ~&{AAC92, ~AB[1], ~AB[0]};
assign nROMRD[1] = AAD114 & ~&{AAC92, ~AB[1], AB[0]};
assign nROMRD[2] = AAD116 & ~&{AAC92, AB[1], ~AB[0]};
assign nROMRD[3] = AAD104 & ~&{AAC92, AB[1], AB[0]};

wire [3:0] CD_DIR;
assign CD_DIR[0] = ~NRD | nROMRD[0];
assign CD_DIR[1] = ~NRD | nROMRD[1];
assign CD_DIR[2] = ~NRD | nROMRD[2];
assign CD_DIR[3] = ~NRD | nROMRD[3];

assign DB_DIR = NRD | &{nROMRD};	// AAD151 AAD142


// SHIFTERS

SHIFTER SH1(clk_12M, {~AS84_XQ, ~AS90_XQ}, {CD3[7], CD3[5], CD3[3], CD3[1]}, SH1_OUT);
SHIFTER SH2(clk_12M, {~AS84_XQ, ~AS90_XQ}, {CD2[7], CD2[5], CD2[3], CD2[1]}, SH2_OUT);
SHIFTER SH3(clk_12M, {~AS84_XQ, ~AS90_XQ}, {CD1[7], CD1[5], CD1[3], CD1[1]}, SH3_OUT);
SHIFTER SH4(clk_12M, {~AS84_XQ, ~AS90_XQ}, {CD0[7], CD0[5], CD0[3], CD0[1]}, SH4_OUT);

SHIFTER SH5(clk_12M, {~AS84_XQ, ~AS90_XQ}, {CD3[6], CD3[4], CD3[2], CD3[0]}, SH5_OUT);
SHIFTER SH6(clk_12M, {~AS84_XQ, ~AS90_XQ}, {CD2[6], CD2[4], CD2[2], CD2[0]}, SH6_OUT);
SHIFTER SH7(clk_12M, {~AS84_XQ, ~AS90_XQ}, {CD1[6], CD1[4], CD1[2], CD1[0]}, SH7_OUT);
SHIFTER SH8(clk_12M, {~AS84_XQ, ~AS90_XQ}, {CD0[6], CD0[4], CD0[2], CD0[0]}, SH8_OUT);

FDM AS129(clk_12M, AR110_Q, AS129_Q, AS129_XQ);

wire [3:0] PIXELA;
wire [3:0] PIXELB;

assign AP158 = ~|{(SH8_OUT[0] & AR128_Q), (SH4_OUT[3] & AR128_XQ)};
assign AP162 = ~|{(SH4_OUT[0] & AR128_Q), (SH8_OUT[3] & AR128_XQ)};
assign AP156 = ~|{(SH8_OUT[0] & ~AR128_XQ), (SH4_OUT[3] & AR128_XQ)};
FDM AW89(clk_12M, AP156, AW89_Q, );
assign PIXELA[3] = ~&{|{AP158, AS129_Q, AR135_Q}, |{AP162, AS129_XQ, AR135_Q}};
assign PIXELB[3] = ~&{|{AP162, AS129_Q, AR104_XQ}, |{AW89_Q, AS129_XQ, AR104_XQ}};

assign AP152 = ~|{(SH6_OUT[0] & AR128_Q), (SH1_OUT[3] & AR128_XQ)};
assign AR142 = ~|{(SH1_OUT[0] & AR128_Q), (SH6_OUT[3] & AR128_XQ)};
assign AP150 = ~|{(SH6_OUT[0] & ~AR128_XQ), (SH1_OUT[3] & AR128_XQ)};
FDM AW104(clk_12M, AP150, AW104_Q, );
assign PIXELA[1] = ~&{|{AP152, AS129_Q, AR135_Q}, |{AR142, AS129_XQ, AR135_Q}};
assign PIXELB[1] = ~&{|{AR142, AS129_Q, AR104_XQ}, |{AW104_Q, AS129_XQ, AR104_XQ}};

assign AP154 = ~|{(SH7_OUT[0] & AR128_Q), (SH3_OUT[3] & AR128_XQ)};
assign AP160 = ~|{(SH3_OUT[0] & AR128_Q), (SH7_OUT[3] & AR128_XQ)};
assign AP142 = ~|{(SH7_OUT[0] & ~AR128_XQ), (SH3_OUT[3] & AR128_XQ)};
FDM AW95(clk_12M, AP142, AW95_Q, );
assign PIXELA[2] = ~&{|{AP154, AS129_Q, AR135_Q}, |{AP160, AS129_XQ, AR135_Q}};
assign PIXELB[2] = ~&{|{AP160, AS129_Q, AR104_XQ}, |{AW95_Q, AS129_XQ, AR104_XQ}};

assign AX128 = ~|{(SH5_OUT[0] & AR128_Q), (SH1_OUT[3] & AR128_XQ)};
assign AX93 = ~|{(SH1_OUT[0] & AR128_Q), (SH5_OUT[3] & AR128_XQ)};
assign AX130 = ~|{(SH5_OUT[0] & ~AR128_XQ), (SH1_OUT[3] & AR128_XQ)};
FDM AX132(clk_12M, AX130, AX132_Q, );
assign PIXELA[0] = ~&{|{AX128, AS129_Q, AR135_Q}, |{AX93, AS129_XQ, AR135_Q}};
assign PIXELB[0] = ~&{|{AX93, AS129_Q, AR104_XQ}, |{AX132_Q, AS129_XQ, AR104_XQ}};


// ROOT SHEET 3

// Render counters
wire [8:0] RENDERH;
C43 G89(clk_12M, HP[4:1], AP71_Q, AM104_Q, AM104_Q, 1'b1, RENDERH[4:1], G89_CO);
C43 S89(clk_12M, HP[8:5], AP71_Q, G89_CO, G89_CO, 1'b1, RENDERH[8:5], );


assign CD0_OUT = ~nROMRD[0] ? DB_IN : 8'h00;
assign CD1_OUT = ~nROMRD[1] ? DB_IN : 8'h00;
assign CD2_OUT = ~nROMRD[2] ? DB_IN : 8'h00;
assign CD3_OUT = ~nROMRD[3] ? DB_IN : 8'h00;


// PALETTE LATCHES

wire [3:0] AG64_Q;
assign AG104 = ~&{(AR71 | OC[4]),(AG64_Q[0] | AH64)};
assign AG85 = ~&{(AR71 | OC[5]),(AG64_Q[1] | AH64)};
assign AG87 = ~&{(AR71 | OC[6]),(AG64_Q[2] | AH64)};
assign AH96 = ~&{(AR71 | OC[7]),(AG64_Q[3] | AH64)};
FDS AG64(clk_12M, {~AH96, ~AG87, ~AG85, ~AG104}, AG64_Q);

wire [3:0] AF4_Q;
FDS AF4(clk_12M, AG64_Q, AF4_Q);
FDM AF44(AK13, ~&{AF4_Q[0], ~PAIR}, AF44_Q, );
FDM AF105(AK13, ~&{AF4_Q[1], ~PAIR}, AF105_Q, );
FDM AE89(AK13, ~&{AF4_Q[2], ~PAIR}, AE89_Q, );
FDM AF86(AK13, ~&{AF4_Q[3], ~PAIR}, AF86_Q, );
assign RAM_F_DIN[8] = ~AF44_Q;	// Test mode ignored
assign RAM_F_DIN[9] = ~AF105_Q;	// Test mode ignored
assign RAM_F_DIN[10] = ~AE89_Q;	// Test mode ignored
assign RAM_F_DIN[11] = ~AF86_Q;	// Test mode ignored

wire [3:0] AD89_Q;
FDS AD89(clk_12M, AG64_Q, AD89_Q);
FDM X131(AJ1, ~&{AD89_Q[0], PAIR}, X131_Q, );
FDM X89(AJ1, ~&{AD89_Q[1], PAIR}, X89_Q, );
FDM X95(AJ1, ~&{AD89_Q[2], PAIR}, X95_Q, );
FDM Y131(AJ1, ~&{AD89_Q[3], PAIR}, Y131_Q, );
assign RAM_B_DIN[8] = ~X131_Q;	// Test mode ignored
assign RAM_B_DIN[9] = ~X89_Q;		// Test mode ignored
assign RAM_B_DIN[10] = ~X95_Q;	// Test mode ignored
assign RAM_B_DIN[11] = ~Y131_Q;	// Test mode ignored

wire [3:0] AD109_Q;
FDS AD109(clk_12M, AG64_Q, AD109_Q);
FDM X112(AJ1, ~&{AD109_Q[0], PAIR}, X112_Q, );	// Really AM110 (PAIR) in common ?
FDM X106(AJ1, ~&{AD109_Q[1], PAIR}, X106_Q, );
FDM Y111(AJ1, ~&{AD109_Q[2], PAIR}, Y111_Q, );
FDM Y105(AJ1, ~&{AD109_Q[3], PAIR}, Y105_Q, );
assign RAM_A_DIN[8] = ~X112_Q;	// Test mode ignored
assign RAM_A_DIN[9] = ~X106_Q;	// Test mode ignored
assign RAM_A_DIN[10] = ~Y111_Q;	// Test mode ignored
assign RAM_A_DIN[11] = ~Y105_Q;	// Test mode ignored

wire [3:0] AE104_Q;
FDS AE104(clk_12M, AG64_Q, AE104_Q);
FDM AE135(AK13, ~&{AE104_Q[0], ~PAIR}, AE135_Q, );
FDM AE129(AK13, ~&{AE104_Q[1], ~PAIR}, AE129_Q, );
FDM AE95(AK13, ~&{AE104_Q[2], ~PAIR}, AE95_Q, );
FDM AF92(AK13, ~&{AE104_Q[3], ~PAIR}, AF92_Q, );
assign RAM_E_DIN[8] = ~AE104_Q;	// Test mode ignored
assign RAM_E_DIN[9] = ~AE129_Q;	// Test mode ignored
assign RAM_E_DIN[10] = ~AE95_Q;	// Test mode ignored
assign RAM_E_DIN[11] = ~AF92_Q;	// Test mode ignored


wire [3:0] AG4_Q;
assign AH85 = ~&{(AR71 | OC[0]),(AG64_Q[0] | AH64)};
assign AH87 = ~&{(AR71 | OC[1]),(AG64_Q[1] | AH64)};
assign AH90 = ~&{(AR71 | OC[2]),(AG64_Q[2] | AH64)};
assign AH93 = ~&{(AR71 | OC[3]),(AG64_Q[3] | AH64)};
FDS AG4(clk_12M, {~AH93, ~AH90, ~AH87, ~AH85}, AG4_Q);

wire [3:0] AG24_Q;
FDS AG24(clk_12M, AG4_Q, AG24_Q);
FDM AG135(AK13, ~&{AG24_Q[0], ~PAIR}, AG135_Q, );
FDM AF72(AK13, ~&{AG24_Q[1], ~PAIR}, AF72_Q, );
FDM AF66(AK13, ~&{AG24_Q[2], ~PAIR}, AF66_Q, );
FDM AF111(AK13, ~&{AG24_Q[3], ~PAIR}, AF111_Q, );
assign RAM_F_DIN[4] = ~AG135_Q;	// Test mode ignored
assign RAM_F_DIN[5] = ~AF72_Q;	// Test mode ignored
assign RAM_F_DIN[6] = ~AF66_Q;	// Test mode ignored
assign RAM_F_DIN[7] = ~AF111_Q;	// Test mode ignored

wire [3:0] AG44_Q;
FDS AG44(clk_12M, AG4_Q, AG44_Q);
FDM AG106(AK13, ~&{AG44_Q[0], ~PAIR}, AG106_Q, );
FDM AG112(AK13, ~&{AG44_Q[1], ~PAIR}, AG112_Q, );
FDM AF30(AK13, ~&{AG44_Q[2], ~PAIR}, AF30_Q, );
FDM AG129(AK13, ~&{AG44_Q[3], ~PAIR}, AG129_Q, );
assign RAM_E_DIN[4] = ~AG106_Q;	// Test mode ignored
assign RAM_E_DIN[5] = ~AG112_Q;	// Test mode ignored
assign RAM_E_DIN[6] = ~AF30_Q;	// Test mode ignored
assign RAM_E_DIN[7] = ~AG129_Q;	// Test mode ignored

wire [3:0] AC89_Q;
FDS AC89(clk_12M, AG4_Q, AC89_Q);
FDM W89(AJ1, ~&{AC89_Q[0], PAIR}, W89_Q, );
FDM Z108(AJ1, ~&{AC89_Q[1], PAIR}, Z108_Q, );
FDM W112(AJ1, ~&{AC89_Q[2], PAIR}, W112_Q, );
FDM Z95(AJ1, ~&{AC89_Q[3], PAIR}, Z95_Q, );
assign RAM_B_DIN[7] = ~W89_Q;		// Test mode ignored
assign RAM_B_DIN[6] = ~Z108_Q;	// Test mode ignored
assign RAM_B_DIN[5] = ~W112_Q;	// Test mode ignored
assign RAM_B_DIN[4] = ~Z95_Q;		// Test mode ignored

wire [3:0] AC109_Q;
FDS AC109(clk_12M, AG4_Q, AC109_Q);
FDM W95(AJ1, ~&{AC109_Q[0], PAIR}, W95_Q, );
FDM Z89(AJ1, ~&{AC109_Q[1], PAIR}, Z89_Q, );
FDM W106(AJ1, ~&{AC109_Q[2], PAIR}, W106_Q, );
FDM Y89(AJ1, ~&{AC109_Q[3], PAIR}, Y89_Q, );
assign RAM_A_DIN[7] = ~W95_Q;		// Test mode ignored
assign RAM_A_DIN[6] = ~Z89_Q;		// Test mode ignored
assign RAM_A_DIN[5] = ~&W106_Q;	// Test mode ignored
assign RAM_A_DIN[4] = ~Y89_Q;		// Test mode ignored


// LB ADDRESS

FDO AB95(AAC98, DB_IN[3], RES_SYNC, AB95_Q, );
assign K108 = PXH[0] ^ AB95_Q;
assign AK183 = ~K108;

/*assign J130 = PXH[8] ^ AB95_Q;
assign R106 = ~|{(RENDERH[8] & ~PAIR), (J130 & PAIR)};
assign RAM_EFGH_A[7] = ~R106;		// Test mode ignored
assign R108 = ~|{(RENDERH[8] & PAIR), (J130 & ~PAIR)};
assign RAM_ABCD_A[7] = ~R108;		// Test mode ignored

assign K100 = PXH[7] ^ AB95_Q;
assign R104 = ~|{(RENDERH[7] & ~PAIR), (K100 & PAIR)};
assign RAM_EFGH_A[6] = ~R104;		// Test mode ignored
assign R100 = ~|{(RENDERH[7] & PAIR), (K100 & ~PAIR)};
assign RAM_ABCD_A[6] = ~R100;		// Test mode ignored

assign K104 = PXH[6] ^ AB95_Q;
assign R116 = ~|{(RENDERH[6] & ~PAIR), (K104 & PAIR)};
assign RAM_EFGH_A[5] = ~R116;		// Test mode ignored
assign R118 = ~|{(RENDERH[6] & PAIR), (K104 & ~PAIR)};
assign RAM_ABCD_A[5] = ~R118;		// Test mode ignored

assign K96 = PXH[5] ^ AB95_Q;
assign R120 = ~|{(RENDERH[5] & ~PAIR), (K96 & PAIR)};
assign RAM_EFGH_A[4] = ~R120;		// Test mode ignored
assign P91 = ~|{(RENDERH[5] & PAIR), (K96 & ~PAIR)};
assign RAM_ABCD_A[4] = ~P91;		// Test mode ignored

assign A137 = PXH[4] ^ AB95_Q;
assign N114 = ~|{(RENDERH[4] & ~PAIR), (A137 & PAIR)};
assign RAM_EFGH_A[3] = ~N114;		// Test mode ignored
assign N116 = ~|{(RENDERH[4] & PAIR), (A137 & ~PAIR)};
assign RAM_ABCD_A[3] = ~N116;		// Test mode ignored

assign J93 = PXH[3] ^ AB95_Q;
assign N108 = ~|{(RENDERH[3] & ~PAIR), (J93 & PAIR)};
assign RAM_EFGH_A[2] = ~N108;		// Test mode ignored
assign N110 = ~|{(RENDERH[3] & PAIR), (J93 & ~PAIR)};
assign RAM_ABCD_A[2] = ~N110;		// Test mode ignored

assign J89 = PXH[2] ^ AB95_Q;
assign N89 = ~|{(RENDERH[2] & ~PAIR), (J89 & PAIR)};
assign RAM_EFGH_A[1] = ~N89;		// Test mode ignored
assign N91 = ~|{(RENDERH[2] & PAIR), (J89 & ~PAIR)};
assign RAM_ABCD_A[1] = ~N91;		// Test mode ignored

assign J134 = PXH[1] ^ AB95_Q;
assign N118 = ~|{(RENDERH[1] & ~PAIR), (J134 & PAIR)};
assign RAM_EFGH_A[0] = ~N118;		// Test mode ignored
assign N128 = ~|{(RENDERH[1] & PAIR), (J134 & ~PAIR)};
assign RAM_ABCD_A[0] = ~N128;		// Test mode ignored
*/
assign RAM_ABCD_A = PAIR ? RENDERH[8:1] : PXH[8:1] ^ {8{AB95_Q}};
assign RAM_EFGH_A = PAIR ? PXH[8:1] ^ {8{AB95_Q}} : RENDERH[8:1];


wire [3:0] AH4_Q;
FDS AH4(clk_12M, PIXELB, AH4_Q);
FDM AF56(AK13, ~&{AH4_Q[0], ~PAIR}, AF56_Q, );
FDM AF24(AK13, ~&{AH4_Q[1], ~PAIR}, AF24_Q, );
FDM AF133(AK13, ~&{AH4_Q[2], ~PAIR}, AF133_Q, );
FDM AF127(AK13, ~&{AH4_Q[3], ~PAIR}, AF127_Q, );
assign RAM_E_DIN[0] = ~AF56_Q;		// Test mode ignored
assign RAM_E_DIN[1] = ~AF24_Q;		// Test mode ignored
assign RAM_E_DIN[2] = ~AF133_Q;		// Test mode ignored
assign RAM_E_DIN[3] = ~AF127_Q;		// Test mode ignored

wire [3:0] AJ23_Q;
FDS AJ23(clk_12M, PIXELB, AJ23_Q);
FDM V96(AJ1, ~&{AJ23_Q[0], PAIR}, V96_Q, );
FDM V90(AJ1, ~&{AJ23_Q[1], PAIR}, V90_Q, );
FDM R110(AJ1, ~&{AJ23_Q[2], PAIR}, R110_Q, );
FDM T129(AJ1, ~&{AJ23_Q[3], PAIR}, T129_Q, );
assign RAM_A_DIN[0] = ~V96_Q;			// Test mode ignored
assign RAM_A_DIN[1] = ~V90_Q;			// Test mode ignored
assign RAM_A_DIN[2] = ~R110_Q;		// Test mode ignored
assign RAM_A_DIN[3] = ~T129_Q;		// Test mode ignored


// REG 1

assign AG191 = ~|{(RAM_C_DOUT & ~PAIR), (RAM_G_DOUT & PAIR)};
FDM AK196(PXH[0], AG191, AK196_Q, );
assign AG198 = ~|{(RAM_D_DOUT & ~PAIR), (RAM_H_DOUT & PAIR)};
FDM AK154(PXH[0], AG198, AK154_Q, );
assign AK160 = ~|{(AK196_Q & AK183), (AK154_Q & K108)};
FDM AL196(clk_6M, AK160, AL196_Q, );

assign AAC104 = |{AV104, OREG, AB[1], ~AB[0]};
FDO AJ128(AAC104, DB_IN[0], RES_SYNC, AJ128_Q, );
assign AL203 = ~^{AL196_Q, AJ128_Q};

FDO AJ91(AAC104, DB_IN[1], RES_SYNC, AJ91_Q, );
assign AK112 = AG64_Q[3] | AJ91_Q;

FDO AJ84(AAC104, DB_IN[2], RES_SYNC, AJ84_Q, );

assign AK114 = &{AJ84_Q, AJ91_Q, &{PIXELA}};
FDM AJ55(clk_12M, AK114, AJ55_Q, );

assign AK117 = &{AJ84_Q, AJ91_Q, &{PIXELB}};
FDM AJ135(clk_12M, AK117, AJ135_Q, );

FDM AH65(AJ1, ~&{AJ55_Q, PAIR}, AH65_Q, );
assign RAM_C_DIN = ~AH65_Q;
FDM AH132(AK13, ~&{AJ55_Q, ~PAIR}, AH132_Q, );
assign RAM_G_DIN = ~AH132_Q;
FDM AH108(AJ1, ~&{AJ135_Q, PAIR}, AH108_Q, );
assign RAM_D_DIN = ~AH108_Q;
FDM AH114(AK13, ~&{AJ135_Q, ~PAIR}, AH114_Q, );
assign RAM_H_DIN = ~AH114_Q;


// ROOT SHEET 7


FDO AT106(clk_24M, nclk_3M, nRES, AT106_Q, AT106_XQ);
FDO AT89(clk_24M, AT106_Q, RES_SYNC, AT89_Q, );
FDO AT96(clk_24M, AT189_Q, RES_SYNC, AT96_Q, );

FDO AV89(clk_24M, ~&{AT106_XQ, AT96_Q, NRD}, RES_SYNC, AV104, );


assign AR73 = ~|{(AR128_XQ & AR71), (OHF & ~AR71)};
FDM AR128(clk_12M, AR73, AR128_Q, AR128_XQ);

assign AAC98 = |{AV104, OREG, AB[1:0]};
FDO AM90(AAC98, DB_IN[5], RES_SYNC, , nROMRDEN);


assign AN116 = HVIN & nRES;
FDN AN130(clk_12M, ~^{AP134, AN130_XQ}, AN116, AN130_Q, AN130_XQ);
FDN AN106(clk_12M, AN130_Q, AN116, AN106_Q, AN106_XQ);
assign PAIR = AN106_Q;		// Must be delayed !
//assign nPAIR = AN106_XQ;	// Must be delayed !


FDM AR16(~clk_12M, ~|{~PXH[0], clk_6M}, AR16_Q, );
assign AS34 = ~|{(AR16_Q & ~OHF), (1'b1 & OHF)};
FDM AS90(clk_12M, AS34, , AS90_XQ);

assign AS36 = ~|{(1'b1 & ~OHF), (AR16_Q & OHF)};
FDM AS84(clk_12M, AS36, , AS84_XQ);

// RAM block WEs
assign AM128 = ~&{|{PIXELA}, AR135_XQ, AN93_Q};	// To check
assign AL89 = ~&{|{PIXELB}, AR104_Q, AM104_Q};	// To check
assign AL79 = AK117 | AL89;
assign AL77 = AK114 | AM128;

/*assign AL57 = ~|{(PXH[0] & ~PAIR), (AM128 & PAIR)};
FDM AL24(clk_12M, AL57, AL24_Q, );
FDM AK7(AM12, AL24_Q, RAM_C_WE, );
assign AL55 = ~|{(AM128 & ~PAIR), (PXH[0] & PAIR)};
FDM AL7(clk_12M, AL55, AL7_Q, );
FDM AK24(AM1, AL7_Q, RAM_G_WE, );

assign AL64 = ~|{(AL89 & ~PAIR), (PXH[0] & PAIR)};
FDM AL30(clk_12M, AL64, AL30_Q, );
FDM AK30(AM1, AL30_Q, RAM_H_WE, );
assign AL66 = ~|{(PXH[0] & ~PAIR), (AL89 & PAIR)};
FDM AL1(clk_12M, AL66, AL1_Q, );
FDM AK1(AM12, AL1_Q, RAM_D_WE, );

assign AL74 = ~|{(PXH[0] & ~PAIR), (AL79 & PAIR)};
FDM AK44(clk_12M, AL74, AK44_Q, );
FDM AK36(AM12, AK44_Q, RAM_A_WE, );
assign AL72 = ~|{(AL79 & ~PAIR), (PXH[0] & PAIR)};
FDM AK64(clk_12M, AL72, AK64_Q, );
FDM AK50(AM1, AK64_Q, RAM_E_WE, );

assign AL70 = ~|{(PXH[0] & ~PAIR), (AL77 & PAIR)};
FDM AK84(clk_12M, AL70, AK48_Q, );
FDM AK90(AM12, AK48_Q, RAM_B_WE, );
assign AL68 = ~|{(AL77 & ~PAIR), (PXH[0] & PAIR)};
FDM AK70(clk_12M, AL68, AK70_Q, );
FDM AK76(AM1, AK70_Q, RAM_F_WE, );*/

wire [7:0] WE_MUX;
assign WE_MUX = PAIR ? {AM128, PXH[0], AL89, PXH[0], AL79, PXH[0], AL77, PXH[0]} : {PXH[0], AM128, PXH[0], AL89, PXH[0], AL79, PXH[0], AL77};

reg [7:0] WE_MUX_REG;
always @(posedge clk_12M)
	WE_MUX_REG <= WE_MUX;
	
reg [3:0] WE_MUX_REG_A;
reg [3:0] WE_MUX_REG_B;
always @(posedge AM12)
	WE_MUX_REG_A <= {WE_MUX_REG[7], WE_MUX_REG[5], WE_MUX_REG[3], WE_MUX_REG[1]};
assign RAM_C_WE = ~WE_MUX_REG_A[3];
assign RAM_D_WE = ~WE_MUX_REG_A[2];
assign RAM_A_WE = ~WE_MUX_REG_A[1];
assign RAM_B_WE = ~WE_MUX_REG_A[0];
always @(posedge AM1)
	WE_MUX_REG_B <= {WE_MUX_REG[6], WE_MUX_REG[4], WE_MUX_REG[2], WE_MUX_REG[0]};
assign RAM_G_WE = ~WE_MUX_REG_B[3];
assign RAM_H_WE = ~WE_MUX_REG_B[2];
assign RAM_E_WE = ~WE_MUX_REG_B[1];
assign RAM_F_WE = ~WE_MUX_REG_B[0];

// ROOT SHEET 8

reg [11:0] PARITY_SEL_REG;	// Final output on OB* pins

assign RAOE = &{(1'b0 | ~nROMRDEN), (NRD | nROMRDEN)};

// All the muxes are test mode related, safe to ignore
assign OB = PARITY_SEL_REG;
assign SHAD = ~AL203;

// ROOT SHEET 9

wire [3:0] AH24_Q;
FDS AH24(clk_12M, PIXELA, AH24_Q);
FDM AB105(AK13, ~&{AH24_Q[0], ~PAIR}, AB105_Q, );
FDM AB89(AK13, ~&{AH24_Q[1], ~PAIR}, AB89_Q, );
FDM AF50(AK13, ~&{AH24_Q[2], ~PAIR}, AF50_Q, );
FDM AF36(AK13, ~&{AH24_Q[3], ~PAIR}, AF36_Q, );
assign RAM_F_DIN[0] = ~AB105_Q;		// Test mode ignored
assign RAM_F_DIN[1] = ~AB89_Q;		// Test mode ignored
assign RAM_F_DIN[2] = ~AF50_Q;		// Test mode ignored
assign RAM_F_DIN[3] = ~AF36_Q;		// Test mode ignored

wire [3:0] AH44_Q;
FDS AH44(clk_12M, PIXELA, AH44_Q);
FDM W132(AK13, ~&{AH44_Q[0], PAIR}, W132_Q, );
FDM V108(AK13, ~&{AH44_Q[1], PAIR}, V108_Q, );
FDM T135(AK13, ~&{AH44_Q[2], PAIR}, T135_Q, );
FDM V131(AK13, ~&{AH44_Q[3], PAIR}, V131_Q, );
assign RAM_B_DIN[0] = ~W132_Q;		// Test mode ignored
assign RAM_B_DIN[1] = ~V108_Q;		// Test mode ignored
assign RAM_B_DIN[2] = ~T135_Q;		// Test mode ignored
assign RAM_B_DIN[3] = ~V131_Q;		// Test mode ignored

// FINAL OUTPUT

wire [11:0] PAIR_SEL_EVEN = PAIR ? RAM_E_DOUT : RAM_A_DOUT;
wire [11:0] PAIR_SEL_ODD = PAIR ? RAM_F_DOUT : RAM_B_DOUT;

reg [11:0] PAIR_SEL_EVEN_REG;	// A/E
reg [11:0] PAIR_SEL_ODD_REG;	// B/F
always @(posedge PXH[0]) begin
	PAIR_SEL_EVEN_REG <= PAIR_SEL_EVEN;
	PAIR_SEL_ODD_REG <= PAIR_SEL_ODD;
end

assign K108 = PXH[0] ^ AB95_Q;

wire [11:0] PARITY_SEL = K108 ? PAIR_SEL_EVEN_REG : PAIR_SEL_ODD_REG;

always @(posedge clk_6M)
	PARITY_SEL_REG <= PARITY_SEL;

assign PCOF = ~|{~PARITY_SEL_REG[3:0]};
assign NCO0 = ~&{~PARITY_SEL_REG[3:0]};


// DELAYS

reg [5:0] LACH_DELAY;
always @(posedge clk_12M or negedge nRES) begin
	if (!nRES) begin
		LACH_DELAY <= 6'b000000;
	end else begin
		LACH_DELAY <= {LACH_DELAY[4:0], LACH};
	end
end
assign AR44_Q = LACH_DELAY[2];
assign AP71_Q = LACH_DELAY[5];
assign AR71 = LACH_DELAY[4];
assign AH64 = ~AR71;

// HVIN sync
reg [7:0] DELAY_HVIN;
always @(posedge clk_6M or negedge RES_SYNC) begin
	if (!RES_SYNC) begin
		DELAY_HVIN <= 8'hFF;
	end else begin
		DELAY_HVIN <= {DELAY_HVIN[6:0], HVIN};
	end
end

assign nHVIN_DELAY = ~DELAY_HVIN[7];

FDN AN84(clk_6M, AN15_Q, nRES, AN84_Q, );
FDM AP52(~clk_12M, AN84_Q | clk_6M, AP52_Q, );
reg [4:0] AN15_DELAY;
always @(posedge clk_12M or negedge nRES) begin
	if (!nRES) begin
		AN15_DELAY <= 5'b00000;
	end else begin
		AN15_DELAY <= {AN15_DELAY[3:0], AP52_Q};
	end
end
assign AP134 = ~AN15_DELAY[4];

reg [6:0] NEWLINE_DELAY;
always @(posedge clk_6M or negedge nRES) begin
	if (!nRES) begin
		NEWLINE_DELAY <= 7'b000000;
	end else begin
		NEWLINE_DELAY <= {NEWLINE_DELAY[5:0], nNEW_LINE};
	end
end
assign AN15_Q = NEWLINE_DELAY[6];

FJD AR4(clk_12M, ~LACH, HEND & AR16_Q, AN15_Q & nRES, , AR4_Q);
BD3 AS135(AR4_Q, AS135_OUT);

reg [3:0] AS135_DELAY;
always @(posedge clk_12M or negedge nRES) begin
	if (!nRES) begin
		AS135_DELAY <= 4'b0000;
	end else begin
		AS135_DELAY <= {AS135_DELAY[2:0], AS135_OUT};
	end
end
assign AR84_Q = AS135_DELAY[3];
FDM AR135(clk_12M, AR84_Q, AR135_Q, AR135_XQ);
FDM AR110(clk_12M, AP4_Q[0], AR110_Q, AR110_XQ);
assign AR116 = ~|{(AR84_Q & AR110_XQ), (AR135_Q & AR110_Q)};
FDM AR104(clk_12M, AR116, AR104_Q, AR104_XQ);

endmodule
