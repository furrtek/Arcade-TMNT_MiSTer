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

// Dev log: (latest at end)
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

// No sprites showing at all. NOBJ never asserted, and only spr_rom_addr[0] changes.
// Sprite RAMs in k051960 were connected wrong. Fixed but no visible improvement.
// Added a CPU stop toggle in the MiSTer menu to inspect the title screen.
// VBLANK starts at line ROW = F0 ok, RAMB wren pulse every 8 attributes counted from 0 to 7F ok (clearing)
// Then VRAM -> internal RAM copy starts. Sprites 0~12 are copied:
// Sprites 0 to 6 in external RAM -> 79 (4F) to 73 in internal RAM: ok, data written in RAMB ok
// Sprites 7 to 12 in external RAM -> 72 to 67 (43) in internal RAM: ok, data written in RAMB ok, ends during row F5
// There are some non-zero values on spr_rom_addr, with non-zero spr_rom_data read back.
// ROM address 0B288 read -> tile 594, corresponds to one of the "TURTLES" letters: ok.

// Changing the signaltap observed signals causes the ROM address to stay at 0 -> Async timing problem.

// Fixed range of T143, was 4 bits instead of 3.
// Reset to 0111 1100 0 (F8)
// VBLANK should rise at 1111 1000 0 (1F0) -> 248 lines ok
// Reset to 0111 1100 0 (F8) after 1FF -> 16 lines
// VBLANK should fall at 1000 1000 0 (110) -> 24 lines ok
// Total Vblank time: 40 lines, total frame time: 224 lines
// ROM address is now changing again but still no output from 051937.

// 051937 SHIFTER1 DOUT changes values ok
// RAMA gets written to with non-zero values, outputs ok
// Changed RAM we polarity, some sprites now show up with apparently correct sizes but wrong tiles.
// "S" of "TURTLES" seems to be tile 25A0+ instead of 5A0+, each tile is 16*16px*4bpp = 1024bits = 64 words
// Offset of 080000 words
// spr_rom_addr = 2D00, SDRAM address should be 2D00 * 2 = 5A00
// Fixed SDRAM sprite ROM loading offset, sprites now have correct tiles but some missing parts and palette issues.

// Using the intro sequence 4 characters screen to debug (4 big sprites).
// Wrong palettes: LSB of palette number is flipped (19 becomes 18, 1B becomes 1A...)
// In parsing order, sprite #78 (top right) comes first then #79 (top left): attributes 18 then 19 in 051960.
// The OC bus is correctly set to 8 then 9, ok.
// In rendering order, attribute 9 (top left) first then 8 (top right). Problem: it's the opposite, on row #2 the OB
// bus is set to 08E (color E is character image border ok) then 09E. So the 051937 is mixing up OC values somewhere.
// Found a mismatch with the schematic: moved assign to PAL_LATCH2 outside of if (!NEW_SPR) as it should be. This fixed
// the wrong palettes. The size issue / missing tiles remains, probably something in 051960.

// Still using the 4 characters screen to debug. All 4 sprites are 128x128 pixels and are completely opaque.
// The lower half (64 px) of the sprites aren't shown.
// The 64x64 and 64x32 pixel sprites of the titlescreen aren't affected.
// Both sprites for the manhole cover in the intro sequence is affected (tile code 310, palette 7, size 32x32 pixels).
// Some parts of the clouds in the intro sequence are affected. They're made of 16x16 and 32x32 sprites. The 16x16 are
// displayed ok but the 32x32 are cut in half.
// 128x128	111	affected (intro square character images)
// 64x64		110	not affected (TURTLES letters and character description screens)
// 32x64		101	?
// 64x32		100	not affected (TMNT banner)
// 32x32		011	affected (clouds)
// 16x32		010	?
// 32x16		001	not affected (pink light column coming out of manhole, maybe not affected because only 1 tile high ?)
// 16x16		000	not affected (clouds)
// Found a mismatch with the schematic: AM195_Q got RAM_F_dout bits 5 and 6 were swapped. Minor improvements ?
// Found an error in the AT184/AT179/AT177 formula. Fixed all sprite size issues except for the 128x128 ones.
// Register AF1 was being fed one bit too much (AH27_S[4:0], sum and carry, instead of just the sum AH27_S[3:0]).
// This fixed the 128x128 sprites.

