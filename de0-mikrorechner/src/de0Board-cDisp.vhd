-- de0Board.vhd
--------------------------------------------------------------------------------
--		ajm		29-dec-2014
--				-derived from: Terasic System Builder
--------------------------------------------------------------------------------
--
-- entity	de0Board	-generic wrapper for Terasic DE0-Nano
--				 prototyping board
-- architecture	wrapper		-pipeline processor 'pipeProc' with cDisplay
--
-- to do:	- replace pipeProc with new top-level design
--		- modify 'procPkg.vhd' to match pipeProc
--		- write  'memory/rom10x32.mif' + 'memory/ram10x32.mif'
--		- check output mechanism in dispP
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cDispPkg.all;
use work.procPkg.all;

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
	adcCsN		: out	std_logic;		-- L: chip select
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

	butWh		: in	std_logic_vector(1 to 8); -- [H]  gpio1(24..31)
	butBk		: in	std_logic_vector(1 to 2); -- [L]  gpio1(16..17)
	butRd		: in	std_logic_vector(1 to 2); -- [L]  gpio1(19..20)

	s_ceN		: out	std_logic;	-- SPI client ena.	[L]
						-- 3-SCE	= gpio1(0)
	s_rstN		: out	std_logic;	-- SPI reset		[L]
						-- 4-RST	= gpio1(1)
	s_dNc		: out	std_logic;	-- SPI data [1]/ctrl [0]
						-- 5-D/C	= gpio1(2)
	s_din		: out	std_logic;	-- SPI data in
						-- 6-DN(MOSI)	= gpio1(3)
	s_clk		: out	std_logic;	-- SPI clock
						-- 7-SCLK	= gpio1(4)
	bgLed		: out	std_logic);	-- background LED
						-- 8-LED	= gpio1(5)
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

  ------------------------------------------------------------------------------
  type   stateTy	is (idle, dNormal, dClear, dChar1, dChar2, dChar3,
			   dChar4, dChar5, dChar6, dChar7, dChar8, dChar9);
  signal state		: stateTy;
  signal req, ack	: std_logic;
  signal cmd		: cmdTy;
  signal char		: character;
  signal invC		: std_logic;
  signal xPos		: natural range 0 to 13;
  signal yPos		: natural range 0 to  5;

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

  dataMemI: ram10x32 port map (dAddr, clkN, dDataO, dWE, dDataI);

  instMemI: rom10x32 port map (iAddr, clkN, iData);

  procI: pipeProc port map (slowClk, rstN, iAddr, iData,
			    dnWE, dAddr, dDataI, dDataO);

  dispI: cDisp14x6
	generic map (	bgLight	=> false)
	port map (	clk	=> clk,
			clkN	=> clkN,
			rstN	=> rstN,
			req	=> req,
			cmd	=> cmd,
			char	=> char,
			invC	=> invC,
			xPos	=> xPos,
			yPos	=> yPos,
			ack	=> ack,
			s_ceN	=> s_ceN,
			s_rstN	=> s_rstN,
			s_dNc	=> s_dNc,
			s_din	=> s_din,
			s_clk	=> s_clk,
			bgLed	=> bgLed);

  dWE <= not dnWE;

  -- processes
  ------------------------------------------------------------------------------
  -- clock divider      ~1Hz clock - 2 MHz / 2^21
  --    gated-clock:    (iAddr = 1023) => "halt"
  ---------------------------------------------------------------------------
  clkP: process (rstN, clk) is
    variable clkDiv	: unsigned (20 downto 0);	-- clock divider
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

  -- memory mapped control for cDisplay
  -- dAddr = 1023 : hex output dDataO 
  -- 'slow' processor clock required < 1/1000 [clk/procClk]
  ---------------------------------------------------------------------------
  dispP: process (clk, rstN) is
    function hex2char	(arg	: std_logic_vector(3 downto 0))
			return	  character is
    begin
	case arg is
	when "0000" =>	return '0';
	when "0001" =>	return '1';
	when "0010" =>	return '2';
	when "0011" =>	return '3';
	when "0100" =>	return '4';
	when "0101" =>	return '5';
	when "0110" =>	return '6';
	when "0111" =>	return '7';
	when "1000" =>	return '8';
	when "1001" =>	return '9';
	when "1010" =>	return 'A';
	when "1011" =>	return 'B';
	when "1100" =>	return 'C';
	when "1101" =>	return 'D';
	when "1110" =>	return 'E';
	when "1111" =>	return 'F';
	when others =>	return 'x';
	end case;
    end function hex2char;

  begin
    if rstN = '0' then		-- async. reset			----------------
	state	<= idle;
	req	<= '0';
	char	<= 'X';
	invC	<= '0';
	xPos	<= 0;
	yPos	<= 0;
    elsif rising_edge(clk) then
      case state is

      -- init. internal vars, wait for ack='0'		------------------------
      when idle		=>
	req	<= '0';
	if ack = '0' then	req	<= not req;
				state	<= dNormal;
				cmd	<= dispNormal;
	end if;

      -- normal display					------------------------
      when dNormal	=>
	if ack = req	then	req	<= not req;
				state	<= dClear;
				cmd	<= dispClear;
	end if;

      -- clear display					------------------------
      when dClear	=>
	if ack = req and unsigned(dAddr) = 1023	then
				req	<= not req;
				state	<= dChar1;
				cmd	<= dispChar;
				char	<= hex2char(dDataO(31 downto 28));
	end if;

      -- char1	'[31..28]'				------------------------
      when dChar1	=>
	if ack = req then	req	<= not req;
				state	<= dChar2;
				cmd	<= dispChar;
				char	<= hex2char(dDataO(27 downto 24));
	end if;

      -- char2	'[27..24]'				------------------------
      when dChar2	=>
	if ack = req then	req	<= not req;
				state	<= dChar3;
				cmd	<= dispChar;
				char	<= hex2char(dDataO(23 downto 20));
	end if;

      -- char3	'[23..20]'				------------------------
      when dChar3	=>
	if ack = req then	req	<= not req;
				state	<= dChar4;
				cmd	<= dispChar;
				char	<= hex2char(dDataO(19 downto 16));
	end if;

      -- char4	'[19..16]'				------------------------
      when dChar4	=>
	if ack = req then	req	<= not req;
				state	<= dChar5;
				cmd	<= dispChar;
				char	<= hex2char(dDataO(15 downto 12));
	end if;

      -- char5	'[15..12]'				------------------------
      when dChar5	=>
	if ack = req then	req	<= not req;
				state	<= dChar6;
				cmd	<= dispChar;
				char	<= hex2char(dDataO(11 downto  8));
	end if;

      -- char6	'[11..8]'				------------------------
      when dChar6	=>
	if ack = req then	req	<= not req;
				state	<= dChar7;
				cmd	<= dispChar;
				char	<= hex2char(dDataO( 7 downto  4));
	end if;

      -- char7	'[7..4]'				------------------------
      when dChar7	=>
	if ack = req then	req	<= not req;
				state	<= dChar8;
				cmd	<= dispChar;
				char	<= hex2char(dDataO(3 downto 0));
	end if;


      -- char8	'[3..0]'				------------------------
      when dChar8	=>
	if ack = req then	req	<= not req;
				state	<= dChar9;
				cmd	<= dispChar;
				char	<= ' ';
	end if;

      -- char9	' '					------------------------
      when dChar9	=>
	if ack = req and unsigned(dAddr) /= 1023 then
				state	<= dClear;
	end if;

      end case;
    end if;
  end process demoP;

end architecture wrapper;

--------------------------------------------------------------------------------
-- de0Board.vhd - end
