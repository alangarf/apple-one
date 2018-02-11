# Olimex iCE40hx8k-evb support

This adds support for building apple one design for [Olimex iCE40hx8k-evb board](https://www.olimex.com/Products/FPGA/iCE40/iCE40HX8K-EVB/open-source-hardware)  with attached [Olimex iCE40-IO extension](https://www.olimex.com/Products/FPGA/iCE40/iCE40-IO/open-source-hardware) for vga and ps2

## Peripheral support

VGA port is working trought the iCE40-IO expansion.

A usb-serial converter can be attached on pins 5(RX), 7(TX), 9(CTS) on either the iCE40-IO extension or witout it directly to the header of the FPGA board (pin out is the same). Consult the schematics for [iCE40-IO](https://github.com/OLIMEX/iCE40-IO/raw/master/ICE40-IO_Rev_A.pdf) and [iCE40HX8K-EVB](https://github.com/OLIMEX/iCE40HX8K-EVB/blob/master/HARDWARE/REV-B/iCE40HX8K-EVB_Rev_B.pdf) for extension header pinmap.

The iCE40-IO board has a ps2 connector you can use if you have a ps2 keyboard but it's not edded to the design pin map.

This port is using 1 PLL for generating the target 25Mhz clock.

## Building
Install a recent IceStorm toolchain, and:

make

## Use

There are 2 possible ways for flashing the board:

1. [Olimex OLIMEXINO-32U4 as programmer](https://www.olimex.com/wiki/ICE40HX1K-EVB#Preparing_OLIMEXINO-32U4_as_programmer) 

2. [Iceprog with Raspberry PI](https://www.olimex.com/wiki/ICE40HX1K-EVB#Iceprog_with_Raspberry_PI)

To load BASIC type "E000R" with CAPS LOCK on.
