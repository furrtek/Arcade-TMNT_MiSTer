// TMNT arcade core
// Sean Gonsalves 2022
`timescale 1ns/100ps

// Clocks:
// 640kHz for the TMNT theme playback
// 640kHz for the NEC voice chip
// 3.58MHz for the Z80 and sound
// 24MHz for the 68000 and video

module top (
	input reset,
	input clk_main,

	input [3:0] P_up,
	input [3:0] P_down,
	input [3:0] P_left,
	input [3:0] P_right,
	input [3:0] P_jump,
	input [3:0] P_attack1,
	input [3:0] P_attack2,
	input [3:0] P_attack3,
	input [3:0] P_start,
	input [3:0] P_coin,
	
	input [3:0] service,
	
	output [1:0] coin_counter,

	output [5:0] video_r,
	output [5:0] video_g,
	output [5:0] video_b,
	output video_sync,

	input [7:0] dipswitch1,
	input [7:0] dipswitch2,
	input [3:0] dipswitch3
);

wire [23:1] m68k_addr;
reg [15:0] m68k_din;
wire [15:0] m68k_dout;
wire [15:0] m68k_rom_dout;
wire [15:0] m68k_ram_dout;

wire [19:0] spr_rom_addr;
wire [31:0] spr_rom_dout;

wire [18:0] tiles_rom_addr;
wire [31:0] tiles_rom_dout;

wire [7:0] pal_dout;

wire [10:0] spr_ram_addr;
wire [7:0] spr_ram_din;
wire [7:0] spr_ram_dout;

wire [12:0] tiles_ram_addr;
wire [15:0] tiles_ram_din;
wire [15:0] tiles_ram_dout;

// ../../sim/roms/
rom_sim #(16, 18, "rom_68k_16.txt") ROM_68K(m68k_addr[18:1], m68k_rom_dout);		// 256k * 16
rom_sim #(32, 20, "rom_sprites_32.txt") ROM_SPRITES(spr_rom_addr, spr_rom_dout);	// 512k * 32
rom_sim #(32, 19, "rom_tiles_32.txt") ROM_TILES(tiles_rom_addr, tiles_rom_dout);	// 256k * 32

reg PRI, PRI2;
wire [11:0] VA;
wire [11:0] VB;
wire [7:0] FX;
wire NVA, NVB, NFX, NOBJ, SHA;

wire [7:0] PROM_addr;
assign PROM_addr = {PRI2, PRI, VB[7], SHA, NFX, NOBJ, NVB, NVA};	// 2C6 = VB[7] ?
wire [3:0] PROM_dout;
rom_sim #(8, 8, "prom_prio_8.txt") ROM_PRIO(PROM_addr, PROM_dout);	// 256 * 8
//rom_prio ROM_PRIO(PROM_addr, PROM_dout);	// 256 * 8

wire SHADOW = PROM_dout[2];	// PROM_dout[3] unused

assign SHA = 0;	// TODO 051937 SHAD
assign NOBJ = 0;	// TODO 051937 NC00
wire [11:0] OB;
assign OB = 12'd0;	// TODO 051937

ram_sim #(16, 13, "") RAM_68K(m68k_addr[13:1], m68k_ram_we, 1'b1, m68k_dout, m68k_ram_dout);			// 8k * 16
ram_sim #(8, 11, "") RAM_SPRITES(spr_ram_addr, spr_ram_we, 1'b1, spr_ram_din, spr_ram_dout);			// 2k * 8
ram_sim #(16, 13, "") RAM_TILES(tiles_ram_addr, tiles_ram_we, 1'b1, tiles_ram_din, tiles_ram_dout);	// 8k * 16

assign OIPL = 1'b1;	// TODO

cpu_68k CPU68K(
	.clk(clk_main),	// TODO
	.nRESET(~reset),
	.IPL2(OIPL), .IPL1(1'b1), .IPL0(OIPL),
	.nDTACK(1'b0),	// TODO nDTACK
	.M68K_ADDR(m68k_addr),
	.FX68K_DATAIN(m68k_din),
	.FX68K_DATAOUT(m68k_dout),
	.nLDS(nLDS), .nUDS(nUDS),
	.nAS(nAS),
	.M68K_RW(m68k_rw),
	.FC2(FC2), .FC1(FC1), .FC0(FC0),
	.nBG(nBG),
	.nBR(1'b1),
	.nBGACK(1'b1)
);

assign NLWR = nLDS | m68k_rw;
assign NUWR = nUDS | m68k_rw;

k051962 k051962_1(
	.nRES(~reset),
	.clk_24M(clk_main),
	.clk_6M(V6M),
	
	.DSA(VA),
	.DSB(VB),
	.DFI(FX),
	
	.NSAC(NVA),
	.NSBC(NVB),
	.NFIC(NFX)
);

reg [7:0] U47;	// CPU LS138
always @(*) begin
	case({nAS, m68k_addr[20], m68k_addr[19:17]})
		5'b0_0000: U47 <= 8'b11111110;
		5'b0_0001: U47 <= 8'b11111101;
		5'b0_0010: U47 <= 8'b11111011;
		5'b0_0011: U47 <= 8'b11110111;
		5'b0_0100: U47 <= 8'b11101111;
		5'b0_0101: U47 <= 8'b11011111;
		5'b0_0110: U47 <= 8'b10111111;
		5'b0_0111: U47 <= 8'b01111111;
		default: U47 <= 8'b11111111;
	endcase
end

assign nROMCS = &{U47[1:0]};	// Bottom ROMs
assign nW1CS = U47[2];			// Top ROMs
assign nW2CS = U47[3];			// Work RAM
assign COLCS = U47[4];			// Palette RAM
assign SYSWR = U47[6];			// ???

reg [7:0] U45;	// CPU LS138
always @(*) begin
	case({U47[5], m68k_addr[16], m68k_rw, m68k_addr[4:3]})
		5'b0_0000: U45 <= 8'b11111110;
		5'b0_0001: U45 <= 8'b11111101;
		5'b0_0010: U45 <= 8'b11111011;
		5'b0_0011: U45 <= 8'b11110111;
		5'b0_0100: U45 <= 8'b11101111;
		5'b0_0101: U45 <= 8'b11011111;
		5'b0_0110: U45 <= 8'b10111111;
		5'b0_0111: U45 <= 8'b01111111;
		default: U45 <= 8'b11111111;
	endcase
end

assign IOWR = U45[0];	// Coin lockouts ?
assign SNDDT = U45[1];	// Sound code
assign AFR = U45[2];		// Watchdog

assign SHOOT = U45[4];	// Read inputs
assign DIP = U45[6];
assign DIP3 = U45[7];

reg RMRD;
reg INT16EN;
reg SNDON;
reg OUT2;
reg OUT1;
always @(posedge IOWR or posedge reset) begin
	if (reset) begin
		{RMRD, INT16EN, SNDON, OUT2, OUT1} <= 5'b0_0000;
	end else begin
		RMRD <= m68k_dout[7];		// GFX ROM read
		INT16EN <= m68k_dout[5];
		SNDON <= m68k_dout[3];
		OUT2 <= m68k_dout[1];
		OUT1 <= m68k_dout[0];
	end
end

always @(posedge SYSWR or posedge reset) begin
	if (reset) begin
		PRI <= 0;
		PRI2 <= 0;
	end else begin
		PRI <= m68k_dout[2];
		PRI2 <= m68k_dout[3];
	end
end

// DIP3 == 0: M68K_DIN[3:0] <= dipswitch3;
// DIP == 0, A[2:1] == 3: M68K_DIN[7:0] <= 8'hFF;
// DIP == 0, A[2:1] == 2: M68K_DIN[7:0] <= INPUTS_4P;	Start, Shoot3, Shoot2, Shoot1, Down, Up, Right, Left
// DIP == 0, A[2:1] == 1: M68K_DIN[7:0] <= dipswitch2;
// DIP == 0, A[2:1] == 0: M68K_DIN[7:0] <= dipswitch1;
// SHOOT == 0, A[2:1] == 3: M68K_DIN[7:0] <= INPUTS_3P;	Start, Shoot3, Shoot2, Shoot1, Down, Up, Right, Left
// SHOOT == 0, A[2:1] == 2: M68K_DIN[7:0] <= INPUTS_2P;	Start, Shoot3, Shoot2, Shoot1, Down, Up, Right, Left
// SHOOT == 0, A[2:1] == 1: M68K_DIN[7:0] <= INPUTS_1P;	Start, Shoot3, Shoot2, Shoot1, Down, Up, Right, Left
// SHOOT == 0, A[2:1] == 0: M68K_DIN[7:0] <= Service4, Service3, Service2, Service1, Coin4, Coin3, Coin2, Coin1

always @(*) begin
	casez({COLCS | ~m68k_rw, nW2CS | ~m68k_rw, nW1CS, nROMCS, DIP3, DIP, SHOOT, m68k_addr[2:1]})
		9'b1_110z_zzzz: m68k_din <= m68k_rom_dout;	//m68k_rom_bot_dout;
		9'b1_101z_zzzz: m68k_din <= m68k_rom_dout;	//m68k_rom_top_dout;
		9'b1_011z_zzzz: m68k_din <= m68k_ram_dout;
		9'b0_111z_zzzz: m68k_din <= {8'h00, pal_dout};
		
		9'b1_1110_zzzz: m68k_din[3:0] <= dipswitch3;

		9'b1_1111_0100: m68k_din[7:0] <= 8'hFF;
		9'b1_1111_0101: m68k_din[7:0] <= {P_start[3], P_attack3[3], P_attack2[3], P_attack1[3], P_down[3], P_up[3], P_right[3], P_left[3]};
		9'b1_1111_0110: m68k_din[7:0] <= dipswitch2;
		9'b1_1111_0111: m68k_din[7:0] <= dipswitch1;

		9'b1_1111_1000: m68k_din[7:0] <= {P_start[2], P_attack3[2], P_attack2[2], P_attack1[2], P_down[2], P_up[2], P_right[2], P_left[2]};
		9'b1_1111_1001: m68k_din[7:0] <= {P_start[1], P_attack3[1], P_attack2[1], P_attack1[1], P_down[1], P_up[1], P_right[1], P_left[1]};
		9'b1_1111_1010: m68k_din[7:0] <= {P_start[0], P_attack3[0], P_attack2[0], P_attack1[0], P_down[0], P_up[0], P_right[0], P_left[0]};
		9'b1_1111_1011: m68k_din[7:0] <= {service, P_coin};

		default: m68k_din[15:0] <= 16'h0000;	//m68k_din[15:0] <= 16'bzzzzzzzz_zzzzzzzz;
	endcase
end

// SYSWR: PRI <= M68K_DOUT[2];
// SYSWR: PRI2 <= M68K_DOUT[3];
// IOWR: OUT1 <= M68K_DOUT[0];	Coin counter 1
// IOWR: OUT2 <= M68K_DOUT[1];	Coin counter 2
// IOWR: SNDON <= M68K_DOUT[3];
// IOWR: INT16EN <= M68K_DOUT[5];
// IOWR: RMRD <= M68K_DOUT[7];

// AFR: 051550 watchdog reset
// V24M = O24M = 24M

// Color data CD[9:0], NCBLK and SHADOW latched by V6M
// Goes into mux for CPU palette RAM access, select by COLCS
// Output of mux used as address for 2* 2kB palette RAM
// Output of palette RAM also latched by V6M -> 5 bits + 1 common -> DACs
// Also goes into 245's for CPU access (lower byte only)

wire [15:1] AB = m68k_addr[15:1];	// Just 2x LS245 buffers

// 007644 x2
// TODO

reg [9:0] CD;
wire [5:0] RED_OUT;
wire [5:0] GREEN_OUT;
wire [5:0] BLUE_OUT;

// Video plane mixing
// 4x LS153

always @(*) begin
	case(PROM_dout[1:0])
		2'b00: CD <= {2'b10, 1'b0, VA[7:5], VA[3:0]};	// VA[4] unused ?
		2'b01: CD <= {2'b10, 1'b1, VB[7:5], VB[3:0]};	// VB[4] unused ?
		2'b10: CD <= {2'b01, OB[7:0]};
		2'b11: CD <= {2'b00, 1'b0, FX[7:5], FX[3:0]};	// FX[4] unused ?
	endcase
end

TMNTColor color(
	.V6M(V6M),
	.AB(AB[12:1]),
	.CD(CD),
	.SHADOW(SHADOW),
	.CPU_DIN(m68k_dout[7:0]),
	.CPU_DOUT(pal_dout),
	.NCBLK(NCBLK),
	.COLCS(COLCS),
	.NLWR(NLWR),
	.NREAD(~m68k_rw),
	.RED_OUT(RED_OUT),
	.GREEN_OUT(GREEN_OUT),
	.BLUE_OUT(BLUE_OUT)
);

endmodule
