library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

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
    
    component register_file32 is port( 
        clk: in std_logic; -- clock
        rs1: in std_logic_vector(4 downto 0); -- input
        rs2: in std_logic_vector(4 downto 0); -- input
        rd: in std_logic_vector(4 downto 0); -- input
        data_input: in std_logic_vector(31 downto 0); -- data input from the wb stage or from the mem(e.g. through a lw instrucution)
        rs1_out: out std_logic_vector(31 downto 0); -- data output
        rs2_out: out std_logic_vector(31 downto 0); -- data output
        writeEnable   : in std_logic -- for conroll, writeEnable == 1 write otherwise read or do nothing
        );
    end component register_file32;

    
    component addressdecoder is
        port (
          instruction: in std_logic_vector(31 downto 0);  -- instruction fetched form the memory
          alu_sel_f : out func_3;
          alu_sel_ff : out func_7;
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
          imm_JtypeFour : out std_logic
        );
    end component addressdecoder;

    
    component alu_entity is
        port (
          signal val_a : in bit_32; 
          signal val_b : in bit_32; 
          signal alu_sel_f  : in func_3;
          signal alu_sel_ff  : in func_7;
          signal alu_out : out bit_32;
          signal sel_opcode : in opcode
        );
    end component alu_entity;

    --signal to and out of the alu
    signal alu_out : bit_32;
    signal val_a : bit_32;
    signal val_b : bit_32;


    -- fetch stage signals



    -- decode stage signals
    -- signals to the registerfile and from the memory
    signal alu_sel_signal_f_D : func_3;
    signal alu_sel_signal_ff_D : func_7;
    signal sel_opcode_signal_D : opcode; -- fuer jeden stage einen neuen sel_opcode[1, 2, 3, 4, 5] erstellen, da sonst dieser überschrieben wird und nicht weitergegeben werden kann
    signal rd_signal_D : std_logic_vector(4 downto 0);
    signal rs1_signal_D : std_logic_vector(4 downto 0);
    signal rs2_signal_D : std_logic_vector(4 downto 0);
    signal imm_signal_Itype_D : std_logic_vector(11 downto 0);
    signal imm_signal_Utype_D : std_logic_vector(20 downto 0);
    signal imm_signal_Stype_D : std_logic_vector(5 downto 0);
    signal imm_signal_StypeTwo_D : std_logic_vector(7 downto 0);
    signal imm_signal_Btype_D : std_logic;
    signal imm_signal_BtypeTwo_D : std_logic_vector(3 downto 0);
    signal imm_signal_BtypeThree_D : std_logic_vector(5 downto 0);
    signal imm_signal_BtypeFour_D : std_logic;
    signal imm_signal_Jtype_D : std_logic_vector(7 downto 0);
    signal imm_signal_JtypeTwo_D : std_logic;
    signal imm_signal_JtypeThree_D : std_logic_vector(9 downto 0);
    signal imm_signal_JtypeFour_D : std_logic;
    signal ins_mem : std_logic_vector(31 downto 0); -- instruction fetched form the memory
    signal rs1_out_D : std_logic_vector(31 downto 0); -- kommt aus der Registerbank
    signal rs2_out_D : std_logic_vector(31 downto 0); -- kommt aus der Registerbank


    -- execute stage signals
    signal alu_sel_signal_f_X : func_3;
    signal alu_sel_signal_ff_X : func_7;
    signal sel_opcode_signal_X : opcode; -- fuer jeden stage einen neuen sel_opcode[1, 2, 3, 4, 5] erstellen, da sonst dieser überschrieben wird und nicht weitergegeben werden kann
    signal rs1_out_X : std_logic_vector(31 downto 0); -- kommt aus der Registerbank
    signal rs2_out_X : std_logic_vector(31 downto 0); -- kommt aus der Registerbank
    signal alu_out_X : std_logic_vector(31 downto 0); -- aus der Alu, somit erster Signal aus der

    
    -- mem stage signals
    signal sel_opcode_signal_M : opcode;
    
    -- wb stage signals
    signal wb_output: std_logic_vector(31 downto 0);






    -- control signals (the brain)
    -- control signals FETCH (instruction fetch and decode stage)
    signal write_enable_F: std_logic; -- is dependent of the opcode #Todo: need a control station each stage which use the opcode to determine the control signals for the datapath(components)

    begin

    -- Instruction decoder before the Memory(ROM, where the bytecode is)
    ADDRESS_DECODER : addressdecoder port map(
        instruction => ins_mem,  -- instruction fetched form the memory
        alu_sel_f => alu_sel_signal_ff_D,
        alu_sel_ff => alu_sel_signal_ff_D,
        sel_opcode => sel_opcode_D, -- fuer jeden stage einen neuen sel_opcode[1, 2, 3, 4, 5] erstellen, da sonst dieser überschrieben wird und nicht weitergegeben werden kann
        rd => rd_signal,
        rs1 => rs1_signal,
        rs2 => rs2_signal,
        imm_Itype => imm_signal_Itype,
        imm_Utype => imm_signal_Utype,
        imm_Stype => imm_signal_Stype,
        imm_StypeTwo => imm_signal_StypeTwo,
        imm_Btype => imm_signal_Btype,
        imm_BtypeTwo => imm_signal_BtypeTwo,
        imm_BtypeThree => imm_signal_BtypeThree,
        imm_BtypeFour => imm_signal_BtypeFour,
        imm_Jtype => imm_signal_Jtype,
        imm_JtypeTwo => imm_signal_JtypeTwo,
        imm_JtypeThree => imm_signal_JtypeThree,
        imm_JtypeFour => imm_signal_JtypeFour
    );

    -- 32x32 registerfile
    -- #todo high active für die enable signale nutzen? --> marvin nochmal nachfragen was er hiermit explizit meinte <-- das hast du geschrieben xD
    REGISTER_FILE: register_file32 port map(
        clk => clk,
        rs1 => rs1_signal,
        rs2 => rs2_signal,
        rd => rd_signal,
        data_input => wb_output,
        writeEnable => write_enable_if_id
        rs1_out => rs1_out_D -- 32 bit output
        rs2_out => rs2_out_D -- 32 bit output
    );


    -- alu_arithmetic aber man muss val_b und alu_sel_ff unterscheiden da zwei bedeutung. val_b ist sowohl lower 5bit immidiate wert vom I-type
    -- als auch wert vom register rs2. alu_sel_ff ist sowohl func7 als auch imm[11:5] vom imm[11:0] I-type field.
    -- alu_sel_f, alu_sel_ff steuersignale
    ALU: alu_entity port map(
        val_a => rs1_out_X,
        val_b => rs2_out_X,
        alu_sel_f => alu_sel_signal_f_X,
        alu_sel_ff => alu_sel_ff_signal_X,
        alu_out => alu_out_X,
        sel_opcode => sel_opcode_signal_X
    );


    -- high active für die enable signale nutzen
    pipleinestage_IF_ID : process(ins_mem_F) 
    begin
        ins_mem_D <= ins_mem_F; -- 32bit opcode
    end process ;

    pipleinestage_ID_EX : process(sel_opcode_signal_D, rs1_out_D, rs2_out_D) 
    begin
        sel_opcode_X <= sel_opcode_D;
        rs1_out_X <= rs1_out_D;
        rs2_out_X <= rs2_out_D;
    end process ;

    pipleinestage_EX_MEM : process(sel_opcode_signal_X, val_a, val_b) 
    begin
    end process ;

    





end;
