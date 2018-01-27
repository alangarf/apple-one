module arlet_6502(
    input clk,
    input enable,
    input reset,
    output reg [15:0] ab,
    input [7:0] dbi,
    output reg [7:0] dbo,
    output reg we,
    input irq,
    input nmi,
    input ready
);

    wire [7:0] dbo_c;
    wire [15:0] ab_c;
    wire we_c;

    cpu arlet_cpu (
        .clk(clk),
        .reset(reset),
        .AB(ab_c),
        .DI(dbi),
        .DO(dbo_c),
        .WE(we_c),
        .IRQ(irq_n),
        .NMI(nmi_n),
        .RDY(ready) 
    );

    always @(posedge clk)
    begin
        if (enable)
        begin
            ab <= ab_c;
            dbo <= dbo_c;
            we <= we_c;
        end
    end
endmodule
