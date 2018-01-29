module ram(
    input clk,
    input [12:0] address,
    input w_en,
    input [7:0] din,
    output reg [7:0] dout
    );

    `ifdef SIM
    parameter RAM_FILENAME = "../roms/ram.hex";
    `else
    parameter RAM_FILENAME = "../../roms/ram.hex";
    `endif

    reg [7:0] ram_data[0:8191];

    initial
        $readmemh(RAM_FILENAME, ram_data, 0, 8191);

    always @(posedge clk)
    begin
        dout <= ram_data[address];
        if (w_en) ram_data[address] <= din;
    end

endmodule
     
