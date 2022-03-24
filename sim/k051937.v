// TMNT arcade core
// Simulation blind schematic copy version
// Sean Gonsalves 2022
`timescale 1ns/100ps
`default_nettype wire

module k051937 (
	input reset,
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
	
	output SHAD, NCOO, PCOF,
	output [11:0] OB,

	input [7:0] CD0,
	input [7:0] CD1,
	input [7:0] CD2,
	input [7:0] CD3,
	
	output [3:0] CAW,

	input [7:0] OC,
	input [8:0] HP,
	
	input CARY, LACH, HEND, OREG, OHF
);

wire D94_XQ, AL126_XQ, F103_Q, AN106_Q, AL36, AV104;
wire AR71, AR104_Q, AH64, PAIR_OUT, nPAIR_OUT, AR135_XQ;
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

ram #(8, 8, "") RAMA(RAM_ABCD_A, RAM_A_WE, RAM_ABCD_EN, RAM_A_DIN, RAM_A_DOUT);
ram #(8, 8, "") RAMB(RAM_ABCD_A, RAM_B_WE, RAM_ABCD_EN, RAM_B_DIN, RAM_B_DOUT);
ram #(1, 8, "") RAMC(RAM_ABCD_A, RAM_C_WE, RAM_ABCD_EN, RAM_C_DIN, RAM_C_DOUT);
ram #(1, 8, "") RAMD(RAM_ABCD_A, RAM_D_WE, RAM_ABCD_EN, RAM_D_DIN, RAM_D_DOUT);

ram #(8, 8, "") RAME(RAM_EFGH_A, RAM_E_WE, RAM_EFGH_EN, RAM_E_DIN, RAM_E_DOUT);
ram #(8, 8, "") RAMF(RAM_EFGH_A, RAM_F_WE, RAM_EFGH_EN, RAM_F_DIN, RAM_F_DOUT);
ram #(1, 8, "") RAMG(RAM_EFGH_A, RAM_G_WE, RAM_EFGH_EN, RAM_G_DIN, RAM_G_DOUT);
ram #(1, 8, "") RAMH(RAM_EFGH_A, RAM_H_WE, RAM_EFGH_EN, RAM_H_DIN, RAM_H_DOUT);

// ROOT SHEET 1

