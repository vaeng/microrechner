library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;

use work.riscy_package.all;

entity riscy is

    port(reset, clk : in bit_32;
    read_data_bus : in bit_32; -- bei rising_clock daten holen aus dem RAM in die Register des CPUs
    write_data_bus : out bit_32;
    adress_bus : out bit_32;
    instruction_bus : in bit_32); -- ausgang eines Registers 
end;

architecture behavioral of riscy is
    signal 
    begin

      alu: process
      begin
      wait;
      end process ; 

        register_file : process
        begin
        wait; 
        end process ; 

        pipeline_stufe_xyz: process -- für jede pipleinestufe
        begin
          wait;
        end process ;

end;
