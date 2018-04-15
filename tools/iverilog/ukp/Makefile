TESTBENCH = ukp_tb

SRC_DIR = ./ukp
SRC = $(SRC_DIR)/ukp.v \
	  $(SRC_DIR)/ukpram.v \
	  $(SRC_DIR)/ukprom.v \
	  $(SRC_DIR)/keymap.v

all: $(TESTBENCH).vcd

display: $(TESTBENCH).vcd
	open $(TESTBENCH).vcd

$(TESTBENCH).vcd: $(TESTBENCH).out
	vvp $(TESTBENCH).out

$(TESTBENCH).out: $(TESTBENCH).v $(SRC)
	iverilog -DSIM -g2005 -o $(TESTBENCH).out $(TESTBENCH).v $(SRC)

