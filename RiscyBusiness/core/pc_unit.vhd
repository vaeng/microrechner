library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.riscy_package.all;


entity pc_unit is
  port (
      clk : in std_logic;
      I_Addr : in std_logic_vector(31 downto 0); -- WB oder PC + 4 consider MUX from
      nRst : in std_logic;
      O_Addr : out std_logic_vector(31 downto 0); -- InsMEM
      mux_control_target : in std_logic
  ) ;
end pc_unit;

architecture arch of pc_unit is
    signal current_pc : std_logic_vector(31 downto 0) := x"00000000"; -- default
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if nRSt = '0' then
                current_pc <= x"00000000"; -- reset signal "low active"
            elsif mux_control_target = '1' then
                current_pc <= std_logic_vector(unsigned(I_Addr)); -- from external input; WB or from not integer pc
            else 
                current_pc <= std_logic_vector(unsigned(current_pc) + 4); -- increment (also should work for lw)
            end if;
        end if;
        
    end process; 

    O_Addr <= current_pc;

end arch ; -- arch