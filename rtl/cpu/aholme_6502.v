module aholme_6502(
    input clk,
    input enable,
    input reset,
    output [15:0] ab,
    input [7:0] dbi,
    output [7:0] dbo,
    output we,
    input irq_n,
    input nmi_n,
    input ready,
    output [15:0] pc_monitor    // program counter monitor signal for debugging
);

    wire we_c;
    assign we = ~we_c;

    cpu aholme_cpu (
        .clk(clk),
        .phi(enable),
        .res(~reset),
        .so(1'b0),
        .rdy(ready),
        .nmi(nmi_n),
        .irq(irq_n),
        .rw(we_c),
        .dbi(dbi),
        .dbo(dbo),
        .ab(ab),
        .pc_monitor(pc_monitor)
    );

endmodule
