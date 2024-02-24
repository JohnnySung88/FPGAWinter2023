module RS232_Rx(Rx,clk,reset,RData);

input Rx;
input clk,reset;
output [7:0]RData;
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
assign RData = (Output_sel==1'b1)?RData_:RData;


endmodule

