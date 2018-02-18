// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//
// Description: Apple1 hardware core
//
// Author.....: Alan Garfield
//              Niels A. Moseley
// Date.......: 26-1-2018
//

module apple1 #(
    parameter BASIC_FILENAME      = "../../../roms/basic.hex",
    parameter FONT_ROM_FILENAME   = "../../../roms/vga_font_bitreversed.hex",
    parameter RAM_FILENAME        = "../../../roms/ram.hex",
    parameter VRAM_FILENAME       = "../../../roms/vga_vram.bin",
    parameter WOZMON_ROM_FILENAME = "../../../roms/wozmon.hex"
) (
    input  clk25,               // 25 MHz master clock
    input  rst_n,               // active low synchronous reset (needed for simulation)

    // I/O interface to computer
    input  uart_rx,             // asynchronous serial data input from computer
    output uart_tx,             // asynchronous serial data output to computer
    output uart_cts,            // clear to send flag to computer

    // I/O interface to keyboard
    input ps2_clk,              // PS/2 keyboard serial clock input
    input ps2_din,              // PS/2 keyboard serial data input
    input ps2_select,           // Input to select the PS/2 keyboard instead of the UART

    // Outputs to VGA display
    output vga_h_sync,          // hozizontal VGA sync pulse
    output vga_v_sync,          // vertical VGA sync pulse
    output vga_red,             // red VGA signal
    output vga_grn,             // green VGA signal
    output vga_blu,             // blue VGA signal
    input vga_cls,              // clear screen button

    // Debugging ports
    output [15:0] pc_monitor    // spy for program counter / debugging
);
    //////////////////////////////////////////////////////////////////////////
    // Registers and Wires

    wire [15:0] ab;
    wire [7:0] dbi;
    wire [7:0] dbo;
    wire we;

    //////////////////////////////////////////////////////////////////////////
    // Clocks

    wire cpu_clken;
    clock my_clock(
        .clk25(clk25),
        .rst_n(rst_n),
        .cpu_clken(cpu_clken)
    );

    //////////////////////////////////////////////////////////////////////////
    // Reset

    wire rst;
    pwr_reset my_reset(
        .clk25(clk25),
        .rst_n(rst_n),
        .enable(cpu_clken),
        .rst(rst)
    );

    //////////////////////////////////////////////////////////////////////////
    // 6502

    arlet_6502 my_cpu(
        .clk    (clk25),
        .enable (cpu_clken),
        .rst    (rst),
        .ab     (ab),
        .dbi    (dbi),
        .dbo    (dbo),
        .we     (we),
        .irq_n  (1'b1),
        .nmi_n  (1'b1),
        .ready  (cpu_clken),
        .pc_monitor (pc_monitor)
    );

    //////////////////////////////////////////////////////////////////////////
    // Address Decoding

    wire ram_cs =   (ab[15:13] ==  3'b000);              // 0x0000 -> 0x1FFF

    // font mode, background and foreground colour
    wire vga_mode_cs = (ab[15:2] == 14'b11000000000000); // 0xC000 -> 0xC003

    // RX: Either keyboard or UART input
    // TX: Always VGA and UART output
    wire rx_cs = (ab[15:1]  == 15'b110100000001000);     // 0xD010 -> 0xD011
    wire tx_cs = (ab[15:1]  == 15'b110100000001001);     // 0xD012 -> 0xD013
    
    // select UART on transmit but only receive when PS/2 is not selected.
    wire uart_cs = tx_cs | ((~ps2_select) & rx_cs);

    // select PS/2 keyboard input when selected.
    wire ps2kb_cs = ps2_select & rx_cs;
    
    // VGA always get characters when they are sent.
    wire vga_cs   = tx_cs;

    wire basic_cs = (ab[15:12] ==  4'b1110);             // 0xE000 -> 0xEFFF
    wire rom_cs =   (ab[15:8]  ==  8'b11111111);         // 0xFF00 -> 0xFFFF

    //////////////////////////////////////////////////////////////////////////
    // RAM and ROM

    // RAM
    wire [7:0] ram_dout;
    ram #(
        .RAM_FILENAME (RAM_FILENAME)
    ) my_ram(
        .clk(clk25),
        .address(ab[12:0]),
        .w_en(we & ram_cs),
        .din(dbo),
        .dout(ram_dout)
    );

    // WozMon ROM
    wire [7:0] rom_dout;
    rom_wozmon #(
        .WOZMON_ROM_FILENAME (WOZMON_ROM_FILENAME)
    ) my_rom_wozmon(
        .clk(clk25),
        .address(ab[7:0]),
        .dout(rom_dout)
    );

    // Basic ROM
    wire [7:0] basic_dout;
    rom_basic #(
        .BASIC_FILENAME (BASIC_FILENAME)
    ) my_rom_basic(
        .clk(clk25),
        .address(ab[11:0]),
        .dout(basic_dout)
    );

    //////////////////////////////////////////////////////////////////////////
    // Peripherals

    // UART
    wire [7:0] uart_dout;
    uart #(
        `ifdef SIM
        100, 10, 2 // for simulation don't need real baud rates
        `else
        25000000, 115200, 8 // 25MHz, 115200 baud, 8 times RX oversampling
        `endif
    ) my_uart(
        .clk(clk25),
        .enable(uart_cs & cpu_clken),
        .rst(rst),

        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_cts(uart_cts),

        .address(ab[1:0]),        // for uart
        .w_en(we & uart_cs),
        .din(dbo),
        .dout(uart_dout)
    );

    // PS/2 keyboard interface
    wire [7:0] ps2_dout;
    ps2keyboard keyboard(
        .clk25(clk25),
        .rst(rst),
        .key_clk(ps2_clk),
        .key_din(ps2_din),
        .cs(ps2kb_cs),
        .address(ab[0]),
        .dout(ps2_dout)
    );

    // VGA Display interface
    reg [2:0] fg_colour;
    reg [2:0] bg_colour;
    reg [1:0] font_mode;
    reg [7:0] vga_mode_dout;

    vga #(
        .VRAM_FILENAME (VRAM_FILENAME),
        .FONT_ROM_FILENAME (FONT_ROM_FILENAME)
    ) my_vga(
        .clk25(clk25),
        .enable(vga_cs & cpu_clken),
        .rst(rst),

        .vga_h_sync(vga_h_sync),
        .vga_v_sync(vga_v_sync),
        .vga_red(vga_red),
        .vga_grn(vga_grn),
        .vga_blu(vga_blu),

        .address(ab[0]),
        .w_en(we & vga_cs),
        .din(dbo),
        .mode(font_mode),
        .fg_colour(fg_colour),
        .bg_colour(bg_colour),
        .clr_screen(vga_cls)
    );

    // Handle font mode and foreground and background
    // colours. This so isn't Apple One authentic, but
    // it can't hurt to have some fun. :D
    always @(posedge clk25 or posedge rst)
    begin
        if (rst)
        begin
            font_mode <= 2'b0;
            fg_colour <= 3'd7;
            bg_colour <= 3'd0;
        end
        else
        begin
            case (ab[1:0])
            2'b00:
            begin
                vga_mode_dout = {6'b0, font_mode};
                if (vga_mode_cs & we & cpu_clken)
                    font_mode <= dbo[1:0];
            end
            2'b01:
            begin
                vga_mode_dout = {5'b0, fg_colour};
                if (vga_mode_cs & we & cpu_clken)
                    fg_colour <= dbo[2:0];
            end
            2'b10:
            begin
                vga_mode_dout = {5'b0, bg_colour};
                if (vga_mode_cs & we & cpu_clken)
                    bg_colour <= dbo[2:0];
            end
            default:
                vga_mode_dout = 8'b0;
            endcase
        end
    end

    //////////////////////////////////////////////////////////////////////////
    // CPU Data In MUX

    // link up chip selected device to cpu input
    assign dbi = ram_cs      ? ram_dout :
                 rom_cs      ? rom_dout :
                 basic_cs    ? basic_dout :
                 uart_cs     ? uart_dout :
                 ps2kb_cs    ? ps2_dout :
                 vga_mode_cs ? vga_mode_dout :
                 8'hFF;
endmodule
