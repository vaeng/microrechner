library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;
use ieee.textio.all;

entity riscy is

    port(reset, clk : in std_logic;
    read_data_bus : in std_logic_vector(31 downto 0); -- bei rising_clock daten holen aus dem RAM in die Register des CPUs
    write_data_bus : out std_logic_vector(31 downto 0);
    adress_bus : out std_logic_vector(31 downto 0)
    instruction_bus : in std_logic_vector(31 downto 0)); -- ausgang eines Registers 
end entity riscy;

architecture behavioral of riscy is

    begin

        alu : process()
        begin
            
        end process ; 

        register_file : process()
        begin
            
        end process ; 

        pipeline_stufe_xyz: process() -- für jede pipleinestufe
        begin

        end process ;

end;