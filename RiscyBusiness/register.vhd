library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.riscy_package.all;

entity register_file32 is port( 
    clk: in std_logic; -- clock
    rs1: in std_logic_vector(4 downto 0); -- input
    rs2: in std_logic_vector(4 downto 0); -- input
    rd: in std_logic_vector(4 downto 0); -- input
    data_input: in std_logic_vector(31 downto 0); -- data input from the wb stage or from the mem(e.g. through a lw instrucution)
    rs1_out: out std_logic_vector(31 downto 0); -- data output
    rs2_out: out std_logic_vector(31 downto 0); -- data output
    writeEnable   : in std_logic -- for conroll, writeEnable == 1 write otherwise read or do nothing
  );
end register_file32;

architecture behavioral of register_file32 is
    type registerFile is array(31 downto 0) of std_logic_vector(31 downto 0); -- somit 32x32 Registerbank
    signal registers : registerFile;
  begin

    regFile: process (clk) is
    begin
      if rising_edge(clk) then
        -- Read A and B before bypass
        rs1_out <= registers(to_integer(unsigned(rs1)));
        rs2_out <= registers(to_integer(unsigned(rs2)));
        -- Write and bypass
        if writeEnable = '1' then
          registers(to_integer(unsigned(rd))) <= data_input;  -- Write
          if rs1 = rd then  -- Bypass for read rs2
            rs1_out <= data_input;
          end if;
          if rs1 = rd then  -- Bypass for read rs1
            rs2_out <= data_input;
          end if;
        end if;
      end if;
    end process;
  end behavioral;