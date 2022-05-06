-- de0Board.vhd
--------------------------------------------------------------------------------
--		ajm		29-dec-2014
--				-derived from: Terasic System Builder
--------------------------------------------------------------------------------
--
-- entity	de0Board	-generic wrapper for Terasic DE0-Nano
--				 prototyping board
-- architecture	wrapper		-pipeline processor 'pipeProc'
--
-- to do:	- replace pipeProc with new top-level design
--		- modify 'procPkg.vhd' to match pipeProc
--		- write  'memory/rom10x32.mif' + 'memory/ram10x32.mif'
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.procPkg.all;
use work.cDispPkg.all;

-- entity	----------------------------------------------------------------
--------------------------------------------------------------------------------
entity de0Board is
port (	clk50		: in	std_logic;		-- 50 MHz external clock

	-- KEY		active LOW	----------------------------------------
	key		: in	std_logic_vector( 1 downto 0);	-- act. L

--	-- DIP switch	0-Up / 1-Down	----------------------------------------
--	switch		: in	std_logic_vector( 3 downto 0);

	-- LED		active HIGH	----------------------------------------
	led		: out	std_logic_vector( 7 downto 0);	-- act. H

--	-- SDRAM 16Mx16	--------------------------------------------------------
--	--		IS42S16160B 4M x 16 x 4 banks
--	--		dram-IS42S16160B		=> page 8ff
	dramCsN		: out	std_logic;		-- L: chip select
--	dramCke		: out	std_logic;		-- H: clock enable
--	dramClk		: out	std_logic;		-- R: input-regs
--	dramRasN	: out	std_logic;		-- L: row-addr. strobe
--	dramCasN	: out	std_logic;		-- L: col-addr. strobe
--	dramWeN		: out	std_logic;		-- L: write enable
--	dramBa		: out	unsigned( 1 downto 0);	-- bank addr.
--	dramAddr	: out	unsigned(12 downto 0);	-- address
--	dramDqm		: out	unsigned( 1 downto 0);	-- byte dat.mask
--	dramDq		: inout	std_logic_vector(15 downto 0);	-- data

--	-- EPCS		--------------------------------------------------------
--	--		Spansion S25FL064P: FPGA config. memory; 64M bit Flash
--	--		DE0-UserManual + epcs-S25FL064P + Altera Manuals
	epcsCsN		: out	std_logic;		-- L: chip sel.	CS#
--	epcsDClk	: out	std_logic;		-- clock	SCK
--	epcsAsd		: out	std_logic;		-- ser.data out	SI/IO0
--	epcsData	: in	std_logic;		-- ser.data in	SO/IO1

--	-- I2C EEPROM	--------------------------------------------------------
--	--		Microchip 24LC02B 2K bit
--	--		eeprom-24xx02			=> page 5ff
--	i2cSClk		: out	std_logic;		-- SClock (bus master)
--	i2cSDat		: inout	std_logic;		-- SData

--	-- I2C Accelerometer	------------------------------------------------
--	--		Analog Devices ADXL345
--	--		accel-ADXL345			=> page 17ff
--	i2cSClk		: out	std_logic;		-- SClock (bus master)
--	i2cSDat		: inout	std_logic;		-- SData
	gSensorCs	: out	std_logic;		-- H: chip sel. I2C-mode
--	gSensorInt	: in	std_logic;		-- interrupt	INT1

--	-- AD converter	--------------------------------------------------------
--	--		National Semiconductor ADC128S022
--	--		adc-ADC128S022			=> page 2+7+16
	adcCsN		: out	std_logic);		-- L: chip select
--	adcSClk		: out	std_logic;		-- clock [0,8-3,2MHz]
--	adcSAddr	: out	std_logic;		-- command	DIN
--	adcSData	: in	std_logic;		-- data		DOUT

--	-- GPIO-0	--------------------------------------------------------
--	--	top	DE0-UserManual			=> page 18
--	gpio0		: inout	std_logic_vector(33 downto 0);
--	gpio0In		: in	std_logic_vector( 1 downto 0);

--	-- GPIO-1	--------------------------------------------------------
--	--	bot.	DE0-UserManual			=> page 18
--	gpio1		: inout	std_logic_vector(33 downto 0);
--	gpio1In		: in	std_logic_vector( 1 downto 0);

--	-- 2x13 GPIO	--------------------------------------------------------
--	--	right	DE0-UserManual			=> page 21
--	gpio2		: inout	std_logic_vector(12 downto 0);
--	gpio2In		: in	std_logic_vector( 2 downto 0));
end entity de0Board;


-- architecture	----------------------------------------------------------------
--------------------------------------------------------------------------------
architecture wrapper of de0Board is
  ------------------------------------------------------------------------------
  -- components from procPkg.vhd

  ------------------------------------------------------------------------------
  signal clk, clkN, slowClk	: std_logic;
  signal rstN, dWE, dnWE	: std_logic;
  signal iAddr, dAddr		: std_logic_vector( 9 downto 0);
  signal iData, dDataI, dDataO	: std_logic_vector(31 downto 0);

begin
  -- disable unused hardware
  ------------------------------------------------------------------------------
  dramCsN	<= '1';
  epcsCsN	<= '1';
  gSensorCs	<= '0';
  adcCsN	<= '1';

  -- component instantitions
  ------------------------------------------------------------------------------
  pllI: pllClk  port map (clk50, clk,  clkN, open, open);	-- 2 MHz clock
--pllI: pllClk  port map (clk50, open, open, clk,  clkN);	-- 1 MHz clock

  dataMemI: sram256x16 port map (dAddr, clkN, dDataO, dWE, dDataI);

  instMemI:  rom256x16 port map (iAddr, clkN, iData);

  procI: pipeProc port map (slowClk, rstN, iAddr, iData,
			    dnWE, dAddr, dDataI, dDataO);

  dWE <= not dnWE;

  -- processes
  ------------------------------------------------------------------------------
  -- clock divider      ~1Hz clock - 2 MHz / 2^21
  --    gated-clock:    (iAddr = 1023) => "halt"
  ---------------------------------------------------------------------------
  clkP: process (rstN, clk) is
    variable clkDiv	: unsigned (20 downto 0);	-- clock divider
--  variable clkDiv	: unsigned (2 downto 0);	-- for simulation
  begin
    if rstN = '0' then					-- async. reset
		slowClk <= '0';
		clkDiv  := (others => '0');
    elsif rising_edge(clk) then
      if (unsigned(iAddr) = 1023)
      then	slowClk <= '0';				-- pseudo "halt"
      else	slowClk <= clkDiv(clkDiv'left);		-- +1 clock delay
      end if;
      clkDiv := clkDiv + 1;
    end if;
  end process clkP;

  butP: process (clkN) is				-- sample buttons...
  begin
    if rising_edge (clkN) then
        rstN    <= key(0);
--      bTest   <= key(1);
    end if;
  end process butP;

  led <= iAddr(7 downto 0);
end architecture wrapper;

--------------------------------------------------------------------------------
-- de0Board.vhd - end
