module Four_b_Add_n_Sub(
    input [3:0] a,
    input [3:0] b,
    input sub,
    output [3:0] sum
);

    wire cout0;
    wire cout1;
    wire [3:0] b_n;
    
    assign b_n = b ^ {4{sub}};
    /*
		Add2 u(a,b,c0,s,c)
		input: [1:0]a,[1:0]b,c0,
		output: [1:0]s,c
	*/
    Add2 u1(.a(a[1:0]), .b(b_n[1:0]), .c0(sub), .s(sum[1:0]), .c(cout0) );   
    Add2 u2(.a(a[3:2]), .b(b_n[3:2]), .c0(cout0), .s(sum[3:2]), .c(cout1) );
    
endmodule

