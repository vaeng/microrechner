-- de0Test.vhd
--
-- entity	de0Test		-testbench for: de0Board
-- architecture	testbench
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity de0Test is
generic(	periodC	: time		:= 20 ns);
end entity de0Test;

architecture testbench of de0Test is

  component de0Board is
  port(	clk50		: in	std_logic;		-- 50 MHz external clock
	key		: in	std_logic_vector( 1 downto 0);
	led		: out	std_logic_vector( 7 downto 0);
	dramCsN		: out	std_logic;		-- L: chip select
	epcsCsN		: out	std_logic;		-- L: chip sel.	CS#
	gSensorCs	: out	std_logic;		-- H: chip sel. I2C-mode
	adcCsN		: out	std_logic);		-- L: chip select
  end component de0Board;

  signal clk50		: std_logic;
  signal key		: std_logic_vector( 1 downto 0);
  signal led		: std_logic_vector( 7 downto 0);
  signal dramCsN	: std_logic;		-- L: chip select
  signal epcsCsN	: std_logic;		-- L: chip sel.	CS#
  signal gSensorCs	: std_logic;		-- H: chip sel. I2C-mode
  signal adcCsN		: std_logic;		-- L: chip select
begin
  de0I: de0Board	port map (clk50, key, led,
			dramCsN, epcsCsN, gSensorCs, adcCsN);

  -- 50 MHz clock
  ----------------------------------------------------------------------------
  clkP: process is
  begin
	clk50 <= '0', '1' after periodC/2;
	wait for periodC;
  end process clkP;

  -- reset at simulation start:	key(0) resets pipeProc (low active)
  ----------------------------------------------------------------------------
  keyP: process is
  begin
	key <= "10", "11" after 5*periodC/4;
	wait;
  end process keyP;
end architecture testbench;
