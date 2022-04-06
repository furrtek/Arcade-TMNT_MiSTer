module planes(
	input reset,
	input clk_main,
	output V6M,
	
	input RMRD,
	input VRAMCS,
	input PDS,
	input NREAD,
	output reg VDTAC,
	
	input [7:0] DB_IN,
	input m68k_addr_16,
	input [15:1] AB,
	input nUDS,
	
	output [7:0] DB_OUT_k052109,
	output DBDIR_k052109,
	output [7:0] DB_OUT_k051962,
	output DBDIR_k051962,
	
	output HVOT,
	output [11:0] VA,
	output [11:0] VB,
	output [7:0] FX,
	
	output NVA,
	output NVB,
	output NFX,
	
	output NVBLK,
	output NCBLK,
	output SYNC
);

	wire clk_12M;
	wire PQ;
	wire [17:0] tiles_rom_addr;
	wire [31:0] tiles_rom_dout;
	wire [7:0] COL;
	wire [10:0] VC;
	wire [2:1] CAB;
	wire [15:0] VD_OUT;
	wire [15:0] VD_IN;
	wire [12:0] RA;
	wire [1:0] RCS;
	wire [2:0] ROE;
	wire [2:0] RWE;

	// LS74
	reg I20_Q;
	always @(posedge PQ or negedge PDS) begin
		if (!PDS)
			I20_Q <= 1'b1;
		else
			I20_Q <= VRAMCS;
	end

	// LS74
	always @(posedge clk_12M or negedge PDS) begin
		if (!PDS)
			VDTAC <= 1'b1;
		else
			VDTAC <= I20_Q;
	end

	k052109 k052109_1(
		.nRES(~reset),
		.clk_24M(clk_main),
		.clk_12M(clk_12M),
		
		.CRCS(VDTAC),		// CPU GFX ROM access
		.RMRD(RMRD),
		.VCS(VDTAC),		// CPU VRAM access
		.NRD(NREAD),		// CPU read
		.PQ(PQ),
		.HVOT(HVOT),
		.DB_DIR(DBDIR_k052109),
		
		// CPU interface
		.DB_IN(DB_IN),
		.DB_OUT(DB_OUT_k052109),
		.AB({m68k_addr_16, AB[15], nUDS, AB[14:13], AB[11:1]}),
		
		// VRAM interface
		.VD_OUT(VD_OUT),
		.VD_IN(VD_IN),
		.RA(RA),
		.RCS(RCS),
		.ROE(ROE),
		.RWE(RWE),
		
		// GFX ROMs interface
		.CAB(CAB),
		.VC(VC),
		
		// k051962 interface
		.COL(COL),				// To k051962 (partially)
		.ZA1H(ZA1H), .ZA2H(ZA2H), .ZA4H(ZA4H),	// To k051962
		.ZB1H(ZB1H), .ZB2H(ZB2H), .ZB4H(ZB4H),	// To k051962
		.BEN(BEN)	// To k051962
	);

	// Tile VRAM
	ram_sim #(8, 13, "") RAM_TILES_U(RA, RWE[1], RCS[1], VD_OUT[15:8], VD_IN[15:8]);		// 8k * 8
	ram_sim #(8, 13, "") RAM_TILES_L(RA, RWE[2], 1'b0, VD_OUT[7:0], VD_IN[7:0]);			// 8k * 8

	assign tiles_rom_addr = {CAB, COL[3:2], COL[4], COL[1:0], VC};

	// ../../sim/roms/
	rom_sim #(32, 18, "C:/Users/furrtek/Documents/Arcade-TMNT_MiSTer/sim/rom_tiles_32.txt") ROM_TILES(tiles_rom_addr, tiles_rom_dout);	// 256k * 32

	k051962 k051962_1(
		.nRES(~reset),
		.clk_24M(clk_main),
		.clk_6M(V6M),
		
		.DSA(VA),
		.DSB(VB),
		.DFI(FX),
		
		.NSAC(NVA),
		.NSBC(NVB),
		.NFIC(NFX),

		.CRCS(VDTAC),
		.BEN(BEN),	// From k052109
		.RMRD(RMRD),
		.DB_DIR(DBDIR_k051962),
		
		.ZA1H(ZA1H), .ZA2H(ZA2H), .ZA4H(ZA4H),	// From k052109
		.ZB1H(ZB1H), .ZB2H(ZB2H), .ZB4H(ZB4H),	// From k052109
		.COL({COL[7:5], 5'b00000}),	// From k052109 (partially)
		
		.VC(tiles_rom_dout),		// GFX ROM data
		
		// Video sync and blanking
		.NVBK(NVBLK),
		.NHBK(NHBK),
		.NVSY(NVSY),	// TODO: Where does NVSYNC go ?
		.NCSY(SYNC),
		
		// CPU interface
		.DB_IN(DB_IN),
		.DB_OUT(DB_OUT_k051962),
		.AB(AB[2:1])
	);
	
	assign NCBLK = NVBLK & NHBK;

endmodule
