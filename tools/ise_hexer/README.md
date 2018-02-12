# ISE_HEXER 1.0<br><h2>Convert a $readmemh HEX file so that Xilinx ISE can use them<br>Niels A. Moseley

Xilinx ISE is a piece of sh*t when it comes to reading HEX file using $readmemh. It will only read files that are _exactly_ the right length for the ROM/RAM to be instantiated.

Furthermore, it only allows _one_ data entry per line and _no_ comments.

This program makes sure there is only one data entry per line.
Comments will still be copied and cause erros.

It was programmed for the TinyCC portable compiler: http://download.savannah.gnu.org/releases/tinycc/

Install TCC in the subdir tcc.