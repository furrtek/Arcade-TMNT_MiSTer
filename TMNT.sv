//============================================================================
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//============================================================================

// TODO: Merge "MiSTer specific: load 8-bit ROM from 16-bit data" blocks into rom_loader.v by using
// a look up to know if roms are 8 or 16 bits

// Last news (latest at end)
// Loads 68k ROM ok. Executes RAM/ROM test ok but gets stuck because of error detected.
// Compiling with HDMI enabled to see if the test screen can be seen.
// Result: black video. Disabling HDMI again and climbing back up video output to find the problem.

// Fixed clocks, video output stable but image incorrect. All black except column of tiles on left.
// POST bitmap in 68k reg D7 indicates everything ok except G27, G28 (2x 052109 MB8464 RAMs), and G8 (051960 RAM).
// Investigating why tile RAMs are reported bad:
// Writes bytes 00, 55, AA, FF to 100000~105FFF
// Tests with 00: ok
// Tests with 55: 68k sees 00 :(
//		VRAMCS goes low ok
//		NREAD goes high ok
//		VD_OUT becomes 55 ok
//		RA follows 68k address ok
//		wren of RAMs never go high: RWEs never go low
//		RWE/RCS are configurable via REG1C00 and TMNT doesn't use the reset setting (see notes in k052109.v)
// Checking that REG1C00 gets set to 0x13 shortly after reset (see disasm)
// It doesn't, because when the write to the REG1C00 register actually occurs, DB_IN is back to 00
// The value selected to appear on DB_IN depends on signals from the 68k, so it should be fine.
// The write to REG1C00 occurs on the rising edge of RWE[1], which is happening too late.
// RWE[1] depends on the CPU address, VCS, RMRD, and REG1C00 itself. RMRD is low ok, REG1C00 is in reset state ok,
// only VCS remains a possible cause. VCS is tied to VDTAC, which depends on nLDS, nUDS, VRAMCS and clk_12M.
// Timing shift between 68k and clk_12M (which is derived from clk_div[1] and a /2 in the 052109 ?)
// Tried clocking the 68k on posedge clk_sys instead of negedge: no change
// Tried init clk_div to 3 instead of 0: no change
// Comparing CPU and 052109 signals timing relationships between here and the (known working) icarus sim
// confirms that the rising edge of RWE[1] is too late here.
// Better with last modifications but phases still not perfect after reset. Continue work to align everything.
// D23 and WRP pulses should have the same duration NOK
// WRP pulse should happen during NRD pulse and nAS low NOK
// I20_Q must drop with nAS NOK
// Comparing PE/PQ outputs of 052109 and 68k clock relatioships at startup: wrong !
// Sim changes EN_PHIs on negedge 24M, but the 68k module is clocked on posedge 24M
// 24M	__|''|__|''|__|''|__|''|__|''|__|''|__|''
// PHI1	_____|'''''|_____|'''''|_____|'''''|_____
// PHI2	'''''|_____|'''''|_____|'''''|_____|'''''
// 68K	  2     1     2     1     2     1     2
// Sim after reset:
// Phi1 tick, then Phi2 tick at the same time clk_6M drops
// FPGA currently does:
// Phi2 tick, then Phi1 tick not aligned with clk_6M
// Phases aligned, now REG1C00 becomes 03 (instead of 13, why ? is DB_IN still ok ?)

// POST bitmap in 68k reg D7 now indicates everything ok except G8 (051960 RAM).
// Display still black. Setting tiles_rom_dout to a fixed value doesn't change anything but the FX[7:0]
// output of the 052109 seems to match the fixed value ok. CD[] after the priority ROM also looks ok.
// The POST display defines the first 16 palettes with (black, white, grey, black, black...)
// CD top 3 bits = 000 ok, corresponds to fix palettes range. With tile data fixed value 01234567, colors
// 0 to 7 should be output repeatedly in lines. (0=Black, 1=White, 2=Grey, 3=Black, 4=Black...)
// video_r stays at 0 when color is 1, instead of being at max value.
// C_REG latched on V6M posedge ok.
// C_REG used because COLCS high ok.

