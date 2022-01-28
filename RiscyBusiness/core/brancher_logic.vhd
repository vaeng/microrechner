library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.riscy_package.all;

entity brancher_logic is
  port (
    sel_opcode : in opcode;
    sel_f : in func_3;
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

        if sel_opcode = OP_BRANCH then 

            case(sel_f) is
            
                when F_BEQ => if signed(rs1) = signed(rs2) then -- beq
                            val <= '1'; -- if rs1==rs2 then branch else not
                            end if;
                when F_bge => if signed(rs1) >= signed(rs2) then val <= '1'; 
                            end if;
                when F_bgeu => if unsigned(rs1) >= unsigned(rs2) then -- bgeu
                            val <= '1';
                            end if;
                when F_blt =>  if signed(rs1) < signed(rs2) then -- blt
                            val <= '1';
                            end if;
                when F_bltu => if unsigned(rs1) < unsigned(rs2) then -- bltu
                            val <= '1';
                            end if; 
                when f_bne => if signed(rs1) /= signed(rs2) then -- bne
                            val <= '1';
                            end if;
                when others => val <= '0';
            end case;
        else
            val <= '0';
        end if;
    end process ; -- brancher

    branch_out <= val;
end arch ; -- arch