// Adding theme loading and playback...
// If the Z80 RAM or ROM checksum fails, a sound effect will be played in a loop.
// The Z80 code relies on the YM2151 timer to catch interrupts, it sits in a loop waiting for the timer B flag.
// Soundcode 0 is sent at startup (reset Z80), then 7D to start playing the theme song.
// Z80 RAM and ROM checks pass ok. Connected JT51, the code now exits the busy loop when the timer B flag is set.
// Z80 nINT never goes low. SNDON never goes high. The 68k writes 08 to A00001 at startup whatever the state of
// the "Demo sounds" DIP switch, this should trigger a Z80 interrupt.
// INT16EN works ok so IOWR must be ok.
// The Z80 IRQ is cleared by nIORQ, which always goes low during an interrupt ack bus cycle.
// Fixed wrong polarity for resetting the nINT register.

// There aren't any more writes to SNDON during attract mode, probably caused by the DIPs being read incorrectly.
// dipswitch2 is read from byte 0A0013 @ 1232 at startup. The read data is 00FF instead of 007C.
// dipswitch2 is read when:
// {OEQ, COLCS | ~m68k_rw, nW2CS | ~m68k_rw, nW1CS, nROMCS, DIP3, DIP, SHOOT, m68k_addr[2:1]} == b11_1111_0110
// m68k_addr[2:1] == b10, doesn't match 0A0013.
// Fixed by inverting m68k_addr[2:1] as visible on schematic.

// Fixed typo (case) causing snd_code to not be loaded by m68k_dout. Getting YM sound now but no theme.
// Fixed theme_en getting toggled randomly, value was set on wrong polarity.
// theme_addr incrementing ok but theme_rom_dout stays at 0. Theme data is requested ok but the SDRAM controller
// never has a chance to start the run because sprite and tile requests take up all the time.
// Testing spacing of sprite and tile requests at 3MHz instead of 6MHz. Sprites ok but tiles sometimes shifted,
// also theme sound corrupt. Theme data bit order was wrong. Phase shifted tiles_rom_req but glitches remain.

// Moved 68k data to SDRAM in order to fit remaining sample ROMs in BRAM.
// Had to fix the output timing of the SDRAM controller, which was still based on 4-word bursts.
// Everything works ok during the first attract mode loop, but the 68k crashes on the 2nd. Certainly due to the
// 68k data not arriving in time from the SDRAM.

// Attempt to improve SDRAM efficiency:
// Moving 68k and theme to bank 0
// Moving sprites and tiles to bank 1
// Moving SDRAM data input to sdram_mux instead of sdram causes POST to almost always fail on 68k ROMs. Unstable.
// Reverted back to having sdram register input data, POST passes, no crashes.
// Tile line glitches that seems related to y scroll, tried triggering tiles_rom_req on tiles_rom_addr changes but no
// effect, so it must be a timing issue in k052109 causing incorrect rom addresses to be output.
// Cleaned up k052109 and the issue seems to be gone ?

// Connected JT7759.
// No k007232 audio.
// ROMs weren't loaded properly when the core was started from the menu. Was caused by incorrect map attribute in MRA
// which was interpreted differently by the mra.exe tool and produced correct TMNT.rom by chance. Fixed MRA.
// After adding the MIA loader, TMNT roms didn't load properly anymore. Caused by "tno" not being sent when loading
// the bitstream via USB Blaster. Works ok when loaded the normal way via the MiSTer menu.
// TODO: MIA stuff, see AND gates on 051962 page, disable unused sound chips.


// Required clocks:
// 640kHz for the TMNT theme playback
// 640kHz for the uPD7759
// 3.58MHz for the Z80 and sound
// 24MHz for the 68000 and video

// clk_sys	96MHz
// ce_main	Clock enable pulse at 96/4 = 24 MHz
// ce_pix	Clock enable pulse at 96/16 = 6 MHz
// ce_z80	Clock enable pulse at 96/27 = 3.56 MHz

// clk_sys	_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|
// ce_main	_|'''|___________|'''|___________|'''|___________|'''|___________|'''|___________|'''|__________
// clk_div	011112222333300001111222233330000111122223333000011112222333300001111222233330000111122223333000
// clk_main _____|'''''''|_______|'''''''|_______|'''''''|_______|'''''''|_______|'''''''|_______|'''''''|__
// ce_pix	_|'''|___________________________________________________________|'''|__________________________

// TMNT ROMs:
// 68k		384kB	16bit	SDRAM	0x0000000	J17 K17 J15 K15
// Z80		32kB	8bit	BRAM					G13
// Tiles		1MB	32bit	SDRAM 0x1000000	H27 K27
// Sprites	2MB	32bit	SDRAM 0x1200000	H4 K4 H6 K6
// k007232	128kB 8bit	BRAM					C13
// uPD7759	128kB 8bit	BRAM					D18
// Theme		512kB	16bit	SDRAM 0x0100000	D5
// Dec		256B	4bit	BRAM					G7
// Prio		256B	4bit	BRAM					G19

