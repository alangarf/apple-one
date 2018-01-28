module rom_basic(
    input clk,
    input [11:0] address,
    output reg [7:0] dout
    );

    parameter ROM_FILENAME = "../roms/basic.hex";

    reg [11:0] rom[0:4095];

    initial
        $readmemh(ROM_FILENAME, rom, 0, 4095);

    always @(posedge clk)
        dout <= rom[address];

endmodule
