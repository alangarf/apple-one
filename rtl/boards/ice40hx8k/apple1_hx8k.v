module apple1_top(
    input  clk,             // 12 MHz board clock

    input  uart_rx,
    output uart_tx,
    output uart_cts,
    output [15:0] led,
    input [3:0] button
);

    wire clk25;

    // 12MHz up to 25MHz
    clock_pll clock_pll_inst(
            .REFERENCECLK(clk),
            .PLLOUTCORE(),
            .PLLOUTGLOBAL(clk25),
            .RESET(1'b1)
            );

    wire [15:0] pc_monitor;
    assign led[7:0] = pc_monitor[7:0];
    assign led[15:8] = ~pc_monitor[15:8];

    // apple one main system
    apple1 my_apple1(
        .clk25(clk25),
        .rst_n(1'b1),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_cts(uart_cts),
        .pc_monitor(pc_monitor),
        .reset_button(button[0])
    );
    
endmodule
