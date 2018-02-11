# Apple One<br>iCE40HX8K Breakout Board target

Maintainer: Alan Garfield https://github.com/alangarf

![iCE40HX8K board photo](https://github.com/alangarf/apple-one/raw/master/media/iCE40HX8K-breakout.png)

### Build environment
The project was started with IceCube2, and the project files are in the subdirectory 'icecube2'. These haven't been updated in a while, but should prove a worthy starting point. I'll endeavour to keep them updated when I can.

The project with the switch of the 6502 CPU from the gate simulated core to a logical simulated core allowed the FOSS yosys and arachne_pr to build the project. Now all you need is icestorm and the Makefile.

To build:
```
make
```

### Features
* UART support using the second serial channel on the breakout board. (CTS support OS willing).
* VGA support (will require a cable to be made).
* PS/2 support (will require a cable to be made).
* LED support using onboard LEDs on breakout, additional LEDs added to mine via a [YL-4 board from ebay](https://www.ebay.com.au/itm/4-4-Matrix-Array-Keyboard-16-Key-Switch-Keypad-8-LED-4-Button-Professional-Blue/183044563197).

### VGA Cable

```
                      270 ohm
vga_red pin - B1 -----/\/\/\----- VGA PIN 1
vga_grn pin - B2 -----/\/\/\----- VGA PIN 2
vga_blu pin - C1 -----/\/\/\----- VGA PIN 3
vga_h_sync  - C2 ---------------- VGA PIN 13
vga_v_sync  - D1 ---------------- VGA PIN 14
             GND -------o-------- VGA PIN 5
                        |-------- VGA PIN 6
                        |-------- VGA PIN 7
                        |-------- VGA PIN 8
                        \-------- VGA PIN 10
```

### PS/2 Cable

```
ps2_clk - N3 -----/\/\/\----- PS/2 PIN 5
ps2_din - N2 -----/\/\/\----- PS/2 PIN 1
         GND ------o--------- PS/2 PIN 3
                   |
                   |
ext. psu GND ------/
ext. psu  5V ---------------- PS/2 PIN 4
