# Ulx3s with Digilent VGA Pmod

This adds support for building the apple one design for [Ulx3s](https://radiona.org/ulx3s/) with attached Digilent Pmod for vga and a ps2 keyboard connected to the us2 usb connector.

## Peripheral support

VGA port is working through a Digilent VGA Pmod on the J2 double Pmod

PS/2 keyboard is connected to the us2 USB connector

## Building
Install a recent Ecp5 open source toolchain, and:

```
$ cd yosys
$ make
```

## Use

To load BASIC type "E000R" with CAPS LOCK on.
