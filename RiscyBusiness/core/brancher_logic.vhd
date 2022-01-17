library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.riscy_package.all;

entity brancher_logic is
  port (
    rs1: in std_logic_vector(31 downto 0);
    rs2: in std_logic_vector(31 downto 0);
    branch_out: out std_logic
    );
end brancher_logic;

architecture arch of brancher_logic is
    signal val : std_logic;
begin

    brancher : process(rs1, rs2)
    begin
        if signed(rs1) = signed(rs2) then -- beq
        	val <= '1'; -- if rs1==rs2 then branch else not
        elsif signed(rs1) >= signed(rs2) then -- bge
        	val <= '1';
        elsif unsigned(rs1) >= unsigned(rs2) then -- bgeu
        	val <= '1';
        elsif signed(rs1) < signed(rs2) then -- blt
            val <= '1';
        elsif unsigned(rs1) < unsigned(rs2) then -- bltu
            val <= '1';
        elsif signed(rs1) /= signed(rs2) then -- bne
            val <= '1';
        else
            val <= '0';
        end if;
    end process ; -- brancher

    branch_out <= val;
end arch ; -- arch