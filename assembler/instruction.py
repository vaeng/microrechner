#usr/bin/env python3

import re
from bitstring import Bits

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

class Instruction:
    def __init__(self, ram_pos, line):
        self.ram_position = ram_pos
        self.line = line
        self.label = None
        self.address = None


        instr, *arguments = re.split(',? |\(|\)+', line)

        if instr == "bne" or instr == "beq" or instr == "blt" or instr == "bge" or instr == "bltu":
            self.label = arguments[2]
        if instr == "jal" or instr == "jalr":
            self.label = arguments[1]

    def set_address(self, address):
        self.address = address

    def transform_immb_to_bytecode(self, label_address):
        #print(label_address, self.ram_position)
        imm_b = label_address - self.ram_position
        imm_b4_1 = (imm_b & 0x1e) << 7
        imm_b11 = (imm_b & 0x800) >> 4
        imm_11_7 = (imm_b4_1 ^ imm_b11) >> 7

        imm_10_5 = imm_b >> 7

        imm_12 = imm_b >> 12

        return (self.int2bin(imm_12, 1), self.int2bin(imm_10_5, 6), self.int2bin(imm_11_7, 5))

    def get_register(self, register_name):
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
            "s11": "11100",#
            "t3": "11101", # Temporaries
            "t4": "11110", #
            "t5": "11111", #
            "t6": "01000", #
        }
        return register[register_name]        

    # int2bin takes an integer and returns a binary string of length binLength
    def int2bin(self, num, binLength):
        bits = None
        if int(num) < 0: # denn bsp mit 23 funktioniert es nicht
            bits = Bits(int=int(num), length=binLength).bin
        else:
            bits = "{0:0"+ str(binLength) + "b}"
            bits = bits.format(int(num))
        return bits

    def get_byte_code(self):
        instr, *arguments = re.split(',? |\(|\)+', self.line)

        if instr == "lui":
            assCode = self.int2bin(arguments[1], 20) + self.get_register(arguments[0]) + OP_LUI
        elif instr == "auipc":
            assCode = self.int2bin(arguments[1], 20) + self.get_register(arguments[0]) + OP_AUIPC
        elif instr == "jal":
            assCode =  self.int2bin((int(arguments[1]) & 0x100000) >> 20, 1) + self.int2bin((int(arguments[1]) & 0x7ff) >> 1, 10) + self.int2bin((int(arguments[1]) & 0x800) >> 11, 1) + self.int2bin((int(arguments[1]) & 0xff000) >> 12, 8) + self.get_register(arguments[0]) + OP_JAL
        elif instr == "jalr":
            assCode = self.int2bin(arguments[2], 12) + self.get_register(arguments[1]) + "000" + self.get_register(arguments[0]) + OP_JALR
        elif instr == "beq":             
            assCode = self.transform_immb_to_bytecode(self.address)[0] + self.transform_immb_to_bytecode(self.address)[1] + self.get_register(arguments[1]) + self.get_register(arguments[0]) + "000" + self.transform_immb_to_bytecode(self.address)[2] + OP_BRANCH #imm_b richtig anordnen
        elif instr == "bne":
            assCode = self.transform_immb_to_bytecode(self.address)[0] + self.transform_immb_to_bytecode(self.address)[1] + self.get_register(arguments[1]) + self.get_register(arguments[0]) + "001" + self.transform_immb_to_bytecode(self.address)[2] + OP_BRANCH
        elif instr == "blt":
            assCode = self.transform_immb_to_bytecode(self.address)[0] + self.transform_immb_to_bytecode(self.address)[1] + self.get_register(arguments[1]) + self.get_register(arguments[0]) + "100" + self.transform_immb_to_bytecode(self.address)[2] + OP_BRANCH
        elif instr == "bge":
            assCode = self.transform_immb_to_bytecode(self.address)[0] + self.transform_immb_to_bytecode(self.address)[1] + self.get_register(arguments[1]) + self.get_register(arguments[0]) + "101" + self.transform_immb_to_bytecode(self.address)[2] + OP_BRANCH
        elif instr == "bltu":
            assCode = self.transform_immb_to_bytecode(self.address)[0] + self.transform_immb_to_bytecode(self.address)[1] + self.get_register(arguments[1]) + self.get_register(arguments[0]) + "110" + self.transform_immb_to_bytecode(self.address)[2] + OP_BRANCH
        elif instr == "bgeu":
            assCode = self.transform_immb_to_bytecode(self.address)[0] + self.transform_immb_to_bytecode(self.address)[1] + self.get_register(arguments[1]) + self.get_register(arguments[0]) + "111" + self.transform_immb_to_bytecode(self.address)[2] + OP_BRANCH
        elif instr == "lw":
            assCode = self.int2bin(arguments[1], 12) + self.get_register(arguments[2]) + "010" + self.get_register(arguments[0]) + OP_LOAD
        elif instr == "sw":
            assCode = self.int2bin((int(arguments[1]) >> 5), 7) + self.get_register(arguments[0]) + self.get_register(arguments[2]) + "010" + self.int2bin((int(arguments[1]) & 0b11111), 5) + OP_STORE
        elif instr == "addi":
            assCode = self.int2bin(arguments[2], 12) + self.get_register(arguments[1]) + "000" + self.get_register(arguments[0]) + OP_IMM
        elif instr == "slti":
            assCode = self.int2bin(arguments[2], 12) + self.get_register(arguments[1]) + "010" + self.get_register(arguments[0]) + OP_IMM
        elif instr == "sltiu":
            assCode = self.int2bin(arguments[2], 12) + self.get_register(arguments[1]) + "011" + self.get_register(arguments[0]) + OP_IMM
        elif instr == "xori":
            assCode = self.int2bin(arguments[2], 12) + self.get_register(arguments[1]) + "100" + self.get_register(arguments[0]) + OP_IMM
        elif instr == "ori":
            assCode = self.int2bin(arguments[2], 12) + self.get_register(arguments[1]) + "110" + self.get_register(arguments[0]) + OP_IMM
        elif instr == "andi":
            assCode = self.int2bin(arguments[2], 12) + self.get_register(arguments[1]) + "111" + self.get_register(arguments[0]) + OP_IMM
        elif instr == "slli":
            assCode = "0000000" + self.int2bin(arguments[2], 5) + self.get_register(arguments[1]) + "001" + self.get_register(arguments[0]) + OP_IMM
        elif instr == "srli":
            assCode = "0000000" + self.int2bin(arguments[2], 5) + self.get_register(arguments[1]) + "101" + self.get_register(arguments[0]) + OP_IMM
        elif instr == "srai":
            assCode = "0100000" + self.int2bin(arguments[2], 5) + self.get_register(arguments[1]) + "101" + self.get_register(arguments[0]) + OP_IMM
        elif instr == "add":
            assCode = "0000000" + self.get_register(arguments[2]) + self.get_register(arguments[1]) + "000" + self.get_register(arguments[0]) + OP_REG
        elif instr == "sub":
            assCode = "0100000" + self.get_register(arguments[2]) + self.get_register(arguments[1]) + "000" + self.get_register(arguments[0]) + OP_REG
        elif instr == "sll":
            assCode = "0000000" + self.get_register(arguments[2]) + self.get_register(arguments[1]) + "001" + self.get_register(arguments[0]) + OP_REG
        elif instr == "slt":
            assCode = "0000000" + self.get_register(arguments[2]) + self.get_register(arguments[1]) + "010" + self.get_register(arguments[0]) + OP_REG
        elif instr == "sltu":
            assCode = "0000000" + self.get_register(arguments[2]) + self.get_register(arguments[1]) + "011" + self.get_register(arguments[0]) + OP_REG
        elif instr == "xor":
            assCode = "0000000" + self.get_register(arguments[2]) + self.get_register(arguments[1]) + "100" + self.get_register(arguments[0]) + OP_REG
        elif instr == "srl":
            assCode = "0000000" + self.get_register(arguments[2]) + self.get_register(arguments[1]) + "101" + self.get_register(arguments[0]) + OP_REG
        elif instr == "sra":
            assCode = "0100000" + self.get_register(arguments[2]) + self.get_register(arguments[1]) + "101" + self.get_register(arguments[0]) + OP_REG
        elif instr == "or":
            assCode = "0000000" + self.get_register(arguments[2]) + self.get_register(arguments[1]) + "110" + self.get_register(arguments[0]) + OP_REG
        elif instr == "and":
            assCode = "0000000" + self.get_register(arguments[2]) + self.get_register(arguments[1]) + "111" + self.get_register(arguments[0]) + OP_REG
        elif instr == "nop":
            assCode = self.int2bin(0, 12) + self.get_register("zero") + "000" + self.get_register("zero") + OP_IMM # ADDI x0, x0, 0.
        elif instr == "halt":
            pass #TODO
        elif instr == "ret":
            assCode = self.int2bin(0, 12) + self.get_register("ra") + "000" + self.get_register("zero") + OP_JALR
        elif instr == "call":
            assCode = self.int2bin(0, 12) + self.get_register("ra") + "000" + self.get_register("zero") + OP_JALR
        elif instr == "mv":
            assCode = self.int2bin(0, 12) + self.get_register(arguments[1]) + "000" + self.get_register(arguments[0]) + OP_IMM 
        else: # Error for unknown codes
            raise Exception(f"unknown operation: {instr}\n")
        
        print(hex(int(assCode, 2)))

        return assCode