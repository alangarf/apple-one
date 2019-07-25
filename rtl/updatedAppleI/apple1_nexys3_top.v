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
// Description: Top level Apple 1 module for Digilent Nexys 3 board 
//					 with Spartan 6
//
// Author.....: Oskar A. Stepien
// Date.......: 25-2-2019
// 

module apple1_nexys3_top #(
	parameter BASIC_FILENAME      = "roms/basic.hex",
	parameter FONT_ROM_FILENAME   = "roms/vga_font_bitreversed.hex",
	parameter RAM_FILENAME        = "roms/ram_ise.hex",
	parameter VRAM_FILENAME       = "roms/vga_vram.bin",
	parameter WOZMON_ROM_FILENAME = "roms/wozmon_ise.hex",
	parameter PROGS					= "progs_apple/programs.hex"
) (    
	input    CLK_100MHZ,      // the 100 MHz master clock

	// UART I/O signals
	output   UART_TXD,       // UART transmit pin on board
	input    UART_RXD,       // UART receive pin on board
	input		VGA_CLR,
	  
	input    PS2_KBCLK,
	input    PS2_KBDAT,

	input    BUTTON,         // Button for RESET
	input		SWITCH,         // Switch between PS/2 input and UART
	output	LED_KB,

	output   VGA_R,
	output   VGA_G,
	output   VGA_B,
	output   VGA_HS,
	output   VGA_VS,
	
	output 	[6:0] SEG,		//7 Segment for Display
	output 	[3:0] AN,		//4 Digit for Display
	output 	DP, 				//Point in display digit
	input		BTN_NEXT,		//Button to shift to next position of the circular array
	input		BTN_PREV,		//Previous postion
	input		BTN_OK,			//Accept and load on RAM
	output	LED_INIT,		//LED to point out the initiation of the Loading
	output	LED_LOADING,	//LED to point the Loading and end of Loading
	
	input		[1:0] MEMSEL,		//Switches to 4 bank Programs memory
	output	[1:0] LED_MEMSEL	//LED above the switches of memory

);

	//////////////////////////////////////////////////////////////////////////    
	// Registers and Wires
	reg clk25;
	reg clkcnt = 1'd0;
	wire [15:0] pc_monitor;

	wire rst_n;    
	assign rst_n = ~BUTTON;
	
	wire next;    
	assign next = ~BTN_NEXT;
	
	wire prev;    
	assign prev = ~BTN_PREV;
	
	wire accept;    
	assign accept = ~BTN_OK;
	
	wire ctrl_led_Init;
	assign LED_INIT = ctrl_led_Init;
	
	wire ctrl_led_Loading;
	assign LED_LOADING = ctrl_led_Loading;
	
	assign LED_KB = SWITCH;
	
	assign LED_MEMSEL [1:0] = MEMSEL [1:0];

	// generate 25MHz clock from 100MHz master clock of the Nexys 3 FPGA board
	always @(posedge CLK_100MHZ)
	begin
		if(clkcnt)
		begin
			clk25 <= ~clk25;
			clkcnt <= 1'd0;
		end
			clkcnt <= ~clkcnt;
	end    
    
	
	//Cassette selector
	
	wire [3:0] pick;
	cassette cassette_sel (
		.clk25(CLK_100MHZ), 
		.next(next),
		.prev(prev),
		.block(MEMSEL),
		.seg(SEG), 
		.an(AN), 
		.dp(DP), 
		.pick(pick)
	);
	//////////////////////////////////////////////////////////////////////////    
	
	// Core of system
	apple1 #(
		.BASIC_FILENAME (BASIC_FILENAME),
		.FONT_ROM_FILENAME (FONT_ROM_FILENAME),
		.RAM_FILENAME (RAM_FILENAME),
		.VRAM_FILENAME (VRAM_FILENAME),
		.WOZMON_ROM_FILENAME (WOZMON_ROM_FILENAME),
		.PROGS (PROGS)
	) apple1_top(
		.clk25(clk25),
		.rst_n(rst_n),         // we don't have any reset pulse..
		.uart_rx(UART_RXD),
		.uart_tx(UART_TXD),
		.uart_cts(uart_CTS),  // there is no CTS on the board :(
		.ps2_clk(PS2_KBCLK),
		.ps2_din(PS2_KBDAT),
		.ps2_select(SWITCH),
		.vga_h_sync(VGA_HS),
		.vga_v_sync(VGA_VS),
		.vga_red(VGA_R),
		.vga_grn(VGA_G),
		.vga_blu(VGA_B),
		.vga_cls(VGA_CLR),
		.pc_monitor(pc_monitor),
		.pick(pick), 									//Program picked or selected externally
		.accept(accept), 								//Start Loading
		.ctrl_led_Init(ctrl_led_Init), 			//LED Start Loading
		.ctrl_led_Loading(ctrl_led_Loading),	//LED Loading
		.block(MEMSEL)									// # Bank Select
	);
    
endmodule

