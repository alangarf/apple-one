module rom_basic(
    input clk,
    input [11:0] address,
    output reg [7:0] dout
    );

    `ifdef SIM
    parameter BASIC_FILENAME = "../roms/basic.hex";
    `else
    parameter BASIC_FILENAME = "../../roms/basic.hex";
    `endif

    reg [7:0] rom_data[0:4095];

    initial
        $readmemh(BASIC_FILENAME, rom_data, 0, 4095);

    always @(posedge clk)
        dout <= rom_data[address];

endmodule