// Setting tiles_rom_dout to 01230123 correctly outputs (black, white, grey, black) stripes.
// Adding the video_cleaner module fixed the jumpy sync. Check 051960 sync outputs again ?

// Self test display incorrect, sometimes filled with the same tile with 1-pixel wide lines, more
// rarely with what looks to be the self-test results but with the wrong tiles.
// CPU writes to tilemap but 052109 doesn't assert RWEs (tilemap ram WEs).
// Fixed: was caused by async clock in k052109 registering DB_IN too late, fixed by delaying the change of 
// DB_IN, see DB_IN_del in TMNT.v

// Fixed 68k crash when loading the core via the MiSTer menu (not by JTAG): caused by the absence of
// ioctl_index check for loading 68k ROM data. DIP switch states were being loaded into 68k ROM space.

// Tile data incorrect, always 1-pixel at most shown per 8-pixel row.
// Is tile request address correct for POST display ? Most of the tilemap is filled with tile 0x10 (empty)
// Chars are between 0x00 and 0x2F (ROM addresses 0x000 to 0x17F)
// Char 0x10 -> ROM addresses 0x80 to 0x87
// Fixed: sdram data bus was incorrectly declared, was reduced to 1-bit. Improved display but tiles still garbled.
// Checking to see if the SDRAM tile data is correct for the 1st line of the "RAM ROM CHECK" row.
// Tile IDs: 22 11 1D 10 22 1F 1D 10 13 18 15 13 1B
// 32-bit data tile ROM addresses: 110 88 E8 80 110 F8 E8 80 98 C0 A8 98 D8
// SDRAM addresses: 220 110 1D0 100 220 1F0 1D0 100 130 180 150 130 1B0
// "R" tile (110) first row: data = BB2011B1, corresponds to what's displayed but colors should be 11111200
// ROM data is incorrect -> MRA is incorrect
// "0" tile's first line should be colors 02111200: k27[1] k27[0] h27[1] h27[0]
// Fixed the MRA and the part of SDRAM_DOUT used to catch tile data, now the POST is being displayed correctly.

// G8 bad: Sprite RAM instance had input and output busses swapped.

// POST now passes but then hangs on black screen.
// 10AC isn't reached.
// 108E is reached.
// RTS at 114A pops wrong return address 100010 (from 60AFC, which matches MAME) instead of 10A2
// Correct address 10A2 is pushed to 60AFC by the BSR at 109E, so 60AFC must be corrupt by the called routine.
// Fixed: 68k work RAM didn't have its CS (NW2CS) connected for writing.
// Crosshatch now displayed but 68k crashes.

// 139C is reached.
// 13DC is not reached, stuck in a loop waiting for a variable to change.
// No Vblank interrupt, 1EF3 never reached. INT16EN rises after the write to A0001 at 1392 ok.
// VPA logic was missing. Now goes into attract mode. Fix layer looks good but scroll layers are offset horizontally.

// Fixed X scrolling offset. Schematic to verilog translation mistake, AA41 was clocked by AA22_nQ instead of ~AA22_nQ.


// Clocks:
// clk_sys	96MHz
// ce_main	Clock enable pulse at 96/4 = 24 MHz
// ce_pix	Clock enable pulse at 96/16 = 6 MHz

// clk_sys	_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|
// ce_main	_|'''|___________|'''|___________|'''|___________|'''|___________|'''|___________|'''|__________
// clk_div	011112222333300001111222233330000111122223333000011112222333300001111222233330000111122223333000
// clk_main _____|'''''''|_______|'''''''|_______|'''''''|_______|'''''''|_______|'''''''|_______|'''''''|__
// ce_pix	_|'''|___________________________________________________________|'''|__________________________