// MIA ROMs:
// 68k		256kB	16bit	SDRAM	0x0000000	H17 J17
// Z80		32kB	8bit	BRAM					F4
// Tiles		256kB	32bit	SDRAM 0x1000000	F28 H28 I28 K28
// Sprites	1MB	32bit	SDRAM 0x1200000	J4 H4
// k007232	128kB 8bit	BRAM					D4
// Prio		256B	4bit	BRAM					F16

// RAMs:
// 68k		16kB	16bit	BRAM				J13 K13
// Z80		2kB	8bit	BRAM
// Palette	4kB	16bit	BRAM				F22 F23
// Tiles		16kB	16bit	BRAM				G27 G28
// Sprites	1kB	8bit	BRAM				G8
//	Linebufs	1.6kB	13bit	BRAM

// BRAM total: 32k + 256 + 16k + 2k + 4k + 16k + 1k + 1.6k = 73kB

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

wire signed [15:0] audio_mono;

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

assign AUDIO_S = 1;
assign AUDIO_L = audio_mono;
assign AUDIO_R = audio_mono;
assign AUDIO_MIX = 0;

assign LED_DISK = 0;
assign LED_POWER = 0;
assign BUTTONS = 0;

//////////////////////////////////////////////////////////////////

assign VIDEO_ARX = 12'd4;
assign VIDEO_ARY = 12'd3;

`include "build_id.v"

// Status Bit Map:
//             Upper                             Lower              
// 0         1         2         3          4         5         6   
// 01234567890123456789012345678901 23456789012345678901234567890123
// 0123456789ABCDEFGHIJKLMNOPQRSTUV 0123456789ABCDEFGHIJKLMNOPQRSTUV
// X        T

localparam CONF_STR = {
	"TMNT;;",
	"-;",
	"DIP;",
	"O9,CPU,RUN,STOP;",
	"T0,Reset;",
	"J1,A,B,C,Start,Coin,Service;",
	"R0,Reset and close OSD;",
	"DEFMRA,tmnt.mra;",
	"V,v",`BUILD_DATE 
};

assign CPU_RUN = ~status[9];	// DEBUG

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
wire [26:0] ioctl_addr;
wire [15:0] sdram_sz;		// TODO: Use this to know if there's enough SDRAM installed
wire ioctl_download, ioctl_wr, ioctl_wait;

hps_io #(.STRLEN($size(CONF_STR)>>3), .WIDE(1)) hps_io
(
	.clk_sys,
	.HPS_BUS,
	.EXT_BUS(),
	.gamma_bus(),

	.conf_str(CONF_STR),
	.forced_scandoubler,

	.buttons,
	.status,
	
	.ps2_key,
	
	.joystick_0,
	.joystick_1,
	.joystick_2,
	.joystick_3,
	
    // ARM -> FPGA download
	.ioctl_download,
	.ioctl_index,
	.ioctl_wr,
	.ioctl_addr,         // In WIDE mode address is incremented by 2
	.ioctl_dout,
	.ioctl_wait,
	
	.sdram_sz
);

// DIP states defined by the MRA file are sent ioctl_index 254, not via status
reg [7:0] dips[3];
always @(posedge clk_sys) begin
	if (ioctl_wr && (ioctl_index == 254) && !ioctl_addr[26:2])
		dips[ioctl_addr[1:0]] <= ioctl_dout[7:0];
end

// Retrieve Title No.
// 1 = TMNT
// 2 = MIA
reg [3:0] tno;
always @(posedge clk_sys) begin
	tno <= 4'd1;	// TMNT DEBUG
   //if (ioctl_wr & (ioctl_index == 1))
	//	tno <= ioctl_dout[3:0];
end

wire rom_68k_we, rom_z80_we, rom_prom1_we, rom_prom2_we, rom_theme_we, rom_007232_we, rom_uPD7759C_we;
wire rom_tiles_we, rom_sprites_we;
wire [15:0] rom_data;
wire [25:0] rom_addr;
wire [1:0] rom_byteena;

