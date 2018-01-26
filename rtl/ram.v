module ram(
    input clk,
    input [12:0] address,
    input w_en,
    input [7:0] din,
    output reg [7:0] dout
    );

    /* synthesis syn_ramstyle = rw_check */
    reg [7:0] ram[0:8191];

    initial
        $readmemh("../../../roms/ram.hex", ram, 0, 8191);

    always @(posedge clk)
    begin
        dout <= ram[address];
        if (w_en) ram[address] <= din;
    end

endmodule
     
