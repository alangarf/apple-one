# icoBoard with Digilent Pmods support

This adds support for building the apple one design for
[icoBoard](http://icoboard.org/about-icoboard.html) with attached Digilent Pmods
for VGA, PS/2 or UART.

## Peripheral support

VGA port is working through a Digilent VGA Pmod on Pmod 1/2.

PS/2 works through a Digilent PS/2 Pmod on Pmod 3 upper row.

UART works through a Digilent USBUART Pmod on Pmod 4 upper row.

By default, UART is enabled (and PS/2 is off), check
rtl/boards/icoboard/apple1_hx8k.v.

## Building
Install a recent IceStorm toolchain, and:

```
$ cd yosys
$ make apple1
```

## Use

To load BASIC type "E000R" with CAPS LOCK on.
