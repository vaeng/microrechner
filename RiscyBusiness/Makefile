GHDL_CMD = ghdl
GTKWAVEL_CMD = gtkwave
GHDL_FLAGS1 = --std=08
GHDL_FLAGS2 = --workdir=work
GTKWAVE_CHDIR = pwd

all: clean compile run

compile: 
	mkdir work
	@$(GHDL_CMD) -a $(GHDL_FLAGS2) $(GHDL_FLAGS1) core/riscy_package.vhd core/register.vhd core/pc_unit.vhd core/extender.vhd core/alu_entity.vhd \
	core/brancher_logic.vhd core/addressdecoder.vhd core/riscy.vhd sramSim/sram2.vhd sramSim/procTst.vhd

run:
	@$(GHDL_CMD) -r $(GHDL_FLAGS2) $(GHDL_FLAGS1) procTst --vcd=riscy.vcd
	export $(GTKWAVE_CHDIR)
	open -n -W -a $(GTKWAVEL_CMD) riscy.vcd

clean:
	rm -r work
	rm -f riscy.vcd