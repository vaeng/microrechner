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
	clkCycles	: positive	:= 1000);		-- clock cycles
end entity procTst;


-- architecture (Harvard Architektur)	--------------------------------------------------------------
------------------------------------------------------------------------------
architecture testbench of procTst is
  signal clk, nRst	: std_logic;
  signal const0, const1	: std_logic;
  signal dnWE		: std_logic;
  signal iAddr,  dAddr	: std_logic_vector(31 downto 0) := x"00000000";
  signal iDataO		: std_logic_vector(31 downto 0);
  signal dDataO, dDataI	: std_logic_vector(31 downto 0); -- dData0 for the RAM to register (for processes)
  signal iCtrl, dCtrl : fileIOty;

  component sram2 is
    generic (	
        addrWd	: integer range 2 to 16	:= 8;	-- #address bits
        dataWd	: integer range 2 to 32	:= 32;	-- #data bits
        fileId	: string		:= "sram.dat"); -- filename
    port (		nCS	: in    std_logic;		-- not Chip Select
              nWE	: in    std_logic;		-- not Write Enable
              addr	: in    std_logic_vector(addrWd-1 downto 0);
              dataIn	: in	std_logic_vector(dataWd-1 downto 0);
              dataOut	: out	std_logic_vector(dataWd-1 downto 0);
              fileIO	: in	fileIOty	:= none);
    end component sram2;

    component riscy is
      port(
          clk: in std_logic;
          nRst: in std_logic;
          iAddr: out std_logic_vector(31 downto 0); -- CPU.PC --> INSMEM (Verbinden mit "pc_unit")
          iData: in std_logic_vector(31 downto 0); -- instruction decode; use as signal in cpu
          dnWE: out std_logic; -- write enable dependent of opcode(determined in the addressdecoder); its low active; if 0 then write in ram else not for dataMEM
          dAddr: out std_logic_vector(31 downto 0); -- to DataMEM (Verbinden mit dem externen Speicher)
          dDataI: out std_logic_vector(31 downto 0); -- ausgang zum speichern in DataMEM
          dDataO: in std_logic_vector(31 downto 0) -- from WB stage
      ); 
  end component riscy;

  signal random : std_logic_vector(31 downto 0) := (others => '0');

begin
  const0 <= '0';
  const1 <= '1';

  -- memories		------------------------------------------------------
  instMemI: sram2	generic map(
          addrWd	=> 8,
					dataWd	=> 32,
					fileID	=> "sramSim/fib2.dat")
			port map    (	
          nCS	=> const0,
					nWE	=> const1,
					addr	=> iAddr(7 downto 0), -- 256x32 fuer die Befehle (instructionAddress), iaddr ist fuer den pc
					dataIn	=> random,
					dataOut	=> iDataO, -- this is the instruction to decode, its an input to iData port first in decode stage
					fileIO	=> iCtrl);
  dataMemI: sram2	generic map (	
          addrWd	=> 8, -- vielleicht 32bit, aber 2**32 zellen zu viel?
					dataWd	=> 32,
					fileID	=> "sramSim/dataMem.dat")
			port map (	
          nCS	=> const0,
					nWE	=> dnWE,
					addr	=> dAddr(7 downto 0), -- 256x32 fuer die Befehle (dataAddress)
					dataIn	=> dDataI,
					dataOut	=> dDataO, -- dataMem --> CPU.Registerfile, lw
					fileIO	=> dCtrl);

  -- pipe processor	(hier kommt unser risc-v prozessor hin "riscy.vhd" ------------------------------------------------------
  pipeProcI: riscy	port map(
          clk	=> clk,
					nRst	=> nRst,
					iAddr	=> iAddr, -- CPU.PC --> instMEMI
					iData	=> iDataO, -- instruction decode; use as signal in cpu; instMemI --> cpu.Decoder
					dnWE	=> dnWE, -- wirte enable dependent of opcode; its low active; if 0 then write in ram else not; CPU.Decoder(Opcode) --> dataMEM
					dAddr	=> dAddr, -- addresse für den RAM, CPU.ALU --> dataMEM eg for sw
					dDataI	=> dDataI, -- CPU.ALU --> dataMEM
					dDataO	=> dDataO); --> dataMem --> CPU.Registerfile, lw

  -- stimuli		------------------------------------------------------
  stiP: process is
  begin
    clk		<= '0';
    nRst	<= '0',   '1'  after 5 ns;
    iCtrl	<= load,  none after 5 ns;
    dCtrl	<= dump,  none after 5 ns;
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
