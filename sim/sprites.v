module sprites(
	input reset,
	input clk_main,
	
	input OBJCS,
	input PDS,
	input NREAD,
	output PE,
	
	input HVOT,
	
	input [7:0] DB_IN,
	input [15:1] AB,
	input nUDS,
	
	output [7:0] DB_OUT_k051960,
	output DBDIR_k051960,
	output [7:0] DB_OUT_k051937,
	output DBDIR_k051937,
	
	output SHA, NOBJ,
	output [11:0] OB,
	
	output reg ODTAC
);

	wire clk_12M;
	wire PQ;
	wire [31:0] spr_rom_dout;
	wire [8:0] HP;
	wire [7:0] OC;
	wire [17:0] CA;
	wire [9:0] OA;
	wire [7:0] OD_in;
	wire [7:0] OD_out;

	// LS74
	reg I20_Q;
	always @(posedge PQ or negedge PDS) begin
		if (!PDS)
			I20_Q <= 1'b1;
		else
			I20_Q <= OBJCS;
	end
	
	// LS74
	always @(posedge clk_12M or negedge PDS) begin
		if (!PDS)
			ODTAC <= 1'b1;
		else
			ODTAC <= I20_Q;
	end
	
	k051960 k051960_1 (
		.nRES(~reset),
		.clk_24M(clk_main),
		.clk_12M(clk_12M),
		
		.HVIN(HVOT),
		
		.PQ(PQ), .PE(PE),

		.NRD(NREAD), .OBCS(ODTAC),

		.AB({AB[10:1], nUDS}),
		
		.DB_OUT(DB_OUT_k051960),
		.DB_IN(DB_IN),
		.DB_DIR(DBDIR_k051960),
		
		.OHF(OHF), .OREG(OREG), .HEND(HEND), .LACH(LACH), .CARY(CARY),

		.HP(HP),
		.OC(OC),
		.CA(CA),

		.OA_out(OA),
		.OWR(OWR), .OOE(OOE),
		.OD_in(OD_in),
		.OD_out(OD_out)
	);

	// Sprite VRAM
	ram_sim #(8, 10, "") RAM_SPR(OA, OWR, 1'b0, OD_out, OD_in);		// 1k * 8
	
	// ../../sim/roms/
	rom_sim #(32, 20, "rom_sprites_32.txt") ROM_SPRITES(CA, spr_rom_dout);	// 512k * 32
	
	reg [9:1] CA_DEC;
	wire [3:0] PROM_dout;
	rom_sim #(8, 8, "prom_sprdec_8.txt") ROM_SPRDEC({CAJ, CA[17:10], CA_DEC, CA[3]}, PROM_dout);	// 256 * 8
	
	always @(*) begin
		case(PROM_dout[2:0])
			3'd0: CA_DEC <= {CA[9], CA[8], CA[7], CA[6], CA[5], CA[4], CA[2], CA[1], CA[0]};
			3'd1: CA_DEC <= {CA[9], CA[8], CA[7], CA[5], CA[6], CA[4], CA[2], CA[1], CA[0]};
			3'd2: CA_DEC <= {CA[9], CA[8], CA[7], CA[6], CA[4], CA[2], CA[1], CA[0], CA[5]};
			3'd3: CA_DEC <= {CA[9], CA[8], CA[7], CA[6], CA[4], CA[2], CA[1], CA[0], CA[5]};
			3'd4: CA_DEC <= {CA[9], CA[7], CA[8], CA[6], CA[4], CA[2], CA[1], CA[0], CA[5]};
			3'd5: CA_DEC <= {CA[9], CA[8], CA[6], CA[4], CA[2], CA[1], CA[0], CA[7], CA[5]};
			3'd6: CA_DEC <= {CA[9], CA[8], CA[6], CA[4], CA[2], CA[1], CA[0], CA[7], CA[5]};
			3'd7: CA_DEC <= {CA[8], CA[6], CA[4], CA[2], CA[1], CA[0], CA[9], CA[7], CA[5]};
		endcase
	end

	k051937 k051937_1 (
		.nRES(~reset),
		.clk_24M(clk_main),
		
		.HVIN(HVOT),
		
		.NRD(NREAD), .OBCS(ODTAC),
		
		.AB({AB[2:1], nUDS}),
		.AB10(AB[11]),
		
		.DB_OUT(DB_OUT_k051937),
		.DB_IN(DB_IN),
		.DB_DIR(DBDIR_k051937),
		
		.SHAD(SHA), .NCOO(NOBJ),
		.OB(OB),

		.CD0(spr_rom_dout[7:0]),
		.CD1(spr_rom_dout[15:8]),
		.CD2(spr_rom_dout[23:16]),
		.CD3(spr_rom_dout[31:24]),

		.OC(OC),
		.HP(HP),
		
		.CARY(CARY), .LACH(LACH), .HEND(HEND), .OREG(OREG), .OHF(OHF)
	);
	
endmodule
