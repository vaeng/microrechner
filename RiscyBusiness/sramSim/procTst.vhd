-- procTst.vhd
--
-- entity	procTst			-testbench for pipeline processor
-- architecture	testbench		-
------------------------------------------------------------------------------
library ieee;						-- packages:
use ieee.std_logic_1164.all;				--   std_logic
use ieee.numeric_std.all;				--   (un)signed
use work.sramPkg.all;					--   sram2
use work.procPkg.all;					--   pipeProc

-- entity	--------------------------------------------------------------
------------------------------------------------------------------------------
entity procTst is
generic(clkPeriod	: time		:= 20 ns;	-- clock period
	clkCycles	: positive	:= 20);		-- clock cycles
end entity procTst;


-- architecture	--------------------------------------------------------------
------------------------------------------------------------------------------
architecture testbench of procTst is
  signal clk, nRst	: std_logic;
  signal const0, const1	: std_logic;
  signal dnWE		: std_logic;
  signal iAddr,  dAddr	: std_logic_vector( 7 downto 0);
  signal iDataO		: std_logic_vector(31 downto 0);
  signal dDataO, dDataI	: std_logic_vector(15 downto 0);
  signal iCtrl,  dCtrl	: fileIOty;

begin
  const0 <= '0';
  const1 <= '1';

  -- memories		------------------------------------------------------
  instMemI: sram2	generic map (	addrWd	=> 8,
					dataWd	=> 32,
					fileID	=> "instMem.dat")
			port map    (	nCS	=> const0,
					nWE	=> const1,
					addr	=> iAddr,
					dataIn	=> open,
					dataOut	=> iDataO,
					fileIO	=> iCtrl);
  dataMemI: sram2	generic map (	addrWd	=> 8,
					dataWd	=> 32,
					fileID	=> "dataMem.dat")
			port map    (	nCS	=> const0,
					nWE	=> dnWE,
					addr	=> dAddr,
					dataIn	=> dDataI,
					dataOut	=> dDataO,
					fileIO	=> dCtrl);

  -- pipe processor	------------------------------------------------------
  pipeProcI: pipeProc	port map    (	clk	=> clk,
					nRst	=> nRst,
					iAddr	=> iAddr,
					iData	=> iDataO,
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
-- procTst.vhd	- end
