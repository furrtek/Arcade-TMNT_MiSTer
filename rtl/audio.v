module TMNTAudio
(

);

	k007232 K007232(
		.DB(DB),
		.AB(AB[3:0]),
		.RAM(PCM_ROM_D),
		.SA(PCM_ROM_A),
		.ASD(SAMPLE_A),
		.BSD(SAMPLE_B),
		.SLEV(SLEV),
		.CLK(CLK),
		.DACS(U82[3]),
		.NRES(),
		.NRD(1),
		.NRCS(1)
	);

	reg [7:0] level;
	reg [7:0] U82;
	reg [7:0] U84;
	reg U115;
	wire [7:0] ROM_DOUT;
	wire [7:0] RAM_DOUT;
	
	always @(posedge SLEV) begin
		level_a <= DB[7:4];
		level_b <= DB[3:0];
	end
	
	Z80 Z80_CPU(
		.A(SA),
		.D(SD),
		.nRESET(SYSRES2),
		.nINT(~U115),
		.nIORQ(nIORQ),
		.nNMI(1),
		.nBUSRQ(1),
		.CLK(CLK_Z80),
		
	);
	
	wire nU115_CLR = SYSRES2 & nIORQ;
	
	always @(posedge SNDON or negedge nU115_CLR) begin
		if (!nU115_CLR)
			U115 <= 0;
		else
			U115 <= 1;
	end
	
	always @(posedge SNDDT)
		U84 <= D;
	assign SD = (U82[2]) ? U84 : 8'bzzzzzzzz;
	
	always @(*) begin
		case ({SA[15], nMREQ, ~RFSH}, SA[14:12])
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
	
	ROM Z80_ROM(
		.A(SA[14:0]),
		.D(ROM_DOUT)
	);
	assign SD = (~SA[15] & ~nRD) ? ROM_DOUT : 8'bzzzzzzzz;

	RAM Z80_RAM(
		.A(SA[10:0]),
		.D(RAM_DOUT),
		.WR(~nWR & ~U82[0])
	);
	assign SD = (~U82[0] & ~nRD) ? RAM_DOUT : 8'bzzzzzzzz;
	
	YM2151 YM(
		.CLK(SNDCLK),
		.IC(SYSRES2),
		.A0(SA[0]),
		.D(SD),
		.nWR(nWR),
		.nRD(nRD),
		.nCS(U82[4])
	);
endmodule
