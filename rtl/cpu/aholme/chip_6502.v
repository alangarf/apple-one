`include "../rtl/cpu/aholme/chip_6502_nodes.inc"

module LOGIC (
    input  [`NUM_NODES-1:0] i,
    output [`NUM_NODES-1:0] o);

    `include "../rtl/cpu/aholme/chip_6502_logic.inc"
endmodule


module chip_6502 (
    input           clk,    // FPGA clock
    input           phi,    // 6502 clock
    input           res,
    input           so,
    input           rdy,
    input           nmi,
    input           irq,
    input     [7:0] dbi,
    output    [7:0] dbo,
    output          rw,
    output          sync,
    output   [15:0] ab);

    // Node states
    wire [`NUM_NODES-1:0] no;
    reg  [`NUM_NODES-1:0] ni;
    reg  [`NUM_NODES-1:0] q = 0;

    LOGIC logic_00 (.i(ni), .o(no));

    always @ (posedge clk)
        q <= no;

    always @* begin
        ni = q;

        ni[`NODE_vcc ]  = 1'b1;
        ni[`NODE_vss ]  = 1'b0;
        ni[`NODE_res ]  = res;
        ni[`NODE_clk0]  = phi;
        ni[`NODE_so  ]  = so;
        ni[`NODE_rdy ]  = rdy;
        ni[`NODE_nmi ]  = nmi;
        ni[`NODE_irq ]  = irq;

       {ni[`NODE_db7],ni[`NODE_db6],ni[`NODE_db5],ni[`NODE_db4],
        ni[`NODE_db3],ni[`NODE_db2],ni[`NODE_db1],ni[`NODE_db0]} = dbi[7:0];
    end

    assign dbo[7:0] = {
        no[`NODE_db7],no[`NODE_db6],no[`NODE_db5],no[`NODE_db4],
        no[`NODE_db3],no[`NODE_db2],no[`NODE_db1],no[`NODE_db0]
    };

    assign ab[15:0] = {
        no[`NODE_ab15], no[`NODE_ab14], no[`NODE_ab13], no[`NODE_ab12],
        no[`NODE_ab11], no[`NODE_ab10], no[`NODE_ab9],  no[`NODE_ab8],
        no[`NODE_ab7],  no[`NODE_ab6],  no[`NODE_ab5],  no[`NODE_ab4],
        no[`NODE_ab3],  no[`NODE_ab2],  no[`NODE_ab1],  no[`NODE_ab0]
    };

    assign rw   = no[`NODE_rw];
    assign sync = no[`NODE_sync];

endmodule
