DEVICE = um-45k
PIN_DEF=ulx4m_v002.lpf

SOURCEDIR = ../../../rtl
BUILDDIR = build

all: apple1 prog

info:
	@echo "       To build: make apple1"
	@echo "     To program: make prog or make dfu"
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
	ecppack --compress $^ $@

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
	$(SOURCEDIR)/boards/ulx4m/apple1_dvi.v \
	$(SOURCEDIR)/boards/ulx4m/vga2dvid.v \
	$(SOURCEDIR)/boards/ulx4m/clk_25_250_125_25.v \
	$(SOURCEDIR)/boards/ulx4m/tmds_encoder.v \
	$(SOURCEDIR)/boards/ulx4m/fake_differential.v

prog: dir $(BUILDDIR)/apple1.bit
	fujprog $(filter-out $<,$^)

dfu:  dir $(BUILDDIR)/apple1.bit
	dfu-util -a 0 -D  $(filter-out $<,$^) -R


# ------ HELPERS ------
clean:
	rm -rf build

.SECONDARY:
.PHONY: all info clean prog
