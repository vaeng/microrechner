library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all; -- require for writing/reading std_logic etc.

entity register_testbench is
end register_testbench;

architecture arch of register_testbench is

    component register_file32 is port( 
        I_clk: in std_logic; -- clock
        I_rs1: in std_logic_vector(4 downto 0); -- input
        I_rs2: in std_logic_vector(4 downto 0); -- input
        I_rd: in std_logic_vector(4 downto 0); -- input
        I_data_input: in std_logic_vector(31 downto 0); -- data input from the wb stage (ALUor from the mem(e.g. through a lw instrucution)
        O_rs1_out: out std_logic_vector(31 downto 0); -- data output
        O_rs2_out: out std_logic_vector(31 downto 0); -- data output
        I_nWE   : in std_logic -- for conroll, writeEnable == 0 write otherwise read or do nothing
  );
    end component register_file32;

    signal clk: std_logic;
    signal rs1: std_logic_vector(4 downto 0);
    signal rs2: std_logic_vector(4 downto 0);
    signal rd: std_logic_vector(4 downto 0);
    signal data_input: std_logic_vector(31 downto 0);
    signal rs1_out: std_logic_vector(31 downto 0);
    signal rs2_out: std_logic_vector(31 downto 0);
    signal nWE: std_logic;


    -- buffer for storing the text from input and for output files
    file input_buf : text;  -- text is keyword

    constant T : time := 50 ns; -- 1000ns <--> 1 ms

begin

    register_32 : register_file32 port map (clk, rs1, rs2, rd, data_input, rs1_out, rs2_out, nWE); -- init reg_file component

    file_open(input_buf, "/Users/KerimErekmen/Desktop/Praesentation/Studium/Semester5/Projekt/microrechner/RiscyBusiness/testbenches/register_test_data.txt", read_mode);

    -- continuous clocks
    process 
    variable i : integer := 10; -- loop variable 
    begin
        clk <= '0';
        wait for T/2;
        clk <= '1';
        wait for T/2;

        i := i - 1;

    end process;


    process (clk)

        variable v_rs1: std_logic_vector(4 downto 0) := (others => '0');
        variable v_rs2: std_logic_vector(4 downto 0) := (others => '0');
        variable v_rd: std_logic_vector(4 downto 0):= (others => '0');
        variable v_data_input: std_logic_vector(31 downto 0) := (others => '0');
        variable v_nWE: std_logic := '0';
        variable v_space: character; -- read space from input
        variable read_col_from_input_buf : line; -- read lines one by one from input_buf

    
    begin

        if endfile(input_buf) then
            report "============= END =============";
            file_close(input_buf);
        end if;

        if rising_edge(clk) then
            readline(input_buf, read_col_from_input_buf);

            read(read_col_from_input_buf, v_rs1);
            read(read_col_from_input_buf, v_space); -- space
            read(read_col_from_input_buf, v_rs2); 
            read(read_col_from_input_buf, v_space); -- space
            read(read_col_from_input_buf, v_rd);
            read(read_col_from_input_buf, v_space); -- space
            read(read_col_from_input_buf, v_data_input);
            read(read_col_from_input_buf, v_space); -- space
            read(read_col_from_input_buf, v_nWE);

            -- Pass the read values to signals
            rs1 <= v_rs1;
            rs2 <= v_rs2;
            rd <= v_rd;
            data_input <= v_data_input;
            nWE <= v_nWE;

        end if;
    end process; 

end arch;