# apple-one

![Apple One](https://github.com/alangarf/apple-one/raw/master/media/apple-one_sml.jpg)

This is a very untested and very basic implementation of an Apple 1 in a iCE40HX FPGA. It has enough to run Woz Mon via the serial USB interface which is available on the iCE40HX8K-B-EVN breakout board, which makes this a very compact little set up.

I've also wired up support for a LED&KEYS IO board using my TM1638 verilog module.

This project borrows heavily from the work of Andrew Holme and his ["Pool"](http://www.aholme.co.uk/6502/Main.htm) project where he built a 6502 CPU core in Verilog using the netlist from the Visual 6502 project. Amazing stuff, and so far seems to work perfectly.

As it stands this project uses the following resources in the iCE40HX8K

```
Total Logic Cells: 1739/7680
  Combinational Logic Cells: 634  out of  7680   (8.25%)
  Sequential Logic Cells:    1105 out of  7680   (14.38%)
  Logic Tiles:               295  out of  960    (30.72%)
Registers:
  Logic Registers:           1105  out of 7680   (14.38%)
  IO Registers:              0     out of 1280   (0%)
 Block RAMS:                 16    out of 32     (50%)
 Global Buffers:             6     out of 8      (75%)
 PLLs:                       0     out of 2      (0%)
 ```
 
 ## Memory Map
 
 The memory is as basic as basic can be. 50% of the iCE40HX8K is used currently, but this gives the Apple 1 basically 8K of memory which is plenty to start with.
 
 The Zero page and Stack page is covered, and a small 256 byte "ROM" is positioned up at 0xFF00 -> 0xFFFF.
 
 Start | End | Description
 ----- | --- | -----------
 0x0000 | 0x1FFF | 8KB of block RAM. 0x1F00 -> 0x1FFF is the "ROM" data.
 0xD000 | | Output register for the breakout LEDs
 0xD010 | | UART RX register used by Woz Mon
 0xD011  || UART RX control register. Woz Mon checks the MSB for received flag
 0xD012 | | UART TX register and control. The TX register only writes 7 bits to the remote host. The MSB is read by Woz Mon to confirm the UART isn't busy sending
 0xD020 | | LED&KEYs display register. [4] is display on/off, [3:0] is brightness
 0xD021|0xD028| LED&KEYs digit data for digit 1 to 8
 0xD029 | | LED&KEYs LEDs 1 to 8
 0xD030 | | LED&KEys input register for the buttons 1 to 8. [7] is button 1, [0] is button 8
 0xFF00 | 0xFFFF | Woz Mon pointed to by the RESET vector
 
 ## Building
 
 This project should just build with IceCube2 without any issue, and I will figure out how to make it work with Yosys shortly.
 
 ## External Devices / Hook-up
 
 To connect the LED&KEYs to the breakout board the following pins are defined in the constraints file.
 
 Pin | ID | Description
 --- | -- | -----------
 P1  | CLK | The clock used to clock data in and out of the LED&KEYs
 P2  | DIO | The tristate digital I/O pin
 R1  | STB | The "chipselect" / strobe line
 
![LED&KEYs](https://github.com/alangarf/apple-one/raw/master/media/ledandkeys_sml.jpg)
 
 ## Serial Setup
 
 To communicate with the Apple 1 you need to use the second channel serial interface for the iCE40HX8K-B-EVN board. This should appear as a COM port on you PC. This project is configured to use the 12MHz onboard clock to generate the baud rate, and as such I've selected 4800 baud (8/N/1) as this was the only baud rate that rounded nicely to 12MHz without an error rate.
 
 A very very basic hardware flow control is implemented too. You should turn on CTS support as this will allow you to cut and paste code into the Woz Mon without the Apple 1 missing any bytes.
 
 ## Helping
 
 All PRs and suggestions happily accepted! Please any support us most welcome, and it would be good to have this as feature complete as possible with the real Apple1. I'd like to implement the cassette interface next with the basic electronics to talk to the headphone/mic jack of a mobile phone to upload and download recordings as a means to save programs.
 
 But yes, help happily accepted!
