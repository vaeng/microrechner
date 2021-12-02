GHDL_CMD = ghdl
GHDL_FLAGS = --ieee=synopsys --std=08

all: compile # clean  run

compile: 
#mkdir work
	@$(GHDL_CMD) -a $(GHDL_FLAGS) riscy_package.vhd
	@$(GHDL_CMD) -a $(GHDL_FLAGS) riscy.vhd


#run:
#	@$(GHDL_CMD) -r $(GHDL_FLAGS) riscy --vcd=riscy.ghw

# clean:
# rm -rf work
# rm -f riscy.ghw
