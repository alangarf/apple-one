# Blackice II with Digilent Pmods support

This adds support for building the apple one design for [mystorm Blackice II](https://github.com/mystorm-org/BlackIce-II) with attached Digilent Pmods for vga and ps2

## Peripheral support

VGA port is working through a Digilent VGA Pmod on Pmod 7/8/9/10

PS/2 keyboard uses a Digilent PS/2 Pmod on Pmod 12

## Building
Install a recent IceStorm toolchain, and:

```
$ cd yosys
$ make
```

## Use

To load BASIC type "E000R" with CAPS LOCK on.
