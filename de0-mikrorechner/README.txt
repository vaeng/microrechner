README.txt	ajm					20-dec-2021
------------------------------------------------------------------------------

Makefile	-non graphical compilation and programming
de0Board.vhd	-top level wrapper for pipeProc
de0Board.qpf	-files for Quartus
de0Board.qsf	-
de0Board.sdc	-

cDisplay/cDisp14x6.vhd	-display controller FSM
cDisplay/cDispPkg.vhd	-component: cDisp14x6, pllClk   type: cmdTy
		=> for external use
		components and types used in cDisp14x6

cDisplay/pll/	-pll to generate 2MHz clocks from 50MHz input on DE0-board
		 must be used within de0Board.vhd, see example
cDisplay/rom/	-character ROM for cDisp14x6
		 internally used in cDisp14x6

memory/		-rom10x32	instruction memory	-edit rom10x32.mif !
		 ram10x32	data memory		-edit ram10x32.mif !

qProgram/	-saved programming files from prev. runs
doc/		-additional datasheets: DE0-board, PCB devices, etc.
src/		-... VHDL design sources

sim/sramSim/	-RTL-Simulation for pipeProc, run before quartus !
sim/xmsim/	-Quartus generated VHDL netlists for simulation

quartusOutput	-Quartus generated output: reports, programming (de0Bord.sof)
		 deleted by Makefile

TO DO		--------------------------------------------------------------
		1. add processor VHDL files to src/
		2. edit 'src/procPkg.vhd' to match files
		3. simulate processor in src/sramSim
		   edit 'sim/sramSim/procTest.vhd'
		4. edit 'de0Board.vhd' (samples in src)
		5. edit memory content
		   'memory/rom10x32.mif' + 'memory/rom10x32.mif'
		6. edit 'de0Board.qsf' (samples in src)
		   add references to new VHDL files in src
		-or- add files to project in 7.
		7. start 'quartus de0Board'
		   run design synthesis
		-optional-
		8. simulate quartus generated netlist in src/xmsim
------------------------------------------------------------------------------
README.txt - end
