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
// Description: Apple 1 implementation for the Ulx4m
//
// Author.....: Lawrie Griffiths and Alan Garfield
// Date.......: 31-3-2018
//

module apple1_top #(
    parameter BASIC_FILENAME      = "../../../roms/basic.hex",
    parameter FONT_ROM_FILENAME   = "../../../roms/vga_font_bitreversed.hex",
    parameter RAM_FILENAME        = "../../../roms/ram.hex",
    parameter VRAM_FILENAME       = "../../../roms/vga_vram.bin",
    parameter WOZMON_ROM_FILENAME = "../../../roms/wozmon.hex"
) (
    input  clk_25mhz,       // 25 MHz board clock

    // I/O interface to computer
    input  ftdi_txd,         // asynchronous serial data input from computer
    output ftdi_rxd,         // asynchronous serial data output to computer
    //output uart_cts,        // clear to send flag to computer - not used

    // I/O interface to keyboard
    //input ps2_clk,          // PS/2 keyboard serial clock input
    //input ps2_din,          // PS/2 keyboard serial data input

    //output usb_fpga_pu_dp,
    //output usb_fpga_pu_dn, 

    input [26:25] gpio,
    
    output [3:0] gpdi_dp, gpdi_dn, 

    // Debugging ports
    output [3:0] led,
    input [2:1] btn     // 2 buttons on board
);
    wire uart_cts;

    parameter C_ddr = 1'b1; // 0:SDR 1:DDR

    // clock generator
    wire clk_250MHz, clk_125MHz, clk_25MHz, clk_locked;
    clk_25_250_125_25
    clock_instance
    (
      .clki(clk_25mhz),
      .clko(clk_250MHz),
      .clks1(clk_125MHz),
      .clks2(clk_25MHz),
      .locked(clk_locked)
    );

    // shift clock choice SDR/DDR
    wire clk_pixel, clk_shift;
    assign clk_pixel = clk_25MHz;
    generate
      if(C_ddr == 1'b1)
        assign clk_shift = clk_125MHz;
      else
        assign clk_shift = clk_250MHz;
    endgenerate

    //assign usb_fpga_pu_dp = 1;
    //assign usb_fpga_pu_dn = 1;

    assign led[0] = 1;
    assign led[1] = reset_n;
    assign led[2] = clr_screen_n;
    assign led[3] = 0;

    wire vga_bit;

    // VGA signal generator
    wire [7:0] vga_r, vga_g, vga_b;
    wire vga_h_sync, vga_v_sync, vga_blank;

    // set the monochrome base colour here..
    assign vga_r = vga_bit ? 8'b10000000 : 8'b00000000;
    assign vga_g = vga_bit ? 8'b11111111 : 8'b00000000;
    assign vga_b = vga_bit ? 8'b10000000 : 8'b00000000;

    // debounce reset button
    wire reset_n;
    debounce reset_button (
        .clk25(clk_25MHz),
        .rst(1'b0),
        .sig_in(~btn[1]),
        .sig_out(reset_n)
    );

    // debounce clear screen button
    wire clr_screen_n;
    debounce clr_button (
        .clk25(clk_25MHz),
        .rst(~reset_n),
        .sig_in(~btn[2]),
        .sig_out(clr_screen_n)
    );

    // apple one main system
    apple1 #(
        .BASIC_FILENAME (BASIC_FILENAME),
        .FONT_ROM_FILENAME (FONT_ROM_FILENAME),
        .RAM_FILENAME (RAM_FILENAME),
        .VRAM_FILENAME (VRAM_FILENAME),
        .WOZMON_ROM_FILENAME (WOZMON_ROM_FILENAME)
    ) my_apple1(
        .clk25(clk_25MHz),
        .rst_n(reset_n),

        .uart_rx(ftdi_txd),
        .uart_tx(ftdi_rxd),
        .uart_cts(uart_cts),

        .ps2_clk(gpio[26]),
        .ps2_din(gpio[25]),
        .ps2_select(1'b1),       // PS/2 enabled, UART TX disabled

        .vga_h_sync(vga_h_sync),
        .vga_v_sync(vga_v_sync),
        .vga_red(vga_bit),
        //.vga_grn(vga_bit),
        //.vga_blu(vga_bit),
	.vga_blank(vga_blank),
        .vga_cls(~clr_screen_n)
    );

    // VGA to digital video converter
    wire [1:0] tmds[3:0];
    vga2dvid
    #(
      .C_ddr(C_ddr),
      .C_shift_clock_synchronizer(1'b1)
    )
    vga2dvid_instance
    (
      .clk_pixel(clk_pixel),
      .clk_shift(clk_shift),
      .in_red(vga_r),
      .in_green(vga_g),
      .in_blue(vga_b),
      .in_hsync(vga_h_sync),
      .in_vsync(vga_v_sync),
      .in_blank(vga_blank),
      .out_clock(tmds[3]),
      .out_red(tmds[2]),
      .out_green(tmds[1]),
      .out_blue(tmds[0])
    );

    // output TMDS SDR/DDR data to fake differential lanes
    fake_differential
    #(
      .C_ddr(C_ddr)
    )
    fake_differential_instance
    (
      .clk_shift(clk_shift),
      .in_clock(tmds[3]),
      .in_red(tmds[2]),
      .in_green(tmds[1]),
      .in_blue(tmds[0]),
      .out_p(gpdi_dp),
      .out_n(gpdi_dn)
    );

endmodule