rom_loader LOADER(
	.reset,
	.clk_sys,
	.load_en(ioctl_index == 16'd0),
	.ioctl_addr(ioctl_addr[25:0]),
	.ioctl_dout,
	.ioctl_wr,
	.tno,
	
	.rom_68k_we,
	.rom_z80_we,
	.rom_prom1_we,
	.rom_prom2_we,
	.rom_tiles_we,
	.rom_sprites_we,
	.rom_theme_we,
	.rom_007232_we,
	.rom_uPD7759C_we,
	
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

wire spr_rom_req;
wire [18:0] spr_rom_addr;
wire [31:0] spr_rom_dout;

wire tiles_rom_req;
wire [17:0] tiles_rom_addr;
wire [31:0] tiles_rom_dout;

wire theme_rom_req;
wire [17:0] theme_rom_addr;
wire [31:0] theme_rom_dout;

wire m68k_rom_req;
wire [17:0] m68k_rom_addr;
wire [15:0] m68k_rom_dout;

sdram_mux SDRAM_MUX(
	.clk_sys(clk_sys),
	.reset(reset),

	.spr_rom_req(spr_rom_req),
	.spr_rom_addr,
	.spr_rom_data(spr_rom_dout),

	.tiles_rom_req(tiles_rom_req),
	.tiles_rom_addr,
	.tiles_rom_data(tiles_rom_dout),
	
	.theme_rom_req(theme_rom_req),
	.theme_rom_addr,
	.theme_rom_data(theme_rom_dout),
	
	.m68k_rom_req(m68k_rom_req),
	.m68k_rom_addr,
	.m68k_rom_data(m68k_rom_dout),

	.DL_EN(ioctl_download),
	.DL_ADDR({rom_addr, 1'b0}),	// All SDRAM data is 16bit
	.DL_DATA(rom_data),
	.DL_WR(rom_tiles_we | rom_sprites_we | rom_theme_we | rom_68k_we),

	.SDRAM_ADDR(sdram_addr),
	.SDRAM_DOUT(sdram_dout),
	.SDRAM_DIN(sdram_din),
	.SDRAM_WR,
	.SDRAM_RD,
	.SDRAM_BURST,
	.SDRAM_BS,
	.SDRAM_READY(sdram_ready),
	
	.sdram_dtack(sdram_dtack)
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
	.tno(tno),
	
	.CPU_RUN(CPU_RUN),
	
	.ioctl_download,
	
	.rom_z80_we,
	.rom_prom1_we,
	.rom_prom2_we,
	.rom_007232_we,
	.rom_uPD7759C_we,
	
	.rom_addr,
	.rom_data,

	.ce_pix,
	
	.spr_rom_req,
	.tiles_rom_req,

	.NCBLK,
	.NHBK,
	.NHSY,
	.NVSY,
	
	// Start, Attack 3, Attack 2, Attack 1, Down, Up, Right, Left
	.inputs_P1(~{joystick_0[7:4], joystick_0[2], joystick_0[3], joystick_0[0], joystick_0[1]}),
	.inputs_P2(~{joystick_1[7:4], joystick_1[2], joystick_1[3], joystick_1[0], joystick_1[1]}),
	.inputs_P3(~{joystick_2[7:4], joystick_2[2], joystick_2[3], joystick_2[0], joystick_2[1]}),
	.inputs_P4(~{joystick_3[7:4], joystick_3[2], joystick_3[3], joystick_3[0], joystick_3[1]}),
	
	.inputs_coin(~{joystick_3[8], joystick_2[8], joystick_1[8], joystick_0[8]}),
	.inputs_service(~{joystick_3[9], joystick_2[9], joystick_1[9], joystick_0[9]}),
	
	// DEBUG
	.dipswitch1(8'b11111100),	// DIPs: coinage settings
	.dipswitch2(8'b01111100),	// DIPs: attract mode sound on, easy, 5 lives
	.dipswitch3(4'b1111),		// DIPs: normal display, game mode
	
	/*.dipswitch1(dips[0]),
	.dipswitch2(dips[1]),
	.dipswitch3(dips[2]),*/
	
	.video_r,
	.video_g,
	.video_b,
	
	.tiles_rom_addr,
	.tiles_rom_dout,
	
	.spr_rom_addr,
	.spr_rom_dout,
	
	.theme_rom_req,
	.theme_rom_addr,
	.theme_rom_dout,
	
	.m68k_rom_req,
	.m68k_rom_addr,
	.m68k_rom_dout,
	
	.audio_mono,
	
	.sdram_dtack(sdram_dtack)
);

assign CLK_VIDEO = clk_sys;
assign CE_PIXEL = ce_pix;

assign LED_USER = 1'b0;

video_cleaner VC(
	.clk_vid(clk_sys),
	.ce_pix(ce_pix),

	.R({video_r, video_r[1:0]}),
	.G({video_g, video_g[1:0]}),
	.B({video_b, video_b[1:0]}),

	.HSync(~NHSY),
	.VSync(~NVSY),
	.HBlank(~NHBK),
	.VBlank(~NCBLK),

	// video output signals
	.VGA_R,
	.VGA_G,
	.VGA_B,
	.VGA_VS,
	.VGA_HS,
	.VGA_DE
);

endmodule
