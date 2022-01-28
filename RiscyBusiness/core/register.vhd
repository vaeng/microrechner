library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.riscy_package.all;

entity register_file32 is 
port( 
    I_clk: in std_logic; -- clock
    I_rs1: in std_logic_vector(4 downto 0); -- input
    I_rs2: in std_logic_vector(4 downto 0); -- input
    I_rd: in std_logic_vector(4 downto 0); -- input
    I_rd2: in std_logic_vector(4 downto 0); -- input
    I_data_input: in std_logic_vector(31 downto 0); -- data input from Alu
    I_data_input2: in std_logic_vector(31 downto 0); -- data input from D_RAM
    sel_opcode: in opcode;
    sel_opcode_lw: in opcode;
    O_rs1_out: out std_logic_vector(31 downto 0); -- data output
    O_rs2_out: out std_logic_vector(31 downto 0); -- data output
    I_nWE   : in std_logic; -- for conroll, writeEnable == 0 write otherwise read or do nothing
    I_nWE2 : in std_logic
  );
end register_file32;

architecture behavioral of register_file32 is
    type registerFile is array(31 downto 0) of std_logic_vector(31 downto 0); -- somit 32x32 Registerbank
    signal registers : registerFile := (others => x"00000000");
    signal out_a : std_logic_vector(31 downto 0);
    signal out_b : std_logic_vector(31 downto 0);
  begin

    regFile: process (I_clk, I_rs1, I_rs2) is
    begin

      if rising_edge(I_clk) then        
        
        if I_nWE2 = '0' and sel_opcode_lw = OP_LOAD then
          registers(to_integer(unsigned(I_rd2))) <= I_data_input2;  -- Write
        end if;

        if I_nWE = '0' and (sel_opcode = OP_REG or sel_opcode = OP_IMM) then
          registers(to_integer(unsigned(I_rd))) <= I_data_input;
        end if;

      end if;

      -- read with no dependency
      out_a <= registers(to_integer(unsigned(I_rs1)));
      out_b <= registers(to_integer(unsigned(I_rs2))); -- zuweisung (S.14 vhdlcrash) --> Zuweisung ein Takt spaeter

      -- Write and bypassss with dependency
      if I_nWE = '0' and (sel_opcode = OP_REG or sel_opcode = OP_IMM) then
        if I_rs1 = I_rd then  -- Bypass for read rs1
          out_a <= I_data_input;
        end if;
        if I_rs2 = I_rd then  -- Bypass for read rs2
          out_b <= I_data_input;
        end if;
      end if;

    end process;

    O_rs1_out <= out_a;
    O_rs2_out <= out_b;

  end behavioral;