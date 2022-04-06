`timescale 1 ns / 1 ns

module tb(
);

reg clk;
reg reset;
wire [5:0] video_r;
wire [5:0] video_g;
wire [5:0] video_b;

reg [7:0] dipswitch1;
reg [7:0] dipswitch2;
reg [3:0] dipswitch3;
wire [1:0] coin_counter;

reg [3:0] P_up;
reg [3:0] P_down;
reg [3:0] P_left;
reg [3:0] P_right;
reg [3:0] P_jump;
reg [3:0] P_attack1;
reg [3:0] P_attack2;
reg [3:0] P_attack3;
reg [3:0] P_start;
reg [3:0] P_coin;
reg [3:0] service;

top DUT(
	.reset(reset),
	.clk_main(clk),

	.P_up(P_up),
	.P_down(P_down),
	.P_left(P_left),
	.P_right(P_right),
	.P_jump(P_jump),
	.P_attack1(P_attack1),
	.P_attack2(P_attack2),
	.P_attack3(P_attack3),
	.P_start(P_start),
	.P_coin(P_coin),
	
	.service(service),
	
	.coin_counter(coin_counter),
	
	.video_r(video_r),
	.video_g(video_g),
	.video_b(video_b),
	.video_sync(video_sync),
	
	.dipswitch1(dipswitch1),
	.dipswitch2(dipswitch2),
	.dipswitch3(dipswitch3)
);

always @(*)
	#1 clk <= ~clk;

initial begin
	clk <= 1'b0;
	reset <= 1'b1;
	dipswitch1 <= 8'b11111100;
	/*	Correct order ?
	xxxxCCCC x:unused
	CCCC: Coin/play setting
	1 coin = 4 play
	*/
	dipswitch2 <= 8'b01111100;
	/*	Correct order ?
	SDDxxxLL x:unused
	LL: Player lives 00:5
	DD: Difficulty 11:Easy
	S: Attract sound 0:On
	xxx: See mame tmnt.cpp, should be kept OFF
	*/
	dipswitch3 <= 4'b1111;
	/*	Correct order ?
	xMxF x:unused
	F: Display flip
	M: Test mode
	xx: See mame tmnt.cpp, should be kept OFF
	*/
	P_up <= 4'b1111;
	P_down <= 4'b1111;
	P_left <= 4'b1111;
	P_right <= 4'b1111;
	P_jump <= 4'b1111;
	P_attack1 <= 4'b1111;
	P_attack2 <= 4'b1111;
	P_attack3 <= 4'b1111;
	P_start <= 4'b1111;
	P_coin <= 4'b1111;
	service <= 4'b1111;

	#100
	reset <= 1'b0;
	
	//#50000
	//$stop();
end

endmodule