wire [3:0] C89_Q;
wire [3:0] E93_Q;
C43 C89(clk_6M, 4'b0000, nNEW_LINE, J97, J97, RES_SYNC, C89_Q, C89_CO);
C43 E93(clk_6M, 4'b0001, nNEW_LINE, C89_CO, C89_CO, RES_SYNC, E93_Q);
assign P2H = C89_Q[0];
assign P4H = C89_Q[1];
assign P8H = C89_Q[2];
assign P16H = C89_Q[3];
assign P32H = E93_Q[0];
assign P64H = E93_Q[1];
assign P128H = E93_Q[2];
assign P256H = E93_Q[3];

assign G137 = &{C89_CO, E93_Q[3:2]};
assign nNEW_LINE = ~|{G137, D94_XQ};
assign J97 = AL126_XQ & P1H;
assign D89 = ~&{~C89_Q[3], C89_Q[2:0], J97};
assign B89 = ~D89;

wire [3:0] A89_Q;
wire [3:0] B90_Q;
C43 B90(clk_6M, 4'b0011, HVOT, F117_Q, H104, RES_SYNC, B90_Q, B90_CO);
C43 A89(clk_6M, 4'b0111, HVOT, F117_Q, B90_CO, RES_SYNC, A89_Q, A89_CO);

FDO F110(B90_Q[3], &{A89_Q[2:0]}, ,F110_XQ);	// B138
LTL F132(A89_Q[3], F89_Q, RES_SYNC, NVSY);

assign NCSY = &{NVSY, F89_Q};
assign HVOT = ~|{A89_CO, D94_XQ};


wire [3:0] AP4_Q;
C43 AP4(clk_12M, {3'b000, HP[0]}, AR44_Q, CARY, CARY, RES, AP4_Q, B90_CO);


FDM AR33(clk_12M, CARY, AR33_Q);
FDM AN93(clk_12M, ~&{AP4_Q[0], AR33_Q}, AN93_Q);	// AR76
FDM AM104(clk_12M, AN93_Q, AM104_Q);


assign H137 = RES_SYNC & (F103_Q | (P64H & C89_CO));
FDO F103(clk_6M, H137, RES_SYNC, F103_Q, F103_XQ);
FDN F89(clk_6M, H91, RES_SYNC & F130_XQ, NHSY, F89_XQ);
assign H91 = ~&{(F89_XQ | B89), (D89 | P32H)};
assign NCBK = F110_XQ & F103_Q;


assign AT137 = clk_24M;	// AT137 must be used for delaying M24 !
FDM AV96(~AT137, clk_M12, AV96_Q);
assign AV139 = ~&{AT137, AV96_Q};
assign AK13 = ~|{AV139, (AN106_Q & ~clk_6M)};
assign RAM_EFGH_EN = AK13;	// Test mode ignored


FDN AS44(clk_24M, AS44_XQ, RES, clk_12M, AS44_XQ);
FDN AS51(clk_24M, ~^{AS44_XQ, AS51_XQ}, RES_SYNC, clk_6M, AS51_XQ);


FDE AS24(clk_24M, 1'b1, RES, RES_SYNC);


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


// ROOT SHEET 2

/*wire [3:0] AX104_Q;
assign AY138 = ~AAA94;
assign AAA93 = ~AAA92;
T34 AY113({1'b0, AAA94, AAA93}, {AAA93, AY138, CD3[7]}, {AAA92, AY138, AX104_Q[1]}, {AAA92, AAA94, AX104_Q[0]});
T34 AY104({AX104_Q[0], AAA94, AAA93}, {AAA93, AY138, CD3[5]}, {AAA92, AY138, AX104_Q[2]}, {AAA92, AAA94, AX104_Q[1]});
T34 AY129({AX104_Q[1], AAA94, AAA93}, {AAA93, AY138, CD3[3]}, {AAA92, AY138, AX104_Q[3]}, {AAA92, AAA94, AX104_Q[2]});
T34 AY89({AX104_Q[2], AAA94, AAA93}, {AAA93, AY138, CD3[1]}, {AAA92, AY138, 1'b0}, {AAA92, AAA94, AX104_Q[3]});
FDS AX104(clk_12M, {~AY89, ~AX92, ~AY139, ~AY113}, AX104_Q);*/

SHIFTER SH1(clk_12M, {AAA94, AAA92}, {CD3[7], CD3[5], CD3[3], CD3[1]}, SH1_OUT);
SHIFTER SH2(clk_12M, {AX138, AAA138}, {CD2[7], CD2[5], CD2[3], CD2[1]}, SH2_OUT);
SHIFTER SH3(clk_12M, {AX139, AAA139}, {CD1[7], CD1[5], CD1[3], CD1[1]}, SH3_OUT);
SHIFTER SH4(clk_12M, {AX140, AAA140}, {CD0[7], CD0[5], CD0[3], CD0[1]}, SH4_OUT);

FDM AS129(clk_12M, AR110_Q, AS129_Q, AS129_XQ);

assign AP158 = ~|{(SH8_OUT[0] & AR128_Q), (SH4_OUT[3] & AR128_XQ)};
assign AP162 = ~|{(SH4_OUT[0] & AR128_Q), (SH8_OUT[3] & AR128_XQ)};
assign AP156 = ~|{(SH8_OUT[0] & ~AR128_XQ), (SH4_OUT[3] & AR128_XQ)};
FDM AW89(clk_12M, AP156, AW89_Q);
assign AV134 = ~|{AP158, AS129_Q, AR135_Q, AP162, AS129_XQ, AR135_Q};
assign AW136 = ~|{AP162, AS129_Q, AR104_XQ, AW89_Q, AS129_XQ, AR104_XQ};

assign AP152 = ~|{(SH6_OUT[0] & AR128_Q), (SH1_OUT[3] & AR128_XQ)};
assign AR142 = ~|{(SH1_OUT[0] & AR128_Q), (SH6_OUT[3] & AR128_XQ)};
assign AP150 = ~|{(SH6_OUT[0] & ~AR128_XQ), (SH1_OUT[3] & AR128_XQ)};
FDM AW104(clk_12M, AP150, AW104_Q);
assign AV112 = ~|{AP152, AS129_Q, AR135_Q, AR142, AS129_XQ, AR135_Q};
assign AW110 = ~|{AR142, AS129_Q, AR104_XQ, AW104_Q, AS129_XQ, AR104_XQ};

assign AP154 = ~|{(SH7_OUT[0] & AR128_Q), (SH3_OUT[3] & AR128_XQ)};
assign AP160 = ~|{(SH3_OUT[0] & AR128_Q), (SH7_OUT[3] & AR128_XQ)};
assign AP142 = ~|{(SH7_OUT[0] & ~AR128_XQ), (SH3_OUT[3] & AR128_XQ)};
FDM AW95(clk_12M, AP142, AW95_Q);
assign AV129 = ~|{AP154, AS129_Q, AR135_Q, AP160, AS129_XQ, AR135_Q};
assign AW131 = ~|{AP160, AS129_Q, AR104_XQ, AW95_Q, AS129_XQ, AR104_XQ};

assign AX128 = ~|{(SH5_OUT[0] & AR128_Q), (SH1_OUT[3] & AR128_XQ)};
assign AX93 = ~|{(SH1_OUT[0] & AR128_Q), (SH5_OUT[3] & AR128_XQ)};
assign AX130 = ~|{(SH5_OUT[0] & ~AR128_XQ), (SH1_OUT[3] & AR128_XQ)};
FDM AX132(clk_12M, AX130, AX132_Q);
assign AV107 = ~|{AX128, AS129_Q, AR135_Q, AX93, AS129_XQ, AR135_Q};
assign AW115 = ~|{AX93, AS129_Q, AR104_XQ, AX132_Q, AS129_XQ, AR104_XQ};


// SHIFTERS 2
SHIFTER SH5(clk_12M, {AAC118, AAC117}, {CD3[6], CD3[4], CD3[2], CD3[0]}, SH5_OUT);
SHIFTER SH6(clk_12M, {AAB140, AAB139}, {CD2[6], CD2[4], CD2[2], CD2[0]}, SH6_OUT);
SHIFTER SH7(clk_12M, {AX90, AAA91}, {CD1[6], CD1[4], CD1[2], CD1[0]}, SH7_OUT);
SHIFTER SH8(clk_12M, {AX91, AAA137}, {CD0[6], CD0[4], CD0[2], CD0[0]}, SH8_OUT);


// ROOT SHEET 3

wire [3:0] G89_Q;
wire [3:0] S89_Q;
C43 G89(clk_12M, HP[4:1], AP71_Q, AM104_Q, AM104_Q, 1'b1, G89_Q, G89_CO);
C43 S89(clk_12M, HP[8:5], AP71_Q, G89_CO, G89_CO, 1'b1, S89_Q);


assign CD0_OUT = ~nROMRD[0] ? DB_IN : 8'h00;
assign CD1_OUT = ~nROMRD[1] ? DB_IN : 8'h00;
assign CD2_OUT = ~nROMRD[2] ? DB_IN : 8'h00;
assign CD3_OUT = ~nROMRD[3] ? DB_IN : 8'h00;


//FDO AL133(TE[0], DB_IN[1], RES_SYNC, AL133_Q);
assign AL133_Q = 0;
//FDO AL126(TE[0], DB_IN[5], RES_SYNC, , AL126_XQ);
assign AL126_XQ = 1;
assign F130 = AL133_Q | G137;
assign H104 = F130 & F117_Q;
FDO F117(clk_6M, ~|{(F117_XQ ^ F130), D94_XQ}, RES_SYNC, F117_Q, F117_XQ);


// PALETTE LATCHES

wire [3:0] AG64_Q;
assign AG104 = ~&{(AR71 | OC[4]),(AG64_Q[0] | AH64)};
assign AG85 = ~&{(AR71 | OC[5]),(AG64_Q[1] | AH64)};
assign AG87 = ~&{(AR71 | OC[6]),(AG64_Q[2] | AH64)};
assign AH96 = ~&{(AR71 | OC[7]),(AG64_Q[3] | AH64)};
FDS AG64(clk_12M, {~AH96, ~AG87, ~AG85, ~AG104}, AG64_Q);

wire [3:0] AF4_Q;
FDS AF4(clk_12M, AG64_Q, AF4_Q);
FDM AF44(AK13, ~&{AF4_Q[0], AAC92}, AF44_Q);
FDM AF105(AK13, ~&{AF4_Q[1], AAC92}, AF105_Q);
FDM AE89(AK13, ~&{AF4_Q[2], AAC92}, AE89_Q);
FDM AF86(AK13, ~&{AF4_Q[3], AAC92}, AF86_Q);
assign RAM_D = ~AF44_Q;		// Test mode ignored
assign RAM_D = ~AF105_Q;	// Test mode ignored
assign RAM_D = ~AE89_Q;		// Test mode ignored
assign RAM_D = ~AF86_Q;		// Test mode ignored

wire [3:0] AD89_Q;
FDS AD89(clk_12M, AG64_Q, AD89_Q);
FDM X131(AJ1, ~&{AD89_Q[0], AM110}, X131_Q);
FDM X89(AJ1, ~&{AD89_Q[1], AM110}, X89_Q);
FDM X95(AJ1, ~&{AD89_Q[2], AM110}, X95_Q);
FDM Y131(AJ1, ~&{AD89_Q[3], AM110}, Y131_Q);
assign RAM_D = ~X131_Q;		// Test mode ignored
assign RAM_D = ~X89_Q;		// Test mode ignored
assign RAM_D = ~X95_Q;		// Test mode ignored
assign RAM_D = ~Y131_Q;		// Test mode ignored

wire [3:0] AD109_Q;
FDS AD109(clk_12M, AG64_Q, AD109_Q);
FDM X112(AJ1, ~&{AD109_Q[0], AM110}, X112_Q);	// Really AM110 in common ?
FDM X106(AJ1, ~&{AD109_Q[1], AM110}, X106_Q);
FDM Y111(AJ1, ~&{AD109_Q[2], AM110}, Y111_Q);
FDM Y105(AJ1, ~&{AD109_Q[3], AM110}, Y105_Q);
assign RAM_D = ~X112_Q;		// Test mode ignored
assign RAM_D = ~X106_Q;		// Test mode ignored
assign RAM_D = ~Y111_Q;		// Test mode ignored
assign RAM_D = ~Y105_Q;		// Test mode ignored

wire [3:0] AE104_Q;
FDS AE104(clk_12M, AG64_Q, AE104_Q);
FDM AE135(AK13, ~&{AE104_Q[0], AM58}, AE135_Q);
FDM AE129(AK13, ~&{AE104_Q[1], AM58}, AE129_Q);
FDM AE95(AK13, ~&{AE104_Q[2], AM}, AE95_Q);
FDM AF92(AK13, ~&{AE104_Q[3], AM58}, AF92_Q);
assign RAM_D = ~AE104_Q;	// Test mode ignored
assign RAM_D = ~AE129_Q;	// Test mode ignored
assign RAM_D = ~AE95_Q;		// Test mode ignored
assign RAM_D = ~AF92_Q;		// Test mode ignored


wire [3:0] AG4_Q;
assign AH85 = ~&{(AR71 | OC[0]),(AG64_Q[0] | AH64)};
assign AH87 = ~&{(AR71 | OC[1]),(AG64_Q[1] | AH64)};
assign AH90 = ~&{(AR71 | OC[2]),(AG64_Q[2] | AH64)};
assign AH93 = ~&{(AR71 | OC[3]),(AG64_Q[3] | AH64)};
FDS AG4(clk_12M, {~AH93, ~AH92, ~AH89, ~AH84}, AG4_Q);

wire [3:0] AG24_Q;
FDS AG24(clk_12M, AG4_Q, AG24_Q);
FDM AG135(AK13, ~&{AG24_Q[0], AM58}, AG135_Q);
FDM AF72(AK13, ~&{AG24_Q[1], AM58}, AF72_Q);
FDM AF66(AK13, ~&{AG24_Q[2], AM58}, AF66_Q);
FDM AF111(AK13, ~&{AG24_Q[3], AM58}, AF111_Q);
assign RAM_D = ~AG135_Q;	// Test mode ignored
assign RAM_D = ~AF72_Q;		// Test mode ignored
assign RAM_D = ~AF66_Q;		// Test mode ignored
assign RAM_D = ~AF111_Q;	// Test mode ignored

wire [3:0] AG44_Q;
FDS AG44(clk_12M, AG4_Q, AG44_Q);
FDM AG106(AK13, ~&{AG44_Q[0], AK13}, AG106_Q);
FDM AG112(AK13, ~&{AG44_Q[1], AK13}, AG112_Q);
FDM AF30(AK13, ~&{AG44_Q[2], AK13}, AF30_Q);
FDM AG129(AK13, ~&{AG44_Q[3], AK13}, AG129_Q);
assign RAM_D = ~AG106_Q;	// Test mode ignored
assign RAM_D = ~AG112_Q;	// Test mode ignored
assign RAM_D = ~AF30_Q;		// Test mode ignored
assign RAM_D = ~AG129_Q;	// Test mode ignored

wire [3:0] AC89_Q;
FDS AC89(clk_12M, AG4_Q, AC89_Q);
FDM W89(AJ1, ~&{AC89_Q[0], AJ1}, W89_Q);
FDM Z108(AJ1, ~&{AC89_Q[1], AJ1}, Z108_Q);
FDM W112(AJ1, ~&{AC89_Q[2], AJ1}, W112_Q);
FDM Z95(AJ1, ~&{AC89_Q[3], AJ1}, Z95_Q);
assign RAM_D = ~W89_Q;		// Test mode ignored
assign RAM_D = ~Z108_Q;		// Test mode ignored
assign RAM_D = ~W112_Q;		// Test mode ignored
assign RAM_D = ~Z95_Q;		// Test mode ignored

wire [3:0] AC109_Q;
FDS AC109(clk_12M, AG4_Q, AC109_Q);
FDM W95(AJ1, ~&{AC109_Q[0], AJ1}, W95_Q);
FDM Z89(AJ1, ~&{AC109_Q[1], AJ1}, Z89_Q);
FDM W106(AJ1, ~&{AC109_Q[2], AJ1}, W106_Q);
FDM Y89(AJ1, ~&{AC109_Q[3], AJ1}, Y89_Q);
assign RAM_D = ~W95_Q;		// Test mode ignored
assign RAM_D = ~Z89_Q;		// Test mode ignored
assign RAM_D = ~&W106_Q;	// Test mode ignored
assign RAM_D = ~Y89_Q;		// Test mode ignored


// LB ADDRESS

FDO AB95(AAC98, DB_IN[3], RES_SYNC, AB95_Q);
assign K108 = P1H ^ AB95_Q;
assign AK183 = ~K108;

assign J130 = P256H ^ AB95_Q;
assign R106 = ~|{(S89_Q[3] & AM58), (J130 & AM110)};
assign RAM_EFGH_A[7] = ~R106;		// Test mode ignored
assign R108 = ~|{(S89_Q[3] & AM110), (J130 & AM58)};
assign RAM_ABCD_A[7] = ~R108;		// Test mode ignored

assign K100 = P128H ^ AB95_Q;
assign R104 = ~|{(S89_Q[2] & AM58), (K100 & AM110)};
assign RAM_EFGH_A[6] = ~R104;		// Test mode ignored
assign R100 = ~|{(S89_Q[2] & AM110), (K100 & AM58)};
assign RAM_ABCD_A[6] = ~R100;		// Test mode ignored

assign K104 = P64H ^ AB95_Q;
assign R116 = ~|{(S89_Q[1] & AM58), (K104 & AM110)};
assign RAM_EFGH_A[5] = ~R116;		// Test mode ignored
assign R118 = ~|{(S89_Q[1] & AM110), (K104 & AM58)};
assign RAM_ABCD_A[5] = ~R118;		// Test mode ignored

assign K96 = P32H ^ AB95_Q;
assign R120 = ~|{(S89_Q[0] & AM58), (K96 & AM110)};
assign RAM_EFGH_A[4] = ~R120;		// Test mode ignored
assign P91 = ~|{(S89_Q[0] & AM110), (K96 & AM58)};
assign RAM_ABCD_A[4] = ~P91;		// Test mode ignored

assign A137 = P16H ^ AB95_Q;
assign N114 = ~|{(G89_Q[3] & AM58), (A137 & AM110)};
assign RAM_EFGH_A[3] = ~N114;		// Test mode ignored
assign N116 = ~|{(G89_Q[3] & AM110), (A137 & AM58)};
assign RAM_ABCD_A[3] = ~N116;		// Test mode ignored

assign J93 = P8H ^ AB95_Q;
assign N108 = ~|{(G89_Q[2] & AM58), (J93 & AM110)};
assign RAM_EFGH_A[2] = ~N108;		// Test mode ignored
assign N110 = ~|{(G89_Q[2] & AM110), (J93 & AM58)};
assign RAM_ABCD_A[2] = ~N110;		// Test mode ignored

assign J89 = P4H ^ AB95_Q;
assign N89 = ~|{(G89_Q[1] & AM58), (J89 & AM110)};
assign RAM_EFGH_A[1] = ~N89;		// Test mode ignored
assign N91 = ~|{(G89_Q[1] & AM110), (J89 & AM58)};
assign RAM_ABCD_A[1] = ~N91;		// Test mode ignored

assign J134 = P2H ^ AB95_Q;
assign N118 = ~|{(G89_Q[0] & AM58), (J134 & AM110)};
assign RAM_EFGH_A[0] = ~N118;		// Test mode ignored
assign N128 = ~|{(G89_Q[0] & AM110), (J134 & AM58)};
assign RAM_ABCD_A[0] = ~N128;		// Test mode ignored

wire [3:0] AH4_Q;
FDS AH4(clk_12M, {AW136, AW131, AW110, AW115}, AH4_Q);
FDM AF56(AK13, ~&{AH4_Q[0], AM58}, AF56_Q);
FDM AF24(AK13, ~&{AH4_Q[1], AM58}, AF24_Q);
FDM AF133(AK13, ~&{AH4_Q[2], AM58}, AF133_Q);
FDM AF127(AK13, ~&{AH4_Q[3], AM58}, AF127_Q);
assign RAM_E_DIN[0] = ~AF56_Q;		// Test mode ignored
assign RAM_E_DIN[1] = ~AF24_Q;		// Test mode ignored
assign RAM_E_DIN[2] = ~AF133_Q;		// Test mode ignored
assign RAM_E_DIN[3] = ~AF127_Q;		// Test mode ignored

wire [3:0] AJ23_Q;
FDS AJ23(clk_12M, {AW136, AW131, AW110, AW115}, AJ23_Q);
FDM V96(AJ1, ~&{AJ23_Q[0], COM1}, V96_Q);
FDM V90(AJ1, ~&{AJ23_Q[1], COM1}, V90_Q);
FDM R110(AJ1, ~&{AJ23_Q[2], COM1}, R110_Q);
FDM T129(AJ1, ~&{AJ23_Q[3], COM1}, T129_Q);
assign RAM_E_DIN[4] = ~V96_Q;			// Test mode ignored
assign RAM_E_DIN[5] = ~V90_Q;			// Test mode ignored
assign RAM_E_DIN[6] = ~R110_Q;		// Test mode ignored
assign RAM_E_DIN[7] = ~T129_Q;		// Test mode ignored


// REG 1

assign AG191 = ~|{(RAM_C_DOUT & nPAIR_OUT), (RAM_G_DOUT & PAIR_OUT)};
FDM AK196(P1H, AG191, AK196_Q);
assign AG198 = ~|{(RAM_D_DOUT & nPAIR_OUT), (RAM_H_DOUT & PAIR_OUT)};
FDM AK154(P1H, AG198, AK154_Q);
assign AK160 = ~|{(AK196_Q & AK183), (AK154_Q & K108)};
FDM AL196(clk_6M, AK160, AL196_Q);

assign AAC104 = |{AV104, OREG, AB[1], ~AB[0]};
FDO AJ128(AAC104, DB_IN[0], RES_SYNC, AJ128_Q);
assign AL203 = ~^{AL196_Q, AJ128_Q};

FDO AJ91(AAC104, DB_IN[1], RES_SYNC, AJ91_Q);
assign AK112 = AG64_Q[3] | AJ91_Q;

FDO AJ84(AAC104, DB_IN[2], RES_SYNC, AJ84_Q);

assign AK132 = &{AV134, AV129, AV112, AV107};
assign AK114 = &{AJ84_Q, AJ91_Q, AK132};
FDM AJ55(clk_12M, AK114, AJ55_Q);

assign AK138 = &{AW136, AW131, AW110, AW115};
assign AK117 = &{AJ84_Q, AJ91_Q, AK138};
FDM AJ135(clk_12M, AK117, AJ135_Q);

FDM AH65(AJ1, ~&{AJ55_Q, AM110}, AH65_Q);
FDM AH132(AK13, ~&{AJ55_Q, AM58}, AH132_Q);
FDM AH108(AJ1, ~&{AJ135_Q, AM110}, AH108_Q);
FDM AH114(AK13, ~&{AJ135_Q, AM58}, AH114_Q);


// ROOT SHEET 7

FDN AT130(clk_24M, ~^{AT130_Q, ~&{~clk_6M, ~clk_12M}}, AT130_Q, AT130_XQ);
FDE AS65(clk_24M, ~AT130_XQ, RES_SYNC, AS65_Q);
FDO K89(clk_6M, AS65_Q, P1H);

FDO AT106(clk_24M, AT130_XQ, RES, AT106_Q, AT106_XQ);
FDO AT89(clk_24M, AT106_Q, RES_SYNC, AT89_Q);
FDO AT96(clk_24M, AT189_Q, RES_SYNC, AT96_Q);

FDO AV89(clk_24M, ~&{AT106_XQ, AT96_Q, NRD}, RES_SYNC, AV104);


assign AR73 = ~|{(AR128_XQ & AR71), (OHF & ~AR71)};
FDM AR128(clk_12M, AR73, AR128_Q, AR128_XQ);

assign AAC98 = |{AV104, OREG, AB[1:0]};
FDO AM90(AAC98, DB_IN[5], RES_SYNC, , nROMRDEN);


assign AN116 = HVIN & RES;
FDN AN130(clk_12M, ~^{AP134, AN130_XQ}, AN116, AN130_Q, AN130_XQ);
FDN AN106(clk_12M, AN130_Q, AN116, AN106_Q, AN106_XQ);
assign PAIR_OUT = AN106_Q;		// Must be delayed !
assign nPAIR_OUT = AN106_XQ;	// Must be delayed !
assign AM12 = ~|{(AN106_XQ & ~clk_6M), AV139};
assign AM69 = ~AM12;			// Test mode ignored


FDM AR16(~clk_12M, ~|{~P1H, clk_6M}, AR16_Q);
assign AS34 = ~|{(AR16_Q & ~OHF), (1'b1 & OHF)};
FDM AS90(clk_12M, AS34, , AS90_XQ);
assign AAC138 = AS90_XQ;
assign AAB137 = AS90_XQ;
assign AP200 = AS90_XQ;
assign AX157 = AS90_XQ;
assign AR150 = AS90_XQ;
assign AV143 = AS90_XQ;
assign AN163 = AS90_XQ;
assign AAA93 = AS90_XQ;

assign AS36 = ~|{(1'b1 & ~OHF), (AR16_Q & OHF)};
FDM AS84(clk_12M, AS36, , AS84_XQ);
assign AN143 = AS84_XQ;
assign AP201 = AS84_XQ;
assign AAB138 = AS84_XQ;
assign AAC139 = AS84_XQ;
assign AY138 = AS84_XQ;
assign AW142 = AS84_XQ;
assign AT148 = AS84_XQ;
assign AS142 = AS84_XQ;


assign AK129 = |{AV134, AV129, AV112, AV107};

assign AK135 = |{AW136, AW131, AW110, AW115};

assign AM128 = ~&{AK129, AR135_XQ, AN93_Q};
assign AL57 = ~|{(P1H & ~AN130_Q), (AM128 & AN130_Q)};
FDM AL24(clock_12M, AL57, AL24_Q);
FDM AK7(AM12, AL24_Q, AK7_Q);
assign AL55 = ~|{(AM128 & ~AN130_Q), (P1H & AN130_Q)};
FDM AL7(clock_12M, AL55, AL7_Q);
FDM AK24(AM12, AL7_Q, AK24_Q);

assign AL89 = ~&{AK135, AR104_Q, AM104_Q};
assign AL64 = ~|{(AL89 & ~AN130_Q), (P1H & AN130_Q)};
FDM AL30(clock_12M, AL64, AL30_Q);
FDM AK30(AM12, AL30_Q, AK30_Q);
assign AL66 = ~|{(P1H & ~AN130_Q), (AL89 & AN130_Q)};
FDM AL1(clock_12M, AL66, AL1_Q);
FDM AK1(AM12, AL1_Q, AK1_Q);

assign AL79 = AK117 | AL89;
assign AL74 = ~|{(P1H & ~AN130_Q), (AL79 & AN130_Q)};
FDM AK44(clock_12M, AL74, AK44_Q);
FDM AK36(AM12, AK44_Q, AK36_Q);
assign AL72 = ~|{(AL79 & ~AN130_Q), (P1H & AN130_Q)};
FDM AK64(clock_12M, AL72, AK64_Q);
FDM AK50(AM12, AK64_Q, AK50_Q);

assign AL77 = AK114 | AM128;
assign AL70 = ~|{(P1H & ~AN130_Q), (AL77 & AN130_Q)};
FDM AK84(clock_12M, AL70, AK44_Q);
FDM AK90(AM12, AK48_Q, AK90_Q);
assign AL68 = ~|{(AL77 & ~AN130_Q), (P1H & AN130_Q)};
FDM AK70(clock_12M, AL68, AK70_Q);
FDM AK76(AM12, AK70_Q, AK76_Q);


// ROOT SHEET 8

reg [11:0] PARITY_SEL_REG;	// Final output on OB* pins

assign RAOE = &{(1'b0 | ~nROMRDEN), (NRD | nROMRDEN)};

// All the muxes are test mode related, safe to ignore
assign OB = PARITY_SEL_REG;
assign SHAD = ~AL203;

// ROOT SHEET 9

wire [3:0] AH24_Q;
FDS AH24(clk_12M, {AV134, AV129, AV112, AV107}, AH24_Q);
FDM AB105(AK13, ~&{AH24_Q[0], AM58}, AB105_Q);
FDM AB89(AK13, ~&{AH24_Q[1], AM58}, AB89_Q);
FDM AF50(AK13, ~&{AH24_Q[2], AM58}, AF50_Q);
FDM AF36(AK13, ~&{AH24_Q[3], AM58}, AF36_Q);
assign RAM_F_DIN[0] = ~AB105_Q;		// Test mode ignored
assign RAM_F_DIN[1] = ~AB89_Q;		// Test mode ignored
assign RAM_F_DIN[2] = ~AF50_Q;		// Test mode ignored
assign RAM_F_DIN[3] = ~AF36_Q;		// Test mode ignored

wire [3:0] AH44_Q;
FDS AH44(clk_12M, {AV134, AV129, AV112, AV107}, AH44_Q);
FDM W132(AK13, ~&{AH44_Q[0], COM1}, W132_Q);
FDM V108(AK13, ~&{AH44_Q[1], COM1}, V108_Q);
FDM T135(AK13, ~&{AH44_Q[2], COM1}, T135_Q);
FDM V131(AK13, ~&{AH44_Q[3], COM1}, V131_Q);
assign RAM_F_DIN[4] = ~W132_Q;		// Test mode ignored
assign RAM_F_DIN[5] = ~V108_Q;		// Test mode ignored
assign RAM_F_DIN[6] = ~T135_Q;		// Test mode ignored
assign RAM_F_DIN[7] = ~V131_Q;		// Test mode ignored

// ROOT SHEET 10

wire [11:0] PAIR_SEL_EVEN = PAIR_OUT ? RAM_A_DOUT : RAM_E_DOUT;
wire [11:0] PAIR_SEL_ODD = PAIR_OUT ? RAM_B_DOUT : RAM_F_DOUT;

reg [11:0] PAIR_SEL_EVEN_REG;	// A/E
reg [11:0] PAIR_SEL_ODD_REG;	// B/F
always @(posedge P1H) begin
	PAIR_SEL_EVEN_REG <= PAIR_SEL_EVEN;
	PAIR_SEL_ODD_REG <= PAIR_SEL_ODD;
end

assign K108 = P1H ^ AB95_Q;

wire [11:0] PARITY_SEL = K108 ? PAIR_SEL_EVEN_REG : PAIR_SEL_ODD_REG;

always @(posedge clk_6M)
	PARITY_SEL_REG <= PARITY_SEL;

assign PC0F = ~|{PARITY_SEL_REG[3:0]};
assign NC00 = ~&{PARITY_SEL_REG[3:0]};


// DELAYS

reg [5:0] HEND_DELAY;
always @(posedge clk_12M or negedge RES) begin
	if (!RES) begin
		HEND_DELAY <= 6'b000000;
	end else begin
		HEND_DELAY <= {HEND_DELAY[4:0], HEND};
	end
end
assign AR44_Q = HEND_DELAY[2];
assign AP71_Q = HEND_DELAY[5];
assign AR71 = HEND_DELAY[4];
assign AH64 = ~AR71;

reg [7:0] HVIN_DELAY;
always @(posedge clk_6M or negedge RES_SYNC) begin
	if (!RES) begin
		HVIN_DELAY <= 8'd0;
	end else begin
		HVIN_DELAY <= {HVIN_DELAY[6:0], HEND};
	end
end
assign D94_XQ = ~HVIN_DELAY[7];

FDN AN84(clk_6M, AN15_Q, RES, AN84_Q);
FDM AP52(~clk_12M, AN84_Q | clk_6M, AP52_Q);
reg [4:0] AN15_DELAY;
always @(posedge clk_12M or negedge RES) begin
	if (!RES) begin
		AN15_DELAY <= 5'b00000;
	end else begin
		AN15_DELAY <= {AN15_DELAY[3:0], AP52_Q};
	end
end
assign AP134 = ~AN15_DELAY[4];

reg [6:0] NEWLINE_DELAY;
always @(posedge clk_6M or negedge RES) begin
	if (!RES) begin
		NEWLINE_DELAY <= 7'b000000;
	end else begin
		NEWLINE_DELAY <= {NEWLINE_DELAY[5:0], nNEW_LINE};
	end
end
assign AN15_Q = NEWLINE_DELAY[6];

FJD AR4(clk_12M, ~HEND, HEND & AR16_Q, AN15_Q & RES, , AR4_Q);
BD3 AS135(AR4_Q, AS135_OUT);

reg [3:0] AS135_DELAY;
always @(posedge clk_12M or negedge RES) begin
	if (!RES) begin
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