module emu
(
	//Master input clock
	input         CLK_50M,

	//Async reset from top-level module.
	//Can be used as initial reset.
	input         RESET,

	//Must be passed to hps_io module
	inout  [45:0] HPS_BUS,

	//Base video clock. Usually equals to CLK_SYS.
	output        CLK_VIDEO,

	//Multiple resolutions are supported using different CE_PIXEL rates.
	//Must be based on CLK_VIDEO
	output        CE_PIXEL,

	//Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
	//if VIDEO_ARX[12] or VIDEO_ARY[12] is set then [11:0] contains scaled size instead of aspect ratio.
	output [12:0] VIDEO_ARX,
	output [12:0] VIDEO_ARY,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,    // = ~(VBlank | HBlank)
	output        VGA_F1,
	output [1:0]  VGA_SL,
	output        VGA_SCALER, // Force VGA scaler

	input  [11:0] HDMI_WIDTH,
	input  [11:0] HDMI_HEIGHT,
	output        HDMI_FREEZE,

`ifdef MISTER_FB
	// Use framebuffer in DDRAM (USE_FB=1 in qsf)
	// FB_FORMAT:
	//    [2:0] : 011=8bpp(palette) 100=16bpp 101=24bpp 110=32bpp
	//    [3]   : 0=16bits 565 1=16bits 1555
	//    [4]   : 0=RGB  1=BGR (for 16/24/32 modes)
	//
	// FB_STRIDE either 0 (rounded to 256 bytes) or multiple of pixel size (in bytes)
	output        FB_EN,
	output  [4:0] FB_FORMAT,
	output [11:0] FB_WIDTH,
	output [11:0] FB_HEIGHT,
	output [31:0] FB_BASE,
	output [13:0] FB_STRIDE,
	input         FB_VBL,
	input         FB_LL,
	output        FB_FORCE_BLANK,

`ifdef MISTER_FB_PALETTE
	// Palette control for 8bit modes.
	// Ignored for other video modes.
	output        FB_PAL_CLK,
	output  [7:0] FB_PAL_ADDR,
	output [23:0] FB_PAL_DOUT,
	input  [23:0] FB_PAL_DIN,
	output        FB_PAL_WR,
`endif
`endif

	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status OR'd with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,

	// I/O board button press simulation (active high)
	// b[1]: user button
	// b[0]: osd button
	output  [1:0] BUTTONS,

	input         CLK_AUDIO, // 24.576 MHz
	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S,   // 1 - signed audio samples, 0 - unsigned
	output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

	//ADC
	inout   [3:0] ADC_BUS,

	//SD-SPI
	output        SD_SCK,
	output        SD_MOSI,
	input         SD_MISO,
	output        SD_CS,
	input         SD_CD,

	//High latency DDR3 RAM interface
	//Use for non-critical time purposes
	output        DDRAM_CLK,
	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	input  [63:0] DDRAM_DOUT,
	input         DDRAM_DOUT_READY,
	output        DDRAM_RD,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,

	//SDRAM interface with lower latency
	output        SDRAM_CLK,
	output        SDRAM_CKE,
	output [12:0] SDRAM_A,
	output  [1:0] SDRAM_BA,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nCS,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nWE,

`ifdef MISTER_DUAL_SDRAM
	//Secondary SDRAM
	//Set all output SDRAM_* signals to Z ASAP if SDRAM2_EN is 0
	input         SDRAM2_EN,
	output        SDRAM2_CLK,
	output [12:0] SDRAM2_A,
	output  [1:0] SDRAM2_BA,
	inout  [15:0] SDRAM2_DQ,
	output        SDRAM2_nCS,
	output        SDRAM2_nCAS,
	output        SDRAM2_nRAS,
	output        SDRAM2_nWE,
`endif

	input         UART_CTS,
	output        UART_RTS,
	input         UART_RXD,
	output        UART_TXD,
	output        UART_DTR,
	input         UART_DSR,

	// Open-drain User port.
	// 0 - D+/RX
	// 1 - D-/TX
	// 2..6 - USR2..USR6
	// Set USER_OUT to 1 to read from USER_IN.
	input   [6:0] USER_IN,
	output  [6:0] USER_OUT,

	input         OSD_STATUS
);

///////// Default values for ports not used in this core /////////

assign ADC_BUS  = 'Z;
assign USER_OUT = '1;
assign {UART_RTS, UART_TXD, UART_DTR} = 0;
assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
assign {DDRAM_CLK, DDRAM_BURSTCNT, DDRAM_ADDR, DDRAM_DIN, DDRAM_BE, DDRAM_RD, DDRAM_WE} = '0;  

