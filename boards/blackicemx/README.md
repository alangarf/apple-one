# Blackice Mx with Digilent Pmods support

This adds support for building the apple one design for [mystorm Blackice Mx](https://github.com/folknology/IceCore) with attached Digilent Pmods for vga and ps2

## Peripheral support

VGA port is working through a Digilent VGA Pmod on the middle Mixmod

PS/2 keyboard uses a Digilent PS/2 on bottom row of the Pmod next to the USB connector

## Building
Install a recent IceStorm toolchain, and:

```
$ cd yosys
$ make
```

## Use

To load BASIC type "E000R" with CAPS LOCK on.
