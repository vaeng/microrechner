library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

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
   signal sel_opcode : opcode := (others => '0');

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

  test_proc1 : process is
  begin
    -- test overflow
    a <= x"00000123";
    b <= x"ffffffff";
    sel_f <= F_ADDI;
    -- sel_ff <= "0000000";
    sel_opcode <= OP_REG;
    wait for 20 ns; -- addi t0, t0, 0xfff; old t0 = 0x123; new t0 = 0x122 (subtract 1)

    -- test overflow
    a <= x"00000001";
    b <= x"00000000";
    sel_f <= F_SUB;
    sel_ff <= "0100000";
    sel_opcode <= OP_REG;
    wait for 20 ns;
    
    -- test leftshift
    a <= x"00000001"; -- erwartet dann ...010
    b <= x"00000001";
    sel_f <= F_SLL;
    sel_ff <= "0000000";
    sel_opcode <= OP_REG;
    wait for 20 ns;

    -- test store
    a <= x"00000001"; -- rs1
    b <= x"10000000"; -- imm_b --> 12bits sign extenden to 31bits
    sel_f <= F_SW;
    -- sel_ff <= x"11000000"; -- other sel_ff <- is dat richtig?, ne sw hat kein sel_ff
    sel_opcode <= OP_STORE; -- alu_out == rs2
    wait for 20 ns;

    -- test load 
    a <= x"00000001";
    b <= x"10000000";
    sel_f <= F_LW;
    -- sel_ff <= x"11000000"; --other sel_ff also nicht 01 oder 00 <- is dat richtig?
    sel_opcode <= OP_LOAD;
    wait for 20 ns;

    wait;
  end process test_proc1;

end architecture behave;