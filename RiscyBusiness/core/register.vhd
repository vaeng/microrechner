library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

use work.riscy_package.all;

entity register_file32 is port( 
    I_clk: in std_logic; -- clock
    I_rs1: in std_logic_vector(4 downto 0); -- input
    I_rs2: in std_logic_vector(4 downto 0); -- input
    I_rd: in std_logic_vector(4 downto 0); -- input
    I_data_input: in std_logic_vector(31 downto 0); -- data input from the wb stage (ALUor from the mem(e.g. through a lw instrucution)
    O_rs1_out: out std_logic_vector(31 downto 0); -- data output
    O_rs2_out: out std_logic_vector(31 downto 0); -- data output
    I_nWE   : in std_logic -- for conroll, writeEnable == 0 write otherwise read or do nothing
  );
end register_file32;

architecture behavioral of register_file32 is
    type registerFile is array(31 downto 0) of std_logic_vector(31 downto 0); -- somit 32x32 Registerbank
    signal registers : registerFile := (others => x"00000000");
  begin

    regFile: process (I_clk) is
    begin
      if rising_edge(I_clk) then
        -- Read A and B before bypass
        O_rs1_out <= registers(to_integer(unsigned(I_rs1)));
        O_rs2_out <= registers(to_integer(unsigned(I_rs2)));
        
        -- Write and bypass
        if I_nWE = '0' then
          I_registers(to_integer(unsigned(I_rd))) <= I_data_input;  -- Write
          -- if rs1 = rd then  -- Bypass for read rs2
          --   rs1_out <= data_input;
          -- end if;
          -- if rs1 = rd then  -- Bypass for read rs1
          --   rs2_out <= data_input;
          -- end if;
        end if;
      end if;
    end process;
  end behavioral;