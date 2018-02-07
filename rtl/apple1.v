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

module apple1(
    input  clk25,               // 25 MHz master clock
    input  rst_n,               // active low synchronous reset (needed for simulation)

    // I/O interface to computer
    input  uart_rx,             // asynchronous serial data input from computer
    output uart_tx,             // asynchronous serial data output to computer
    output uart_cts,            // clear to send flag to computer

    // I/O interface to keyboard
    input ps2_clk,              // PS/2 keyboard serial clock input
    input ps2_din,              // PS/2 keyboard serial data input

    // Outputs to VGA display
    input clr_screen_btn,       // active high clear screen button
    output vga_h_sync,          // hozizontal VGA sync pulse
    output vga_v_sync,          // vertical VGA sync pulse
    output reg vga_red,         // red VGA signal
    output reg vga_grn,         // green VGA signal
    output reg vga_blu,         // blue VGA signal

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
        .ready  (cpu_clken)
        //.pc_monitor (pc_monitor)
    );

    //////////////////////////////////////////////////////////////////////////
    // Address Decoding

    wire ram_cs =   (ab[15:13] ==  3'b000);             // 0x0000 -> 0x1FFF

    wire uart_cs =  (ab[15:2]  == 14'b11010000000100); // 0xD010 -> 0xD013
    //wire ps2kb_cs = 1'b0;
    //wire vga_cs = 1'b0;

    //wire ps2kb_cs = (ab[15:1]  == 15'b110100000001000); // 0xD010 -> 0xD011
    //wire uart_cs =  (ab[15:1]  == 15'b110100000001001); // 0xD012 -> 0xD013
    //wire vga_cs = 1'b0;

    //wire uart_cs =  (ab[15:1]  == 15'b110100000001000); // 0xD010 -> 0xD011
    wire ps2kb_cs = 1'b0;
    wire vga_cs =   (ab[15:1]  == 15'b110100000001001); // 0xD012 -> 0xD013

    wire basic_cs = (ab[15:12] ==  4'b1110);            // 0xE000 -> 0xEFFF
    wire rom_cs =   (ab[15:8]  ==  8'b11111111);        // 0xFF00 -> 0xFFFF

    wire mode_cs = (ab[15:12]  == 4'b1100); // 0xC000

    //////////////////////////////////////////////////////////////////////////
    // RAM and ROM

    // RAM
    wire [7:0] ram_dout;
    ram my_ram(
        .clk(clk25),
        .address(ab[12:0]),
        .w_en(we & ram_cs),
        .din(dbo),
        .dout(ram_dout)
    );

    // WozMon ROM
    wire [7:0] rom_dout;
    rom_wozmon my_rom_wozmon(
        .clk(clk25),
        .address(ab[7:0]),
        .dout(rom_dout)
    );

    // Basic ROM
    wire [7:0] basic_dout;
    rom_basic my_rom_basic(
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

        //.address({1'b1, ab[0]}),  // for ps/2
        //.address({1'b0, ab[0]}),  // for vga
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
    reg [1:0] vga_mode;
    vga my_vga(
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
        .mode(vga_mode),
        .debug(pc_monitor)
    );

    always @(posedge clk25 or posedge rst)
    begin
        if (rst)
            vga_mode <= 2'b0;
        else
            if (mode_cs & we & cpu_clken)
                vga_mode <= dbo[1:0];
    end

    //////////////////////////////////////////////////////////////////////////
    // CPU Data In MUX

    // link up chip selected device to cpu input
    assign dbi = ram_cs   ? ram_dout :
                 rom_cs   ? rom_dout :
                 basic_cs ? basic_dout :
                 uart_cs  ? uart_dout :
                 ps2kb_cs ? ps2_dout :
                 mode_cs ? vga_mode :
                 8'hFF;
endmodule
