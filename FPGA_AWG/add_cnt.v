module add_cnt(clk,freq_word,RDaddress);
	input clk;
	input [22:0] freq_word;
	output reg [9:0] RDaddress;
	reg [26:0] phaseadder;
	always @(posedge clk)
		begin
			phaseadder = phaseadder + freq_word;
			RDaddress = phaseadder[26:17];
		end
endmodule
