DEVICE = hx8k
PIN_DEF=blackicemx.pcf

SOURCEDIR = ../../../rtl
BUILDDIR = build

all: apple1 prog

info:
	@echo "       To build: make apple1"
	@echo "     To program: make prog"
	@echo "To build report: make report"
	@echo "    To clean up: make clean"

dir:
	mkdir -p $(BUILDDIR)

# ------ TEMPLATES ------
$(BUILDDIR)/%.json: $(SOURCEDIR)/%.v
	yosys -q -p "chparam -list; hierarchy -top apple1_top; synth_ice40 -json $@" $^

$(BUILDDIR)/%.asc: $(PIN_DEF) $(BUILDDIR)/%.json
	 nextpnr-ice40 --${DEVICE} --package tq144:4k --freq 25 --asc $@ --json $(filter-out $<,$^) --pcf $< --placer heap

$(BUILDDIR)/%.bin: $(BUILDDIR)/%.asc
	icepack $^ $@

%.rpt: $(BUILDDIR)/%.asc
	icetime -d $(DEVICE) -P $(PACKAGE) -c $(FREQ_PLL) -mtr $@ $<

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
	$(SOURCEDIR)/boards/blackicemx/apple1_hx8k.v

apple1.rpt: $(BUILDDIR)/apple1.asc

prog: dir $(BUILDDIR)/apple1.bin
	stty -F /dev/ttyACM0 raw
	cat $(filter-out $<,$^) >/dev/ttyACM0

# ------ HELPERS ------
clean:
	rm -rf build apple1.rpt

.SECONDARY:
.PHONY: all info clean prog iceprog
