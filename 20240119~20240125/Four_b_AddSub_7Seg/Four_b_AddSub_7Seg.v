module Four_b_AddSub_7Seg(
    input [3:0] A,
    input [3:0] B,
    input Sub,
	 output [6:0] Sout,
    output Cout
);

wire [3:0] Sum;

/*
	module Four_b_Add_n_Sub(
    input [3:0] a,
    input [3:0] b,
    input sub,
    output [3:0] sum
);

*/

Four_b_Add_n_Sub Ans (A, B, Sub, Sum, Cout);
Seven_Seg(.din(Sum), .dout(Sout));

endmodule
