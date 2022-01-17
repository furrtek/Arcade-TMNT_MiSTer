// TMNT arcade core
// Simulation blind schematic copy version
// Sean Gonsalves 2022
`timescale 1ns/100ps

module k051960 (
	input reset,
	output rst,
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

	inout [11:0] OA,
	output OWR, OOE,
	inout [7:0] OD,
	
	output IRQ, FIRQ, NMI,
	
	output clk_6M, clk_12M
);


// ADDERS

assign AN143 = AG27_Q[0] & SPR_YMATCH[0];
wire [4:0] AX101;
wire [2:0] AR101;
A4H AX101(SPR_YMATCH[0] ? AG1_Q : 4'b0000, SPR_YMATCH[1] ? {AG27_Q[0], AG1_Q[3:1]} : 4'b0000, SPR_YMATCH[1] & AG27_Q[1] & AN143, AX101);
A2N AR101({SPR_YMATCH[1] & AG1_Q[0], SPR_YMATCH[1]}, {SPR_YMATCH[0], 1'b0}, AX101[4], AR101);

wire [4:0] AW101;
wire [2:0] AP101;
A4H AW101({AR101[0], AX101[3:1]}, SPR_YMATCH[2] ? {AG27_Q[0], AG1_Q[3:1]} : 4'b0000, SPR_YMATCH[2] & AG27_Q[1] & AX101[0], AW101);
A2N AP101({SPR_YMATCH[2] & AG1_Q[0], SPR_YMATCH[2]}, AR101[2:1], AW101[4], AP101);

// TODO: The rest of these...

wire [3:0] AF27_Q;
KREG AF27(clk_6M, AB1, {AH27[2:0], AJ141}, AF27_Q);
wire [3:0] AF1_Q;
KREG AF1(clk_6M, AH218, {AH81_COUT, AH81[1:0], AH27[3]}, AF1_Q);


// ROOT SHEET 2

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

assign A124 = ~|{OBCS, RDEN, A152, ~(AB[2:0] == 3'd0};
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


// INTERNAL RAM

// Test mode gates ignored
assign ATTR1_RAM_WE = &{AB98, VBLANK_SYNC, Z95, (ATTR_A == 2'b001)};
assign ATTR2_RAM_WE = &{AB98, VBLANK_SYNC, Z95, (ATTR_A == 2'b010)};
assign ATTR3_RAM_WE = &{AB98, VBLANK_SYNC, Z95, (ATTR_A == 2'b011)};
assign ATTR4_RAM_WE = &{AB98, VBLANK_SYNC, Z95, (ATTR_A == 2'b100)};
assign ATTR5_RAM_WE = &{AB98, VBLANK_SYNC, Z95, (ATTR_A == 2'b101)};
assign ATTR6_RAM_WE = &{AB98, VBLANK_SYNC, Z95, (ATTR_A == 2'b110)};
assign ATTR7_RAM_WE = &{AB98, VBLANK_SYNC, Z95, (ATTR_A == 2'b111)};


// ROOT SHEET 4

wire [3:0] N94_Q;
FDR N94(clk_12M, LACH ? {~H121, ~H127, ~K132, ~H95} : {N94[3:0]}, N94_Q);

assign AC277 = OHF ^ AB233_Q[1];
T5A AC256(AG228, AC277, ~SPR_SIZE[0], AD253, SPR_SIZE[0], AC277, AC277, AC256);
assign AC273 = OHF ^ AB233_Q[2];
T5A AC268(AG214, AG214, ~SPR_SIZE[0], AD253, SPR_SIZE[0], AC273, AC273, AC268);
wire [3:0] Y255_Q;
FDR Y255(clk_12M, {~AC268, N94_Q[2], ~AC256, N94_Q[3]}, AA253, Y255_Q);

T5A AC196(AD151, AD151, ~SPR_SIZE[0], AD253, SPR_SIZE[0], AD151, SPR_HFLIP ^ AB233_Q[3], AC196);
wire [3:0] Y229_Q;
FDR Y229(clk_12M, {SPR_CODE[6], N94_Q[0], ~AC196, N94_Q[1]}, AA253, Y229_Q);

wire [3:0] AD255_Q;
FDR Y229(clk_12M, SPR_CODE[10:7], AA253, AD255_Q);

wire [3:0] T208_P;
LT4 T208(D121, AB[9:6], T208_P);
assign CA[17:4] = ROM_READ ? {REG3[1:0], REG2[7:0], T208_P} : {AD227_Q[1:0], AD255_Q, Y229_Q, Y255};


endmodule