assign VGA_SL = 0;
assign VGA_F1 = 0;
assign VGA_SCALER = 0;
assign HDMI_FREEZE = 0;

assign AUDIO_S = 0;
assign AUDIO_L = 0;
assign AUDIO_R = 0;
assign AUDIO_MIX = 0;

assign LED_DISK = 0;
assign LED_POWER = 0;
assign BUTTONS = 0;

//////////////////////////////////////////////////////////////////

//wire [1:0] ar = status[9:8];

//assign VIDEO_ARX = (!ar) ? 12'd4 : (ar - 1'd1);
//assign VIDEO_ARY = (!ar) ? 12'd3 : 12'd0;

assign VIDEO_ARX = 12'd4;
assign VIDEO_ARY = 12'd3;

`include "build_id.v"

// Status Bit Map:
//             Upper                             Lower              
// 0         1         2         3          4         5         6   
// 01234567890123456789012345678901 23456789012345678901234567890123
// 0123456789ABCDEFGHIJKLMNOPQRSTUV 0123456789ABCDEFGHIJKLMNOPQRSTUV
// X

localparam CONF_STR = {
	"TMNT;;",
	"-;",
	"DIP;",
	/*"O34,Noise,White,Red,Green,Blue;",
	"-;",
	"P1,Test Page 1;",
	"P1-;",
	"P1-, -= Options in page 1 =-;",
	"P1-;",
	"P1O5,Option 1-1,Off,On;",
	"-;",
	"P2,Test Page 2;",
	"P2-;",
	"P2-, -= Options in page 2 =-;",
	"P2-;",
	"P2O67,Option 2,1,2,3,4;",
	"-;",
	"-;",
	"T0,Reset;",*/
	"R0,Reset and close OSD;",
	"DEFMRA,tmnt.mra;",
	"V,v",`BUILD_DATE 
};

wire forced_scandoubler;
wire [1:0] buttons;
wire [63:0] status;
wire [10:0] ps2_key;
wire [31:0] joystick_0;
wire [31:0] joystick_1;
wire [31:0] joystick_2;
wire [31:0] joystick_3;
wire [15:0] ioctl_index;
wire [15:0] ioctl_dout;
//wire [7:0] ioctl_din;
wire [26:0] ioctl_addr;
wire [15:0] sdram_sz;		// TODO: Use this to know if there's enough SDRAM installed
wire ioctl_download, ioctl_wr, ioctl_wait;

hps_io #(.STRLEN($size(CONF_STR)>>3), .WIDE(1)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),
	.EXT_BUS(),
	.gamma_bus(),

	.conf_str(CONF_STR),
	.forced_scandoubler(forced_scandoubler),

	.buttons(buttons),
	.status(status),
	//.status_menumask({status[5]}),
	
	.ps2_key(ps2_key),
	
	.joystick_0,
	.joystick_1,
	.joystick_2,
	.joystick_3,
	
    // ARM -> FPGA download
	.ioctl_download, 		// signal indicating an active download
	.ioctl_index,			// menu index used to upload the file
	.ioctl_wr,
	.ioctl_addr,         // in WIDE mode address will be incremented by 2
	.ioctl_dout,
	//.ioctl_upload,   		// signal indicating an active upload
	//.ioctl_upload_req,
	//.ioctl_din,
	//.ioctl_rd,
	//.ioctl_file_ext,
	.ioctl_wait,
	.sdram_sz
);

// DIP states defined by the MRA file are sent ioctl_index 254, not via status
reg [7:0] dips[3];
always @(posedge clk_sys) begin
	if (ioctl_wr && (ioctl_index == 254) && !ioctl_addr[26:2])
		dips[ioctl_addr[1:0]] <= ioctl_dout[7:0];
end

// Retrieve Title No. - 1 = TMNT - Unused for now
reg [3:0] tno;
always @(posedge clk_sys) begin
   if (ioctl_wr & (ioctl_index == 1))
		tno <= ioctl_dout[3:0];
end

