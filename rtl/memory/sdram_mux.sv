//============================================================================
//  TMNT for MiSTer
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
	output reg [31:0] tiles_rom_data,	// 8 pixels
	
	input             spr_rom_req,
	input      [18:0] spr_rom_addr,		// Dword address
	output reg [31:0] spr_rom_data,		// 8 pixels

	/*input					theme_rom_req,
	input	     [17:0] theme_rom_addr,
	output reg [15:0]	theme_rom_data,*/
	
	output reg        SDRAM_WR,
	output reg        SDRAM_RD,
	output reg        SDRAM_BURST,
	output reg [26:1] SDRAM_ADDR,
	input      [63:0] SDRAM_DOUT,
	output     [15:0] SDRAM_DIN,
	input             SDRAM_READY,
	output      [1:0] SDRAM_BS,

	input             DL_EN,
	input      [15:0] DL_DATA,
	input      [26:0] DL_ADDR,
	input             DL_WR
);

	//localparam P2ROM_OFFSET = 27'h0300000;

	reg [26:1] dl_addr;
	reg [15:0] dl_data;

	assign SDRAM_BS = 2'b11;
	assign SDRAM_DIN = dl_data;

	reg SROM_RD_RUN, CROM_RD_RUN;	//, THEME_RD_RUN;

	// SDRAM address mux
	always_comb begin 
		casez ({DL_EN, CROM_RD_RUN, SROM_RD_RUN})
			// HPS loading pass-through
			3'b1zz: SDRAM_ADDR = dl_addr;	// Word address
			
			// Byte $000000-$0FFFFF (1MB)
			// Word $000000-$07FFFF
			// Tiles		$0000000~$003FFFF 32-bit ($0000000~$007FFFF word)
			3'b001: SDRAM_ADDR = {7'b00_0000_0, tiles_rom_addr, 1'b0};	// Word address

			// Byte $000000-$1FFFFF (2MB)
			// Word $000000-$0FFFFF
			// With offset:
			// Byte $200000-$3FFFFF (2MB)
			// Word $100000-$1FFFFF
			// Sprites	$0000000~$007FFFF 32-bit ($0000000~$00FFFFF word) + $0100000
			3'b010: SDRAM_ADDR = {6'b00_0001, spr_rom_addr, 1'b0};		// Word address
			
			default: SDRAM_ADDR = 26'd0;
		endcase
	end

	reg SDRAM_CROM_SIG_SR;
	reg SDRAM_SROM_SIG_SR;
	//reg SDRAM_THEME_SIG_SR;

	//wire REQ_CROM_RD = (~SDRAM_CROM_SIG_SR & spr_rom_req);
	//wire REQ_SROM_RD = (~SDRAM_SROM_SIG_SR & tiles_rom_req);
	//wire REQ_THEME_RD = (~SDRAM_THEME_SIG_SR & theme_rom_req);

	always @(posedge clk_sys) begin
		reg SROM_RD_REQ, CROM_RD_REQ, THEME_RD_REQ;
		reg old_ready;

		if (DL_WR & DL_EN) begin
			dl_addr <= DL_ADDR[26:1];	// DL_ADDR is byte-based, dl_addr is word-based
			dl_data <= DL_DATA;
			SDRAM_WR <= 1;
		end
		
		old_ready <= SDRAM_READY;
		if (old_ready & ~SDRAM_READY) begin
			SDRAM_WR <= 0;
			SDRAM_RD <= 0;
		end

		SDRAM_CROM_SIG_SR <= spr_rom_req;
		SDRAM_SROM_SIG_SR <= tiles_rom_req;
		//SDRAM_THEME_SIG_SR <= theme_rom_req;
		
		if (reset) begin
			CROM_RD_REQ <= 0;
			SROM_RD_REQ <= 0;
			//THEME_RD_REQ <= 0;

			CROM_RD_RUN <= 0;
			SROM_RD_RUN <= 0;
			//THEME_RD_RUN <= 0;
			
			if(~DL_EN) begin
				SDRAM_WR <= 0;
				SDRAM_RD <= 0;
			end
		end else begin

			// Detect sprite data read requests
			// Detect rising edge of spr_rom_req
			//if (REQ_CROM_RD) CROM_RD_REQ <= 1;
			if (spr_rom_req) CROM_RD_REQ <= 1;

			// Detect fix data read requests
			// Detect rising edge of tiles_rom_req
			//if (REQ_SROM_RD) SROM_RD_REQ <= 1;
			if (tiles_rom_req) SROM_RD_REQ <= 1;

			// Detect fix data read requests
			// Detect rising edge of tiles_rom_req
			//if (REQ_THEME_RD) THEME_RD_REQ <= 1;
			
			if (SDRAM_READY & ~SDRAM_RD & ~SDRAM_WR) begin

				// Terminate running access, if needed
				// Having two non-nested IF statements with the & in the condition
				// prevents synthesis from chaining too many muxes and causing
				// timing analysis to fail
				if (SROM_RD_RUN) begin
					tiles_rom_data <= SDRAM_DOUT[31:0];
					SROM_RD_RUN    <= 0;
				end
				if (CROM_RD_RUN) begin
					spr_rom_data   <= SDRAM_DOUT[31:0];
					CROM_RD_RUN    <= 0;
				end
				/*if (THEME_RD_RUN) begin
					theme_rom_data <= SDRAM_DOUT[15:0];
					THEME_RD_RUN   <= 0;
				end*/

				// Start requested access, if needed
				if (CROM_RD_REQ | spr_rom_req) begin
					CROM_RD_REQ    <= 0;
					CROM_RD_RUN    <= 1;
					SDRAM_RD       <= 1;
					SDRAM_BURST    <= 1;
				end else if (SROM_RD_REQ | tiles_rom_req) begin
					SROM_RD_REQ    <= 0;
					SROM_RD_RUN    <= 1;
					SDRAM_RD       <= 1;
					SDRAM_BURST    <= 1;
				end /*else if (THEME_RD_REQ | REQ_THEME_RD) begin
					THEME_RD_REQ    <= 0;
					THEME_RD_RUN    <= 1;
					SDRAM_RD       <= 1;
					SDRAM_BURST    <= 1;	// TODO: No need for burst ?
				end*/
			end
		end
	end
endmodule
