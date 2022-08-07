library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.riscy_package.all;


entity alu_entity is
  port (
    val_a : in bit_32; 
    val_b : in bit_32; 
    alu_sel_f  : in func_3;
    alu_sel_ff  : in func_7;
    alu_out : out bit_32;
    sel_opcode : in opcode
  );
end alu_entity;

architecture behah of alu_entity is 

begin

    process(val_a, val_b, alu_sel_f, alu_sel_ff, sel_opcode) -- val_a := value of rs1; val_b := value of rs2; alu_out := value of rd
      alias lower_bits is val_b(4 downto 0); -- used also for "lower 5 bits of the I-immediate field"
      begin
        case(sel_opcode) is
            when OP_REG =>
                case(alu_sel_ff) is
                    when "0000000" => -- operations "0000000" class
                        if alu_sel_f = F_ADD then alu_out <=  std_logic_vector(signed(val_a) + signed(val_b)); end if;
                        if alu_sel_f = F_SLL then alu_out <= std_logic_vector(signed(val_a) sll to_integer(unsigned(lower_bits))); end if;
                        if alu_sel_f = F_SRL then  alu_out <= std_logic_vector(signed(val_a) srl to_integer(unsigned(lower_bits))); end if;
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
                        if alu_sel_f = F_SLL then alu_out <= std_logic_vector(signed(val_a) sll to_integer(unsigned(lower_bits))); end if;
                        if alu_sel_f = F_SRL then alu_out <= std_logic_vector(signed(val_a) srl to_integer(unsigned(lower_bits))); end if;
                        if alu_sel_f = F_MULH then alu_out <= std_logic_vector(signed(val_a) * signed(val_b)); end if;
                        if alu_sel_f = F_MULHU then alu_out <= std_logic_vector(unsigned(val_a) * unsigned(val_b)); end if;
                        -- if alu_sel_f = F_MULHSU then alu_out <= std_logic_vector(signed(val_a) * unsigned(val_b)); end if;
                        if alu_sel_f = F_DIV then assert to_integer(unsigned(val_b)) > 0 report "Division by zero"; alu_out <= std_logic_vector(signed(val_a) / signed(val_b)); end if;
                        if alu_sel_f = F_DIVU then assert to_integer(unsigned(val_b)) > 0 report "Division by zero"; alu_out <= std_logic_vector(unsigned(val_a) / unsigned(val_b)); end if;
                        if alu_sel_f = F_REM then assert to_integer(unsigned(val_b)) > 0 report "Division by zero"; alu_out <= std_logic_vector(signed(val_a) rem signed(val_b)); end if;
                        if alu_sel_f = F_REMU then assert to_integer(unsigned(val_b)) > 0 report "Division by zero"; alu_out <= std_logic_vector(unsigned(val_a) rem unsigned(val_b)); end if;
                        
                    when "0100000" => -- operations "0100000" class
                        if alu_sel_f = F_SUB then alu_out <= std_logic_vector(signed(val_b) - signed(val_a)); end if;
                        if alu_sel_f = F_SRA then alu_out <= std_logic_vector(signed(val_a) sra to_integer(unsigned(lower_bits))); end if;                    
                    
                    when others => alu_out <= x"00000000";
                        
                end case ;
            
            when OP_IMM => 
                case( alu_sel_ff ) is
                    when "0000000" =>
                        if alu_sel_f = F_SLLI then alu_out <= std_logic_vector(signed(val_a) sll to_integer(unsigned(lower_bits))); end if;
                        if alu_sel_f = F_SRLI then alu_out <= std_logic_vector(signed(val_a) srl to_integer(unsigned(lower_bits))); end if;
                
                    when "0100000" =>
                        if alu_sel_f = F_SRAI then alu_out <= std_logic_vector(signed(val_a) sra to_integer(unsigned(lower_bits))); end if;

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

            -- val_a == PC, val_b == 12bit to 32 bit sign extended imm
            when OP_JAL | OP_JALR | OP_BRANCH => alu_out <= std_logic_vector(signed(val_a) + signed(val_b));

            when others => alu_out <= x"00000000";

        end case;       
            
      end process ;

end behah ; 



