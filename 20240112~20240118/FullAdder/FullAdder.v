module FullAdder(
	input  A,B,Cin,
	output out,Cout
);
/*
-------------------------------------
   A     B   Cin  |     out   Cout 
-------------------------------------
   0     0    0   |      0      0    
   0     0    1   |      1      0    
   0     1    0   |      1      0     
   0     1    1   |      0      1     
	1     0    0   |      1      0     
	1     0    1   |      0      1     
	1     1    0   |      0      1     
	1     1    1   |      1      1     

*/
 
assign out  = (A & ~B & ~Cin)|(~A & B & ~Cin)|(~A & ~B & Cin)|(A & B & Cin);
assign Cout = (A & B)|(A & Cin)|(B & Cin);

endmodule 