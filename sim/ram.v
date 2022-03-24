`timescale 1ns/100ps

module ram_sim(
	address,
	nwe,
	nen,
	din,
	dout
);

parameter integer dataBits = 8;
parameter integer addrBits = 11;
parameter initFile = "";

input [addrBits-1:0] address;
input nwe;
input nen;
input [dataBits-1:0] din;
output reg [dataBits-1:0] dout;

integer i, f_init;
wire [dataBits-1:0] d_init;
reg [dataBits-1:0] data[0:(2**addrBits)-1];

initial begin
	/*f_init = $fopen(initFile, "rb");
    for (i = 0; i < (2**addrBits); i+=1) begin
		$fread(d_init, f_init);
	    data[i] <= d_init;
	end
	$fclose(f_init);*/
end

always @(*) begin
	if (!nwe & !nen)
		#1 data[address] <= din;
end

always @(*) begin
	#1 dout <= data[address];
end

endmodule
