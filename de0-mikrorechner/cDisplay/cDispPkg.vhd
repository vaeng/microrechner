-- cDispPkg.vhd
--------------------------------------------------------------------------------
--		ajm		17-jun-2015
--------------------------------------------------------------------------------
--
-- package	cDispPkg	-character display 14x6
--
-- usage	cDisp14x6	------------------------------------------------
-- generic map (bgLight)	--boolean := false	-- background light
-- port map    (clk, clkN,	--in  std_logic		-- 1-2MHz clock	[R/F]
--		rstN,		--in  std_logic		-- reset	[L]
-- user interface, connect to your design		------------------------
--		req,		--in  std_logic		-- request	[T]
--		cmd,		--in  cmdTy		-- command	<cmd>
--		char,		--in  character		-- ASCII subset	20..7e
--		invC,		--in  std_logic;	-- inverted char[T]
--		xPos,		--in  natural 0..13	-- X-position	 0..13
--		yPos,		--in  natural 0..5	-- Y-position	 0..5
--		ack,		--out std_logic		-- acknowledge	[T]
-- display interface, connect to de0Board external pins	------------------------
--		s_ceN,		--out std_logic		-- SPI client enable
--		s_rstN,		--out std_logic		-- SPI reset
--		s_dNc,		--out std_logic		-- SPI data [1]/ctrl [0]
--		s_din,		--out std_logic		-- SPI data in
--		s_clk,		--out std_logic		-- SPI clock
--		bgLed);		--out std_logic		-- background LED
--
--	<cmd>	dispReset	--reset and clear display
--		dispAllOn	--all pixel on,  does not affect display memory
--		dispAllOff	--all pixel off, -"-
--		dispNormal	--set normal   display mode
--		dispInverse	--set inverted display mode
--		dispClear	--clear display memory
--		dispPosXY	--set X-/Y-position (0..13/0..5)
--		dispChar	--display char at current position, advance pos.
--
-- interface sequence		------------------------------------------------
--	idle        command       busy            idle     next command
--	req=ack     toggle req    req/=ack        req=ack
--	___          ________             ________          ________
-- clk	   \________/        \___ --- ___/        \________/        \___
--	............ ______________________________________ ............
-- req	____________X......................................X____________
--	____________ ______________________________________ ____________
-- cmd	____________X______________________________________X____________
--	____________ ______________________________________ ____________
-- dat	____________X______________________________________X____________
--	.......................................... _____________________
-- ack	__________________________________________X.....................
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


-- package	----------------------------------------------------------------
--------------------------------------------------------------------------------
package cDispPkg is

  -- constant	-- internal	------------------------------------------------
  constant instExtdC	: std_logic_vector (7 downto 0)	:= x"21";
  constant instNormC	: std_logic_vector (7 downto 0)	:= x"20";
  constant setBiasC	: std_logic_vector (7 downto 0)	:= x"13";--14
  constant setVopC	: std_logic_vector (7 downto 0)	:= x"bc";--c6 e0
  constant dispSet0c	: std_logic_vector (7 downto 0)	:= x"08";
  constant dispSet1C	: std_logic_vector (7 downto 0)	:= x"09";
  constant dispNormC	: std_logic_vector (7 downto 0)	:= x"0c";
  constant dispInvC	: std_logic_vector (7 downto 0)	:= x"0d";
  constant setXAddrC	: std_logic			:= '1';
  constant setYAddrC	: std_logic_vector (4 downto 0)	:= "01000";
  constant romInvalC	: integer			:= 95;

  -- component	-- internal	------------------------------------------------
  component charROM is
  port(	address         : in	std_logic_vector (6 downto 0);
	clock           : in	std_logic	:= '1';
	q               : out	std_logic_vector (39 downto 0));
  end component charROM;

  -- type	-- external	------------------------------------------------
  type	cmdTy	is (dispReset, dispAllOn, dispAllOff, dispNormal, dispInverse,
		    dispClear, dispPosXY, dispChar);

  -- component	-- external	------------------------------------------------
  component pllClk is		--		use either 1 or 2 MHz clock pair
  port(	inclk0		: in	std_logic	:= '0';	-- 50 MHz
	c0		: out	std_logic;		--  2 MHz	= clk
	c1		: out	std_logic;		--  2 MHZ+180°	= clkN
	c2		: out	std_logic;		--  1 MHz	= clk
	c3		: out	std_logic);		--  1 MHZ+180°	= clkN
  end component pllClk;

  component cDisp14x6 is
  generic(bgLight	:	boolean	:= false);
  port(	clk, clkN	: in	std_logic;		-- 1-2MHz clock	[R/F]
	rstN		: in	std_logic;		-- reset	[L]
	req		: in	std_logic;		-- request	[T]
	cmd		: in	cmdTy;			-- command
	char		: in	character;		-- ASCII subset	20..7e
	invC		: in	std_logic;		-- inverted char[T]
	xPos		: in	natural range 0 to 13;	-- X-position	 0..13
	yPos		: in	natural range 0 to  5;	-- Y-position	 0..5
	ack		: out	std_logic;		-- acknowledge	[T]
	-- alternative	=> combined input: char | xPos & yPos
	-- data		: in	std_logic_vector(7 downto 0);
	-- display interface	------------------------------------------------
	s_ceN		: out	std_logic;		-- SPI client enable
	s_rstN		: out	std_logic;		-- SPI reset
	s_dNc		: out	std_logic;		-- SPI data [1]/ctrl [0]
	s_din		: out	std_logic;		-- SPI data in
	s_clk		: out	std_logic;		-- SPI clock
	bgLed		: out	std_logic);		-- background LED
  end component cDisp14x6;

end package cDispPkg;
--------------------------------------------------------------------------------
-- cDispPkg.vhd - end
