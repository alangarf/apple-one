// 
// FIXME:
// there defines must be enabled in the project
// settings to avoid conflicts with different
// development platforms
//
//`define ICE40
//

module top(
    input  clk25,           // 25 MHz master clock
    input  uart_rx,
    output uart_tx,
    output uart_cts,

    output [7:0] led,       // what do these do?
    output [7:0] ledx       // what do these do?
);
    //////////////////////////////////////////////////////////////////////////
    // Registers and Wires

    reg [15:0] ab;
    wire [7:0] dbi;
    reg [7:0] dbo;
    reg we;

    //////////////////////////////////////////////////////////////////////////
    // Clocks
    wire cpu_clken;

    // FIXME:
    // the clocks here should come from higher up 
    // the hierarchy, i.e. generated at the board
    // level.
    //
    // if cpu_clken is a simple block,
    // keep it here but make it generic.
    
    `ifdef ICE40
    clocks my_clocks(
        .clk(clk),
        .clk25(clk25),
        .cpu_clken(cpu_clken)
    );
    `endif
    
    // generate clock enable once every 
    // 25 clocks. This will (hopefully) make
    // the 6502 run at 1 MHz or 1Hz
    //
    reg [4:0] clk_div;
    always @(posedge clk25)
    begin
        if (clk_div == 25)
            clk_div <= 0;
        else
            clk_div <= clk_div + 1'b1;

        cpu_clken <= (clk_div[4:0] == 0);
    end

    //////////////////////////////////////////////////////////////////////////
    // Reset
    wire reset;
    reg hard_reset;
    reg [5:0] reset_cnt;
    wire pwr_up_reset = &reset_cnt;

    always @(posedge clk25)
    begin
        if (cpu_clken)
        begin
            if (!pwr_up_reset)
                reset_cnt <= reset_cnt + 1;

            hard_reset <= pwr_up_reset;
        end
    end

    assign reset = ~hard_reset;

    //////////////////////////////////////////////////////////////////////////
    // 6502
    wire [7:0] dbo_c;
    wire [15:0] ab_c;
    wire we_c;
    reg [7:0] dbi_c;

    cpu my_cpu (
        .clk    (clk25),
        .reset  (reset),
        .AB     (ab_c),
        .DI     (dbi_c),
        .DO     (dbo_c),
        .WE     (we_c),
        .IRQ    (1'b0),
        .NMI    (1'b0),
        .RDY    (cpu_clken)
    );

    always @(posedge clk25)
    begin
        if (cpu_clken)
        begin
            ab <= ab_c;
            dbo <= dbo_c;
            dbi_c <= dbi;
            we <= we_c;
        end
    end

    //////////////////////////////////////////////////////////////////////////
    // RAM and ROM

    wire ram_cs =   (ab[15:13] ==  3'b000);            // 0x0000 -> 0x1FFF
    wire uart_cs =  (ab[15:2]  == 14'b11010000000100); // 0xD010 -> 0xD013
    wire basic_cs = (ab[15:12] ==  4'b1110);           // 0xE000 -> 0xEFFF
    wire rom_cs =   (ab[15:8]  ==  8'b11111111);       // 0xFF00 -> 0xFFFF

    // RAM
    wire [7:0] ram_dout;
    ram my_ram (
        .clk(clk25),
        .address(ab[12:0]),
        .w_en(we & ram_cs),
        .din(dbo),
        .dout(ram_dout)
    );

    // WozMon ROM
    wire [7:0] rom_dout;
    rom_wozmon my_rom_wozmon (
        .clk(clk25),
        .address(ab[7:0]),
        .dout(rom_dout)
    );

    // UART
    wire [7:0] uart_dout;
    uart my_uart (
        .clk(clk25),

        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_cts(uart_cts),

        .enable(uart_cs & cpu_clken),
        .address(ab[1:0]),
        .w_en(we & uart_cs),
        .din(dbo),
        .dout(uart_dout),
        .led(led)
    );

    // link up chip selected device to cpu input
    assign dbi = ram_cs  ? ram_dout : 
                 rom_cs  ? rom_dout :
                 uart_cs ? uart_dout :
                 8'hFF;

    assign ledx = ab[7:0];

//    always @(posedge clk25)
//    begin
//        if (cpu_clken)
//        begin
//            led <= ab[7:0];
//            ledx <= ~ab[15:8];
//        end
//    end

//    reg [7:0] ram[0:8191] /* synthesis syn_ramstyle = "block_ram" */;
//    reg [7:0] rom[0:255] /* synthesis syn_ramstyle = "block_ram" */;
//    reg [7:0] basic[0:4095] /* synthesis syn_ramstyle = "block_ram" */;
//    
//    initial begin
//        $readmemh("../roms/ram.hex", ram, 0, 8191);
//        $readmemh("../roms/rom.hex", rom, 0, 255);
//        $readmemh("../roms/basic.hex", basic, 0, 4095);
//    end
//
//    always @(posedge clk_25)
//    begin
//        if (phi_clk_en)
//        begin
//            if (res)
//            begin
//                case(ab)
//                    default:
//                    begin
//                        if (ab[15:12] == 4'b0000 || ab[15:12] == 4'b0001)
//                        begin
//                            // 0x0000 -> 0x1FFF - RAM
//                            dbi <= ram[ab[12:0]];
//                            if (~rw) ram[ab[12:0]] <= dbo;
//                        end
//                        else if (ab[15:12] == 4'b1110)
//                        begin
//                            // 0xE000 -> 0xEFFF - BASIC
//                            dbi <= basic[ab[11:0]];
//                        end
//                        else if (ab[15:8] == 8'b11111111)
//                        begin
//                            // 0xFF00 -> 0xFFFF - ROM
//                            dbi <= rom[ab[7:0]];
//                        end
//                        else
//                            // unknown address return zero
//                            dbi <= 8'h0;
//                    end
//
//                endcase
//            end
//        end
//    end
endmodule
