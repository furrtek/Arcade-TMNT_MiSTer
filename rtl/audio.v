module TMNTAudio(
	input nRESET,
	input clk_sys,
	input ioctl_download,
	input [25:0] rom_addr,
	input [15:0] rom_data,
	input rom_z80_we,
	input rom_theme_we,
	input SNDON,
	input [15:0] M68K_dout,
	input SNDDT,
	
	output reg theme_rom_req,				// TODO
	output [17:0] theme_rom_addr,
	input [15:0] theme_rom_dout
);

wire nWR, nRD, nWAIT, nMREQ, nIORQ, nRFSH;
wire [15:0] z80_addr;
reg [7:0] z80_din;
wire [7:0] z80_dout;
wire [7:0] z80_rom_dout;
wire [7:0] z80_ram_dout;
reg [7:0] snd_code;
wire [7:0] ym2151_dout;
reg nINT;
reg SNDON_prev;
reg SNDDT_prev;

/*
rom_sim #(8, 15, "C:/Users/furrtek/Documents/Arcade-TMNT_MiSTer/sim/roms/rom_z80_8.txt") ROM_Z80(Z80_addr[14:0], Z80_rom_dout);			// 32k * 8
rom_sim #(16, 18, "C:/Users/furrtek/Documents/Arcade-TMNT_MiSTer/sim/roms/rom_theme_16.txt") ROM_THEME(theme_addr[17:0], theme_rom_dout);		// 256k * 16
rom_sim #(8, 16, "C:/Users/furrtek/Documents/Arcade-TMNT_MiSTer/sim/roms/rom_7759C_8.txt") ROM_7759(upd7759_addr, upd7759_rom_dout);		// 128k * 8
rom_sim #(8, 16, "C:/Users/furrtek/Documents/Arcade-TMNT_MiSTer/sim/roms/rom_007232_8.txt") ROM_007232(k007232_addr, k007232_rom_dout);	// 128k * 8
ram_sim #(8, 11, "") RAM_Z80(Z80_addr[10:0], ~nWR & ~U82[0], Z80_dout, Z80_ram_dout);		// 2k * 8
*/

// MiSTer specific: load 8-bit ROM from 16-bit data
reg rom_z80_we_byte, rom_lsb;
always @(posedge clk_sys) begin
	if (ioctl_download) begin
		if (rom_z80_we) begin
			rom_lsb <= 1'b0;
			rom_z80_we_byte <= 1'b1;
		end
		if (rom_z80_we_byte & !rom_lsb) begin
			rom_lsb <= 1'b1;
		end
		if (rom_z80_we_byte & rom_lsb) begin
			rom_lsb <= 1'b0;
			rom_z80_we_byte <= 1'b0;
		end
	end else begin
		rom_lsb <= 1'b0;
		rom_z80_we_byte <= 1'b0;
	end
end

// clk_sys				_|'|_|'|_|'|_|'|_|'|_|'|_
// rom_z80_we 			_____|'''|_______________
// rom_z80_we_byte	_________|'''''''|_______
// rom_lsb				_____________|'''|_______

// 256k * 16
// TODO: This is in SDRAM !
/*rom_theme ROM_MAIN(
	.clock(~clk_sys),
	.address(ioctl_download ? rom_addr[17:0] : theme_addr),
	.data({rom_data[7:0], rom_data[15:8]}),
	.wren(rom_theme_we),
	.q(theme_rom_dout)
);*/

// 32k * 8
rom_z80 ROM_Z80(
	.clock(~clk_sys),
	.address(ioctl_download ? {rom_addr[14:1], rom_lsb} : z80_addr[14:0]),
	.q(z80_rom_dout),
	.wren(rom_z80_we_byte),
	.data(rom_lsb ? rom_data[11:8] : rom_data[3:0])
);

// 2k * 8
ram_z80 RAM_Z80(
	.clock(~clk_sys),
	.address(z80_addr[11:0]),
	.q(z80_ram_dout),
	.wren(~nWR & ~U82[0]),
	.data(z80_dout)
);

k007232 K007232(
	.DB(z80_dout),
	.AB({z80_addr[3:1], ~z80_addr[0]}),
	.RAM(PCM_ROM_D),
	.SA(PCM_ROM_A),
	.ASD(SAMPLE_A),
	.BSD(SAMPLE_B),
	.SOEV(SLEV),
	.CLK(CLK),		// TODO
	.DACS(U82[3]),
	.NRES(nRESET),
	.NRD(1),
	.NRCS(1)
);

reg [3:0] level_a;
reg [3:0] level_b;
reg [7:0] U82;

always @(posedge SLEV) begin
	level_a <= z80_dout[7:4];
	level_b <= z80_dout[3:0];
end

