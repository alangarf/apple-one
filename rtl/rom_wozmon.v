module rom_wozmon(
    input clk,
    input [7:0] address,
    output reg [7:0] dout
    );

    `ifdef SIM
    parameter ROM_FILENAME = "../roms/wozmon.hex";
    `else
    parameter ROM_FILENAME = "../../roms/wozmon.hex";
    `endif

    reg [7:0] rom_data[0:255];

    initial
        $readmemh(ROM_FILENAME, rom_data, 0, 255);

    always @(posedge clk)
        dout <= rom_data[address];

endmodule
    
    
