module Add2(
	input [1:0]a,
	input [1:0]b,
	input c0,
	output [1:0]s,
	output c
);
//2 full adders used to make 2 bit adder.
//carry of each full adder is passed as input to the next full adder

wire c1;
FullAdder F1(a[0],b[0],c0,s[0],c1);
FullAdder F2(a[1],b[1],c1,s[1],c);

endmodule
