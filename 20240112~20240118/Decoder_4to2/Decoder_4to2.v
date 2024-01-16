module Decoder_4to2(
	input  [1:0] in,
	output [3:0] out
);
/*
------------------------------------------------
in[1] in[0]  |  out[3] out[2] out[1] out[0] 
------------------------------------------------
   0     0   |      1      1      0      1
   0     1   |      1      1      1      0
   1     0   |      0      1      1      0
   1     1   |      0      0      0      1

*/
 
assign out[0] = (~in[0] & ~in[1]) | ( in[0] &  in[1]);
assign out[1] = ( in[0] & ~in[1]) | (~in[0] &  in[1]);
assign out[2] = ~in[0] | ~in[1];
assign out[3] = ~in[1];

endmodule 