wire rom_68k_we, rom_z80_we, rom_prom1_we, rom_prom2_we, rom_theme_we;
wire [15:0] rom_data;
wire [25:0] rom_addr;
wire [1:0] rom_byteena;
	
rom_loader ROM_LOADER(
	.reset,
	.clk_sys,
	.load_en(ioctl_index == 16'd0),
	.ioctl_addr(ioctl_addr[25:0]),
	.ioctl_dout,
	.ioctl_wr,
	
	.rom_68k_we,
	.rom_z80_we,
	.rom_prom1_we,
	.rom_prom2_we,
	.rom_tiles_we,
	.rom_sprites_we,
	.rom_theme_we,
	
	.rom_addr,	// Word-based for 16-bit ROMs
	.rom_data
);

///////////////////////   CLOCKS   ///////////////////////////////

wire clk_sys, locked;
pll pll
(
	.refclk(CLK_50M),
	.rst(0),
	.outclk_0(clk_sys),	// 96MHz
	.locked(locked)
);

wire reset = RESET | status[0] | buttons[1];

//////////////////////////////////////////////////////////////////

wire [26:1] sdram_addr;
wire [63:0] sdram_dout;
wire [15:0] sdram_din;
wire [1:0] SDRAM_BS;
wire SDRAM_BURST;
wire SDRAM_WR, SDRAM_RD;

wire [18:0] spr_rom_addr;
wire [31:0] spr_rom_dout;

wire [17:0] tiles_rom_addr;
wire [31:0] tiles_rom_dout;

wire theme_rom_req;
wire [17:0] theme_rom_addr;
wire [15:0] theme_rom_dout;

sdram_mux SDRAM_MUX(
	.clk_sys(clk_sys),
	.reset(reset),

	.spr_rom_req(ce_pix2),
	.spr_rom_addr(spr_rom_addr),
	.spr_rom_data(spr_rom_dout),

	.tiles_rom_req(ce_pix),				// TODO
	.tiles_rom_addr(tiles_rom_addr),
	.tiles_rom_data(tiles_rom_dout),
	
	/*.theme_rom_req(1'b0),
	.theme_rom_addr(theme_rom_addr),
	.theme_rom_data(theme_rom_dout),*/

	.DL_EN(ioctl_download),
	.DL_ADDR({rom_addr, 1'b0}),	// All SDRAM data is 16bit
	.DL_DATA(rom_data),
	.DL_WR(rom_tiles_we | rom_sprites_we),	// ioctl_wr

	.SDRAM_ADDR(sdram_addr),
	.SDRAM_DOUT(sdram_dout),
	.SDRAM_DIN(sdram_din),
	.SDRAM_WR,
	.SDRAM_RD,
	.SDRAM_BURST,
	.SDRAM_BS,
	.SDRAM_READY(sdram_ready)
);

wire   sdr_pri_sel = 1;
assign sdram2_dout = '0;
assign sdram2_ready = 1;
assign sdr2_cprd = 0;
assign sdr2_cpbusy = 0;
assign sdr2_en = 0;

sdram ram1(
	.SDRAM_CLK,
	.SDRAM_CKE,
	.SDRAM_A,
	.SDRAM_BA,
	.SDRAM_DQ,
	.SDRAM_DQML,
	.SDRAM_DQMH,
	.SDRAM_nCS,
	.SDRAM_nCAS,
	.SDRAM_nRAS,
	.SDRAM_nWE,
	.SDRAM_EN(1),

	.init(~locked),	// Init SDRAM as soon as the PLL is locked
	.clk(clk_sys),
	.addr(sdram_addr[26:1]),
	.sel(sdr_pri_sel),
	.dout(sdram_dout),
	.din(sdram_din),
	.bs(SDRAM_BS),
	.wr(SDRAM_WR),
	.rd(SDRAM_RD),
	.burst(SDRAM_BURST),
	.ready(sdram_ready),

	.cpsel(1'b0),
	.cpaddr(26'h0),
	.cpdin(16'h0),
	.cpreq(1'b0)
);

//////////////////////////////////////////////////////////////////

wire [1:0] col = status[4:3];

wire HBlank;
wire HSync;
wire VSync;
wire ce_pix;
wire [5:0] video_r;
wire [5:0] video_g;
wire [5:0] video_b;

tmnt mycore
(
	.reset(reset),
	.clk_sys(clk_sys),	// 96MHz
	
	//.scandouble(forced_scandoubler),
	.ioctl_download,
	//.rom_byteena,
	.rom_addr,
	
	.rom_68k_we,
	.rom_z80_we,
	.rom_prom1_we,
	.rom_prom2_we,
	
	.rom_data,

	.ce_pix(ce_pix),
	.ce_pix2(ce_pix2),

	.NCBLK(NCBLK),
	.NHBK(NHBK),
	.NHSY(HSync),
	.NVSY(VSync),
	
	.P_right({joystick_3[0], joystick_2[0], joystick_1[0], joystick_0[0]}),
	.P_left({joystick_3[1], joystick_2[1], joystick_1[1], joystick_0[1]}),
	.P_down({joystick_3[2], joystick_2[2], joystick_1[2], joystick_0[2]}),
	.P_up({joystick_3[3], joystick_2[3], joystick_1[3], joystick_0[3]}),

	.P_attack1({joystick_3[4], joystick_2[4], joystick_1[4], joystick_0[4]}),
	.P_attack2({joystick_3[5], joystick_2[5], joystick_1[5], joystick_0[5]}),
	.P_attack3({joystick_3[6], joystick_2[6], joystick_1[6], joystick_0[6]}),
	
	.P_start({joystick_3[7], joystick_2[7], joystick_1[7], joystick_0[7]}),
	.P_coin({joystick_3[8], joystick_2[8], joystick_1[8], joystick_0[8]}),
	
	.service({joystick_3[9], joystick_2[9], joystick_1[9], joystick_0[9]}),
	
	// DEBUG
	.dipswitch1(8'b11111100),	// DIPs: coinage settings
	.dipswitch2(8'b01111100),	// DIPs: attract mode sound on, easy, 5 lives
	.dipswitch3(4'b1111),		// DIPs: normal display, game mode
	
	/*.dipswitch1(dips[0]),
	.dipswitch2(dips[1]),
	.dipswitch3(dips[2]),
	*/
	.video_r,
	.video_g,
	.video_b,
	
	.tiles_rom_addr,
	.tiles_rom_dout,
	
	.spr_rom_addr,
	.spr_rom_dout,
	
	.theme_rom_addr,
	.theme_rom_dout
);

assign CLK_VIDEO = clk_sys;
assign CE_PIXEL = ce_pix;

/*assign VGA_DE = NCBLK;
assign VGA_HS = ~HSync;
assign VGA_VS = ~VSync;

// Extend 6-bit color to 8-bit
assign VGA_R  = {video_r, video_r[1:0]};
assign VGA_G  = {video_g, video_g[1:0]};
assign VGA_B  = {video_b, video_b[1:0]};*/

// "Breathing" PWM
reg  [26:0] act_cnt;
always @(posedge clk_sys)
	act_cnt <= act_cnt + 1'd1;
assign LED_USER = act_cnt[26] ? act_cnt[25:18]  > act_cnt[7:0]  : act_cnt[25:18]  <= act_cnt[7:0];

video_cleaner VC(
	.clk_vid(clk_sys),
	.ce_pix(ce_pix),

	.R({video_r, video_r[1:0]}),
	.G({video_g, video_g[1:0]}),
	.B({video_b, video_b[1:0]}),

	.HSync(~HSync),
	.VSync(~VSync),
	.HBlank(~NHBK),
	.VBlank(~NCBLK),

	//optional de
	//input            DE_in,

	// video output signals
	.VGA_R(VGA_R),
	.VGA_G(VGA_G),
	.VGA_B(VGA_B),
	.VGA_VS(VGA_VS),
	.VGA_HS(VGA_HS),
	.VGA_DE(VGA_DE)
	
	// optional aligned blank
	//output reg       HBlank_out,
	//output reg       VBlank_out,
	
	// optional aligned de
	//output reg       DE_out
);

endmodule
