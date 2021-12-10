import argparse # https://docs.python.org/3/library/argparse.html
import reg # https://docs.python.org/3/library/re.html
import re


## Instruction field definitions.
## RV32I opcode definitions:
OP_JAL    = "1101111"
OP_JALR   = "1100111"
OP_BRANCH = "1100011"
OP_LUI    = "0110111"
OP_REG    = "0110011"
OP_LOAD   = "0000011"
OP_STORE  = "0100011"
OP_AUIPC  = "0010111"
OP_IMM    = "0010011"



def get_register(register_name):
    register = {
        "zero": "00000", # Hard-wired zero
        "ra": "00001", # Return address
        "sp": "00010", # Stack pointer
        "gp": "00011", # Global pointer
        "tp": "00100", # Thread pointer
        "t0": "00101", # Temporary link register
        "t1": "00110", # Temporaries
        "t2": "00111", # Temporaries
        "s0": "01001", # Saved register/frame pointer
        "fp": "01001", # Saved register/frame pointer
        "s1": "01010", # Saved register
        "a0": "01011", # Function arguments/return values
        "a1": "01100", # 
        "a2": "01101", # Function arguments
        "a3": "01110", #
        "a4": "01111", #
        "a5": "10000", #
        "a6": "10001", #
        "a7": "10010", # 
        "s2": "10011", # Saved registers
        "s3": "10100", #
        "s4": "10101", #
        "s5": "10110", #
        "s6": "10111", #
        "s7": "11000", #
        "s8": "11001", #
        "s9": "11010", #
        "s10":"11011", #
        "s11": "11100", #
        "t3": "11101", # Temporaries
        "t4": "11110", #
        "t5": "11111", #
        "t6": "01000", #
    }
    return register[register_name]

# hexstring starting with x to binary string of length n
# example hex2binary("t3", 8) -> "00101000" t3 = x28 lui rd, bin(2)
def hex2binary(hexString, binLength):
    s = "{0:0" + str(binLength) + "b}"
    return s.format(int(hexString[1:], base=16)) #hexString


# int2bin takes an integer and returns a binary string of length binLength
def int2bin(num, binLength):
    s = "{0:0" + str(binLength) + "b}"
    return s.format(int(num))
 
