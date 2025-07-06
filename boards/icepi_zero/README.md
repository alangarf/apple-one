# Icepi Zero

![](https://hc-cdn.hel1.your-objectstorage.com/s/v3/d2e1d2fe540b8c4ee1d35ecd6e0287b981d7ee8d_image.png)

This adds support for building the Apple One design for [Icepi Zero](https://github.com/cheyao/icepi-zero) with HDMI output and a PS/2 keyboard connected to the first USB-C port.

## Peripheral support

HDMI output on the built-in HDMI connector.

PS/2 keyboard is connected to the us2 USB connector.
Note that some USB keyboards drup down to PS/2 mode and will work.

## Building
Install a recent ECP5 open source toolchain, and do:

```
$ cd yosys
$ make
$ make install_bitstream # To install to flash
```

## Use

To load BASIC type "E000R" (with SHIFT when you are typing letters if you are using UART).

