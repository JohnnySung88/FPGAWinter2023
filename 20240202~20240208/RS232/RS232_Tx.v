module RS232_Tx(t_data,start,reset,OG_clk,Tx);

input [7:0] t_data;
input start,reset,OG_clk;
output reg Tx;

wire tdc; //Transmit Data Complet
wire rst; //Counter Reset
wire en;  //Shift Register Enable

reg [2:0] cs,ns; // Current State, Next State
reg [1:0] output_sel;
reg [2:0] cnt;
reg [7:0] t_data_shift;
reg Tx_reg;

//FSM D Flip-Flop
always @(posedge OG_clk or posedge reset)begin
	begin
		if(reset)
			cs <= 3'b000;
		else
			cs <= ns;
	end
end

//FSM Next State Generator
always @(*) begin
   case(cs)
		3'd0: ns = 3'd1;
      3'd1: ns = (start == 1'b1)?3'd2:3'd1;
      3'd2: ns = 3'd3;
      3'd3: ns = (tdc == 1'b1)?3'd2:3'd1;
		3'd4: ns = 3'd1;        
		default: ns = 3'd0;
   endcase
end

//FSM Decoder
assign rst = (cs == 3'd3)?1'b0:1'b1;
assign en = (cs == 3'd3)?1'b1:1'b0;
always @(cs) begin
	case(cs)
		3'd0: output_sel = 2'b00;
		3'd1: output_sel = 2'b00;
		3'd2: output_sel = 2'b01;
		3'd3: output_sel = 2'b10;
		3'd4: output_sel = 2'b11;
		default: output_sel = 2'b00;
	endcase
end

//Counter
always @(posedge OG_clk or posedge reset)begin
	begin
		if(rst)
			cnt <= 3'd0;
		else if(en)
			cnt <= cnt + 1 ;
	end
end

//Shift Register
always @(posedge OG_clk)begin
	begin
		if(~en)
			t_data_shift <= t_data;
		else 
			t_data_shift <= {1'b0,t_data_shift[7:1]};
	end
end

//Output MUX
always @(*)begin
	case(output_sel)
		2'd0: Tx_reg = 1'b1; //Wait
		2'd1: Tx_reg = 1'b0; //Start
		2'd2: Tx_reg = t_data_shift[0]; //Data
		2'd3: Tx_reg = 1'b1; //Stop
		default: Tx_reg = 1'b1;
	endcase
end

always @(posedge OG_clk)begin
    Tx <= Tx_reg;
end

endmodule