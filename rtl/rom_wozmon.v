module rom_wozmon(
    input clk,
    input [7:0] address,
    output reg [7:0] dout
    );

    parameter ROM_FILENAME = "../roms/wozmon.hex";

    reg [7:0] rom[0:255];

    initial
        $readmemh(ROM_FILENAME, rom, 0, 255);

    always @(posedge clk)
    begin
        dout <= rom[address];
    end

endmodule
    
    
