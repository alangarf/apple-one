# Apple One<br>iCE40HX8K Breakout Board target

Maintainer: Alan Garfield https://github.com/alangarf

![Terasic DE0 board photo](images/terasic_DE0.jpg)

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
* LED support using onboard LEDs on breakout, additional LEDs added to mine via a [https://www.ebay.com.au/itm/4-4-Matrix-Array-Keyboard-16-Key-Switch-Keypad-8-LED-4-Button-Professional-Blue/183044563197](YL-4 board from ebay).

### VGA Cable


### PS/2 Cable


