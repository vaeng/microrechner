library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

use work.riscy_package.all;

entity alu_testbench is
end alu_testbench;

architecture behave of alu_testbench is

    component alu_entity is
        port (
          signal val_a : in bit_32; 
          signal val_b : in bit_32; 
          signal alu_sel_f  : in func_3;
          signal alu_sel_ff  : in func_7;
          signal alu_out : out bit_32;
          signal sel_opcode : in opcode
        );
      end component;

    -- inputs
    signal a : bit_32 := (others => '0');
   signal b : bit_32 := (others => '0');
   signal sel_f : func_3 := (others => '0');
   signal sel_ff : func_7 := (others => '0');
   signal sel_opcode : opcode :=(others => '0');

  --Outputs
   signal alu_out : bit_32;

begin

    -- Instantiate the Unit Under Test (UUT)
   alu: alu_entity PORT MAP (
    val_a => a, 
    val_b => b, 
    alu_sel_f => sel_f,
    alu_sel_ff => sel_ff,
    alu_out => alu_out,
    sel_opcode => sel_opcode
  );

  -- test overflow
  test_proc1 : process is
  begin
    a <= x"ffffffff";
    b <= x"00000001";
    sel_f <= F_ADD;
    sel_ff <= "0000000";
    sel_opcode <= OP_REG;
    wait for 100 ns;
    wait;
  end process test_proc1;
  
  -- test underflow/negatives
  test_proc2 : process is 
  begin
    a <= x"00000000";
    b <= x"00000001";
    sel_f <= F_SUB;
    sel_ff <= "01000000";
    sel_opcode <= OP_REG;
    wait for 50 ns;
    wait;
  end process test_proc2;

  -- test leftshift
  test_proc3 : process is
  begin
    a <= "00000000000000000000000000000001"; -- erwartet dann ...010
    -- b <= -- keine value nötig: null
    sel_f <= F_SLL;
    sel_ff <= "00000000";
    sel_opcode <= OP_REG;
    wait for 25 ns;
    wait;
  end process test_proc3;

  -- test store
  test_proc4 : process is
    begin
      a <= x"00000001";
      b <= x"10000000";
      sel_f <= F_SW;
      sel_ff <= x"11000000"; --other sel_ff <- is dat richtig?
      sel_opcode <= OP_STORE;
      wait for 6 ns;
      wait;
    end process test_proc4;

    -- test load
    test_proc5 : process is
    begin
        a <= x"00000001";
        b <= x"10000000";
        sel_f <= F_LW;
        sel_ff <= x"11000000"; --other sel_ff also nicht 01 oder 00 <- is dat richtig?
        sel_opcode <= OP_LOAD;
      wait for 12 ns;
      wait;
    end process test_proc5;
end architecture behave;