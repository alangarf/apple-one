SOURCEDIR := ../../../rtl
VERILOG_SOURCES := \
       ${SOURCEDIR}/apple1.v \
       $(SOURCEDIR)/clock.v \
       $(SOURCEDIR)/pwr_reset.v \
       $(SOURCEDIR)/ram.v \
       $(SOURCEDIR)/rom_wozmon.v \
       $(SOURCEDIR)/rom_basic.v \
       $(SOURCEDIR)/cpu/arlet_6502.v \
       $(SOURCEDIR)/cpu/arlet/ALU.v \
       $(SOURCEDIR)/cpu/arlet/cpu.v \
       $(SOURCEDIR)/uart/uart.v \
       $(SOURCEDIR)/uart/async_tx_rx.v \
       $(SOURCEDIR)/vga/vga.v \
       $(SOURCEDIR)/vga/vram.v \
       $(SOURCEDIR)/vga/font_rom.v \
       $(SOURCEDIR)/ps2keyboard/debounce.v \
       $(SOURCEDIR)/ps2keyboard/ps2keyboard.v \
       $(SOURCEDIR)/boards/icepi_zero/apple1_icepi_zero.v \
       $(SOURCEDIR)/boards/icepi_zero/pll.v \
       $(SOURCEDIR)/boards/icepi_zero/tmds_encoder.sv \
       $(SOURCEDIR)/boards/icepi_zero/vga2tmds.sv

OUTPUT := apple1
PACKAGE := CABGA256

all: debug

%.json: $(VERILOG_SOURCES)
	rm -f $(OUTPUT).bit $(OUTPUT).config $(OUTPUT).json
	yosys -p 'synth_ecp5 -top apple1_top -json $@' $^

%.config: %.json icepi-zero.lpf
	nextpnr-ecp5 --25k --package $(PACKAGE) --lpf icepi-zero.lpf --json $< --textcfg $@ # 2> log.txt
	# cat log.txt | grep Device -A 28

%.bit: %.config
	ecppack $< $@

build: $(OUTPUT).bit

debug: build
	openFPGALoader -cft231X --pins=7:3:5:6 $(OUTPUT).bit

install: build
	openFPGALoader -cft231X --pins=7:3:5:6 $(OUTPUT).bit --write-flash

install-bitstream:
	openFPGALoader -cft231X --pins=7:3:5:6 $(OUTPUT).bit --write-flash

lint:
	verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-WIDTHEXPAND $(VERILOG_SOURCES)

help:
	echo "Usage: make [option]"
	echo "Options:"
	echo "- install: install to flash"
	echo "- debug: install to chip's temp memory (bitstream lost on power loss)"
	echo "- build: builds the bitstream"
	echo "- clean: delete all temparary files"

clean:
	rm -f $(OUTPUT).bit $(OUTPUT).config $(OUTPUT).json

.PHONY: build clean install
