-- sram2.vhd		------------------------------------------------------
------------------------------------------------------------------------------
-- Andreas Maeder	01-feb-2007
--			-simulation model of a simple SRAM
--			-separate input/output buses
--			-no timing !!
--
-- parameters		addrWd		-address width	2..16 [8]
--					 was 32 => vhdl overflow: 2**32 -1
--			dataWd		-data with	2..32 [8]
--			fileID		-filename	[sram.dat]
--
-- package		sramPkg
-- entity		sram2
-- architecture		simModel

------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- sramPkg		------------------------------------------------------
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package sramPkg is
  type fileIOty	is (none, dump, load);

  component sram2 is
  generic (	addrWd	: integer range 2 to 16	:= 8;	-- #address bits
		dataWd	: integer range 2 to 32	:= 8;	-- #data    bits
		fileId	: string		:= "sram.dat"); -- filename
  port (	nCS	: in    std_logic;		-- not Chip   Select
			nWE	: in    std_logic;		-- not Write  Enable
	        addr	: in    std_logic_vector(addrWd-1 downto 0);
	        dataIn	: in	std_logic_vector(dataWd-1 downto 0);
	        dataOut	: out	std_logic_vector(dataWd-1 downto 0);
	        fileIO	: in	fileIOty	:= none);
  end component sram2;
end package sramPkg;

------------------------------------------------------------------------------
-- sram			------------------------------------------------------
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;
use work.sramPkg.all;

entity sram2 is
generic (addrWd	: integer range 2 to 16	:= 8;	-- #address bits
		dataWd	: integer range 2 to 32	:= 8;	-- #data bits
		fileId	: string		:= "sram.dat"); -- filename
port (		nCS	: in    std_logic;		-- not Chip Select
			nWE	: in    std_logic;		-- not Write Enable
	        addr	: in    std_logic_vector(addrWd-1 downto 0);
	        dataIn	: in	std_logic_vector(dataWd-1 downto 0);
	        dataOut	: out	std_logic_vector(dataWd-1 downto 0);
	        fileIO	: in	fileIOty	:= none);
end entity sram2;

-- sram(simModel)	------------------------------------------------------
------------------------------------------------------------------------------
architecture simModel of sram2 is
begin

  -- sram		simulation model
  ----------------------------------------------------------------------------
  sramP: process (nCS, nWE, addr, dataIn, fileIO) is
    constant	addrHi		: natural	:= (2**addrWd)-1;

    subtype	sramEleTy	is std_logic_vector(dataWd-1 downto 0);
    type	sramMemTy	is array (0 to addrHi) of sramEleTy; -- 256x32 speicher

    variable	sramMem		:  sramMemTy;		-- RAM content

    file	ioFile		: text;			-- used for file I/O
    variable	ioLine		: line;			--
    variable	ioStat		: file_open_status;	--
    variable	rdStat		: boolean;		--
    variable	ioAddr		: integer range sramMem'range; 
    variable	ioData		: std_logic_vector(dataWd-1 downto 0);
  begin
	
    -- fileIO	dump/load the SRAM contents into/from file
    --------------------------------------------------------------------------
    if fileIO'event then
      	
		if fileIO = dump then	--  dump sramData	----------------------
			file_open(ioStat, ioFile, fileID, write_mode);
			assert ioStat = open_ok report "SRAM - dump: error opening data file" severity error;

			for dAddr in sramMem'range loop
				write(ioLine, dAddr);				-- format line:
				write(ioLine, ' ');				--   <addr> <data>
				write(ioLine, std_logic_vector(sramMem(dAddr)));
				writeline(ioFile, ioLine);			-- write line
			end loop;
			file_close(ioFile);

		elsif fileIO = load then	--  load sramData	----------------------
			file_open(ioStat, ioFile, fileID, read_mode);
			report fileID;
			assert ioStat = open_ok report "SRAM - load: error opening data file" severity error;
			while not endfile(ioFile) loop
				readline(ioFile, ioLine);			-- read line
				read(ioLine, ioAddr, rdStat);			-- read <addr>
				-- report "Addresse: " & integer'image(ioAddr);
				if rdStat then				--      <data>
					read(ioLine, ioData, rdStat);
					-- report "DataIN: " & integer'image(to_integer(unsigned(ioData)));
				end if;
				if rdStat then
					sramMem(ioAddr) := ioData;
				else
					report "SRAM - load: format error in data file"
					severity error;
				end if;
			end loop;

			file_close(ioFile);
      	end if;	-- fileIO = ...
    end if;	-- fileIO'event

    -- consistency checks: inputs without X, no timing!
    ------------------------------------------------------------------------
    if nCS'event  then	assert not Is_X(nCS)
			  report "SRAM: nCS - X value"
			  severity warning;
    end if;

    if nWE'event  then	assert not Is_X(nWE)
			  report "SRAM: nWE - X value"
			  severity warning;
    end if;

    if addr'event then	assert not Is_X(addr)
			  report "SRAM: addr - X value"
			  severity warning;
    end if;

--    if dataIn'event then	assert not Is_X(dataIn)
--			  report "SRAM: dataIn - X value"
--			  severity warning;
--    end if;

    -- here starts the real work...
    ------------------------------------------------------------------------
    if nCS = '0'	then				-- chip select
      if nWE = '0'	then				-- + write cycle
		sramMem(to_integer(unsigned(addr))) := dataIn;
		-- dataOut <= dataIn;

		-- dump (Store) the data
		file_open(ioStat, ioFile, fileID, write_mode);
		assert ioStat = open_ok report "SRAM - dump: error opening data file" severity error;

		for dAddr in sramMem'range loop
			write(ioLine, dAddr);				-- format line:
			write(ioLine, ' ');				--   <addr> <data>
			write(ioLine, std_logic_vector(sramMem(dAddr)));
			writeline(ioFile, ioLine);			-- write line
		end loop;
		file_close(ioFile);

      else						-- + read cycle
	  -- report "The data out " & to_string(dataIn);
		dataOut <= sramMem(to_integer(unsigned(addr)));
      end if;	-- nWE = ...
    end if;	-- nCS = '0'

  end process sramP;

end architecture simModel;
------------------------------------------------------------------------------
-- sram2.vhd - end	------------------------------------------------------
