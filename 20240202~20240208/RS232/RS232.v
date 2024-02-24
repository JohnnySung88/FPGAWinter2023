module RS232(Rx,reset,clk,Seven1,Seven2,Tx);

input Rx; //GPIO_D0
input clk; //50MHz
input reset; // SW0
output Tx; //GPIO_D1
output [6:0]Seven1,Seven2;
wire [7:0]Data;
wire start;
wire clk_115200;

FreqDivider M0(clk,clk_115200);
RS232_Rx M1(Rx,clk_115200,reset,Data,start);
RS232_Tx M2(Data,start,reset,clk_115200,Tx);
_7seg B0(Data[3:0],Seven1);
_7seg B1(Data[7:4],Seven2);

endmodule

//Rx
module RS232_Rx(Rx,clk,reset,RData,start);

input Rx;
input clk,reset;
output [7:0]RData;
output reg start;
wire start_;
reg [2:0]cs,ns;
reg [2:0]cnt;
reg [7:0]RData_;
wire RDC; //Receive Data Complete
wire Rst; //Counter reset
wire en; //Shift register enable
wire Output_sel_;
reg Output_sel;

//FSM Dff
always @(posedge clk or posedge reset)begin
    if(reset)begin
        cs <= 3'b000;
    end
    else begin
        cs <= ns;
    end
end

//FSM NSG
always @(*)begin
    case(cs)
        3'd0: ns = 3'd1;
        3'd1: ns = (Rx==1'b0)?3'd2:3'd1;
        3'd2: ns = (RDC==1'b1)?3'd3:3'd2;
        3'd3: ns = (Rx==1'b1)?3'd4:3'd1;
        3'd4: ns = (Rx==1'b1)?3'd1:3'd2;
        default: ns = 3'd0;
    endcase
end

//FSM Decoder
assign Rst = (cs==3'd2)?1'b0:1'b1;
assign en = (cs==3'd2)?1'b1:1'b0;
assign Output_sel_ = (cs==3'd4)?1'b1:1'b0;

//Counter
always @(posedge clk or posedge Rst)begin
    if(Rst)begin
        cnt <= 3'd0;
    end
    else if(en)begin
        cnt <= cnt+1;
    end
end
assign RDC = (cnt==3'd7)?1'b1:1'b0;

//Shift Register
always @(posedge clk)begin
    if(en)begin
        RData_ <= {Rx,RData_[7:1]};
    end
end

//Output
always @(posedge clk)begin
    Output_sel <= Output_sel_;
end
assign RData = (reset)?8'd0:((Output_sel==1'b1)?RData_:RData);

//Start
assign start_ = (cs==3'd4)?1'b1:1'b0;
always @(posedge clk)begin
    start <= start_;
end


endmodule

//TX
module RS232_Tx(TData,start,reset,clk,Tx);

input [7:0]TData;
input start,reset,clk;
output reg Tx;
reg [2:0]cs,ns;
wire TDC; //Transmit Data Complete
wire Rst; //Counter reset
wire en; //Shift register enable
reg [1:0]Output_sel;
reg [2:0]cnt;
reg [7:0]TData_shift;
reg Tx_reg;

//FSM Dff
always @(posedge clk or posedge reset)begin
    if(reset)begin
        cs <= 3'b000;
    end
    else begin
        cs <= ns;
    end
end

//FSM NSG
always @(*)begin
    case(cs)
        3'd0: ns = 3'd1;
        3'd1: ns = (start==1'b1)?3'd2:3'd1;
        3'd2: ns = 3'd3;
        3'd3: ns = (TDC==1'b1)?3'd4:3'd3;
        3'd4: ns = 3'd1;
        default: ns = 3'd0;
    endcase
end

//FSM Decoder
assign Rst = (cs==3'd3)?1'b0:1'b1;
assign en = (cs==3'd3)?1'b1:1'b0;
always @(cs)begin
    case(cs)
    2'd0: Output_sel = 2'd0;
    2'd1: Output_sel = 2'd0;
    2'd2: Output_sel = 2'b01;
    2'd3: Output_sel = 2'b10;
    2'd4: Output_sel = 2'b11;
    default: Output_sel = 2'd0;
    endcase
end

//Counter
always @(posedge clk or posedge Rst)begin
    if(Rst)begin
        cnt <= 3'd0;
    end
    else if(en)begin
        cnt <= cnt+1;
    end
end
assign TDC = (cnt==3'd7)?1'b1:1'b0;

//Shift Register
always @(posedge clk)begin
    if(~en)begin
        TData_shift <= TData;
    end
    else begin
        TData_shift <= {1'b0,TData_shift[7:1]};
    end
end

//Output MUX
always @(*)begin
    case(Output_sel)
    2'd0: Tx_reg = 1'b1; //waiting
    2'd1: Tx_reg = 1'b0; //start
    2'd2: Tx_reg = TData_shift[0]; //data
    2'd3: Tx_reg = 1'b1; //stop
    default: Tx_reg = 1'b1;
    endcase
end

always @(posedge clk)begin
    Tx <= Tx_reg;
end

endmodule

//FreqDivider
module FreqDivider(

		input 	  fin,
		output reg _fout

);

wire [31:0] DIVN;
wire [31:0] _DIVN;
wire 			fout;
reg  [31:0] count;

                      
assign DIVN = 434;   // 50M/434 = 115200 baud rate
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

//7seg
module _7seg(din,dout);

input [3:0] din;
output reg [6:0] dout;

always @(*)begin
    case(din)
        4'b0000: dout <= 7'b1000000;
        4'b0001: dout <= 7'b1111001;
        4'b0010: dout <= 7'b0100100;
        4'b0011: dout <= 7'b0110000;
        4'b0100: dout <= 7'b0011001;
        4'b0101: dout <= 7'b0010010;
        4'b0110: dout <= 7'b0000010;
        4'b0111: dout <= 7'b1111000;
        4'b1000: dout <= 7'b0000000;
        4'b1001: dout <= 7'b0010000;
        4'b1010: dout <= 7'b0001000;
        4'b1011: dout <= 7'b0000011;
        4'b1100: dout <= 7'b1000110;
        4'b1101: dout <= 7'b0100001;
        4'b1110: dout <= 7'b0000110;
        4'b1111: dout <= 7'b0001110;
        default: dout <= 7'b0000000;
    endcase
end

endmodule
