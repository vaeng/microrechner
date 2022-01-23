library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.riscy_package.all;

-- Consider also that each piplinestage acts also as an CONTROLLER like the ADDRESSDECODER which give further import control signals
entity riscy is
    port(
        clk: in std_logic;
        nRst: in std_logic;
        iAddr: out std_logic_vector(31 downto 0); -- CPU.PC --> INSMEM (Verbinden mit "pc_unit")
        iData: in std_logic_vector(31 downto 0); -- instruction decode; use as signal in cpu
        dnWE: out std_logic; -- write enable dependent of opcode(determined in the addressdecoder); its low active; if 0 then write in ram else not for dataMEM
        dAddr: out std_logic_vector(31 downto 0); -- to DataMEM (Verbinden mit dem externen Speicher)
        dDataI: out std_logic_vector(31 downto 0); -- ausgang zum speichern in DataMEM
        dDataO: in std_logic_vector(31 downto 0) -- from WB stage
    ); 
end;



architecture behavioral of riscy is
    
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

    
    component addressdecoder is
        port (
            instruction: in std_logic_vector(31 downto 0);  -- instruction fetched form the memory
            alu_sel_f : out std_logic_vector(2 downto 0);
            alu_sel_ff : out std_logic_vector(6 downto 0);
            sel_opcode : out opcode; -- fuer jeden stage einen neuen sel_opcode[1, 2, 3, 4, 5] erstellen, da sonst dieser überschrieben wird und nicht weitergegeben werden kann
            rd : out std_logic_vector(4 downto 0);
            rs1 : out std_logic_vector(4 downto 0);
            rs2 : out std_logic_vector(4 downto 0);
            imm_Itype : out std_logic_vector(11 downto 0);
            imm_Utype : out std_logic_vector(19 downto 0);
            imm_Stype : out std_logic_vector(4 downto 0);
            imm_StypeTwo : out std_logic_vector(6 downto 0);
            imm_Btype : out std_logic;
            imm_BtypeTwo : out std_logic_vector(3 downto 0);
            imm_BtypeThree : out std_logic_vector(5 downto 0);
            imm_BtypeFour : out std_logic;
            imm_Jtype : out std_logic_vector(7 downto 0);
            imm_JtypeTwo : out std_logic;
            imm_JtypeThree : out std_logic_vector(9 downto 0);
            imm_JtypeFour : out std_logic;
            I_nWE_R2 : out std_logic; -- not write Enable; control signal also for jmp, beq, .... 
            I_nWE_RAM : out std_logic -- not write Enable; control signal also for jmp, beq, .... 
        );
    end component addressdecoder;

    component extender is
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
      
          imm_O : out std_logic_vector(31 downto 0)
        ) ;
      end component extender;

    
    component alu_entity is
        port (
         val_a : in bit_32; 
         val_b : in bit_32; 
         alu_sel_f  : in func_3;
         alu_sel_ff  : in func_7;
         alu_out : out bit_32;
         sel_opcode : in opcode
        );
    end component alu_entity;

    component pc_unit is
        port(
            clk : in std_logic;
            I_Addr : in std_logic_vector(31 downto 0); -- WB oder PC + 4 consider MUX from 
            nRst : in std_logic;
            O_Addr : out std_logic_vector(31 downto 0); -- CPU.PC --> INSMEM
            mux_control_target : in std_logic
        );
    end component pc_unit;

    component brancher_logic is
        port (
           sel_opcode : in opcode;
          rs1: in std_logic_vector(31 downto 0);
          rs2: in std_logic_vector(31 downto 0);
          branch_out: out std_logic
          );
    end component brancher_logic;

    -- decode stage signals
    -- signals to the registerfile and from the memory
    signal alu_sel_signal_f_D : std_logic_vector(2 downto 0);
    signal alu_sel_signal_ff_D : std_logic_vector(6 downto 0);
    signal sel_opcode_signal_D : opcode; -- fuer jeden stage einen neuen sel_opcode[1, 2, 3, 4, 5] erstellen, da sonst dieser überschrieben wird und nicht weitergegeben werden kann
    signal rd_signal_D : std_logic_vector(4 downto 0); -- kommt spaeter in die Registerbank
    signal rs1_signal_D : std_logic_vector(4 downto 0);
    signal rs2_signal_D : std_logic_vector(4 downto 0);
    signal imm_signal_Itype_D : std_logic_vector(11 downto 0);
    signal imm_signal_Utype_D : std_logic_vector(19 downto 0);
    signal imm_signal_Stype_D : std_logic_vector(4 downto 0);
    signal imm_signal_StypeTwo_D : std_logic_vector(6 downto 0);
    signal imm_signal_Btype_D : std_logic;
    signal imm_signal_BtypeTwo_D : std_logic_vector(3 downto 0);
    signal imm_signal_BtypeThree_D : std_logic_vector(5 downto 0);
    signal imm_signal_BtypeFour_D : std_logic;
    signal imm_signal_Jtype_D : std_logic_vector(7 downto 0);
    signal imm_signal_JtypeTwo_D : std_logic;
    signal imm_signal_JtypeThree_D : std_logic_vector(9 downto 0);
    signal imm_signal_JtypeFour_D : std_logic;
    signal rs1_out_D : std_logic_vector(31 downto 0); -- kommt aus der Registerbank
    signal rs2_out_D : std_logic_vector(31 downto 0); -- kommt aus der Registerbank
    -- from fetch stage signals
    signal ins_mem_D : std_logic_vector(31 downto 0); -- instruction fetched form the memory
    signal O_Addr_D : std_logic_vector(31 downto 0); -- from PC.mux
    signal O_Addr_D2 : std_logic_vector(31 downto 0); -- to PC.mux, we have to downcast 32 bits to 8 bits because the address space is 2**8
    signal branch_out : std_logic; -- the control signal for the mux
    signal O_Addr_F : std_logic_vector(31 downto 0);
    signal imm_O_D: std_logic_vector(31 downto 0); -- imm signal


    -- execute stage signals
    signal alu_sel_signal_f_X : func_3;
    signal alu_sel_signal_ff_X : func_7;
    signal sel_opcode_signal_X : opcode; -- fuer jeden stage einen neuen sel_opcode[1, 2, 3, 4, 5] erstellen, da sonst dieser überschrieben wird und nicht weitergegeben werden kann
    signal rs1_out_X : std_logic_vector(31 downto 0); -- kommt aus der Registerbank
    signal rs2_out_X : std_logic_vector(31 downto 0); -- kommt aus der Registerbank
    signal rs2_out_X2 : std_logic_vector(31 downto 0); -- for store
    signal alu_out_X : std_logic_vector(31 downto 0); -- aus der Alu, somit erster Signal aus der
    signal rd_signal_X : std_logic_vector(4 downto 0);


    
    -- mem stage signals
    signal sel_opcode_signal_M : opcode;
    signal rd_signal_M : std_logic_vector(4 downto 0);
    signal alu_out_M : std_logic_vector(31 downto 0); -- aus der Alu, somit zweiter Signal aus der

    -- wb stage signals
    signal Data_output_WB: std_logic_vector(31 downto 0);
    signal rd_signal_WB : std_logic_vector(4 downto 0);

    -- control signals (the brain)
    -- control signals FETCH (instruction fetch and decode stage)
    signal nWE_D_RAM: std_logic; -- is dependent of the opcode #Todo: need a control station each stage which use the opcode to determine the control signals for the datapath(components)
    signal nWE_X_RAM: std_logic;

    signal nWE_D_R2: std_logic; 
    signal nWE_X_R: std_logic;
    signal nWE_WB_R : std_logic;
    signal nWE_M_R : std_logic;


    begin
    

    PC : pc_unit port map(
        clk => clk,
        I_Addr => O_Addr_D2, -- + from ALU_ADDRESSER or PC + 4 consider MUX from 
        nRst => nRst,
        O_Addr => O_Addr_F, -- CPU.PC --> INSMEM
        mux_control_target => branch_out
    );

    -- controller for the brancher
    brancher_brain: brancher_logic port map(
        sel_opcode => sel_opcode_signal_D,
        rs1 => rs1_out_D,
        rs2 => rs2_out_D,
        branch_out => branch_out
    );

    -- Instruction decoder before the Memory(ROM, where the bytecode is)
    ADDRESS_DECODER : addressdecoder port map(
        instruction => ins_mem_D,  -- instruction fetched form the memory
        alu_sel_f => alu_sel_signal_f_D,
        alu_sel_ff => alu_sel_signal_ff_D,
        sel_opcode => sel_opcode_signal_D, -- fuer jeden stage einen neuen sel_opcode[1, 2, 3, 4, 5] erstellen, da sonst dieser überschrieben wird und nicht weitergegeben werden kann
        rd => rd_signal_D,
        rs1 => rs1_signal_D,
        rs2 => rs2_signal_D,
        imm_Itype => imm_signal_Itype_D,
        imm_Utype => imm_signal_Utype_D,
        imm_Stype => imm_signal_Stype_D,
        imm_StypeTwo => imm_signal_StypeTwo_D,
        imm_Btype => imm_signal_Btype_D,
        imm_BtypeTwo => imm_signal_BtypeTwo_D,
        imm_BtypeThree => imm_signal_BtypeThree_D,
        imm_BtypeFour => imm_signal_BtypeFour_D,
        imm_Jtype => imm_signal_Jtype_D,
        imm_JtypeTwo => imm_signal_JtypeTwo_D,
        imm_JtypeThree => imm_signal_JtypeThree_D,
        imm_JtypeFour => imm_signal_JtypeFour_D,
        I_nWE_R2 =>  nWE_D_R2,
        I_nWE_RAM => nWE_D_RAM
    );

    -- 32x32 registerfile
    -- #todo high active für die enable signale nutzen? --> marvin nochmal nachfragen was er hiermit explizit meinte <-- das hast du geschrieben xD
    REGISTER_FILE: register_file32
    port map(
        I_clk => clk,
        I_rs1 => rs1_signal_D,
        I_rs2 => rs2_signal_D,
        I_rd => rd_signal_WB,
        I_data_input => Data_output_WB, -- 32 bit from DATAMEM --> Cpu.Register
        O_rs1_out => rs1_out_D, -- 32 bit output
        O_rs2_out => rs2_out_D, -- 32 bit output
        I_nWE => nWE_WB_R
    );


    -- alu_arithmetic aber man muss val_b und alu_sel_ff unterscheiden da zwei bedeutung. val_b ist sowohl lower 5bit immidiate wert vom I-type
    -- als auch wert vom register rs2. alu_sel_ff ist sowohl func7 als auch imm[11:5] vom imm[11:0] I-type field.
    -- alu_sel_f, alu_sel_ff steuersignale
    ALU_INTEGER: alu_entity port map(
        val_a => rs1_out_X,
        val_b => rs2_out_X,
        alu_sel_f => alu_sel_signal_f_X,
        alu_sel_ff => alu_sel_signal_ff_X,
        alu_out => alu_out_X,
        sel_opcode => sel_opcode_signal_X
    );

    ALU_ADDRESSER: alu_entity port map(
        val_a => O_Addr_D, -- #TODO output from extender unit
        val_b => O_Addr_D,
        alu_sel_f => alu_sel_signal_f_D, -- dont care
        alu_sel_ff => alu_sel_signal_ff_D, -- dont care
        alu_out => O_Addr_D2, -- to PC.MUX
        sel_opcode => sel_opcode_signal_D
    );

    EXTENDER_IMM: extender port map(
        sel_opcode => sel_opcode_signal_D,
        imm_Itype => imm_signal_Itype_D,
        imm_Utype => imm_signal_Utype_D,
        imm_Stype => imm_signal_Stype_D,
        imm_StypeTwo => imm_signal_StypeTwo_D,
        imm_Btype => imm_signal_Btype_D,
        imm_BtypeTwo => imm_signal_BtypeTwo_D,
        imm_BtypeThree => imm_signal_BtypeThree_D,
        imm_BtypeFour => imm_signal_BtypeFour_D,
        imm_Jtype => imm_signal_Jtype_D,
        imm_JtypeTwo => imm_signal_JtypeTwo_D,
        imm_JtypeThree => imm_signal_JtypeThree_D,
        imm_JtypeFour => imm_signal_JtypeFour_D,
        imm_O => imm_O_D
    );

    
    -- high active für die enable signale nutzen
    pipleinestage_IF_ID : process(iData, O_Addr_F, clk) 
    begin
        if rising_edge(clk) then
            ins_mem_D <= iData; -- 32bit opcode
            O_Addr_D <= O_Addr_F;
            iAddr <= O_Addr_F;
        end if;
    end process ;

    pipleinestage_ID_EX : process(sel_opcode_signal_D, rs1_out_D, rs2_out_D, imm_O_D, nWE_D_RAM, nWE_D_R2, rd_signal_D, alu_sel_signal_ff_D, alu_sel_signal_f_D, clk) 
    begin
        if rising_edge(clk) then
            sel_opcode_signal_X <= sel_opcode_signal_D;
            rs1_out_X <= rs1_out_D;
            
            if sel_opcode_signal_D = OP_IMM or sel_opcode_signal_D = OP_STORE  or sel_opcode_signal_D = OP_LOAD then
                rs2_out_X <= imm_O_D; -- for Store and Load because one CPU.ALU
                rs2_out_X2 <= rs2_out_D; -- for store
            else
                rs2_out_X <= rs2_out_D; -- normal for Reg type
            end if;

            rd_signal_X <= rd_signal_D;
            alu_sel_signal_ff_X <= alu_sel_signal_ff_D;
            alu_sel_signal_f_X <= alu_sel_signal_f_D;
            nWE_X_RAM <= nWE_D_RAM;
            nWE_X_R <= nWE_D_R2;

        end if;
    end process ;

    pipleinestage_EX_MEM : process(sel_opcode_signal_X, alu_out_X, nWE_X_RAM, nWE_X_R, rd_signal_X, rs2_out_X2, clk) 
    begin
        if rising_edge(clk) then
            sel_opcode_signal_M <= sel_opcode_signal_X;
            dAddr <= alu_out_X; -- rs1+imm
            dDataI <= rs2_out_X2; -- m32(rs1+imm) ← rs2[31:0], pc ← pc+4
            dnWE <= nWE_X_RAM; -- out to the DataMEM (external) dnWE is "out" signal
            nWE_M_R <= nWE_X_R;
            rd_signal_M <= rd_signal_X;
            alu_out_M <= alu_out_X;
        end if;
    end process;

    pipleinestage_MEM_WB : process(sel_opcode_signal_M, alu_out_M, rd_signal_M, dDataO, clk) 
    begin
        if rising_edge(clk) then
            
            if sel_opcode_signal_M = OP_LOAD then
                Data_output_WB <= dDataO; -- from DataMEM
            else
                Data_output_WB <= alu_out_M; -- CPU.ALU.INT --> CPU.REG
            end if;
            
            rd_signal_WB <= rd_signal_M; -- rd vom bytecode
            nWE_WB_R <= nWE_M_R;
        end if;
    end process;

end;
