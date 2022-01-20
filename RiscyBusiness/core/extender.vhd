library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.riscy_package.all;

entity extender is
  port (
    sel_opcode : in opcode; -- fuer jeden stage einen neuen sel_opcode[1, 2, 3, 4, 5] erstellen, da sonst dieser überschrieben wird und nicht weitergegeben werden kann

    imm_Itype : in std_logic_vector(11 downto 0);

    imm_Utype : in std_logic_vector(19 downto 0);
    
    imm_Stype : in std_logic_vector(4 downto 0);
    imm_StypeTwo : in std_logic_vector(6 downto 0);

    imm_Btype : in std_logic;
    imm_BtypeTwo : in std_logic_vector(3 downto 0);
    imm_BtypeThree : in std_logic_vector(5 downto 0);
    imm_BtypeFour : in std_logic;

    imm_Jtype : in std_logic_vector(7 downto 0);
    imm_JtypeTwo : in std_logic;
    imm_JtypeThree : in std_logic_vector(9 downto 0);
    imm_JtypeFour : in std_logic;

    imm_O : out std_logic_vector(31 downto 0);
    clk : in std_logic
  ) ;
end extender;

architecture arch of extender is
begin

  process( sel_opcode , clk)
  variable Itype_extender : std_logic_vector(31 downto 12); -- := (others => imm_Itype(11));
  variable Utype_extender : std_logic_vector(11 downto 0); -- := (others => '0');
  variable Jtype_extender : std_logic_vector(10 downto 0); -- := (others => imm_JtypeFour);
  variable Stype_extender : std_logic_vector(31 downto 12); -- := (others => imm_StypeTwo(6));
  variable Btype_extender : std_logic_vector(31 downto 13); -- := (others => imm_BtypeFour);

  variable random1 : std_logic; -- := (others => imm_Itype(11));
  variable random2 : std_logic;
  variable random3 : std_logic;
  variable random4 : std_logic;
  variable random5 : std_logic;
  begin

    if rising_edge(clk) then
      random1 := imm_Itype(11); 
      random2 := '0';
      random3 := imm_JtypeFour;
      random4 := imm_StypeTwo(6);
      random5 := imm_BtypeFour;

      Itype_extender := (others => random1);
      Utype_extender := (others => random2);
      Jtype_extender := (others => random3);
      Stype_extender := (others => random4);
      Btype_extender := (others => random5);

      case( sel_opcode ) is
      
        when OP_IMM | OP_JALR =>
          imm_O <= Itype_extender & imm_Itype;
        when OP_AUIPC | OP_LUI =>
          imm_o <= imm_Utype & Utype_extender;
        when OP_JAL =>
          imm_o <= Jtype_extender & imm_JtypeFour & imm_Jtype & imm_JtypeTwo & imm_JtypeThree & '0';
        when OP_STORE =>
          imm_o <= Stype_extender & imm_StypeTwo & imm_Stype;
        when OP_BRANCH =>
          imm_o <= imm_BtypeFour & imm_Btype & imm_BtypeThree & imm_BtypeTwo & '0';
        when others =>
          imm_O <= x"00000000";
      
      end case ;
    end if;

  end process ;

end arch ; -- arch