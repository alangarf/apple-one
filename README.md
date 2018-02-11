![Apple One](media/apple-logo.png)

This is a basic implementation of the original Apple 1 in Verilog for an iCE40HX FPGA. It can run the Apple 1 WozMon and Integer Basic via the serial USB interface which is available on the iCE40HX8K-B-EVN breakout board. This makes this a very compact little set up. There is no reason this cannot be implemented for other FPGAs with very little work.

![iCE40HX8K](boards/ice40hx9k-b-evn/images/iCE40HX8K-breakout.png)

This project borrows heavily from the *awesome* work of Andrew Holme and his ["Pool"](http://www.aholme.co.uk/6502/Main.htm) project where he built a 6502 CPU core in Verilog using the netlist from the Visual 6502 project. Amazing stuff, and so far seems to work perfectly. Also many special thanks to ["sbprojects.com"](https://www.sbprojects.com/projects/apple1/index.php) for the wealth of information I gleaned from there.

 ## Memory Map
 
The iCE40HX8K has 16KB of available block RAM, this is currently set up to have:

 Start | End | Description
 ----- | --- | -----------
 0x0000 | 0x1FFF | 8KB of block RAM for system
 0xE000 | 0xEFFF | 4KB of block RAM for basic ROM
 0xFF00 | 0xFFFF | 512B of block RAM for WozMon ROM

The remaining 3.5KB is being earmarked for character ROMs and video RAM when I start implementing that (any help greatfully accepted). The basic ROM could be removed which would allow for 12KB of system RAM if needs be.
 
## Hardware Map

I've implemented a few physical hardware peripherals in this design, and also added a UART inplace of the PIA used in the original Apple 1, this allows USB communucation with the system very similar to the "terminal" in the original.

I've also added support for the commonly available TM1638 based LED&KEY board. This allows 8 x 7 segment displays, 8 x LEDs and 8 x push buttons all in an easily addressable way.

 Start | End | Description
 ----- | --- | -----------
 0xD000 | | Output register for the eight LEDs on the breakout board
 0xD010 | | UART RX register
 0xD011 | | UART RX control register
 0xD012 | | UART TX register and control
 0xD020 | | LED&KEY display register. [4] is display on/off, [3:0] is brightness
 0xD021 | 0xD028 | LED&KEY digit data for digit 1 to 8
 0xD029 | | LED&KEY LEDs 1 to 8
 0xD030 | | LED&KEY input register for the buttons 1 to 8. [7] is button 1, [0] is button 8
 
 ## Building
 
 This project should just build with IceCube2 without any issue, and I will figure out how to make it work with Yosys shortly.
 
 At the moment yosys/arachne-pr fails to properly synth the project, mostly due to the complexity of the gate-level logic implementation of the 6502.
 
 ## External Devices / Hook-up
 
 To connect the LED&KEY to the breakout board the following pins are defined in the constraints file.
 
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
