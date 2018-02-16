iverilog -DSIM -g2005 -s uart_tb -o uart_tb -c uart_files.txt
vvp uart_tb
