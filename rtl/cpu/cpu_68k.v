module cpu_68k(
	input clk,
	input clken,	// Must be 2x CPU clock
	input nRESET,
	input IPL2, IPL1, IPL0,
	input nDTACK,
	output [23:1] M68K_ADDR,
	input [15:0] FX68K_DATAIN,
	output [15:0] FX68K_DATAOUT,
	output nLDS, nUDS,
	output nAS,
	output M68K_RW,
	output FC2, FC1, FC0,
	output nBG,
	input nBR, nBGACK
);

// clk		_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_|'|_
// clken 	_____________|'''|___________|'''|___________|'''|___________|'''|___________
// EN_PHI1	_________________|'''|___________________________|'''|_______________________
// EN_PHI2	_________________________________|'''|___________________________|'''|_______

reg toggle, EN_PHI1, EN_PHI2;

/*always @(posedge clk or negedge nRESET)	// always @(negedge clk or negedge nRESET)
begin
	if (!nRESET) begin
		toggle = 1'b0;
		{EN_PHI1, EN_PHI2} <= 2'b00;
	end else begin
		EN_PHI1 <= (clken & toggle);
		EN_PHI2 <= (clken & ~toggle);
		if (clken)
			toggle <= ~toggle;
	end
end*/
always @(posedge clk or negedge nRESET)	// always @(negedge clk or negedge nRESET)
begin
	if (!nRESET) begin
		toggle = 1'b0;
		{EN_PHI1, EN_PHI2} <= 2'b01;
	end else begin
		EN_PHI1 <= (clken & ~toggle);
		EN_PHI2 <= (clken & toggle);
		if (clken)
			toggle <= ~toggle;
	end
end
	
reg reset;
always @(posedge clk)
	if (EN_PHI2) reset <= ~nRESET;
	
wire final_reset = reset | ~nRESET;

fx68k FX68K(
	.clk(clk),
	.extReset(final_reset),
	.pwrUp(final_reset),

	.enPhi1(EN_PHI1),
	.enPhi2(EN_PHI2),

	.eRWn(M68K_RW),
	.ASn(nAS),
	.UDSn(nUDS),
	.LDSn(nLDS),

	.BGn(nBG),
	.BRn(nBR),
	.BGACKn(nBGACK),

	.DTACKn(nDTACK),

	.VPAn(~&{M68K_ADDR[23], ~nAS}),
	.BERRn(1'b1),

	.IPL0n(IPL0),
	.IPL1n(IPL1),
	.IPL2n(IPL2),

	.FC0(FC0),
	.FC1(FC1),
	.FC2(FC2),

	.iEdb(FX68K_DATAIN),
	.oEdb(FX68K_DATAOUT),
	.eab(M68K_ADDR)
);
	
endmodule
