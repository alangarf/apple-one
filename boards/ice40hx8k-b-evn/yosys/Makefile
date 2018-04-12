DEVICE = 8k
PACKAGE = ct256
FREQ_OSC = 12
FREQ_PLL = 25

PIN_DEF = ice40hx8k.pcf

SOURCEDIR = ../../../rtl
BUILDDIR = build

PLL = $(BUILDDIR)/pll.sv

all: apple1 prog

info:
	@echo "       To build: make apple1"
	@echo "     To program: make prog"
	@echo "To build report: make report"
	@echo "    To clean up: make clean"

dir:
	mkdir -p $(BUILDDIR)

# ------ TEMPLATES ------
$(BUILDDIR)/%.blif: $(SOURCEDIR)/%.v
	yosys -q -p "synth_ice40 -top apple1_top -blif $@" $^

$(BUILDDIR)/%.asc: $(PIN_DEF) $(BUILDDIR)/%.blif
	arachne-pnr -d $(DEVICE) -P $(PACKAGE) -o $@ -p $^

$(BUILDDIR)/%.bin: $(BUILDDIR)/%.asc
	icepack $^ $@

%.rpt: $(BUILDDIR)/%.asc
	icetime -d $(DEVICE) -mtr $@ $<

%_tb.vvp: %_tb.v %.v
	iverilog -o $@ $^

%_tb.vcd: %_tb.vvp
	vvp -N $< +vcd=$@

$(PLL):
	icepll $(QUIET) -i $(FREQ_OSC) -o $(FREQ_PLL) -m -f $@

# ------ APPLE 1 ------
apple1: dir $(PLL) $(BUILDDIR)/apple1.bin
report: dir apple1.rpt

$(BUILDDIR)/apple1.bin: $(BUILDDIR)/apple1.asc
$(BUILDDIR)/apple1.asc: $(BUILDDIR)/apple1.blif
$(BUILDDIR)/apple1.blif: $(SOURCEDIR)/apple1.v \
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
	$(SOURCEDIR)/ukp/ukp.v \
	$(SOURCEDIR)/ukp/ukpram.v \
	$(SOURCEDIR)/ukp/ukprom.v \
	$(SOURCEDIR)/ukp/keymap.v \
	$(SOURCEDIR)/boards/ice40hx8k-b-evn/apple1_hx8k.v \
	$(BUILDDIR)/pll.sv

apple1.rpt: $(BUILDDIR)/apple1.asc

prog: dir $(BUILDDIR)/apple1.bin
	iceprog -S $(filter-out $<,$^)

# ------ HELPERS ------
clean:
	rm -rf build apple1.rpt

.SECONDARY:
.PHONY: all info clean prog iceprog
