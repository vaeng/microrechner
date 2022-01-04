library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.riscy_package.all;

entity alu_entity is
  port (
    signal val_a : in bit_32; 
    signal val_b : in bit_32; 
    signal alu_sel_f  : in func_3;
    signal alu_sel_ff  : in func_7;
    signal alu_out : out bit_32;
    signal sel_opcode : in opcode
  );
end alu_entity;

architecture behah of alu_entity is 

begin

    process(val_a, val_b, alu_sel_f, alu_sel_ff, sel_opcode, alu_out) -- val_a := value of rs1; val_b := value of rs2; alu_out := value of rd
      alias lower_bits is val_b(4 downto 0); -- used also for "lower 5 bits of the I-immediate field"
      begin
        case(sel_opcode) is
            when OP_REG =>
                case(alu_sel_ff) is
                    when "0000000" => -- operations "0000000" class
                        if alu_sel_f = F_ADD then alu_out <=  std_logic_vector(signed(val_a) + signed(val_b)); end if;
                        if alu_sel_f = F_SLL then alu_out <= std_logic_vector(signed(val_a) sll to_integer(signed(lower_bits))); end if;
                        if alu_sel_f = F_SRL then  alu_out <= std_logic_vector(signed(val_a) srl to_integer(signed(lower_bits))); end if;
                        if alu_sel_f = F_XOR then  alu_out <= val_a xor val_b; end if;
                        if alu_sel_f = F_OR  then alu_out <= val_a or val_b; end if;
                        if alu_sel_f = F_AND then  alu_out <= val_a and val_b; end if;
                        if alu_sel_f = F_SLT then  -- set less then writing 1 to rd if rs1 < rs2, 0 otherwise.
                            if (signed(val_a) < signed(val_b)) then 
                                alu_out <= x"00000001"; 
                            else
                                alu_out <= x"00000000";  
                            end if;
                        end if;
                        if alu_sel_f = F_SLTU then -- SLTU rd, x0, rs2 sets rd to 1 if rs2 is not equal to zero, otherwise sets rd to zero
                            if (unsigned(val_a) < unsigned(val_b)) then
                                alu_out <= x"00000001";
                            else
                                alu_out <= x"00000000";
                            end if;
                        end if;
                        if alu_sel_f = F_SLL then alu_out <= std_logic_vector(signed(val_a) sll to_integer(signed(lower_bits))); end if;
                        if alu_sel_f = F_SRL then alu_out <= std_logic_vector(signed(val_a) srl to_integer(signed(lower_bits))); end if;
                        
                    when "0100000" => -- operations "0100000" class
                        if alu_sel_f = F_SUB then alu_out <= std_logic_vector(signed(val_b) - signed(val_a)); end if;
                        if alu_sel_f = F_SRA then alu_out <= std_logic_vector(signed(val_a) sra to_integer(signed(lower_bits))); end if;
                    
                    when others => alu_out <= x"00000000";
                        
                end case ;
            
            when OP_IMM => 
                case( alu_sel_ff ) is
                    when "0000000" =>
                        if alu_sel_f = F_SLLI then alu_out <= std_logic_vector(signed(val_a) sll to_integer(signed(lower_bits))); end if;
                        if alu_sel_f = F_SRLI then alu_out <= std_logic_vector(signed(val_a) srl to_integer(signed(lower_bits))); end if;
                
                    when "0100000" =>
                        if alu_sel_f = F_SRAI then alu_out <= std_logic_vector(signed(val_a) sra to_integer(signed(lower_bits))); end if;

                    when others => 
                        if alu_sel_f = F_ANDI then alu_out <= val_a and val_b; end if;
                        if alu_sel_f = F_ORI then alu_out <= val_a or val_b; end if;
                        if alu_sel_f = F_XORI then alu_out <= val_a xor val_b; end if;
                        if alu_sel_f = F_SLTIU then 
                            if(unsigned(val_a) < unsigned(val_b)) then
                                alu_out <= x"00000001"; 
                            else 
                                alu_out <= x"00000000";
                            end if;
                        end if;
                        if alu_sel_f = F_SLTI then
                            if (signed(val_a) < signed(val_b)) then
                                alu_out <= x"00000001"; 
                            else 
                                alu_out <= x"00000000";
                            end if;
                        end if;
                        if alu_sel_f = F_ADDI then alu_out <= std_logic_vector(signed(val_a) + signed(val_b)); end if;
                end case;

            when OP_STORE =>
                if alu_sel_f = F_SW then alu_out <= std_logic_vector(signed(val_a) + signed(val_b)); end if;
            when OP_LOAD =>
                if alu_sel_f = F_LW then alu_out <= std_logic_vector(signed(val_a) + signed(val_b)); end if;
            when OP_JAL | OP_JALR => alu_out <= std_logic_vector(signed(val_a) + signed(val_b)); -- val_a == PC, val_b == 12bit to 32 bit sign extended

            when others => alu_out <= x"00000000";

        end case;       
             
      end process ;

end behah ; 



