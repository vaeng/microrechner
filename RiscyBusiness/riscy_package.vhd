library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;
use ieee.textio.all;

package dp32_types is
    
    subtype bit_32 is std_logic_vector(31 downto 0);
    subtype opcode is std_logic_vector(6 downto 0);
    subtype func_3 is std_logic_vector(2 downto 0);
    subtype func_7 is std_logic_vector(6 downto 0);
    type bit_32_array is array (integer range <>) of bit_32;
 

    -- Instruction field definitions.
    -- RV32I opcode definitions:
    OP_LUI    : opcode := "0110111";
    OP_AUIPC  : opcode := "0010111";
    OP_JAL    : opcode := "1101111";
    OP_JALR   : opcode := "1100111";
    OP_BRANCH : opcode := "1100011";
    OP_LOAD   : opcode := "0000011";
    OP_STORE  : opcode := "0100011";
    OP_REG    : opcode := "0110011";
    OP_IMM    : opcode := "0010011";
    -- RV32I "funct3" bits. These select different functions with
    -- R-type, I-type, S-type, and B-type instructions.
    F_JALR   : func_3 := "000"
    F_BEQ    : func_3 := "000"
    F_BNE    : func_3 := "001"
    F_BLT    : func_3 := "100"
    F_BGE    : func_3 := "101"
    F_BLTU   : func_3 := "110"
    F_BGEU   : func_3 := "111"
    F_LW     : func_3 := "010"
    F_SW     : func_3 := "010"
    F_ADDI   : func_3 := "000"
    F_SLTI   : func_3 := "010"
    F_SLTIU  : func_3 := "011"
    F_XORI   : func_3 := "100"
    F_ORI    : func_3 := "110"
    F_ANDI   : func_3 := "111"
    F_SLLI   : func_3 := "001"
    F_SRLI   : func_3 := "101"
    F_SRAI   : func_3 := "101"
    F_ADD    : func_3 := "000"
    F_SUB    : func_3 := "000"
    F_SLL    : func_3 := "001"
    F_SLT    : func_3 := "010"
    F_SLTU   : func_3 := "011"
    F_XOR    : func_3 := "100"
    F_SRL    : func_3 := "101"
    F_SRA    : func_3 := "101"
    F_OR     : func_3 := "110"
    F_AND    : func_3 := "111"
    -- RV32I "funct7" bits. Along with the "funct3" bits, these select
    -- different functions with R-type instructions.
    FF_SLLI : func_7 := "0000000"
    FF_SRLI : func_7 := "0000000"
    FF_SRAI : func_7 := "0100000"
    FF_ADD  : func_7 := "0000000"
    FF_SUB  : func_7 := "0100000"
    FF_SLL  : func_7 := "0000000"
    FF_SLT  : func_7 := "0000000"
    FF_SLTU : func_7 := "0000000"
    FF_XOR  : func_7 := "0000000"
    FF_SRL  : func_7 := "0000000"
    FF_SRA  : func_7 := "0100000"
    FF_OR   : func_7 := "0000000"
    FF_AND  : func_7 := "0000000"

    -- ID numbers for different types of traps (exceptions). 
    -- TRAP_IMIS  = 1
    -- TRAP_ILLI  = 2
    -- TRAP_BREAK = 3
    -- TRAP_LMIS  = 4
    -- TRAP_SMIS  = 6
    

end dp32_types;