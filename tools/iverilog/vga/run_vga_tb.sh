iverilog -DSIM -g2005 -s vga_tb -o vga_tb -c vga_files.txt
vvp vga_tb
