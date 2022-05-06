-- procPkg.vhd
--
-- package	procPkg			-processor "global" declarations
------------------------------------------------------------------------------
library ieee;					-- packages:
use ieee.std_logic_1164.all;			--   std_logic
use ieee.numeric_std.all;			--   (un)signed

-- package	--------------------------------------------------------------
------------------------------------------------------------------------------
package procPkg is

  -- opcode constants	------------------------------------------------------
  -- constant	opcSample	: std_logic_vector (4 downto 0)	:= "00000";

  -- component decl.	------------------------------------------------------
--component pipeProc is
--port(	clk	: in	std_logic;			-- clock
--	nRst	: in	std_logic;			-- not reset
--	iAddr	: out	std_logic_vector( 7 downto 0);	-- instMem address
--	iData	: in	std_logic_vector(15 downto 0);	-- instMem data
--	dnWE	: out	std_logic;			-- dataMem write-ena
--	dAddr	: out	std_logic_vector( 7 downto 0);	-- dataMem address
--	dDataI	: in	std_logic_vector(15 downto 0);	-- dataMem data RAM->
--	dDataO	: out	std_logic_vector(15 downto 0));	-- dataMem data ->RAM
--end component pipeProc;

  -- quartus generated	------------------------------------------------------
  component ram10x32
  port(	address	: in	std_logic_vector ( 9 downto 0);
	clock	: in	std_logic;
	data	: in	std_logic_vector (31 downto 0);
	wren	: in	std_logic;
	q	: out	std_logic_vector (31 downto 0));
  end component ram10x32;

  component rom10x32
  port(	address	: in	std_logic_vector ( 9 downto 0);
	clock	: in	std_logic;
	q	: out	std_logic_vector (31 downto 0));
  end component rom10x32;

end package procPkg;
------------------------------------------------------------------------------
-- procPkg.vhd	- end