cpu_z80 cpu(
	.nRESET(nRESET),
	.clk(CLK_Z80),		// TODO
	//.CEN(1'b1),			// TODO
	.nWAIT(nWAIT),
	.nINT(nINT),
	.nNMI(1'b1),		// Hardwired
	.nMREQ(nMREQ),
	.nIORQ(nIORQ),
	.nRD(nRD),
	.nWR(nWR),
	.nRFSH(nRFSH),
	.Z80_ADDR(z80_addr),
	.Z80_DIN(z80_din),
	.Z80_DOUT(z80_dout)
);

// Z80 has 32kB ROM at 0000~7FFF
// Z80_A[15:12] Zone
// 1000			work RAM	8000~8FFF (mirrored x2)
// 1001			SRES    	9000~9FFF
// 1010			Comm reg	A000~AFFF
// 1011			DACS    	B000~BFFF (007232)
// 1100			YM2151  	C000~CFFF
// 1101			VDIN    	D000~DFFF
// 1110			VST     	E000~EFFF
// 1111			BSY    	F000~FFFF
// Address decoding only enabled when Z80_RFSH is high !

// On the real PCB, nothing prevents the Z80 from fighting against the sound code reg U84 if it decides to write to it
// Hopefully this never actually happens
always @(*) begin
	// Check Z80_nMREQ ?
	casez(z80_addr[15:12])
		4'b0zzz: z80_din <= z80_rom_dout;
		4'b1000: z80_din <= z80_ram_dout;
		4'b1010: z80_din <= snd_code;
		4'b1100: z80_din <= ym2151_dout;
		default: z80_din <= 8'bzzzz_zzzz;	// DEBUG
	endcase
end

//assign SD = (U82[2]) ? U84 : 8'bzzzzzzzz;

always @(*) begin
	case ({z80_addr[15], nMREQ, ~nRFSH, z80_addr[14:12]})
		6'b100_000: U82 <= 8'b11111110;
		6'b100_001: U82 <= 8'b11111101;
		6'b100_010: U82 <= 8'b11111011;
		6'b100_011: U82 <= 8'b11110111;
		6'b100_100: U82 <= 8'b11101111;
		6'b100_101: U82 <= 8'b11011111;
		6'b100_110: U82 <= 8'b10111111;
		6'b100_111: U82 <= 8'b01111111;
		default: U82 <= 8'b11111111;
	endcase
end

always @(posedge clk_sys) begin
	// Z80 IRQ
	if (~nRESET | ~nIORQ)
		nINT <= 1;	// Clear IRQ on any Z80 io access
	else if ({SNDON_prev, SNDON} == 2'b01)
		nINT <= 0;	// Trigger IRQ on SNDON rising edge

	SNDON_prev <= SNDON;

	// Z80 comm reg
	if ({SNDDT_prev, SNDDT} == 2'b01)
		snd_code <= M68K_dout[7:0];	// Store data on SNDDT rising edge

	SNDDT_prev <= SNDDT;
end

// TMNT theme playback system

reg [7:0] clk_640k_div;
reg theme_en;	// TODO: Use
reg [18:0] theme_addr;

assign theme_rom_addr = theme_addr[17:0];

always @(posedge clk_sys or negedge nRESET) begin
	if (!nRESET) begin
		clk_640k_div <= 8'd0;
		theme_en <= 0;
		theme_addr <= 19'd0;
		theme_rom_req <= 1'b0;
	end else begin
		clk_640k_div <= clk_640k_div + 1'b1;	// TODO: Check, 96M/150=640k
		// U119_Q: clk_640k_div[0];

		if (!theme_en) begin
			theme_addr <= 19'd0;
		end else begin
			if ((clk_640k_div == 8'd150) & !theme_addr[18]) begin
				clk_640k_div <= 8'd0;
				theme_rom_req <= 1'b1;
				theme_addr <= theme_addr + 1'b1;
			end else begin
				theme_rom_req <= 1'b0;
			end
		end
	end
end

/*ROM Z80_ROM(
	.A(SA[14:0]),
	.D(ROM_DOUT)
);
assign SD = (~SA[15] & ~nRD) ? ROM_DOUT : 8'bzzzzzzzz;

RAM Z80_RAM(
	.A(SA[10:0]),
	.D(RAM_DOUT),
	.WR(~nWR & ~U82[0])
);
assign SD = (~U82[0] & ~nRD) ? RAM_DOUT : 8'bzzzzzzzz;*/

/*YM2151 YM(
	.CLK(SNDCLK),
	.IC(nRESET),
	.A0(Z80_addr[0]),
	.DIN(Z80_dout),
	.DOUT(ym2151_dout),
	.nWR(nWR),
	.nRD(nRD),
	.nCS(U82[4])
);*/
assign ym2151_dout = 8'd0;

endmodule
