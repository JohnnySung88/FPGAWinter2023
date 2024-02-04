module Traffic_Light(OG_clk,reset,off,LightA,LightB);
 input  OG_clk, reset, off;
 output [2:0] LightA,LightB;
 wire  clk;
 
 freq_divider_1hz u1(OG_clk,clk); // From 50 MHz to 1 Hz
 
 reg[3:0] ncount, ccount;
 reg[2:0] LightA, LightB;
 reg[2:0] cs,ns;
 
 // Next State
 always@ (*)begin
  case(cs)
  3'b000:
  begin
   ncount = (ccount < 4'd3) ? ccount + 4'd1 :  4'd1;
   ns   = (ccount < 4'd3) ?         3'b000 : 3'b001;
  end
  3'b001:
  begin
   ncount = (ccount < 4'd1) ? ccount + 4'd1 :  4'd1;
   ns   = (ccount < 4'd1) ?         3'b001 : 3'b010;
  end
  3'b010:
  begin
   ncount = (ccount < 4'd4) ? ccount + 4'd1 :  4'd1;
   ns   = (ccount < 4'd4) ?         3'b010 : 3'b011;
  end
  3'b011:
  begin
   ncount = (ccount < 4'd1) ? ccount + 4'd1 :  4'd1;
   ns   = (ccount < 4'd1) ?         3'b011 : 3'b000;
  end
  default:
  begin
   ncount = (ccount < 4'd3) ? ccount + 4'd1 :  4'd1;
   ns   = (ccount < 4'd3) ?         3'b000 : 3'b001;
  end
  endcase
 end
 
 // state register
 always@(posedge clk or negedge reset) begin
  if(!reset)
  begin
   ccount <= 4'd1;
   cs <= 3'b000;
  end
  else if(!off)
  begin
	ccount <= 4'd0;
	cs <= 3'b111;
  end
  else
  begin
   ccount <=ncount;
   cs <= ns;
  end
 end
 
 // output logic
 always@(*)begin
  case(cs)
  3'b000:
  begin
   LightA = 3'b001;
   LightB = 3'b100;
  end
  3'b001:
  begin
   LightA = 3'b010;
   LightB = 3'b100;
  end
  3'b010:
  begin
   LightA = 3'b100;
   LightB = 3'b001;
  end
  3'b011:
  begin
   LightA = 3'b100;
   LightB = 3'b010;
  end
  3'b111:
  begin
   LightA = 3'b000;
   LightB = 3'b000;
  end
  default:
  begin
   LightA = 3'b001;
   LightB = 3'b100;
  end
  endcase
 end
 
endmodule
