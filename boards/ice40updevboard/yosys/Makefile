DEVICE = up5k
PIN_DEF = ice40updevboard.pcf

SOURCEDIR = ../../../rtl
BUILDDIR = build

all: apple1 

info:
	@echo "       To build: make apple1"
	@echo "To build report: make report"
	@echo "    To clean up: make clean"

dir:
	mkdir -p $(BUILDDIR)

# ------ TEMPLATES ------
$(BUILDDIR)/%.json: $(SOURCEDIR)/%.v
	yosys -q -p "chparam -list; hierarchy -top apple1_top; synth_ice40 -json $@" $^

$(BUILDDIR)/%.asc: $(BUILDDIR)/%.json
	nextpnr-ice40 --up5k --package sg48 --pcf $(PIN_DEF) --json $^ --asc $@

$(BUILDDIR)/%.bin: $(BUILDDIR)/%.asc
	icepack $^ $@

%.rpt: $(BUILDDIR)/%.asc
	icetime -d $(DEVICE) -mtr $@ $<

%_tb.vvp: %_tb.v %.v
	iverilog -o $@ $^

%_tb.vcd: %_tb.vvp
	vvp -N $< +vcd=$@

# ------ APPLE 1 ------
apple1: dir $(BUILDDIR)/apple1.bin
report: dir apple1.rpt

$(BUILDDIR)/apple1.bin: $(BUILDDIR)/apple1.asc
$(BUILDDIR)/apple1.asc: $(BUILDDIR)/apple1.json
$(BUILDDIR)/apple1.json: $(SOURCEDIR)/apple1.v \
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
	$(SOURCEDIR)/boards/ice40updevboard/apple1_ice40updevboard.v

apple1.rpt: $(BUILDDIR)/apple1.asc

# ------ HELPERS ------
clean:
	rm -rf build apple1.rpt

.SECONDARY:
.PHONY: all info clean