def main():
    parser = argparse.ArgumentParser(description='Assembles to byte code.')
    parser.add_argument('input_file', type=str, help='Path to the file that will be assembled.')
    parser.add_argument('output_file', type=str, help='Name of the file to output the bytecode to.')
    ram_position = 0

    args = parser.parse_args()
    outputlines = []
    try:
        with open(args.input_file, "r") as file_object:
            print('Assembling', args.input_file)
            for line in file_object.readlines():
                assCode = ""
               
                instr, *arguments = re.split(',? +', line)
                #print(f"Instruction: {instr}, Args: {arguments}")
                if instr == "lui":
                    assCode = int2bin(arguments[1], 20) + get_register(arguments[0]) + OP_LUI
                elif instr == "auipc":
                    assCode = int2bin(arguments[1], 20) + get_register(arguments[0]) + OP_AUIPC
                elif instr == "jal":
                    assCode = int2bin(arguments[1], 20) + get_register(arguments[0]) + OP_JAL
                elif instr == "jalr":
                    assCode = int2bin(arguments[2], 12) + get_register(arguments[1]) + "000" + get_register(arguments[0]) + OP_JALR
                elif instr == "beq":
                    assCode = int2bin(arguments[3], 7) + get_register(arguments[2]) + get_register(arguments[1]) + "000" + int2bin(arguments[0], 5) + OP_BRANCH
                elif instr == "bne":
                    assCode = int2bin(arguments[3], 7) + get_register(arguments[2]) + get_register(arguments[1]) + "001" + int2bin(arguments[0], 5) + OP_BRANCH
                elif instr == "blt":
                    assCode = int2bin(arguments[3], 7) + get_register(arguments[2]) + get_register(arguments[1]) + "100" + int2bin(arguments[0], 5) + OP_BRANCH
                elif instr == "bge":
                    assCode = int2bin(arguments[3], 7) + get_register(arguments[2]) + get_register(arguments[1]) + "101" + int2bin(arguments[0], 5) + OP_BRANCH
                elif instr == "bltu":
                    assCode = int2bin(arguments[3], 7) + get_register(arguments[2]) + get_register(arguments[1]) + "110" + int2bin(arguments[0], 5) + OP_BRANCH
                elif instr == "bgeu":
                    assCode = int2bin(arguments[3], 7) + get_register(arguments[2]) + get_register(arguments[1]) + "111" + int2bin(arguments[0], 5) + OP_BRANCH
                elif instr == "lw":
                    assCode = int2bin(arguments[2], 12) + get_register(arguments[1]) + "010" + get_register(arguments[0]) + OP_LOAD
                elif instr == "sw":
                    assCode = int2bin(arguments[3], 7) + get_register(arguments[2]) + get_register(arguments[1]) + "010" + int2bin(arguments[0], 5) + OP_STORE
                elif instr == "addi":
                    assCode = int2bin(arguments[2], 12) + get_register(arguments[1]) + "000" + get_register(arguments[0]) + OP_IMM
                elif instr == "slti":
                    assCode = int2bin(arguments[2], 12) + get_register(arguments[1]) + "010" + get_register(arguments[0]) + OP_IMM
                elif instr == "sltiu":
                    assCode = int2bin(arguments[2], 12) + get_register(arguments[1]) + "011" + get_register(arguments[0]) + OP_IMM
                elif instr == "xori":
                    assCode = int2bin(arguments[2], 12) + get_register(arguments[1]) + "100" + get_register(arguments[0]) + OP_IMM
                elif instr == "ori":
                    assCode = int2bin(arguments[2], 12) + get_register(arguments[1]) + "110" + get_register(arguments[0]) + OP_IMM
                elif instr == "andi":
                    assCode = int2bin(arguments[2], 12) + get_register(arguments[1]) + "111" + get_register(arguments[0]) + OP_IMM
                elif instr == "slli":
                    assCode = "0000000" + int2bin(arguments[2], 5) + get_register(arguments[1]) + "001" + get_register(arguments[0]) + OP_IMM
                elif instr == "srli":
                    assCode = "0000000" + int2bin(arguments[2], 5) + get_register(arguments[1]) + "101" + get_register(arguments[0]) + OP_IMM
                elif instr == "srai":
                    assCode = "0100000" + int2bin(arguments[2], 5) + get_register(arguments[1]) + "101" + get_register(arguments[0]) + OP_IMM
                elif instr == "add":
                    assCode = "0000000" + get_register(arguments[2]) + get_register(arguments[1]) + "000" + get_register(arguments[0]) + OP_REG
                elif instr == "sub":
                    assCode = "0100000" + get_register(arguments[2]) + get_register(arguments[1]) + "000" + get_register(arguments[0]) + OP_REG
                elif instr == "sll":
                    assCode = "0000000" + get_register(arguments[2]) + get_register(arguments[1]) + "001" + get_register(arguments[0]) + OP_REG
                elif instr == "slt":
                    assCode = "0000000" + get_register(arguments[2]) + get_register(arguments[1]) + "010" + get_register(arguments[0]) + OP_REG
                elif instr == "sltu":
                    assCode = "0000000" + get_register(arguments[2]) + get_register(arguments[1]) + "011" + get_register(arguments[0]) + OP_REG
                elif instr == "xor":
                    assCode = "0000000" + get_register(arguments[2]) + get_register(arguments[1]) + "100" + get_register(arguments[0]) + OP_REG
                elif instr == "srl":
                    assCode = "0000000" + get_register(arguments[2]) + get_register(arguments[1]) + "101" + get_register(arguments[0]) + OP_REG
                elif instr == "sra":
                    assCode = "0100000" + get_register(arguments[2]) + get_register(arguments[1]) + "101" + get_register(arguments[0]) + OP_REG
                elif instr == "or":
                    assCode = "0000000" + get_register(arguments[2]) + get_register(arguments[1]) + "110" + get_register(arguments[0]) + OP_REG
                elif instr == "and":
                    assCode = "0000000" + get_register(arguments[2]) + get_register(arguments[1]) + "111" + get_register(arguments[0]) + OP_REG
                elif instr == "nop":
                    assCode = int2bin(0, 12) + get_register("zero") + "000" + get_register("zero") + OP_IMM # ADDI x0, x0, 0.
                elif instr == "halt":
                    pass #TODO
                elif instr == "ret":
                    assCode = int2bin(0, 12) + get_register("ra") + "000" + get_register("zero") + OP_JALR
                elif instr == "call":
                    assCode = int2bin(0, 12) + get_register("ra") + "000" + get_register("zero") + OP_JALR
                elif instr = "mv":
                    assCode = int2bin(0, 12) + get_register(arguments[1]) + "000" + get_register(arguments[0]) + OP_IMM 
                else: # Error for unknown codes
                     raise Exception(f"unknown operation: {instr}\n") 
                outputlines.append(str(ram_position) + " " + assCode + "\n")
                ram_position += 1
    
    except FileNotFoundError:
        print(args.input_file, 'could not be found.')
    
    # write it
    try:
        with open(args.output_file, "w") as f:
            for line in outputlines:
                f.writelines(line)
    except FileNotFoundError:
        print(args.output_file, 'could not be found.')

if __name__ == "__main__":
    main()