module clocks (
    input clk,
    output clk25,

    output reg cpu_clken
);

    // 12MHz up to 25MHz
    clock_pll clock_pll_inst(
            .REFERENCECLK(clk),
            .PLLOUTCORE(),
            .PLLOUTGLOBAL(clk25),
            .RESET(1'b1)
            );

    reg [25:0] clk_div;

    always @(posedge clk25)
    begin
        if (clk_div == 12000000)
            clk_div <= 0;
        else
            clk_div <= clk_div + 1;

        // 1MHz
        cpu_clken <= (clk_div[25:0] == 0);

        // 2MHz
        //cpu_clken <= (clk_div[4] == 0) & (clk_div[2:0] == 0);

        // 4MHz
        //cpu_clken <= (clk_div[4] == 0) & (clk_div[1:0] == 0);
    end
endmodule
