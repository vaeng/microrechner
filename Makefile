GHDL_CMD = ghdl
GHDL_FLAGS = --ieee=synopsys --std=08

all: clean compile run

compile: 
	mkdir work
	@$(GHDL_CMD) -a $(GHDL_FLAGS) --workdir=work RiscyBusiness/riscy_package.vhd
	@$(GHDL_CMD) -a $(GHDL_FLAGS) --workdir=work RiscyBusiness/riscy.vhd
	@$(GHDL_CMD) -e $(GHDL_FLAGS) --workdir=work riscy


run:
	@$(GHDL_CMD) -r $(GHDL_FLAGS) --workdir=work riscy --wave=riscy.ghw


clean:
	rm -rf work
	rm -f riscy.ghw
