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
	input main_clk,

	input P1_up,
	input P1_down,
	input P1_left,
	input P1_right,
	input P1_jump,
	input P1_attack,
	input P1_start,
	input P1_coin,
	
	input [1:0] service,
	
	output [1:0] coin_counter,
	
	output [5:0] video_r,
	output [5:0] video_g,
	output [5:0] video_b,
	output video_sync,
	
	input [7:0] dipswitch1,
	input [7:0] dipswitch2,
	input [3:0] dipswitch3,
);

reg [5:0] clk_640k_div;
reg [18:0] theme_playback_addr;
reg theme_playback_en;

// TMNT theme playback system
always @(posedge clk_640k or posedge reset) begin
	if (reset) begin
		clk_640k_div <= 6'd0;
		theme_playback_en <= 0;
		theme_playback_addr <= 19'd0;
	end else begin
		clk_640k_div <= clk_640k_div + 1'b1;
		// U119_Q: clk_640k_div[0];
		
		if (theme_playback_en) begin
			theme_playback_addr <= 19'd0;
		end else begin
			if ((clk_640k_div[4:0] == 5'd16) & !theme_playback_addr[18])
        		theme_playback_addr <= theme_playback_addr + 1'b1;
		end
	end
end

// Z80 has 32kB ROM at 0000~7FFF
// Z80_A[15:12] Zone
// 1000			work RAM	8000~8FFF (mirrored x2)
// 1001			SRES    	9000~9FFF
// 1010			Comm reg	A000~AFFF
// 1011			DACS    	B000~BFFF (007232)
// 1100			YM2151  	C000~CFFF
// 1101			VDIN    	D000~DFFF
// 1110			VST     	E000~EFFF
// 1111			BSY    		F000~FFFF
// Address decoding only enabled when Z80_RFSH is high !

// The 007232 SLEV ("Set Level") output is used to latch Z80_DOUT to set the analog output levels (4 bits per channel)

assign Z80_nNMI = 1'b1;		// Hardwired
assign Z80_nBUSREQ = 1'b1;	// Hardwired

reg [7:0] snd_code;
reg [7:0] Z80_DIN;
wire [7:0] Z80_DOUT;
wire [15:0] M68K_DIN;
wire [15:0] M68K_DOUT;

// On the real PCB, nothing prevents the Z80 from fighting against the sound code reg U84 if it decides to write to it
// Hopefully this never actually happens
always @(*) begin
	// Check Z80_nMREQ ?
	casez(Z80_A[15:12])
		4'b0zzz: Z80_DIN <= Z80_ROM_dout;
		4'h1000: Z80_DIN <= Z80_WRAM_dout;
		4'h1010: Z80_DIN <= snd_code;
		4'h1100: Z80_DIN <= YM2151_dout;
		default: Z80_DIN <= 8'bzzzz_zzzz;	// DEBUG
	endcase
end

// DIP3 == 0: M68K_DIN[3:0] <= dipswitch3;
// DIP == 0, A[2:1] == 3: M68K_DIN[7:0] <= 8'hFF;
// DIP == 0, A[2:1] == 2: M68K_DIN[7:0] <= INPUTS_4P;	Start, Shoot3, Shoot2, Shoot1, Down, Up, Right, Left
// DIP == 0, A[2:1] == 1: M68K_DIN[7:0] <= dipswitch2;
// DIP == 0, A[2:1] == 0: M68K_DIN[7:0] <= dipswitch1;
// HOOT == 0, A[2:1] == 3: M68K_DIN[7:0] <= INPUTS_3P;	Start, Shoot3, Shoot2, Shoot1, Down, Up, Right, Left
// HOOT == 0, A[2:1] == 2: M68K_DIN[7:0] <= INPUTS_2P;	Start, Shoot3, Shoot2, Shoot1, Down, Up, Right, Left
// HOOT == 0, A[2:1] == 1: M68K_DIN[7:0] <= INPUTS_1P;	Start, Shoot3, Shoot2, Shoot1, Down, Up, Right, Left
// HOOT == 0, A[2:1] == 0: M68K_DIN[7:0] <= Service4, Service3, Service2, Service1, Coin4, Coin3, Coin2, Coin1

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

always @(posedge ???) begin
	// Z80 IRQ
	if (reset | ~Z80_nIORQ)
		Z80_nINT <= 1;	// Clear IRQ on any Z80 access
	else if ({SNDON_prev, SNDON} == 2'b01)
		Z80_nINT <= 0;	// Trigger IRQ on SNDON rising edge

	SNDON_prev <= SNDON;

	// Z80 comm reg
	if ({SNDDT_prev, SNDDT} == 2'b01)
		snd_code <= M68K_DOUT[7:0];	// Store data on SNDDT rising edge

	SNDDT_prev <= SNDDT;
	

end

endmodule
