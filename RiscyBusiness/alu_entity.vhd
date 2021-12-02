library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

use work.riscy_package.all;

entity alu_entity is
  port (
    signal val_a : in bit_32; 
    signal val_b : in bit_32; 
    signal alu_sel_f  : in func_3;
    signal alu_sel_ff  : in func_7s;
    signal alu_out : out bit_32;
  );
end alu_entity;

architecture behah of alu_entity is

    process(val_a, val_b, alu_sel_f, alu_sel_ff, alu_out) -- val_a := value of rs1; val_b := value of rs2; alu_out := value of rd
      alias lower_bits is val_b(4 downto 0); -- used also for "lower 5 bits of the I-immediate field"
      begin
        case(alu_sel_ff) is
            when "0000000" => -- operations "0000000" class
                if F_ADD = alu_sel_f then alu_out <= val_a + val_b; end if;
                if F_SLL = alu_sel_f then alu_out <= std_logic_vector(unsigned(val_a) sll to_integer(unsigned(lower_bits))); end if;
                if alu_sel_f = F_SRL then alu_out <= std_logic_vector(unsigned(val_a) srl to_integer(unsigned(lower_bits))); end if;
                if alu_sel_f = F_XOR then alu_out <= val_a xor val_b; end if;
                if alu_sel_f = F_OR  then alu_out <= val_a or val_b; end if;
                if alu_sel_f = F_AND then alu_out <= val_a and val_b; end if;
                if alu_sel_f = F_SLT then  -- set less then writing 1 to rd if rs1 < rs2, 0 otherwise.
                    if (signed(val_a) < signed(val_b)) then 
                        alu_out <= x"00000001"; 
                    else 
                        alu_out <= x"00000000";  
                    end if;
                end if;
                if alu_sel_f = F_SLT then -- SLTU rd, x0, rs2 sets rd to 1 if rs2 is not equal to zero, otherwise sets rd to zero
                    if (unsigned(val_a) /= unsigned(val_b)) then 
                        alu_out <= x"00000001"; 
                    else 
                        alu_out <= x"00000000";
                    end if;
                end if;
                if alu_sel_f = F_SLL then alu_out <= std_logic_vector(unsigned(val_a) sll to_integer(unsigned(lower_bits))); end if;
                if alu_sel_f = F_SRL then alu_out <= std_logic_vector(unsigned(val_a) srl to_integer(unsigned(lower_bits))); end if;
            when "0100000" => -- operations "0100000" class
                if alu_sel_f = F_SUB then alu_out <= val_b - val_a; end if;
                if alu_sel_f = F_SRA then alu_out <= std_logic_vector(unsigned(val_a) sra to_integer(unsigned(lower_bits))); end if;
                if alu_sel_f = F_SRAI then alu_out <= std_logic_vector(unsigned(val_a) sra to_integer(unsigned(lower_bits))); end if;
            when others => alu_out <= val_a + val_b; --maybe for nop
        end case;                          
             
      end process ; 

begin

end behah ; -- behah