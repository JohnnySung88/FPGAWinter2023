module Debounce_Circuit(
    input clk, reset, in,
    output reg out
);

reg [1:0] ns, cs;

// Next State
always @(*) begin
    case(cs)
        2'd0: ns = (in) ? 2'd0 : 2'd1;
        2'd1: ns = (in) ? 2'd0 : 3'd2;
        2'd2: ns = (in) ? 2'd0 : 2'd3;
        2'd3: ns = (in) ? 2'd0 : 2'd3;
        default: ns = 2'd0;
    endcase
end

// State Register
always @(posedge clk or negedge reset) begin
    if (!reset)
        cs <= 2'd0;
    else
        cs <= ns;
end

// Output
always @(*) begin
    case(cs)
        2'd0, 2'd1, 2'd2: out = 1'b1;
        2'd3: out = 1'b0;
        default: out = 1'b1;
    endcase
end

endmodule
