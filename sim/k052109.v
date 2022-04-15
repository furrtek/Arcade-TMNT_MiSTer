// TMNT arcade core
// Simulation blind schematic copy version
// Sean Gonsalves 2022

// TODO: Check VRAM address (RA), VD_OUT, /CE, /OE and /WE during CPU access

`timescale 1ns/100ps

module k052109 (
	input nRES,
	output RST,
	input clk_24M,
	
	output clk_12M,
	
	input CRCS,		// CPU GFX ROM access
	input RMRD,
	input VCS,		// CPU VRAM access
	input NRD,		// CPU read
	output FIRQ,
	output IRQ,
	output NMI,
	output PQ,		// 6809
	output PE,		// 6809
	output HVOT,	// VSync ?
	output RDEN,	// ? Unused
	output WREN,	// ? Unused
	output WRP,		// ? Unused
	
	// CPU interface
	input [7:0] DB_IN,
	output [7:0] DB_OUT,
	input [15:0] AB,
	
	// VRAM interface
	output [15:0] VD_OUT,
	input [15:0] VD_IN,
	output [12:0] RA,
	output [1:0] RCS,
	output [2:0] ROE,
	output [2:0] RWE,
	
	// GFX ROMs interface
	output [2:1] CAB,
	output [10:0] VC,
	
	output VDE,	// ?
	
	// k051962 interface
	output [7:0] COL,				// Tile COL attribute bits
	output ZA1H, ZA2H, ZA4H,	// Plane A fine scroll
	output ZB1H, ZB2H, ZB4H,	// Plane B fine scroll
	output BEN,
	
	output DB_DIR
);

wire [3:0] G29_Q;
wire [8:0] PXH;
wire [7:0] ROW;
wire [10:0] MAP_A;
wire [10:0] MAP_B;
wire [2:0] ROW_A;
wire [2:0] ROW_B;
wire [5:0] SCROLL_RAM_A;

reg [7:0] REG1D80;
reg [3:0] REG1D00;
reg [7:0] REG1C00;
reg [7:0] REG1C80;
reg [7:0] REG1F00;

// VRAM ADDRESS

wire AA38;
assign {Y80, Y91, Y78, Y129} = AA38 ? {1'b1, ROW[7:5]} : 4'b0000;

// T5As:
wire PXH4F, PXH3F, J79_Q;
wire [12:0] RA_MUX_A;
wire [12:0] RA_MUX_B;
wire [12:0] RA_MUX_C;
// A1: 110 Y80 Y91 Y76 Y129 SCROLL_RAM_A[5:0]	Scroll data
// A2: 01 MAP_A[10:0]									Tilemap A
// B1: 00 ROW[7:3] PXH[8:5] PXH4F PXH3F			Fixmap
// B2: 10 MAP_B[10:0]									Tilemap B
assign RA_MUX_A = ~PXH[1] ? {3'b110, Y80, Y91, Y78, Y129, SCROLL_RAM_A[5:0]} : {2'b01, MAP_A[10:0]};
assign RA_MUX_B = PXH[1] ? {2'b00, ROW[7:3], PXH[8:5], PXH4F, PXH3F} : {2'b10, MAP_B[10:0]};
assign RA_MUX_C = ~PXH[2] ? RA_MUX_A : RA_MUX_B;
assign RA = J79_Q ? RA_MUX_C : AB[12:0];

wire CPU_VRAM_CS0, CPU_VRAM_CS1, J140_nQ, J151;
assign ROE[0] = J79_Q ? J140_nQ : RDEN;
assign ROE[1] = J79_Q ? J151 : RDEN;
assign ROE[2] = J79_Q ? 1'b1 : RDEN;	// Only CPU access ?

assign RCS[0] = J79_Q ? 1'b0 : CPU_VRAM_CS0;
assign RCS[1] = J79_Q ? 1'b0 : CPU_VRAM_CS1;


// GFX ROM ADDRESS

FDO J140(nclk_12M, J121, RES_SYNC, J140_Q, J140_nQ);
assign J151 = J140_Q & REG1C00[5];

FDO H79(J121, ~PE, J79_Q, H79_Q, );
assign VDE = H79_Q | RMRD;

FDN K141(clk_24M, nclk_12M, RES_SYNC, clk_12M, nclk_12M);
FDN J114(clk_24M, ~^{nclk_12M, J114_nQ}, RES_SYNC, J121, J114_nQ);	// 6M

FDN J94(clk_24M, ~^{J94_Q, ~(nclk_12M & J114_nQ)}, RES_SYNC, J94_Q, J94_nQ);	// 3M
FDE J79(~clk_24M, J94_nQ, RES_SYNC, J79_Q, );
assign K117 = ~J94_nQ;
assign L82 = J94_nQ;

assign C92 = ~|{&{~CRCS, ~J94_nQ, PE}, REG1C00[5]};

FDO K123(clk_24M, J94_nQ, RES_SYNC, K123_Q, K123_nQ);
FDO K148(clk_24M, K123_Q, RES_SYNC, K148_Q, );
FDE L120(clk_24M, K148_Q, RES_SYNC, PE, );
FDO K130(clk_24M, K148_Q, RES_SYNC, K130_Q, );

reg [3:0] K77_Q;
always @(posedge clk_24M or negedge RES_SYNC) begin
	if (!RES_SYNC)
		K77_Q <= 4'b0000;
	else
		K77_Q <= {NRD & K123_Q, ~&{NRD, K117, K123_nQ}, ~&{NRD, K123_nQ, K130_Q}, K117};
end

assign PQ = K77_Q[0];
assign WRP = K77_Q[1];
assign WREN = K77_Q[2];
assign RDEN = K77_Q[3];

FDO C64(BEN, DB_IN[2], RES_SYNC, C64_Q);
assign C81 = COL[1] & C64_Q;

FDG CC59(PXH[1], ROW[2], RES_SYNC, CC59_Q);
FDG CC68(PXH[1], ROW[1], RES_SYNC, CC68_Q);
FDG BB39(PXH[1], ROW[0], RES_SYNC, BB39_Q);

// T5As
wire [2:0] VC_MUX_A;
wire [2:0] VC_MUX_B;
wire [2:0] VC_MUX_C;
// A1: CC59_Q CC68_Q BB39_Q
// A2: CC59_Q CC68_Q BB39_Q
// B1: ROW_B[2] ROW_B[1] ROW_B[0]
// B2: ROW_A[2] ROW_A[1] ROW_A[0]
assign VC_MUX_A = {CC59_Q, CC68_Q, BB39_Q};	// Identical inputs
assign VC_MUX_B = PXH[1] ? {ROW_B[2:0]} : {ROW_A[2:0]};
assign VC_MUX_C = ~PXH[2] ? VC_MUX_A : VC_MUX_B;

// LTKs
reg B111, C144, C119;
reg C99, C93, C103;
always @(*) begin
	if (!C92) begin
		B111 <= AB[4];	// All 3 are delayed by BD3s
		C144 <= AB[3];
		C119 <= AB[2];
	end
	
	if (!J79_Q) begin
		C99 <= VC_MUX_C[2] ^ C81;
		C93 <= VC_MUX_C[1] ^ C81;
		C103 <= VC_MUX_C[0] ^ C81;
	end
end

// LT4s - Latch CPU address for ROM reading
reg [3:0] E120_P;
reg [3:0] D81_P;
always @(*) begin
	if (!C92) begin
		E120_P <= AB[8:5];
		D81_P <= AB[12:9];
	end
end

// FDSs - Register rendering tile address
reg [3:0] D96_Q;
reg [3:0] D136_Q;
always @(posedge ~PXH[0]) begin
	D96_Q <= VD_IN[3:0];
	D136_Q <= VD_IN[7:4];
end

// Select between rendering and CPU ROM reading
assign VC = RMRD ? {D136_Q, D96_Q, C99, C93, C103} : {D81_P, E120_P, B111, C144, C119};


// CPU STUFF

assign VD_OUT = {DB_IN, DB_IN};

FDE N122(clk_24M, 1'b1, nRES, RES_SYNC);

// 8-frame delay for RES -> RST
// Same in k051962 ?
wire TRIG_IRQ;
reg [7:0] RES_delay;
always @(posedge TRIG_IRQ or negedge RES_SYNC) begin
	if (!RES_SYNC)
		RES_delay <= 8'h00;
	else
		RES_delay <= {RES_delay[6:0], RES_SYNC};
end
assign RST = RES_delay[7];

// Interrupt flags
// Same in k051962 ?
FDN P4(TRIG_IRQ, 1'b0, REG1D00[2], IRQ);
FDN F27(TRIG_FIRQ, 1'b0, REG1D00[1], FIRQ);
FDN CC52(TRIG_NMI, 1'b0, REG1D00[0], NMI);

wire A126;
assign B123 = |{CPU_VRAM_CS0, RDEN, ~REG1C00[4]};
assign B129 = |{A126, RDEN, ~REG1C00[4]};
assign B121 = ~REG1C00[4] & REG1C00[3];
assign B119 = ~REG1C00[4] & REG1C00[2];
assign A154 = ~|{CPU_VRAM_CS1, RDEN};

assign B137 = ~&{A154, ~B119, ~B121};
assign B143 = ~&{A154, ~B119, B121};
assign B139 = ~&{A154, B119, ~B121};
assign B147 = B123 & B143;
assign B149 = B137 & B147;
assign B152 = B129 & B139;
assign L147 = ~B152;
assign DB_DIR = B149 & B152;

assign L15 = ~RWE[1];

assign E34 = ~|{VCS, RMRD};

reg [5:0] range;
always @(*) begin
	casez({E34, AB[15:13]})
		4'b1000: range <= 6'b111110;	// 0000~1FFF
		4'b1001: range <= 6'b111101;	// 2000~3FFF
		4'b1010: range <= 6'b111011;	// 4000~5FFF
		4'b1011: range <= 6'b110111;	// 6000~7FFF
		4'b1100: range <= 6'b101111;	// 8000~9FFF
		4'b1101: range <= 6'b011111;	// A000~BFFF
		default: range <= 6'b111111;
	endcase
end

/*
REG1C00_D[1:0]:

   A101 A106 A111
00  0    1    2
01  1    2    3
10  2    3    4
11  3    4    5
*/

/*assign CPU_VRAM_CS0_A = REG1C00[0] ? range[3] : range[2];
assign CPU_VRAM_CS0_B = REG1C00[0] ? range[5] : range[4];
assign CPU_VRAM_CS0 = REG1C00[1] ? CPU_VRAM_CS0_B : CPU_VRAM_CS0_A;*/
T5A A111(range[2], range[3], range[5], range[4], REG1C00[0], REG1C00[1], A111_OUT);
assign CPU_VRAM_CS0 = ~A111_OUT;
assign RWE[0] = WRP | CPU_VRAM_CS0;

/*assign A126_A = REG1C00[0] ? range[2] : range[1];
assign A126_B = REG1C00[0] ? range[4] : range[3];
assign A126 = REG1C00[1] ? A126_B : A126_A;*/
T5A A106(range[1], range[2], range[4], range[3], REG1C00[0], REG1C00[1], A106_OUT);
assign A126 = ~A106_OUT;
assign RWE[2] = A126 | WRP;

/*assign CPU_VRAM_CS1_A = REG1C00[0] ? range[1] : range[0];
assign CPU_VRAM_CS1_B = REG1C00[0] ? range[3] : range[2];
assign CPU_VRAM_CS1 = REG1C00[1] ? CPU_VRAM_CS1_B : CPU_VRAM_CS1_A;*/
T5A A100(range[0], range[1], range[3], range[2], REG1C00[0], REG1C00[1], A100_OUT);
assign CPU_VRAM_CS1 = ~A100_OUT;
assign RWE[1] = WRP | CPU_VRAM_CS1;

// Scroll interval set

assign E40 = (REG1C80[0] & G29_Q[0]) | (REG1C80[3] & ~G29_Q[0]);
assign ROW_A = ROW[2:0] & {3{E40}};		// Enable/disable scrolling entirely

wire [5:0] FLIP_ADDER;
wire FLIP_SCREEN;
assign FLIP_ADDER = {PXH[8:5], PXH4F, PXH3F} + {6{FLIP_SCREEN}};

assign SCROLL_RAM_A = AA38 ? {ROW[4:3], ROW_A, PXH[3]} : FLIP_ADDER;

// VRAM read by CPU - Upper/lower byte select
reg [15:0] VD_LATCH;
always @(*) begin
	if (!L82)
		VD_LATCH <= VD_IN;
end
assign DB_OUT = L147 ? VD_LATCH[7:0] : VD_LATCH[15:8];	// Schematic says it's the opposite ?


// H/V COUNTERS

// H

FDO H20(J121, PE, RES_SYNC, H20_Q);
assign PXH[0] = H20_Q;

C43 N16(J121, 4'b0000, LINE_END, H20_Q, H20_Q, RES_SYNC, PXH[4:1], N16_COUT);
C43 G29(J121, 4'b0001, LINE_END, C43_COUT, C43_COUT, RES_SYNC, G29_Q, );
assign PXH[8:5] = G29_Q ^ {4{FLIP_SCREEN}};
assign PXH3F = PXH[3] ^ FLIP_SCREEN;
assign PXH4F = PXH[4] ^ FLIP_SCREEN;

FDO G4(J121, ~G2, RES_SYNC, G4_Q);
assign G2 = ~&{LINE_END, G4_Q | (N16_COUT & G29_Q[1])};

assign LINE_END = &{N16_COUT, G29_Q[3:2]};

assign AA38 = ~G4_Q;

// V

FDO G20(J121, LINE_END ^ G20_nQ, RES_SYNC, G20_Q, G20_nQ);
assign TRIG_FIRQ = ~G20_nQ;

wire [3:0] J29_Q;
C43 J29(J121, 4'b1100, ~H29_COUT, G20_Q, LINE_END & G20_Q, RES_SYNC, J29_Q, J29_Q_COUT);
wire [3:0] H29_Q;
C43 H29(J121, 4'b0111, ~H29_COUT, G20_Q, J29_Q_COUT, RES_SYNC, H29_Q, H29_COUT);

assign ROW = {H29_Q[2:0], J29_Q, G20_Q} ^ {8{FLIP_SCREEN}};

FDO K42(J29_Q[3], &{H29_Q[2:0]}, RES_SYNC, TRIG_IRQ);

FDG CC13(J29_Q[1], CC13_nQ, RES_SYNC, CC13_Q, CC13_nQ);
FDG CC24(CC13_Q, CC24_nQ, RES_SYNC, TRIG_NMI, CC24_nQ);


// REGISTERS

assign D12 = ~&{AB[12:10], ~AB[9], AB[8:7], L15};
always @(posedge D12 or negedge RES_SYNC) begin
	if (!RES_SYNC)
		REG1D80 <= 8'h00;
	else
		REG1D80 <= DB_IN;
end

assign D18 = ~&{AB[12:10], ~AB[9], AB[8], ~AB[7], L15};
always @(posedge D18 or negedge RES_SYNC) begin
	if (!RES_SYNC)
		REG1D00 <= 4'h0;
	else
		REG1D00 <= DB_IN[3:0];
end

assign D23 = ~&{AB[12:10], ~AB[9:7], L15};
always @(posedge D23 or negedge RES_SYNC) begin
	if (!RES_SYNC)
		REG1C00 <= 8'h00;
	else
		REG1C00 <= DB_IN;
end

assign D7 = ~&{AB[12:10], ~AB[9:8], AB[7], L15};
always @(posedge D7 or negedge RES_SYNC) begin
	if (!RES_SYNC)
		REG1C80 <= 8'h00;
	else
		REG1C80 <= DB_IN;
end

assign D33 = ~&{AB[12:10], AB[9:8], ~AB[7], L15};
always @(posedge D33 or negedge RES_SYNC) begin
	if (!RES_SYNC)
		REG1F00 <= 8'h00;
	else
		REG1F00 <= DB_IN;
end

// Reg 1E80
assign BEN = ~&{AB[12:10], AB[9], ~AB[8], ~AB[7], L15};
FDO M53(BEN, DB_IN[0], RES_SYNC, FLIP_SCREEN);

assign nREG_1E00_WR = ~&{AB[12:10], AB[9], ~AB[8:7], L15};


// LAYER A SCROLL

FDN AA2(PXH[1], PXH[3], READ_SCROLL_A, AA2_Q);
reg [7:0] VD_REG_AX;
always @(posedge ~AA2_Q or negedge RES_SYNC) begin
	if (!RES_SYNC)
		VD_REG_AX <= 8'h00;
	else
		VD_REG_AX <= VD_IN[15:8];
end

FDE AA22(PXH[1], PXH[3], READ_SCROLL_A, AA22_Q);
FDE AA41(AA22_Q, VD_IN[8], AA41_Q);

wire [8:0] ADD_AX;
assign ADD_AX = {{6{FLIP_SCREEN}}, 1'b0, {2{FLIP_SCREEN}}} + {AA41_Q, VD_REG_AX};
assign MAP_A[5:0] = {PXH[8:5], PXH4F, PXH3F} + ADD_AX[8:3];

wire [2:0] ADD_AX_F;
assign ADD_AX_F = ADD_AX[2:0] ^ {3{FLIP_SCREEN}};
assign {ZA4H, ZA2H, ZA1H} = ADD_AX_F + PXH[2:0];

wire BB33;
assign BB30 = ~|{PXH[2], BB33 & ~REG1C80[2]} & RES_SYNC;
FDE BB20(PXH[1], 1'b1, BB30, BB20_Q);

reg [7:0] VD_REG_AY;
always @(posedge BB20_Q or negedge RES_SYNC) begin
	if (!RES_SYNC)
		VD_REG_AY <= 8'h00;
	else
		VD_REG_AY <= VD_IN[15:8];
end

assign {MAP_A[10:6], ROW_A[2:0]} = ROW + VD_REG_AY;


// LAYER B SCROLL - Exactly the same thing as LAYER A SCROLL ?

FDN BB2(PXH[1], PXH[3], READ_SCROLL_B, BB2_Q);
reg [7:0] VD_REG_BX;
always @(posedge ~BB2_Q or negedge RES_SYNC) begin
	if (!RES_SYNC)
		VD_REG_BX <= 8'h00;
	else
		VD_REG_BX <= VD_IN[7:0];
end

FDE BB9(PXH[1], PXH[3], READ_SCROLL_B, BB9_Q);
FDE AA81(BB9_Q, VD_IN[0], AA81_Q);

wire [8:0] ADD_BX;
assign ADD_BX = {{6{FLIP_SCREEN}}, 1'b0, {2{FLIP_SCREEN}}} + {AA81_Q, VD_REG_BX};
assign MAP_B[5:0] = {PXH[8:5], PXH4F, PXH3F} + ADD_BX[8:3];

wire [2:0] ADD_BX_F;
assign ADD_BX_F = ADD_BX[2:0] ^ {3{FLIP_SCREEN}};
assign {ZB4H, ZB2H, ZB1H} = ADD_BX_F + PXH[2:0];

assign C22 = ~|{PXH[2], BB33 & ~REG1C80[5]} & RES_SYNC;
FDE CC3(PXH[1], 1'b1, C22, CC3_Q);

reg [7:0] VD_REG_BY;
always @(posedge CC3_Q or negedge RES_SYNC) begin
	if (!RES_SYNC)
		VD_REG_BY <= 8'h00;
	else
		VD_REG_BY <= VD_IN[7:0];
end

assign {MAP_B[10:6], ROW_B[2:0]} = ROW + VD_REG_BY;


// COL OUTPUTS

reg [3:0] REG1E00;
always @(posedge nREG_1E00_WR or negedge RES_SYNC) begin
	if (!RES_SYNC)
		REG1E00 <= 4'h0;
	else
		REG1E00 <= DB_IN[3:0];
end

wire F41, F24;
wire [1:0] COL_MUX_A;
assign COL_MUX_A = F41 ? F24 ? {REG1F00[5], REG1F00[4]} : {REG1D80[5], REG1D80[4]} : F24 ? {REG1F00[1], REG1F00[0]} : {REG1D80[1], REG1D80[0]};
assign COL[3:2] = RMRD ? REG1E00[3:2] : REG1C00[6] ? {F24, F41} : COL_MUX_A;

assign CAB = F41 ? F24 ? {REG1F00[7], REG1F00[6]} : {REG1D80[7], REG1D80[6]} : F24 ? {REG1F00[3], REG1F00[2]} : {REG1D80[3], REG1D80[2]};

assign BB33 = |{PXH[8:7], ~PXH[6:5], PXH4F, PXH[3]};

assign X57 = ~|{ROW[7:0]};
assign READ_SCROLL_A = &{~G4_Q, G29_Q[0], REG1C80[1] | X57, RES_SYNC};
assign READ_SCROLL_B = &{~G4_Q, ~G29_Q[0], REG1C80[4] | X57, RES_SYNC};

reg [3:0] H127_Q;
always @(posedge J140_nQ)
	H127_Q <= VD_IN[11:8];
	
reg [3:0] G136_Q;
always @(posedge ~PXH[0])
	G136_Q <= VD_IN[11:8];

assign F130 = &{J121, REG1C00[5], ~PXH[0]};
	
wire [1:0] COL_MUX_AA;
wire [1:0] COL_MUX_AB;
assign COL_MUX_AA = ~F130 ? {G136_Q[2], G136_Q[3]} : {H127_Q[2], H127_Q[3]};
assign COL_MUX_AB = {2{REG1E00[1:0]}};	// Identical inputs
assign COL[1:0] = ~RMRD ? COL_MUX_AA : COL_MUX_AB;
	
assign F24 = ~F130 ? H127_Q[0] : G136_Q[0];
assign F41 = ~F130 ? H127_Q[1] : G136_Q[1];

reg [3:0] G77_Q;
always @(posedge ~PXH[0])
	G77_Q <= VD_IN[15:12];

reg [3:0] H92_Q;
always @(posedge J140_nQ)
	H92_Q <= VD_IN[15:12];
	
reg [3:0] F77_Q;
always @(posedge nREG_1E00_WR or negedge RES_SYNC) begin
	if (!RES_SYNC)
		F77_Q <= 4'h0;
	else
		F77_Q <= VD_IN[7:4];
end

wire [1:0] COL_MUX_BA;
wire [1:0] COL_MUX_BB;
assign COL_MUX_BA = ~F130 ? G77_Q : H92_Q;
assign COL_MUX_BB = F77_Q;	// Identical inputs
assign COL[7:4] = ~RMRD ? COL_MUX_BA : COL_MUX_BB;
	
endmodule
