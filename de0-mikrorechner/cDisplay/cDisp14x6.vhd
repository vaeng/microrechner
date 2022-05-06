-- cDisp14x6.vhd
--------------------------------------------------------------------------------
--		ajm		17-jun-2015
--------------------------------------------------------------------------------
--
-- entity	cDisp14x6	-character display 14x6
-- architecture	pcd8544		-controller is PCD8544, see datasheet
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
use ieee.numeric_std.all;
use work.cDispPkg.all;

-- entity	----------------------------------------------------------------
--------------------------------------------------------------------------------
entity cDisp14x6 is
generic(bgLight		:	boolean	:= false);
port (	clk, clkN	: in	std_logic;		-- 2 MHz clock	[R/F]
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
end entity cDisp14x6;


-- architecture	----------------------------------------------------------------
--------------------------------------------------------------------------------
architecture pcd8544 of cDisp14x6 is
  type   stateTy	is (power, reset, init, active);
  signal state		: stateTy;
  signal dispEna	: std_logic;
  signal ackL		: std_logic;
  signal charBit	: natural range 0 to 4031;
  signal charReg	: std_logic_vector (47 downto 0);
  signal romA		: std_logic_vector ( 6 downto 0);
  signal romD		: std_logic_vector (39 downto 0);
begin
  -- set bg LED
  ---------------------------------------------------------------------------
  bgLed		<= '1' when bgLight else '0';

  -- component instantitions
  ---------------------------------------------------------------------------
  romI: charROM port map (romA,  clk, romD);


  ctrlP: process (clkN, rstN) is
    procedure stInit (	nxtState	: stateTy;
			isData		: std_logic;
			regBit		: natural range 0 to 4031;
			regData		: std_logic_vector (47 downto 0)) is
    begin
	state	<= nxtState;
	s_dNc	<= isData;
	charBit <= regBit;
	charReg	<= regData;
    end procedure stInit;

  begin
    if rstN = '0' then			-- async. reset
		dispEna	<= '0';
		state	<= power;
		s_rstN	<= '1';
		s_dNc	<= '0';
		charReg	<= (others => '0');
    elsif rising_edge(clkN) then
      case state is
      -- power on / hardware reset	----------------------------------------
      when power =>
		ackL	<= '1';
		dispEna	<= '1';
		state	<= reset;	-- 1. reset pcd8544
		s_rstN	<= '0';
      -- reset controller		----------------------------------------
      when reset =>
		s_rstN	<= '1';
		stInit(init, '0', 39,	-- 2. setup pcd8544
		instExtdC & setBiasC & setVopC & instNormC & dispNormC & x"00");
      -- initialize controller		----------------------------------------
      when init =>
	if charBit = 0 then		-- 3. clear display memory, write '0's
		stInit(active, '1', 4031, x"000000000000");
	else	charBit <= charBit-1;	-- finish current operation
		charReg <= charReg(46 downto 0)&'0';
	end if;
      -- active state, cmd switch	----------------------------------------
      when active =>
	if charBit = 0 then
	  if ackL = req then		-- no new command
--		stInit(active, '0', 7, x"000000000000");	-- nop
		dispEna	<= '0';		-- disable pcd8544
		state	<= active;
	  else	dispEna	<= '1';
	    case cmd is
	    when dispReset	=>	-- start reset sequence
		state	<= reset;	-- 1. reset pcd8544
		s_rstN	<= '0';
	    when dispAllOn	=>	-- all bits on, temporary!
		stInit(active, '0', 7, dispSet1C & x"0000000000");
	    when dispAllOff	=>	-- all bit off, temporary!
		stInit(active, '0', 7, dispSet0C & x"0000000000");
	    when dispNormal	=>	-- set normal display mode
		stInit(active, '0', 7, dispNormC & x"0000000000");
	    when dispInverse	=>	-- set inverted display mode
		stInit(active, '0', 7, dispInvC & x"0000000000");
	    when dispClear	=>	-- clear display memory
		stInit(active, '1', 4031, x"000000000000");
	    when dispPosXY	=>	-- set display position
		stInit(active, '0', 15,
			setXAddrC & std_logic_vector(to_unsigned(xPos*6, 7)) &
			setYAddrC & std_logic_vector(to_unsigned(yPos, 3)) &
			x"00000000");
	    when dispChar	=>	-- write character
		if invC = '1'	then stInit(active, '1', 47, not(romD & x"00"));
				else stInit(active, '1', 47, romD & x"00");
		end if;
	    end case;
	  end if;
	else
	  if charBit = 4 then		-- prepare next command, 4 cycles adv.
	    ackL <= req;
	  end if;
	  charBit <= charBit-1;		-- finish current operation
	  charReg <= charReg(46 downto 0)&'0';
	end if;
      end case;
    end if;
  end process ctrlP;

  ack	<= ackL;
  s_din <= charReg(47);
  s_clk <= clk;-- and dispEna;
  s_ceN <= not dispEna;

  romA <= std_logic_vector(to_unsigned(romInvalC, romA'length))
    when char < ' ' or char > '~' else
	  std_logic_vector(to_unsigned(character'pos(char)-32, romA'length));

end architecture pcd8544;
--------------------------------------------------------------------------------
-- cDisp14x6.vhd - end
