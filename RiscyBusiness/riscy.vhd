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
    signal alu_out : bit_32;
    signal val_a : bit_32
    signal val_b : bit_32
    signal alu_sel_f : func_3;
    signal alu_sel_ff : func_7;

    begin

      alu: process(val_a, val_b, alu_sel_f, alu_sel_ff, alu_out) -- val_a := value of rs1; val_b := value of rs2
      alias lower_bits is val_b(4 downto 0);
      -- alias immidiate todo

      begin
        case(alu_sel_ff) is
            when FF_operations => -- operations "0000000" class
                case(alu_sel_f) is
                    when F_ADD => alu_out <= val_a + val_b;
                    when F_SLL => alu_out <= std_logic_vector(unsigned(val_a) sll lower_bits);
                    when F_SRL => alu_out <= std_logic_vector(unsigned(val_a) srl lower_bits);
                    when F_XOR => alu_out <= val_a xor val_b;
                    when F_OR => alu_out <= val_a or val_b;
                    when F_AND => alu_out <= val_a and val_b;
                    when F_SLT => alu_out <= if val_a < val_b then alu_out <= 1; else alu_out <= 0; end if;

        -- when others => alu_out <= val_a ? val_b; 

        std_logic_vector(to_unsigned((to_integer(unsigned(A)) * to_integer(unsigned(B))),8)) ;
        when

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
