DEVICE = 25k
PIN_DEF=ulx3s_v20.lpf
IDCODE ?= 0x21111043 # 12f

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
	yosys -q -p "chparam -list; hierarchy -top apple1_top; synth_ecp5 -json $@" $^

$(BUILDDIR)/%.config: $(PIN_DEF) $(BUILDDIR)/%.json
	 nextpnr-ecp5 --${DEVICE} --package CABGA381 --freq 25 --textcfg  $@ --json $(filter-out $<,$^) --lpf $< 

$(BUILDDIR)/%.bit: $(BUILDDIR)/%.config
	ecppack --compress --idcode ${IDCODE} $^ $@

%_tb.vvp: %_tb.v %.v
	iverilog -o $@ $^

%_tb.vcd: %_tb.vvp
	vvp -N $< +vcd=$@

# ------ APPLE 1 ------
apple1: dir $(BUILDDIR)/apple1.bit

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
	$(SOURCEDIR)/boards/ulx3s/apple1_dvi.v \
	$(SOURCEDIR)/boards/ulx3s/vga2dvid.v \
	$(SOURCEDIR)/boards/ulx3s/clk_25_250_125_25.v \
	$(SOURCEDIR)/boards/ulx3s/tmds_encoder.v \
	$(SOURCEDIR)/boards/ulx3s/fake_differential.v

prog: dir $(BUILDDIR)/apple1.bit
	ujprog $(filter-out $<,$^)
# ------ HELPERS ------
clean:
	rm -rf build

.SECONDARY:
.PHONY: all info clean prog
