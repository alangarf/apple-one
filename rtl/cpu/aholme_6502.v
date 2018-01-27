module aholme_6502(
    input clk,
    input enable,
    input reset,
    output [15:0] ab,
    input [7:0] dbi,
    output [7:0] dbo,
    output we,
    input irq,
    input nmi,
    input ready
);

    wire we_c;

    chip_6502 aholme_cpu (
        .clk(clk),
        .phi(clk & enable),
        .res(~reset),
        .so(1'b0),
        .rdy(ready),
        .nmi(nmi_n),
        .irq(irq_n),
        .rw(we_c),
        .dbi(dbi),
        .dbo(dbo),
        .ab(ab)
    );

    assign we = ~we_c;

endmodule
