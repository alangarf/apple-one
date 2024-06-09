# Ulx3s with HDMI

This adds support for building the Apple One design for [Ulx3s](https://radiona.org/ulx3s/) with HDMI output and a PS/2 keyboard connected to the us2 USB connector.

## Peripheral support

HDMI output on the built-in HDMI connector

PS/2 keyboard is connected to the us2 USB connector.
Note that some USB keyboards drup down to PS/2 mode and will work.

## Building
Install a recent ECP5 open source toolchain, and do:

```
$ cd yosys
$ make
```

## Use

To load BASIC type "E000R" (with CAPS LOCK on if you are using the UART rather than the PS/2 keyboard).
