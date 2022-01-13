-- procTst.vhd
--
-- entity	procTst			-testbench for pipeline processor
-- architecture	testbench		-
------------------------------------------------------------------------------
library ieee;						-- packages:
use ieee.std_logic_1164.all;				--   std_logic
use ieee.numeric_std.all;				--   (un)signed
use work.sramPkg.all;					--   sram2
-- use work.procPkg.all;					--   pipeProc

-- entity	--------------------------------------------------------------
------------------------------------------------------------------------------
entity procTst is
generic(clkPeriod	: time		:= 20 ns;	-- clock period
	clkCycles	: positive	:= 20);		-- clock cycles
end entity procTst;



-- architecture (Harvard Architektur)	--------------------------------------------------------------
------------------------------------------------------------------------------
architecture testbench of procTst is
  signal clk, nRst	: std_logic;
  signal const0, const1	: std_logic;
  signal dnWE		: std_logic;
  signal iAddr,  dAddr	: std_logic_vector( 7 downto 0);
  signal iDataO		: std_logic_vector(31 downto 0);
  signal dDataO, dDataI	: std_logic_vector(31 downto 0); --dData0 for the ram to register (for procedures)
  signal iCtrl,  dCtrl	: fileIOty;



begin -- probiere erstmal aus, ob ueberhaupt ein Befehl aus dem Speicher geholt wird!!!!
  const0 <= '0';
  const1 <= '1';

  -- memories ------------------------------------------------------
  instMemI: sram2	generic map(
          addrWd	=> 8,
					dataWd	=> 32,
					fileID	=> "instMem.dat")
			port map
      (	
          nCS	=> const0,
					nWE	=> const1,
					addr	=> iAddr, -- 256x32 fuer die Befehle (instructionAddress), iaddr ist fuer den pc
					dataIn	=> open,
					dataOut	=> iDataO, -- this is the instruction to decode, its an input to iData port first in decode stage
					fileIO	=> iCtrl
      );

    -- fetch ------------------------------------------------------
    registerI: register_file32
        port map(
            clk => clk, -- clock
            rs1 =>  ,-- input
            rs2 =>  , -- input
            rd =>  , -- input
            data_input => , -- data input from the wb stage (ALUor from the mem(e.g. through a lw instrucution)
            rs1_out =>  , -- data output
            rs2_out =>  , -- data output
            writeEnable =>  -- for conroll, writeEnable == 1 write otherwise read or do nothing
        );

        );

  -- stimuli		------------------------------------------------------
  stiP: process is
  begin
    clk		<= '0';
    nRst	<= '0',   '1'  after 5 ns;
    iCtrl	<= load,  none after 5 ns;
    dCtrl	<= load,  none after 5 ns;
    wait for clkPeriod/2;
    for n in 1 to clkCycles loop
	clk <= '0', '1' after clkPeriod/2;
	wait for clkPeriod;
    end loop;
    wait;
  end process stiP;

end architecture testbench;
------------------------------------------------------------------------------
-- procTst.vhd	- end
