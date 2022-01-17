// TMNT arcade core
// Simulation blind schematic copy version
// Sean Gonsalves 2022
`timescale 1ns/100ps

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
	
	input CARY, LACH, HEND, OREG, OHF,
	
	input [1:0] TE
);


// ROOT SHEET 1

wire [3:0] C89_Q;
wire [3:0] E93_Q;
C43 C89(clk_6M, 4'b0000, nNEW_LINE, J97, J97, RES_SYNC, C89_Q, C89_CO);
C43 E93(clk_6M, 4'b0001, nNEW_LINE, C89_CO, C89_CO, RES_SYNC, E93_Q);

assign G137 = &{C89_CO, E93_Q[3:2]};
assign nNEW_LINE = ~|{G137, D94_XQ}:
assign J97 = AL126_XQ & K89_Q;
assign D89 = ~&{~C89_Q[3], C89_Q[2:0], J97};
assign B89 = ~D89;


assign P2H = C89_Q[0];

wire [3:0] A89_Q;
wire [3:0] B90_Q;
C43 B90(clk_6M, 4'b0011, HVOT, F117_Q, H104, RES_SYNC, B90_Q, B90_CO);
C43 A89(clk_6M, 4'b0111, HVOT, F117_Q, B90_CO, RES_SYNC, A89_Q, A89_CO);

FDO F110(B90_Q[3], &{A89_Q[2:0]}, ,F110_XQ);	// B138
LTL F132(A89[3], F89_Q, RES_SYNC, NVSY);

assign NCSY = &{NVSY, F89_Q};
assign HVOT = ~|{A89_CO, D94_XQ};


wire [3:0] AP4_Q;
C43 B90(clk_12M, {3'b000, HP[0]}, AR44_Q, CARY, CARY, RES, AP4_Q, B90_CO);


FDM AR33(clk_12M, CARY, AR33_Q);
FDM AN93(clk_12M, ~&{AP4_Q[0], AR33}, AN93_Q);	// AR76
FDM AN93(clk_12M, AN93_Q, AM104_Q);


assign H137 = RES_SYNC & (F103_Q | (P64H & C89_CO));
FDO(clk_6M, H137, RES_SYNC, F103_Q, F103_XQ);
FDN(clk_6M, H91, RES_SYNC & F130_XQ, NHSY, F89_XQ);
assign H91 = ~&{(F89_XQ | B89), (D89 | P32H)};
assign NCBK = F110_XQ & F103_Q;


assign AT137 = clk_24M;	// AT137 must be used for delaying M24 !
FDM AV96(~AT137, clk_M12, AV96_Q);
assign AV139 = ~&{AT137, AV96_Q}:
assign AK13 = ~|{AV139, (AN106_Q & ~clk_6M)};
assign AM130 = ~&{(AK13 | TE[1]), (AAC95 | ~TE[1])};	// Test select


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

assign CD_DIR[0] = ~NRD | nROMRD[0];
assign CD_DIR[1] = ~NRD | nROMRD[1];
assign CD_DIR[2] = ~NRD | nROMRD[2];
assign CD_DIR[3] = ~NRD | nROMRD[3];

assign DB_DIR = NRD | &{AAD137, AAD132, AAD139, AAD108};	// AAD151 AAD142


// ROOT SHEET 2

/*wire [3:0] AX104_Q;
assign AY138 = ~AAA94;
assign AAA93 = ~AAA92;
T34 AY113({1'b0, AAA94, AAA93}, {AAA93, AY138, CD3[7]}, {AAA92, AY138, AX104_Q[1]}, {AAA92, AAA94, AX104_Q[0]});
T34 AY104({AX104_Q[0], AAA94, AAA93}, {AAA93, AY138, CD3[5]}, {AAA92, AY138, AX104_Q[2]}, {AAA92, AAA94, AX104_Q[1]});
T34 AY129({AX104_Q[1], AAA94, AAA93}, {AAA93, AY138, CD3[3]}, {AAA92, AY138, AX104_Q[3]}, {AAA92, AAA94, AX104_Q[2]});
T34 AY89({AX104_Q[2], AAA94, AAA93}, {AAA93, AY138, CD3[1]}, {AAA92, AY138, 1'b0}, {AAA92, AAA94, AX104_Q[3]});
FDS AX104(clk_12M, {~AY89, ~AX92, ~AY139, ~AY113}, AX104_Q);*/

wire [3:0] SH1_OUT;	// 3 ODD
SHIFTER SH1(clk_12M, {AAA94, AAA92}, {CD3[7], CD3[5], CD3[3], CD3[1]}, SH1_OUT);
wire [3:0] SH2_OUT;	// 2 ODD
SHIFTER SH2(clk_12M, {AX138, AAA138}, {CD2[7], CD2[5], CD2[3], CD2[1]}, SH2_OUT);
wire [3:0] SH3_OUT;	// 1 ODD
SHIFTER SH3(clk_12M, {AX139, AAA139}, {CD1[7], CD1[5], CD1[3], CD1[1]}, SH3_OUT);
wire [3:0] SH4_OUT;	// 0 ODD
SHIFTER SH4(clk_12M, {AX140, AAA140}, {CD0[7], CD0[5], CD0[3], CD0[1]}, SH4_OUT);


FDM AS129(clk_12M, AR110_Q, AS129_Q, AS129_XQ);

// AR128_XQ2 wrong ?

assign AP158 = ~|{(AN204_Q[0] & AR128_Q), (AS184_Q[3] & AR128_XQ)};
assign AP162 = ~|{(AS184_Q[0] & AR128_Q), (AN204_Q[3] & AR128_XQ)};
assign AP156 = ~|{(AN204_Q[0] & AR128_XQ2), (AS184_Q[3] & AR128_XQ)};
FDM AW89(clk_12M, AP156, AW89_Q);
assign AV134 = ~|{AP158, AS129_Q, AR135_Q, AP162, AS129_XQ, AR135_Q};
assign AW136 = ~|{AP162, AS129_Q, AR104_XQ, AW89, AS129_XQ, AR104_XQ};

assign AP152 = ~|{(AZ104_Q[0] & AR128_Q), (AS204_Q[3] & AR128_XQ)};
assign AR142 = ~|{(AS204_Q[0] & AR128_Q), (AZ104_Q[3] & AR128_XQ)};
assign AP150 = ~|{(AZ104_Q[0] & AR128_XQ2), (AS204_Q[3] & AR128_XQ)};
FDM AW104(clk_12M, AP150, AW104_Q);
assign AV112 = ~|{AP152, AS129_Q, AR135_Q, AR142, AS129_XQ, AR135_Q};
assign AW110 = ~|{AR142, AS129_Q, AR104_XQ, AW104, AS129_XQ, AR104_XQ};

assign AP154 = ~|{(AS4_Q[0] & AR128_Q), (AR204_Q[3] & AR128_XQ)};
assign AR160 = ~|{(AR204_Q[0] & AR128_Q), (AS4_Q[3] & AR128_XQ)};
assign AP142 = ~|{(AS4_Q[0] & AR128_XQ2), (AR204_Q[3] & AR128_XQ)};
FDM AW95(clk_12M, AP142, AW95_Q);
assign AV129 = ~|{AP154, AS129_Q, AR135_Q, AP160, AS129_XQ, AR135_Q};
assign AW131 = ~|{AP160, AS129_Q, AR104_XQ, AW95, AS129_XQ, AR104_XQ};

assign AX128 = ~|{(AAA104_Q[0] & AR128_Q), (AX104_Q[3] & AR128_XQ)};
assign AX93 = ~|{(AX104_Q[0] & AR128_Q), (AAA104_Q[3] & AR128_XQ)};
assign AX130 = ~|{(AAA104_Q[0] & AR128_XQ2), (AX104_Q[3] & AR128_XQ)};
FDM AX132(clk_12M, AX130, AX132_Q);
assign AV107 = ~|{AX128, AS129_Q, AR135_Q, AX93, AS129_XQ, AR135_Q};
assign AW115 = ~|{AX93, AS129_Q, AR104_XQ, AX132, AS129_XQ, AR104_XQ};


// SHIFTERS 2

wire [3:0] SH5_OUT;	// 3 EVEN
SHIFTER SH5(clk_12M, {AAC118, AAC117}, {CD3[6], CD3[4], CD3[2], CD3[0]}, SH5_OUT);
wire [3:0] SH6_OUT;	// 2 EVEN
SHIFTER SH6(clk_12M, {AAB140, AAB139}, {CD2[6], CD2[4], CD2[2], CD2[0]}, SH6_OUT);
wire [3:0] SH7_OUT;	// 1 EVEN
SHIFTER SH7(clk_12M, {AX90, AAA91}, {CD1[6], CD1[4], CD1[2], CD1[0]}, SH7_OUT);
wire [3:0] SH8_OUT;	// 0 EVEN
SHIFTER SH8(clk_12M, {AX91, AAA137}, {CD0[6], CD0[4], CD0[2], CD0[0]}, SH8_OUT);


// ROOT SHEET 3

wire [3:0] G89_Q;
wire [3:0] S89_Q;
C43 G89(clk_12M, HP[4:1], AP71_Q, AM104_Q, AM104_Q, 1'b1, G89_Q, G89_CO);
C43 S89(clk_12M, HP[8:5], AP71_Q, G89_CO, G89_CO, 1'b1, S89_Q);


assign CD0_OUT = AS245 ? DB_IN : 8'h00;
assign CD1_OUT = AP243 ? DB_IN : 8'h00;
assign CD2_OUT = AS243 ? DB_IN : 8'h00;
assign CD3_OUT = AP242 ? DB_IN : 8'h00;


FDO AL133(TE[0], DB_IN[1], RES_SYNC, AL133_Q);
FDO AL126(TE[0], DB_IN[5], RES_SYNC, AL126_Q);	// AL126_XQ ?
assign F130 = AL133_Q | G137;
assign H104 = F130 & F117_Q;
FDO F117(clk_6M, ~|{(F117_XQ ^ F130), D94_XQ}, RES_SYNC, F117_Q, F117_XQ);


// PALETTE LATCHES

wire [3:0] AG64_Q;
assign AG104 = ~&{(AR71 | OC[4]),(AG64[0] | AH64)};
assign AG85 = ~&{(AR71 | OC[5]),(AG64[1] | AH64)};
assign AG87 = ~&{(AR71 | OC[6]),(AG64[2] | AH64)};
assign AH96 = ~&{(AR71 | OC[7]),(AG64[3] | AH64)};
FDS AG64(clk_12M, {~AH96, ~AG87, ~AG85, ~AG104}, AG64_Q};

wire [3:0] AF4_Q;
FDS AF4(clk_12M, AG64_Q, AF4_Q};
FDM AF44(AK13, ~&{AF4_Q[0], AAC92}, AF44_Q);
FDM AF104(AK13, ~&{AF4_Q[1], AAC92}, AF104_Q);
FDM AC130(AK13, ~&{AF4_Q[2], AAC92}, AC130_Q);
FDM AC131(AK13, ~&{AF4_Q[3], AAC92}, AC131_Q);
assign RAM_D = ~&{(AF44_Q | TE[1]), (CD1[0] | ~TE[1])};		// Test select
assign RAM_D = ~&{(AF105_Q | TE[1]), (CD1[1] | ~TE[1])};	// Really CD1 ? Not OC ?
assign RAM_D = ~&{(AE89_Q | TE[1]), (CD1[2] | ~TE[1])};
assign RAM_D = ~&{(AF86_Q | TE[1]), (CD1[3] | ~TE[1])};

wire [3:0] AD89_Q;
FDS AD89(clk_12M, AG64_Q, AD89_Q};
FDM X131(AJ1, ~&{AD89_Q[0], AM110}, X131_Q);
FDM X89(AJ1, ~&{AD89_Q[1], AM110}, X89_Q);
FDM X95(AJ1, ~&{AD89_Q[2], AM110}, X95_Q);
FDM Y131(AJ1, ~&{AD89_Q[3], AM110}, Y131_Q);
assign RAM_D = ~&{(X131_Q | TE[1]), (CD1[0] | ~TE[1])};	// Test select
assign RAM_D = ~&{(X89_Q | TE[1]), (CD1[1] | ~TE[1])};
assign RAM_D = ~&{(X95_Q | TE[1]), (CD1[2] | ~TE[1])};
assign RAM_D = ~&{(Y131_Q | TE[1]), (CD1[3] | ~TE[1])};

wire [3:0] AD109_Q;
FDS AD109(clk_12M, AG64_Q, AD109_Q};
FDM X112(AJ1, ~&{AD109_Q[0], AM110}, X112_Q);	// Really AM110 in common ?
FDM X106(AJ1, ~&{AD109_Q[1], AM110}, X106_Q);
FDM Y111(AJ1, ~&{AD109_Q[2], AM110}, Y111_Q);
FDM Y105(AJ1, ~&{AD109_Q[3], AM110}, Y105_Q);
assign RAM_D = ~&{(X112_Q | TE[1]), (CD1[0] | ~TE[1])};	// Test select
assign RAM_D = ~&{(X106_Q | TE[1]), (CD1[1] | ~TE[1])};
assign RAM_D = ~&{(Y111_Q | TE[1]), (CD1[2] | ~TE[1])};
assign RAM_D = ~&{(Y105_Q | TE[1]), (CD1[3] | ~TE[1])};

wire [3:0] AE104_Q;
FDS AE104(clk_12M, AG64_Q, AE104_Q};
FDM AE135(AK13, ~&{AE104_Q[0], AM58}, AE135_Q);
FDM AE129(AK13, ~&{AE104_Q[1], AM58}, AE129_Q);
FDM AE95(AK13, ~&{AE104_Q[2], AM}, AE95_Q);
FDM AF92(AK13, ~&{AE104_Q[3], AM58}, AF92_Q);
assign RAM_D = ~&{(AE104_Q | TE[1]), (CD1[0] | ~TE[1])};// Test select
assign RAM_D = ~&{(AE129_Q | TE[1]), (CD1[1] | ~TE[1])};
assign RAM_D = ~&{(AE95_Q | TE[1]), (CD1[2] | ~TE[1])};
assign RAM_D = ~&{(AF92_Q | TE[1]), (CD1[3] | ~TE[1])};


wire [3:0] AG4_Q;
assign AH85 = ~&{(AR71 | OC[0]),(AG64[0] | AH64)};
assign AH87 = ~&{(AR71 | OC[1]),(AG64[1] | AH64)};
assign AH90 = ~&{(AR71 | OC[2]),(AG64[2] | AH64)};
assign AH93 = ~&{(AR71 | OC[3]),(AG64[3] | AH64)};
FDS AG4(clk_12M, {~AH93, ~AH92, ~AH89, ~AH84}, AG4_Q};

wire [3:0] AG24_Q;
FDS AG24(clk_12M, AG4_Q, AG24_Q};
FDM AG135(AK13, ~&{AG24_Q[0], AM58}, AG135_Q);
FDM AF72(AK13, ~&{AG24_Q[1], AM58}, AF72_Q);
FDM AF66(AK13, ~&{AG24_Q[2], AM58}, AF66_Q);
FDM AF111(AK13, ~&{AG24_Q[3], AM58}, AF111_Q);
assign RAM_D = ~&{(AG135_Q | TE[1]), (OC[4] | ~TE[1])};	// Test select
assign RAM_D = ~&{(AF72_Q | TE[1]), (OC[5] | ~TE[1])};
assign RAM_D = ~&{(AF66_Q | TE[1]), (OC[6] | ~TE[1])};
assign RAM_D = ~&{(AF111_Q | TE[1]), (OC[7] | ~TE[1])};

wire [3:0] AG44_Q;
FDS AG44(clk_12M, AG4_Q, AG44_Q};
FDM AG106(AK13, ~&{AG44_Q[0], AK13}, AG106_Q);
FDM AG112(AK13, ~&{AG44_Q[1], AK13}, AG112_Q);
FDM AF30(AK13, ~&{AG44_Q[2], AK13}, AF30_Q);
FDM AG129(AK13, ~&{AG44_Q[3], AK13}, AG129_Q);
assign RAM_D = ~&{(AG106_Q | TE[1]), (OC[4] | ~TE[1])};	// Test select
assign RAM_D = ~&{(AG112_Q | TE[1]), (OC[5] | ~TE[1])};
assign RAM_D = ~&{(AF30_Q | TE[1]), (OC[6] | ~TE[1])};
assign RAM_D = ~&{(AG129_Q | TE[1]), (OC[7] | ~TE[1])};

wire [3:0] AC89_Q;
FDS AC89(clk_12M, AG4_Q, AC89_Q};
FDM W89(AJ1, ~&{AC89_Q[0], AJ1}, W89_Q);
FDM Z108(AJ1, ~&{AC89_Q[1], AJ1}, Z108_Q);
FDM W112(AJ1, ~&{AC89_Q[2], AJ1}, W112_Q);
FDM Z95(AJ1, ~&{AC89_Q[3], AJ1}, Z95_Q);
assign RAM_D = ~&{(W89_Q | TE[1]), (OC[4] | ~TE[1])};	// Test select
assign RAM_D = ~&{(Z108_Q | TE[1]), (OC[5] | ~TE[1])};
assign RAM_D = ~&{(W112_Q | TE[1]), (OC[6] | ~TE[1])};
assign RAM_D = ~&{(Z95_Q | TE[1]), (OC[7] | ~TE[1])};

wire [3:0] AC109_Q;
FDS AC109(clk_12M, AG4_Q, AC109_Q};
FDM W95(AJ1, ~&{AC109_Q[0], AJ1}, W95_Q);
FDM Z89(AJ1, ~&{AC109_Q[1], AJ1}, Z89_Q);
FDM W106(AJ1, ~&{AC109_Q[2], AJ1}, W106_Q);
FDM Y89(AJ1, ~&{AC109_Q[3], AJ1}, Y89_Q);
assign RAM_D = ~&{(W95_Q | TE[1]), (OC[4] | ~TE[1])};// Test select
assign RAM_D = ~&{(Z89_Q | TE[1]), (OC[5] | ~TE[1])};
assign RAM_D = ~&{(W106_Q | TE[1]), (OC[6] | ~TE[1])};
assign RAM_D = ~&{(Y89_Q | TE[1]), (OC[7] | ~TE[1])};


// LB ADDRESS

FDO AB95(AAC98, DB_IN[3], RES_SYNC, AB95_Q);
assign K108 = K89_Q ^ AB95_Q;
assign AK183 = ~K108;

assign J130 = P256H ^ AB95_Q;
assign R106 = ~|{(S89_Q[3] & AM58), (J130 & AM110)};
assign RAM_A = ~&{(R106 | TE[1]), (HP[8] | P120)};	// Test select
assign R108 = ~|{(S89_Q[3] & AM110), (J130 & AM58)};
assign RAM_A = ~&{(R108 | TE[1]), (HP[8] | P120)};	// Test select

assign K104 = P64H ^ AB95_Q;
assign R116 = ~|{(S89_Q[1] & AM58), (K104 & AM110)};
assign RAM_A = ~&{(R116 | TE[1]), (HP[6] | P120)};	// Test select
assign R118 = ~|{(S89_Q[1] & AM110), (K104 & AM58)};
assign RAM_A = ~&{(R118 | TE[1]), (HP[6] | P120)};	// Test select

assign A137 = P16H ^ AB95_Q;
assign N114 = ~|{(G89_Q[3] & AM58), (A137 & AM110)};
assign RAM_A = ~&{(N114 | TE[1]), (HP[4] | P120)};	// Test select
assign N116 = ~|{(G89_Q[3] & AM110), (A137 & AM58)};
assign RAM_A = ~&{(N116 | TE[1]), (HP[4] | P120)};	// Test select

assign K96 = P32H ^ AB95_Q;
assign R120 = ~|{(S89_Q[0] & AM58), (K96 & AM110)};
assign RAM_A = ~&{(R120 | TE[1]), (HP[5] | P120)};	// Test select
assign P91 = ~|{(S89_Q[0] & AM110), (K96 & AM58)};
assign RAM_A = ~&{(P91 | TE[1]), (HP[5] | P120)};	// Test select

assign K100 = P128H ^ AB95_Q;
assign R104 = ~|{(S89_Q[2] & AM58), (K100 & AM110)};
assign RAM_A = ~&{(R104 | TE[1]), (HP[7] | P120)};	// Test select
assign R100 = ~|{(S89_Q[2] & AM110), (K100 & AM58)};
assign RAM_A = ~&{(R100 | TE[1]), (HP[7] | P120)};	// Test select

assign J93 = P8H ^ AB95_Q;
assign N108 = ~|{(S89_Q[2] & AM58), (J93 & AM110)};	// Certainly not S89_Q[2] !
assign RAM_A = ~&{(N108 | TE[1]), (HP[3] | P120)};	// Test select
assign N110 = ~|{(S89_Q[2] & AM110), (J93 & AM58)};	// Certainly not S89_Q[2] !
assign RAM_A = ~&{(N110 | TE[1]), (HP[3] | P120)};	// Test select

assign J89 = P4H ^ AB95_Q;
assign N89 = ~|{(G89_Q[1] & AM58), (J89 & AM110)};
assign RAM_A = ~&{(N89 | TE[1]), (HP[2] | P120)};	// Test select
assign N91 = ~|{(G89_Q[1] & AM110), (J89 & AM58)};
assign RAM_A = ~&{(N91 | TE[1]), (HP[2] | P120)};	// Test select

assign J134 = P2H ^ AB95_Q;
assign N118 = ~|{(G89_Q[0] & AM58), (J134 & AM110)};
assign RAM_A = ~&{(N118 | TE[1]), (HP[1] | P120)};	// Test select
assign N128 = ~|{(G89_Q[0] & AM110), (J134 & AM58)};
assign RAM_A = ~&{(N128 | TE[1]), (HP[1] | P120)};	// Test select

wire [3:0] AH4_Q;
FDS AH4(clk_12M, {AW136, AW131, AW110, AW115}, AH4_Q);
FDM AF56(AK13, ~&{AH4_Q[0], AM58}, AF56_Q);
FDM AF24(AK13, ~&{AH4_Q[1], AM58}, AF24_Q);
FDM AF133(AK13, ~&{AH4_Q[2], AM58}, AF133_Q);
FDM AF127(AK13, ~&{AH4_Q[3], AM58}, AF127_Q);
assign RAM_E = ~&{(AF56_Q | Z130), (OC[0] | ~TE[1])};
assign RAM_E = ~&{(AF24_Q | Z130), (OC[1] | ~TE[1])};
assign RAM_E = ~&{(AF133_Q | Z130), (OC[2] | ~TE[1])};
assign RAM_E = ~&{(AF127_Q | Z130), (OC[3] | ~TE[1])};

wire [3:0] AJ23_Q;
FDS AJ23(clk_12M, {AW136, AW131, AW110, AW115}, AJ23_Q);
FDM V96(AJ1, ~&{AJ23_Q[0], COM1}, V96_Q);
FDM V90(AJ1, ~&{AJ23_Q[1], COM1}, V90_Q);
FDM R110(AJ1, ~&{AJ23_Q[2], COM1}, R110_Q);
FDM T129(AJ1, ~&{AJ23_Q[3], COM1}, T129_Q);
assign RAM_E = ~&{(V96_Q | Z130), (OC[0] | ~TE[1])};
assign RAM_E = ~&{(V90_Q | Z130), (OC[1] | ~TE[1])};
assign RAM_E = ~&{(R110_Q | Z130), (OC[2] | ~TE[1])};
assign RAM_E = ~&{(T129_Q | Z130), (OC[3] | ~TE[1])};


// REG 1

assign AG191 = ~|{(AM155 & AM180), (AM210 & AL182)};
FDM AK196(P1H, AG191, AK196_Q);
assign AG198 = ~|{(AM177 & AM180), (AM199 & AL182)};
FDM AK154(P1H, AG198, AG154_Q);
assign AK160 = ~|{(AK196_Q & AK183), (AK154 & K108)};
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
assign AL182 = AN106_Q;		// Must be delayed !
assign AM180 = AN106_XQ;	// Must be delayed !
assign AM12 =~|{(AN106_XQ & ~clk_6M), AV139};
assign AM69 = ~&{(AM12 | TE[1]), (AAC95 | ~TE[1])};	// Test select


assign PCOF = ~|{A152_XQ, D152_XQ, C152_XQ, B152_XQ};
assign NCOO = ~&{A152_XQ, D152_XQ, C152_XQ, B152_XQ};


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
FDM AK7(AM12, AL24_Q, AK7);
assign AL55 = ~|{(AM128 & ~AN130_Q), (P1H & AN130_Q)};
FDM AL7(clock_12M, AL55, AL7_Q);
FDM AK24(AM12, AL7_Q, AK24);

assign AL89 = ~&{AK135, AR104_Q, AM104_Q};
assign AL64 = ~|{(AL89 & ~AN130_Q), (P1H & AN130_Q)};
FDM AL30(clock_12M, AL64, AL30_Q);
FDM AK30(AM12, AL30_Q, AK30);
assign AL66 = ~|{(P1H & ~AN130_Q), (AL89 & AN130_Q)};
FDM AL1(clock_12M, AL66, AL1_Q);
FDM AK1(AM12, AL1_Q, AK1);

assign AL79 = AK117 | AL89;
assign AL74 = ~|{(P1H & ~AN130_Q), (AL79 & AN130_Q)};
FDM AK44(clock_12M, AL74, AK44_Q);
FDM AK36(AM12, AK44_Q, AK36);
assign AL72 = ~|{(AL79 & ~AN130_Q), (P1H & AN130_Q)};
FDM AK64(clock_12M, AL72, AK64_Q);
FDM AK50(AM12, AK64_Q, AK50);

assign AL77 = AK114 | AM128;
assign AL70 = ~|{(P1H & ~AN130_Q), (AL77 & AN130_Q)};
FDM AK84(clock_12M, AL70, AK44_Q);
FDM AK90(AM12, AK48_Q, AK90);
assign AL68 = ~|{(AL77 & ~AN130_Q), (P1H & AN130_Q)};
FDM AK70(clock_12M, AL68, AK70_Q);
FDM AK76(AM12, AK70_Q, AK76);


// ROOT SHEET 8

assign RAOE = &{(1'b0 | ~nROMRDEN), (NRD | nROMRDEN)};

// All the muxes are test mode related, safe to ignore
assign OB[0] = ~AB155;
assign OB[1] = ~AB152;
assign OB[2] = ~AB156;
assign OB[3] = ~AB157;
assign OB[4] = ~AK181;
assign OB[5] = ~AK182;
assign OB[6] = ~AL163;
assign OB[7] = ~AL220;
assign OB[8] = ~AL221;
assign OB[9] = ~AL202;
assign OB[10] = ~AL222;
assign OB[11] = ~AL223;
assign SHAD = ~AL203;


// ROOT SHEET 9

wire [3:0] AH24_Q;
FDS AH24(clk_12M, {AV134, AV129, AV112, AV107}, AH24_Q};
FDM AB105(AK13, ~&{AH24_Q[0], AM58}, AB105_Q);
FDM AB89(AK13, ~&{AH24_Q[1], AM58}, AB89_Q);
FDM AF50(AK13, ~&{AH24_Q[2], AM58}, AF50_Q);
FDM AF36(AK13, ~&{AH24_Q[3], AM58}, AF36_Q);
assign RAM_F = ~&{(AB105_Q | Z130), (OC[0] | ~TE[1])};	// Test select
assign RAM_F = ~&{(AB89_Q | Z130), (OC[1] | ~TE[1])};
assign RAM_F = ~&{(AF50_Q | Z130), (OC[2] | ~TE[1])};
assign RAM_F = ~&{(AF36_Q | Z130), (OC[3] | ~TE[1])};

wire [3:0] AH44_Q;
FDS AH44(clk_12M, {AV134, AV129, AV112, AV107}, AH44_Q};
FDM W132(AK13, ~&{AH44_Q[0], COM1}, W132_Q);
FDM V108(AK13, ~&{AH44_Q[1], COM1}, V108_Q);
FDM T135(AK13, ~&{AH44_Q[2], COM1}, T135_Q);
FDM V131(AK13, ~&{AH44_Q[3], COM1}, V131_Q);
assign RAM_F = ~&{(W132_Q | Z130), (OC[0] | ~TE[1])};	// Test select
assign RAM_F = ~&{(V108_Q | Z130), (OC[1] | ~TE[1])};
assign RAM_F = ~&{(T135_Q | Z130), (OC[2] | ~TE[1])};
assign RAM_F = ~&{(V131_Q | Z130), (OC[3] | ~TE[1])};

// ROOT SHEET 10

assign AG212 = ~|{(AB138 & AM180), (AH201 & AL182)};
FDM AK216(P1H, AG212, AK216_Q);
assign AG156 = ~|{(F152 & AM180), (E155 & AL182)};
FDM AK210(P1H, AG156, AK210_Q);
assign AK202 = ~|{(AK216_Q & AK183), (AK210_Q & K108)};
FDM AL232(clk_6M, AK202, AL232_Q);
assign AL222 = ~AL232_Q;

assign AG154 = ~|{(Y138 & AM180), (X151 & AL182)};
FDM AH212(P1H, AG154, AH212_Q);
assign AG162 = ~|{(AB135 & AM180), (AD155 & AL182)};
FDM AH218(P1H, AG162, AH218_Q);
assign AH210 = ~|{(AH212_Q & AK183), (AH218_Q & K108)};
FDM C152(clk_6M, AH210, C152_Q);
assign AB152 = ~C152_Q;

// TODO: The rest of these...

reg [23:0] TEMP_A;
always @(posedge P1H) begin
	TEMP_A <= AM180 ? {AB138, F152, Y138, V152, AB135, G152, AB111, G155, AH135, S152, AB114, T152, AB129, S155, AH161, F155, AB126, T155, AH158, R155, AB132, E152, AB117, R152} :
						{AH201, E155, X151, H152, AD155, P155, N155, H155, W152, J152, AH198, K152, AG241, L152, V155, M152, AH241, J155, W155, K155, AG231, M155, AH238, L155};
end
reg [11:0] TEMP_B;
always @(posedge clk_6M) begin
	TEMP_B <= AK183 ? {TEMP_A[23], TEMP_A[21], TEMP_A[19], TEMP_A[17], TEMP_A[15], TEMP_A[13], TEMP_A[11], TEMP_A[9], TEMP_A[7], TEMP_A[5], TEMP_A[3], TEMP_A[1]} :
						{TEMP_A[22], TEMP_A[20], TEMP_A[18], TEMP_A[16], TEMP_A[14], TEMP_A[12], TEMP_A[10], TEMP_A[8], TEMP_A[6], TEMP_A[4], TEMP_A[2], TEMP_A[0]};
end
assign AL222 = ~TEMP_B[11];
assign AB152 = ~TEMP_B[10];
assign AL223 = ~TEMP_B[9];
assign AB155 = ~TEMP_B[8];
assign AB157 = ~TEMP_B[7];
assign AK181 = ~TEMP_B[6];
assign AK182 = ~TEMP_B[5];
assign AL202 = ~TEMP_B[4];
assign AB156 = ~TEMP_B[3];
assign AL163 = ~TEMP_B[2];
assign AL221 = ~TEMP_B[1];
assign AL220 = ~TEMP_B[0];


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
		HVIN_DELAY <= 8'b000000;
	end else begin
		HVIN_DELAY <= {HEND_DELAY[6:0], HEND};
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

FJD AR4(clk_12M, ~HEND, HEND & AR16_Q, AN15_Q & RES, , AR4);
BD3 AS135(AR4, AS135);

reg [3:0] AS135_DELAY;
always @(posedge clk_12M or negedge RES) begin
	if (!RES) begin
		AS135_DELAY <= 4'b0000;
	end else begin
		AS135_DELAY <= {AS135_DELAY[2:0], AS135};
	end
end
assign AR84_Q = AS135_DELAY[3];
FDM AR135(clk_12M, AR84_Q, AR135_Q, AR135_XQ);
FDM AR110(clk_12M, AP4_Q[0], AR110_Q, AR110_XQ);
assign AR116 = ~|{(AR84_Q & AR110_XQ), (AR135_Q & AR110_Q)};
FDM AR104(clk_12M, AR116, AR104_Q, AR104_XQ);

endmodule
