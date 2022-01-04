library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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
    
    -- type registerFile is array(0 to 31) of std_logic_vector(31 downto 0);

    --signal to and out of the alu
    signal alu_out : bit_32;
    signal val_a : bit_32;
    signal val_b : bit_32;


    --decode signals to the registerfile
    signal ins_mem : bit_32; -- instruction fetched form the memory
    signal alu_sel_f : func_3;
    signal alu_sel_ff : func_7;
    signal sel_opcode : opcode; -- fuer jeden stage einen neuen sel_opcode[1, 2, 3, 4, 5] erstellen, da sonst dieser überschrieben wird und nicht weitergegeben werden kann
    signal rd_signal : bit_32(4 downto 0);
    signal r1_signal : bit_32(4 downto 0);
    signal r2_signal : bit_32(4 downto 0);

    signal imm_signal_Itype : std_logic_vector(11 downto 0);
    
    signal imm_signal_Utype : std_logic_vector(20 downto 0);
    
    signal imm_signal_Stype : std_logic_vector(5 downto 0);
    signal imm_signal_StypeTwo : std_logic_vector(7 downto 0);

    signal imm_signal_Btype : std_logic;
    signal imm_signal_BtypeTwo : std_logic_vector(3 downto 0);
    signal imm_signal_BtypeThree : std_logic_vector(5 downto 0);
    signal imm_signal_BtypeFour : std_logic;

    signal imm_signal_Jtype : std_logic_vector(7 downto 0);
    signal imm_signal_JtypeTwo : std_logic;
    signal imm_signal_JtypeThree : std_logic_vector(9 downto 0);
    signal imm_signal_JtypeFour : std_logic;

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
             
      end process;

      address_decoder : process(ins_mem) -- instruction register
      begin
        if ins_mem(6 downto 0) = OP_REG then
            sel_opcode <= ins_mem(6 downto 0);
            rd_signal <= ins_mem(11 downto 7);
            alu_sel_f <= ins_mem(14 downto 12);
            r1_signal <= ins_mem(19 downto 15);
            r2_signal <= ins_mem(24 downto 20);
            alu_sel_ff<= ins_mem(31 downto 25);
        elsif ins_mem(6 downto 0) = OP_IMM then
            sel_opcode <= ins_mem(6 downto 0);
            rd_signal <= ins_mem(11 downto 7);
            alu_sel_f <= ins_mem(14 downto 12);
            r1_signal <= ins_mem(19 downto 15);
            imm_signal_Itype <= ins_mem(31 downto 20);
        elsif ins_mem(6 downto 0) = OP_LUI or ins_mem(6 downto 0) = OP_AUIPC then
            sel_opcode <= ins_mem(6 downto 0);
            rd_signal <= ins_mem(11 downto 7);
            imm_signal_Utype <= ins_mem(31 downto 12);
        elsif ins_mem(6 downto 0) = OP_LOAD then
            sel_opcode <= ins_mem(6 downto 0);
            rd_signal <= ins_mem(11 downto 7);
            alu_sel_f <= ins_mem(14 downto 12);
            r1_signal <= ins_mem(19 downto 15);
            imm_signal_Itype <= ins_mem(31 downto 20);
        elsif ins_mem(6 downto 0) = OP_STORE then
            sel_opcode <= ins_mem(6 downto 0);
            imm_signal_Stype <= ins_mem(11 downto 7);
            alu_sel_f <= ins_mem(14 downto 12);
            r1_signal <= ins_mem(19 downto 15);
            r2_signal <= ins_mem(24 downto 20);
            imm_signal_StypeTwo <= ins_mem(31 downto 25);
        elsif ins_mem(6 downto 0) = OP_BRANCH then
            sel_opcode <= ins_mem(6 downto 0);
            imm_signal_Btype <= ins_mem(7);
            imm_signal_BtypeTwo <= ins_mem(11 downto 8);
            alu_sel_f <= ins_mem(14 downto 12);
            r1_signal <= ins_mem(19 downto 15);
            r2_signal <= ins_mem(24 downto 20);
            imm_signal_BtypeThree <= ins_mem(30 downto 25);
            imm_signal_BtypeFour <= ins_mem(31);
        elsif ins_mem(6 downto 0) = OP_JAL then
            sel_opcode <= ins_mem(6 downto 0);
            rd_signal <= ins_mem(11 downto 7);
            imm_signal_Jtype <= ins_mem(19 downto 12);
            imm_signal_JtypeTwo <= ins_mem(20);
            imm_signal_JtypeThree <= ins_mem(30 downto 21);
            imm_signal_JtypeFour <= ins_mem(31);
        elsif ins_mem(6 downto 0) = OP_JALR then
            sel_opcode <= ins_mem(6 downto 0);
            rd_signal <= ins_mem(11 downto 7);
            alu_sel_f <= ins_mem(14 downto 12);
            r1_signal <= ins_mem(19 downto 15);
            imm_signal_Itype <= ins_mem(31 downto 20);
        end if;
          
      end process ; -- address_decoder


    -- high active für die enable signale nutzen
    register_file : process(val_a, val_b) -- val_a, val_b are the outputs
    begin
    end process ;

    -- high active für die enable signale nutzen
    pipleinestage_IF_ID : process(sel_opcode, rd_signal) -- val_a, val_b are the outputs
    begin
    end process ;

    pipleinestage_ID_EX : process(val_a, val_b) -- val_a, val_b are the outputs
    begin
    end process ;

    pipleinestage_EX_MEM : process(val_a, val_b) -- val_a, val_b are the outputs
    begin
    end process ;

    -- - Instruction fetch = F
    -- -     IF/ID
    -- entity IF_ID is
    --    port(
    --    clk, reset : in std_logic,
    
    --    );
    -- end entity if_id ;
    
    -- --- Instruction decode/ register read = D
    --    --- ID/EX
    -- entity ID_EX is
    --    port(
    --    clk, reset : in std_logic,
    
    --    );
    -- end entity ID_EX ;

    -- --- ALU Exec = X
    --    --- EX/MEM
    -- entity EX_MEM is
    --    port(
    --    clk, reset : in std_logic,

    --    );
    -- end entity EX_MEM ;

    -- --- Memory Access = M
    --    --- MEM/WB 
    -- entity MEM_WB is
    --    port(
    --    clk, reset : in std_logic,

    --    );
    -- end entity MEM_WB ;

    -- - Write Back = W
    
end;
