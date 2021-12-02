library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

use work.riscy_package.all;

entity riscy is

    port(reset, clk : in std_logic;
    read_data_bus : in bit_32; -- bei rising_clock daten holen aus dem RAM in die Register des CPUs
    write_data_bus : out bit_32;
    adress_bus : out bit_32;
    instruction_data_bus : in bit_32;
    instruction_address_bus : out bit_32); -- ausgang eines Registers 
end;



architecture behavioral of riscy is
    signal alu_out : bit_32;
    signal val_a : bit_32;
    signal val_b : bit_32;
    signal alu_sel_f : func_3;
    signal alu_sel_ff : func_7;
    signal sel_opcode : opcode;

    begin
        
        -- alu_arithmetic aber man muss val_b und alu_sel_ff unterscheiden da zwei bedeutung. val_b ist sowohl lower 5bit immidiate wert vom I-type
        -- als auch wert vom register rs2. alu_sel_ff ist sowohl func7 als auch imm[11:5] vom imm[11:0] I-type field.
        -- alu_sel_f, alu_sel_ff steuersignale
      alu_arithmetic: process(val_a, val_b, alu_sel_f, alu_sel_ff, sel_opcode, alu_out) -- val_a := value of rs1; val_b := value of rs2; alu_out := value of rd
      alias lower_bits is val_b(4 downto 0); -- used also for "lower 5 bits of the I-immediate field"
      begin
        case(sel_opcode) is
            when OP_REG => 
                case(alu_sel_ff) is
                    when "0000000" => -- operations "0000000" class
                        if alu_sel_f = F_ADD then alu_out <=  val_a + val_b; end if;
                        if alu_sel_f = F_SLL then alu_out <= std_logic_vector(unsigned(val_a) sll to_integer(unsigned(lower_bits))); end if;
                        if alu_sel_f = F_SRL then  alu_out <= std_logic_vector(unsigned(val_a) srl to_integer(unsigned(lower_bits))); end if;
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
                        if alu_sel_f = F_SLL then alu_out <= std_logic_vector(unsigned(val_a) sll to_integer(unsigned(lower_bits))); end if;
                        if alu_sel_f = F_SRL then alu_out <= std_logic_vector(unsigned(val_a) srl to_integer(unsigned(lower_bits))); end if;
                        
                    when "0100000" => -- operations "0100000" class
                        if alu_sel_f = F_SUB then alu_out <= val_b - val_a; end if;
                        if alu_sel_f = F_SRA then alu_out <= std_logic_vector(unsigned(val_a) sra to_integer(unsigned(lower_bits))); end if;
                    
                    when others => alu_out <= x"00000000";
                        
                end case ;
            
            when OP_IMM => 
                case( alu_sel_ff ) is
                    when "0000000" =>
                        if alu_sel_f = F_SLLI then alu_out <= std_logic_vector(unsigned(val_a) sll to_integer(unsigned(lower_bits))); end if;
                        if alu_sel_f = F_SRLI then alu_out <= std_logic_vector(unsigned(val_a) srl to_integer(unsigned(lower_bits))); end if;
                
                    when "0100000" =>
                        if alu_sel_f = F_SRAI then alu_out <= std_logic_vector(unsigned(val_a) sra to_integer(unsigned(lower_bits))); end if;

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
                        if alu_sel_f = F_ADDI then alu_out <= val_a + val_b; end if;
                end case;

            when OP_STORE =>
                if alu_sel_f = F_SW then alu_out <= val_a + val_b; end if;
            when OP_LOAD =>
                if alu_sel_f = F_LW then alu_out <= val_a + val_b; end if;
            when 
            when others => alu_out <= x"00000000";

        end case;       
             
      end process ; 

            -- high active für die enable signale nutzen
        register_file : process
        begin
        wait; 
        end process ; 

        -- für jede pipleinestufe; jede pipline stufe trägt die kontroll signale (enable) und aktivert damit enstprechend die Funktionseinheiten.
        -- Bsp lw und sw haben func3=010 gleich, jedoch hilft der opcode (welcher mitgegeben wird) zu entscheiden ob nun in der memory stage
        -- RAM gelesen oder geschrieben wird. Somit triggert jede piplinestufe in dem eigenem stage die Funktionseinheiten (Register/Speicher).
        pipeline_stufe_xyz: process   
        begin
        wait;
        end process ;

end;
