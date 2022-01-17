library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.riscy_package.all;


entity addressdecoder is

  port (
    instruction: in std_logic_vector(31 downto 0);  -- instruction fetched form the memory
    alu_sel_f : out std_logic_vector(2 downto 0);
    alu_sel_ff : out std_logic_vector(6 downto 0);
    sel_opcode : out opcode; -- fuer jeden stage einen neuen sel_opcode[1, 2, 3, 4, 5] erstellen, da sonst dieser überschrieben wird und nicht weitergegeben werden kann
    rd : out std_logic_vector(4 downto 0);
    rs1 : out std_logic_vector(4 downto 0);
    rs2 : out std_logic_vector(4 downto 0);

    imm_Itype : out std_logic_vector(11 downto 0);
    imm_Utype : out std_logic_vector(20 downto 0);
    
    imm_Stype : out std_logic_vector(5 downto 0);
    
    imm_StypeTwo : out std_logic_vector(7 downto 0);

    imm_Btype : out std_logic;
    imm_BtypeTwo : out std_logic_vector(3 downto 0);
    imm_BtypeThree : out std_logic_vector(5 downto 0);
    imm_BtypeFour : out std_logic;

    imm_Jtype : out std_logic_vector(7 downto 0);
    imm_JtypeTwo : out std_logic;
    imm_JtypeThree : out std_logic_vector(9 downto 0);
    imm_JtypeFour : out std_logic;

    I_nWE : out std_logic -- not write Enable; control signal also for jmp, beq, .... 
  );

end addressdecoder;

architecture behavior of addressdecoder is

begin

    address_decoder : process(instruction) -- instruction register
    begin
        if instruction(6 downto 0) = OP_REG then -- lesen des bytecodes (bits) von rechts nach links
            sel_opcode <= instruction(6 downto 0);
            rd <= instruction(11 downto 7);
            alu_sel_f <= instruction(14 downto 12);
            rs1 <= instruction(19 downto 15);
            rs2 <= instruction(24 downto 20);
            alu_sel_ff <= instruction(31 downto 25);
            I_nWE <= '0';
        elsif instruction(6 downto 0) = OP_IMM then
            sel_opcode <= instruction(6 downto 0);
            rd <= instruction(11 downto 7);
            alu_sel_f <= instruction(14 downto 12);
            rs1 <= instruction(19 downto 15);
            imm_Itype <= instruction(31 downto 20);
            I_nWE <= '0';
        elsif instruction(6 downto 0) = OP_LUI or instruction(6 downto 0) = OP_AUIPC then
            sel_opcode <= instruction(6 downto 0);
            rd <= instruction(11 downto 7);
            imm_Utype <= instruction(31 downto 12);
            I_nWE <= '0';
        elsif instruction(6 downto 0) = OP_LOAD then
            sel_opcode <= instruction(6 downto 0);
            rd <= instruction(11 downto 7);
            alu_sel_f <= instruction(14 downto 12);
            rs1 <= instruction(19 downto 15);
            imm_Itype <= instruction(31 downto 20);
            I_nWE <= '0';
        elsif instruction(6 downto 0) = OP_STORE then
            sel_opcode <= instruction(6 downto 0);
            imm_Stype <= instruction(11 downto 7);
            alu_sel_f <= instruction(14 downto 12);
            rs1 <= instruction(19 downto 15);
            rs2 <= instruction(24 downto 20);
            imm_StypeTwo <= instruction(31 downto 25);
        elsif instruction(6 downto 0) = OP_BRANCH then
            sel_opcode <= instruction(6 downto 0);
            imm_Btype <= instruction(7);
            imm_BtypeTwo <= instruction(11 downto 8);
            alu_sel_f <= instruction(14 downto 12);
            rs1 <= instruction(19 downto 15);
            rs2 <= instruction(24 downto 20);
            imm_BtypeThree <= instruction(30 downto 25);
            imm_BtypeFour <= instruction(31);
        elsif instruction(6 downto 0) = OP_JAL then
            sel_opcode <= instruction(6 downto 0);
            rd <= instruction(11 downto 7);
            imm_Jtype <= instruction(19 downto 12);
            imm_JtypeTwo <= instruction(20);
            imm_JtypeThree <= instruction(30 downto 21);
            imm_JtypeFour <= instruction(31);
            I_nWE <= '0';
        elsif instruction(6 downto 0) = OP_JALR then
            sel_opcode <= instruction(6 downto 0);
            rd <= instruction(11 downto 7);
            alu_sel_f <= instruction(14 downto 12);
            rs1 <= instruction(19 downto 15);
            imm_Itype <= instruction(31 downto 20);
            I_nWE <= '0';
        end if;
    end process ; -- address_decoder

end behavior ; -- behavior