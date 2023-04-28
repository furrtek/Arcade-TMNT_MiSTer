//============================================================================
//  Konami TMNT for MiSTer
//
//  Copyright (C) 2022 Sean 'Furrtek' Gonsalves
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
//============================================================================

// SDRAM mux/demux logic

module sdram_mux(
	input             clk_sys,

	input             reset,

	input             tiles_rom_req,
	input      [17:0] tiles_rom_addr,	// Dword address
	output reg [31:0] tiles_rom_data,	// 8x 4bpp pixels
	
	input             spr_rom_req,
	input      [18:0] spr_rom_addr,		// Dword address
	output reg [31:0] spr_rom_data,		// 8x 4bpp pixels

	input					theme_rom_req,
	input	     [17:0] theme_rom_addr,	// Dword address
	output reg [31:0]	theme_rom_data,	// Two zero-padded 13-bit samples
	
	input					m68k_rom_req,
	input	     [17:0] m68k_rom_addr,		// Dword address
	output reg [15:0]	m68k_rom_data,
	
	// To/from SDRAM controller
	output reg        SDRAM_WR,
	output reg        SDRAM_RD,
	output reg        SDRAM_BURST,
	output [26:1] SDRAM_ADDR,
	
	input      [63:0] SDRAM_DOUT,
	
	output     [15:0] SDRAM_DIN,
	input             SDRAM_READY,
	output      [1:0] SDRAM_BS,

	// HPS download
	input             DL_EN,
	input      [15:0] DL_DATA,
	input      [26:0] DL_ADDR,
	input             DL_WR,
	
	output reg sdram_dtack
);

	reg [26:1] dl_addr_reg;
	reg [15:0] dl_data_reg;

	assign SDRAM_BS = 2'b11;
	assign SDRAM_DIN = dl_data_reg;

	reg TILES_RD_RUN, SPR_RD_RUN, THEME_RD_RUN, M68K_RD_RUN;
	reg TILES_TODO, SPR_TODO, THEME_TODO, M68K_TODO;
	reg old_ready;

	// SDRAM address mux for currently running access
	/*always_comb begin 
		casez ({DL_EN, SPR_RD_RUN, TILES_RD_RUN, THEME_RD_RUN, M68K_RD_RUN})
			// HPS loading pass-through
			5'b1zzzz: SDRAM_ADDR = dl_addr_reg;	// Word address
			
			// Byte $0000000-$00FFFFF (1MB)
			// Word $0000000-$007FFFF
			// With offset:
			// Byte $1000000-$10FFFFF ($1000000)
			// Word $0800000-$087FFFF
			// Tiles		$0000000~$003FFFF 32-bit ($0000000~$007FFFF word)
			5'b00100: SDRAM_ADDR = {7'b00_1000_0, tiles_rom_addr, 1'b0};	// DWord to word address
			
			// Byte $0000000-$01FFFFF (2MB)
			// Word $0000000-$00FFFFF
			// With offset:
			// Byte $1200000-$13FFFFF ($1200000)
			// Word $0900000-$09FFFFF
			// Sprites	$0000000~$007FFFF 32-bit ($0000000~$00FFFFF word)
			5'b01000: SDRAM_ADDR = {6'b00_1001, spr_rom_addr, 1'b0};		// DWord to word address
			
			// Byte $0000000-$007FFFF (512kB)
			// Word $0000000-$003FFFF
			// With offset:
			// Byte $0100000-$017FFFF ($0100000)
			// Word $0080000-$00BFFFF
			// Theme		$0000000~$003FFFF 16-bit
			5'b00010: SDRAM_ADDR = {8'b00_0000_10, theme_rom_addr};		// Word address
			
			// Byte $0000000-$005FFFF (384kB)
			// Word $0000000-$002FFFF
			// With offset:
			// Byte $0000000-$005FFFF ($0000000)
			// Word $0000000-$002FFFF
			// Code		$0000000~$002FFFF 16-bit
			5'b00001: SDRAM_ADDR = {8'b00_0000_00, m68k_rom_addr};		// Word address
			
			default: SDRAM_ADDR = 26'd0;
		endcase
	end*/
	
	reg [17:0] TILES_ADDR_REQ;
	reg [18:0] SPR_ADDR_REQ;
	reg [17:0] M68K_ADDR_REQ;
	reg [17:0] THEME_ADDR_REQ;

	assign ready = SDRAM_READY & ~SDRAM_RD & ~SDRAM_WR;
	
	reg [26:1] ADDR_REQ;
	
	assign SDRAM_ADDR = DL_EN ? dl_addr_reg : ADDR_REQ;

	always @(posedge clk_sys) begin
		// HPS loading pulse
		if (DL_WR & DL_EN) begin
			dl_addr_reg <= DL_ADDR[26:1];	// DL_ADDR is byte-based, dl_addr is word-based
			dl_data_reg <= DL_DATA;
			SDRAM_WR <= 1;
		end
		
		// Stop request as soon as SDRAM is busy
		old_ready <= SDRAM_READY;
		if (old_ready & ~SDRAM_READY) begin
			SDRAM_WR <= 0;
			SDRAM_RD <= 0;
		end
		
		if (reset) begin
			SPR_TODO <= 0;
			TILES_TODO <= 0;
			THEME_TODO <= 0;
			M68K_TODO <= 0;

			SPR_RD_RUN <= 0;
			TILES_RD_RUN <= 0;
			THEME_RD_RUN <= 0;
			M68K_RD_RUN <= 0;
			
			SDRAM_BURST <= 0;
			
			if(~DL_EN) begin
				SDRAM_WR <= 0;
				SDRAM_RD <= 0;
			end
			
			sdram_dtack <= 0;	// TESTING
		end else begin
		
			if (m68k_rom_req & ~ready) begin
				// Save for later
				M68K_ADDR_REQ <= m68k_rom_addr;
				M68K_TODO <= 1;
				sdram_dtack <= 0;	// TESTING
			end
			if (spr_rom_req & ~ready) begin
				// Save for later
				SPR_ADDR_REQ <= spr_rom_addr;
				SPR_TODO <= 1;
			end
			if (tiles_rom_req & ~ready) begin
				// Save for later
				TILES_ADDR_REQ <= tiles_rom_addr;
				TILES_TODO <= 1;
			end
			if (theme_rom_req & ~ready) begin
				// Save for later
				THEME_ADDR_REQ <= theme_rom_addr;
				THEME_TODO <= 1;
			end

			if ((m68k_rom_req | M68K_TODO) & ready) begin
				// Start run now
				ADDR_REQ <= {8'b00_0000_00, M68K_TODO ? M68K_ADDR_REQ : m68k_rom_addr};
				M68K_TODO <= 0;
				M68K_RD_RUN <= 1;
				sdram_dtack <= 0;	// TESTING
				SDRAM_RD <= 1;
				SDRAM_BURST <= 0;	//1;
			end else if ((spr_rom_req | SPR_TODO) & ready) begin
				// Start run now
				ADDR_REQ <= {6'b00_1001, SPR_TODO ? SPR_ADDR_REQ : spr_rom_addr, 1'b0};	// DWord to word address
				SPR_TODO <= 0;
				SPR_RD_RUN <= 1;
				SDRAM_RD <= 1;
				SDRAM_BURST <= 1;
			end else if ((tiles_rom_req | TILES_TODO) & ready) begin
				// Start run now
				ADDR_REQ <= {7'b00_1000_0, TILES_TODO ? TILES_ADDR_REQ : tiles_rom_addr, 1'b0};	// DWord to word address
				TILES_TODO <= 0;
				TILES_RD_RUN <= 1;
				SDRAM_RD <= 1;
				SDRAM_BURST <= 1;
			end else if ((theme_rom_req | THEME_TODO) & ready) begin
				// Start run now
				ADDR_REQ <= {8'b00_0000_10, THEME_TODO ? THEME_ADDR_REQ : theme_rom_addr};
				THEME_TODO <= 0;
				THEME_RD_RUN <= 1;
				SDRAM_RD <= 1;
				SDRAM_BURST <= 1;
			end
			
			if (SDRAM_READY & ~SDRAM_RD & ~SDRAM_WR) begin

				// Terminate running access and register data when SDRAM is ready again
				if (TILES_RD_RUN) begin
					tiles_rom_data <= SDRAM_DOUT[31:0];
					TILES_RD_RUN <= 0;
				end
				if (SPR_RD_RUN) begin
					spr_rom_data <= SDRAM_DOUT[31:0];
					SPR_RD_RUN <= 0;
				end
				if (THEME_RD_RUN) begin
					theme_rom_data <= {3'd0, SDRAM_DOUT[15:3]};	// YM data is 13 bit - TODO: use 32-bit data from burst ?
					THEME_RD_RUN <= 0;
				end
				if (M68K_RD_RUN) begin
					m68k_rom_data <= {SDRAM_DOUT[7:0], SDRAM_DOUT[15:8]};	//SDRAM_DOUT[15:0];
					M68K_RD_RUN <= 0;
					sdram_dtack <= 1;	// TESTING
				end
			end
		end
	end
endmodule
