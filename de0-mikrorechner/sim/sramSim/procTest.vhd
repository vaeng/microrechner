-- procTest.vhd
--
-- entity	procTest		-testbench for pipeline processor
-- architecture	testbench		-
--
-- to do:	- replace pipeProc with new top-level design
--		- add component declaration or provide 'procPkg.vhd' with it
--		- write: 'instMem.dat' + 'dataMem.dat'
------------------------------------------------------------------------------
library ieee;						-- packages:
use ieee.std_logic_1164.all;				--   std_logic
use ieee.numeric_std.all;				--   (un)signed
use work.sramPkg.all;					--   sram2
--use work.procPkg.all;					--   pipeProc

-- entity	--------------------------------------------------------------
------------------------------------------------------------------------------
entity procTest is
generic(clkPeriod	: time		:= 20 ns;	-- clock period
	clkCycles	: positive	:= 100);	-- clock cycles
end entity procTest;


-- architecture	--------------------------------------------------------------
------------------------------------------------------------------------------
architecture testbench of procTest is
  signal clk, nRst	: std_logic;
  signal const1		: std_logic;
  signal dnWE		: std_logic;
  signal iAddr,  dAddr	: std_logic_vector( 9 downto 0);  -- 10-bit address!!!
  signal iDataI, dDataI	: std_logic_vector(31 downto 0);  -- mem  => proc
  signal dummy,  dDataO	: std_logic_vector(31 downto 0);  -- proc => mem
  signal iCtrl,  dCtrl	: fileIOty;

begin
  const1 <= '1';
  dummy  <= (others => '-');

  -- memories		------------------------------------------------------
  instMemI: sram2	generic map (	addrWd	=> 10,
					dataWd	=> 32,
					fileID	=> "instMem.dat")
			port map    (	nWE	=> const1,	-- read-only
					addr	=> iAddr,
					dataIn	=> dummy,
					dataOut	=> iDataI,
					fileIO	=> iCtrl);
  dataMemI: sram2	generic map (	addrWd	=> 10,
					dataWd	=> 32,
					fileID	=> "dataMem.dat")
			port map    (	nWE	=> dnWE,
					addr	=> dAddr,
					dataIn	=> dDataO,
					dataOut	=> dDataI,
					fileIO	=> dCtrl);

  -- pipe processor	------------------------------------------------------
  pipeProcI: pipeProc	port map    (	clk	=> clk,
					nRst	=> nRst,
					iAddr	=> iAddr,
					iData	=> iDataI,
					dnWE	=> dnWE,
					dAddr	=> dAddr,
					dDataI	=> dDataI,
					dDataO	=> dDataO);

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
-- procTest.vhd	- end
