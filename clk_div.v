module clk_div 
#( 
    //parameter WIDTH = 16,
    //parameter N = 65535      // divide by 12
    parameter WIDTH = 4,
    parameter N = 1      // divide by 12
)
(
    input clk,
    output clk_out
);
 
reg [WIDTH-1:0] r_reg;
wire [WIDTH-1:0] r_nxt;
reg clk_track;
 
always @(posedge clk)
begin
    if (r_nxt == N)
    begin
        r_reg <= 0;
        clk_track <= ~clk_track;
    end

    else 
        r_reg <= r_nxt;
end
 
assign r_nxt = r_reg + 1;   	      
assign clk_out = clk_track;

endmodule
