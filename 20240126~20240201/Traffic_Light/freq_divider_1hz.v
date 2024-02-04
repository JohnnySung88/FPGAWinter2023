module freq_divider_1hz(

		input 	  fin,
		output reg _fout

);

wire [31:0] DIVN;
wire [31:0] _DIVN;
wire 			fout;
reg  [31:0] count;

                      
assign DIVN = 32'd50000000;
assign _DIVN = {1'b0,DIVN[31:1]};


always @(posedge fin)
	if(count >= DIVN)
		count <= 32'd1;
	else
		count <= count+32'd1;
		
assign fout = (count <= _DIVN)?1'b0:1'b1;
always @(negedge fin)
		_fout <= fout;

endmodule 