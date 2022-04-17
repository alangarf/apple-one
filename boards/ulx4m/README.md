# Ulx4m with HDMI

This adds support for building the Apple One design for [Ulx4m](https://intergalaktik.eu/projects/ulx4m/) with HDMI output and a PS/2 keyboard connected to a Digilent PS2 keyboard PMOD.

## Peripheral support

HDMI output on the first HDMI connector on a CM4 I/O board

PS/2 keyboard via a Digilent PS2 keyboard PMOD on gpio[25] and gpio[26].

## Building
Install a recent ECP5 open source toolchain, and do:

```
$ cd yosys
$ make dfu
```

## Use

To load BASIC type "E000R" (with CAPS LOCK on if you are using the UART rather than the PS/2 keyboard).
