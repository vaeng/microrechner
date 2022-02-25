# usr/bin/env python3

from atexit import register
import re
from bitstring import Bits

# Instruction field definitions.
# RV32I opcode definitions:
OP_JAL = "1101111"
OP_JALR = "1100111"
OP_BRANCH = "1100011"
OP_LUI = "0110111"
OP_REG = "0110011"
OP_LOAD = "0000011"
OP_STORE = "0100011"
OP_AUIPC = "0010111"
OP_IMM = "0010011"

WRITE_INSTRUCTIONS = ["addi", "lw", "slti", "sltiu", "lui", "jal", "jalr", "xori", "ori", "andi",
                      "slli", "srli", "srai", "add", "sub", "slli", "slt", "sltu", "xor", "srl", "sra", "or", "and"]


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

        self.instruction = instr

        # Wenn die Instruktion in ein Register schreibt, speichern wir uns in welches Register geschrieben wurde
        if instr in WRITE_INSTRUCTIONS:
            self.write_register = arguments[0]
        else:
            self.write_register = None

    def set_address(self, address):
        self.address = address

    
    def transform_immb_to_bytecode(self, label_address):
        imm_b = label_address - self.ram_position
        print("he", label_address, self.ram_position, imm_b)
        imm_b4_1 = (imm_b & 0x1e) << 7
        imm_b11 = (imm_b & 0x800) >> 4
        imm_11_7 = (imm_b4_1 ^ imm_b11) >> 7

        imm_10_5 = imm_b >> 7

        imm_12 = imm_b >> 12

        return (self.int2bin(imm_12, 1), self.int2bin(imm_10_5, 6), self.int2bin(imm_11_7, 5))

    def get_register(self, register_name):
        register = {
            "zero": "00000",  # Hard-wired zero
            "ra": "00001",  # Return address
            "sp": "00010",  # Stack pointer
            "gp": "00011",  # Global pointer
            "tp": "00100",  # Thread pointer
            "t0": "00101",  # Temporary link register
            "t1": "00110",  # Temporaries
            "t2": "00111",  # Temporaries
            "s0": "01001",  # Saved register/frame pointer
            "fp": "01001",  # Saved register/frame pointer
            "s1": "01010",  # Saved register
            "a0": "01011",  # Function arguments/return values
            "a1": "01100",
            "a2": "01101",  # Function arguments
            "a3": "01110",
            "a4": "01111",
            "a5": "10000",
            "a6": "10001",
            "a7": "10010",
            "s2": "10011",  # Saved registers
            "s3": "10100",
            "s4": "10101",
            "s5": "10110",
            "s6": "10111",
            "s7": "11000",
            "s8": "11001",
            "s9": "11010",
            "s10": "11011",
            "s11": "11100",
            "t3": "11101",  # Temporaries
            "t4": "11110",
            "t5": "11111",
            "t6": "01000",
        }
        return register[register_name]

    # int2bin takes an integer and returns a binary string of length binLength
    def int2bin(self, num, binLength):
        bits = None
        if int(num) < 0:  # denn bsp mit 23 funktioniert es nicht
            bits = Bits(int=int(num), length=binLength).bin
        else:
            bits = "{0:0" + str(binLength) + "b}"
            bits = bits.format(int(num))
        return bits

    def get_byte_code(self):
        instr, *arguments = re.split(',? |\(|\)+', self.line)

        if instr == "lui":
            assCode = self.int2bin(
                arguments[1], 20) + self.get_register(arguments[0]) + OP_LUI
        elif instr == "auipc":
            assCode = self.int2bin(
                arguments[1], 20) + self.get_register(arguments[0]) + OP_AUIPC
        elif instr == "jal":
            assCode = self.int2bin((int(arguments[1]) & 0x100000) >> 20, 1) + self.int2bin((int(arguments[1]) & 0x7ff) >> 1, 10) + self.int2bin(
                (int(arguments[1]) & 0x800) >> 11, 1) + self.int2bin((int(arguments[1]) & 0xff000) >> 12, 8) + self.get_register(arguments[0]) + OP_JAL
        elif instr == "jalr":
            assCode = self.int2bin(arguments[2], 12) + self.get_register(
                arguments[1]) + "000" + self.get_register(arguments[0]) + OP_JALR
        elif instr == "beq":
            assCode = self.transform_immb_to_bytecode(self.address)[0] + self.transform_immb_to_bytecode(self.address)[1] + self.get_register(
                arguments[1]) + self.get_register(arguments[0]) + "000" + self.transform_immb_to_bytecode(self.address)[2] + OP_BRANCH  # imm_b richtig anordnen
        elif instr == "bne":
            assCode = self.transform_immb_to_bytecode(self.address)[0] + self.transform_immb_to_bytecode(self.address)[1] + self.get_register(
                arguments[1]) + self.get_register(arguments[0]) + "001" + self.transform_immb_to_bytecode(self.address)[2] + OP_BRANCH
        elif instr == "blt":
            assCode = self.transform_immb_to_bytecode(self.address)[0] + self.transform_immb_to_bytecode(self.address)[1] + self.get_register(
                arguments[1]) + self.get_register(arguments[0]) + "100" + self.transform_immb_to_bytecode(self.address)[2] + OP_BRANCH
        elif instr == "bge":
            assCode = self.transform_immb_to_bytecode(self.address)[0] + self.transform_immb_to_bytecode(self.address)[1] + self.get_register(
                arguments[1]) + self.get_register(arguments[0]) + "101" + self.transform_immb_to_bytecode(self.address)[2] + OP_BRANCH
        elif instr == "bltu":
            assCode = self.transform_immb_to_bytecode(self.address)[0] + self.transform_immb_to_bytecode(self.address)[1] + self.get_register(
                arguments[1]) + self.get_register(arguments[0]) + "110" + self.transform_immb_to_bytecode(self.address)[2] + OP_BRANCH
        elif instr == "bgeu":
            assCode = self.transform_immb_to_bytecode(self.address)[0] + self.transform_immb_to_bytecode(self.address)[1] + self.get_register(
                arguments[1]) + self.get_register(arguments[0]) + "111" + self.transform_immb_to_bytecode(self.address)[2] + OP_BRANCH
        elif instr == "lw":
            assCode = self.int2bin(arguments[1], 12) + self.get_register(
                arguments[2]) + "010" + self.get_register(arguments[0]) + OP_LOAD
        elif instr == "sw":
            assCode = self.int2bin((int(arguments[1]) >> 5), 7) + self.get_register(arguments[0]) + self.get_register(
                arguments[2]) + "010" + self.int2bin((int(arguments[1]) & 0b11111), 5) + OP_STORE
        elif instr == "addi":
            assCode = self.int2bin(arguments[2], 12) + self.get_register(
                arguments[1]) + "000" + self.get_register(arguments[0]) + OP_IMM
        elif instr == "slti":
            assCode = self.int2bin(arguments[2], 12) + self.get_register(
                arguments[1]) + "010" + self.get_register(arguments[0]) + OP_IMM
        elif instr == "sltiu":
            assCode = self.int2bin(arguments[2], 12) + self.get_register(
                arguments[1]) + "011" + self.get_register(arguments[0]) + OP_IMM
        elif instr == "xori":
            assCode = self.int2bin(arguments[2], 12) + self.get_register(
                arguments[1]) + "100" + self.get_register(arguments[0]) + OP_IMM
        elif instr == "ori":
            assCode = self.int2bin(arguments[2], 12) + self.get_register(
                arguments[1]) + "110" + self.get_register(arguments[0]) + OP_IMM
        elif instr == "andi":
            assCode = self.int2bin(arguments[2], 12) + self.get_register(
                arguments[1]) + "111" + self.get_register(arguments[0]) + OP_IMM
        elif instr == "slli":
            assCode = "0000000" + self.int2bin(arguments[2], 5) + self.get_register(
                arguments[1]) + "001" + self.get_register(arguments[0]) + OP_IMM
        elif instr == "srli":
            assCode = "0000000" + self.int2bin(arguments[2], 5) + self.get_register(
                arguments[1]) + "101" + self.get_register(arguments[0]) + OP_IMM
        elif instr == "srai":
            assCode = "0100000" + self.int2bin(arguments[2], 5) + self.get_register(
                arguments[1]) + "101" + self.get_register(arguments[0]) + OP_IMM
        elif instr == "add":
            assCode = "0000000" + self.get_register(arguments[2]) + self.get_register(
                arguments[1]) + "000" + self.get_register(arguments[0]) + OP_REG
        elif instr == "sub":
            assCode = "0100000" + self.get_register(arguments[2]) + self.get_register(
                arguments[1]) + "000" + self.get_register(arguments[0]) + OP_REG
        elif instr == "sll":
            assCode = "0000000" + self.get_register(arguments[2]) + self.get_register(
                arguments[1]) + "001" + self.get_register(arguments[0]) + OP_REG
        elif instr == "slt":
            assCode = "0000000" + self.get_register(arguments[2]) + self.get_register(
                arguments[1]) + "010" + self.get_register(arguments[0]) + OP_REG
        elif instr == "sltu":
            assCode = "0000000" + self.get_register(arguments[2]) + self.get_register(
                arguments[1]) + "011" + self.get_register(arguments[0]) + OP_REG
        elif instr == "xor":
            assCode = "0000000" + self.get_register(arguments[2]) + self.get_register(
                arguments[1]) + "100" + self.get_register(arguments[0]) + OP_REG
        elif instr == "srl":
            assCode = "0000000" + self.get_register(arguments[2]) + self.get_register(
                arguments[1]) + "101" + self.get_register(arguments[0]) + OP_REG
        elif instr == "sra":
            assCode = "0100000" + self.get_register(arguments[2]) + self.get_register(
                arguments[1]) + "101" + self.get_register(arguments[0]) + OP_REG
        elif instr == "or":
            assCode = "0000000" + self.get_register(arguments[2]) + self.get_register(
                arguments[1]) + "110" + self.get_register(arguments[0]) + OP_REG
        elif instr == "and":
            assCode = "0000000" + self.get_register(arguments[2]) + self.get_register(
                arguments[1]) + "111" + self.get_register(arguments[0]) + OP_REG
        elif instr == "nop":
            # ADDI x0, x0, 0.
            assCode = self.int2bin(
                0, 12) + self.get_register("zero") + "000" + self.get_register("zero") + OP_IMM
        elif instr == "halt":
            pass  # TODO
        elif instr == "ret":
            assCode = self.int2bin(
                0, 12) + self.get_register("ra") + "000" + self.get_register("zero") + OP_JALR
        elif instr == "call":
            assCode = self.int2bin(0, 12) + self.get_register("ra") + \
                "000" + self.get_register("zero") + OP_JALR  # TODO
        elif instr == "mv":
            assCode = self.int2bin(0, 12) + self.get_register(
                arguments[1]) + "000" + self.get_register(arguments[0]) + OP_IMM
        else:  # Error for unknown codes
            raise Exception(f"unknown operation: {instr}\n")

        return assCode

    
    def execute_command(self, machine_state):
        # machine state has several entries:
        # dictionaries: ram, register, labels and rom
        # pc and instruction_count as int

        instr, *arguments = re.split(',? |\(|\)+', self.line)


#     Integer Register-Immediate Instructions:

#     ADDI (Add imidiate): sign-extended 12-bit immediate to register rs1 (ADDI rd, rs1, 0)
        if instr == "addi":
            target = arguments[0]
            if arguments[1] not in machine_state["register"].keys():
                source = 0
            else:
                source = machine_state["register"][arguments[1]]
            imm = arguments[2]
            machine_state["register"][target] = source + int(imm)
#     SLTI (set less than immediate): "rd ? if rs1 < signextended immediate : 0;"
#     ANDI, ORI, XORI (logical operations): perform bitwise OP := AND, OR, XOR; "rd = rs1 OP sign-extended 12-bit immediate"
#     SRLI (logical right shift): zeros are shifted into the upper bits
#     SRAI (arithmetic right shift): the original sign bit is copied into the vacated upper bits
#     SLLI (logical left shift): zeros are shifted into the lower bits
#     LUI (load upper immediate): used to build 32-bit constants, i.e. places the U-immediate value in the top 20 bits of the destination register rd, filling in the lowest 12 bits with zeros.
#     AUIPC (add upper immediate to pc): is used to build pc-relative addresses

# Integer Register-Register Operations:

#     ADD, SUB: addition of rs1 and rs2; rd = rs1 + rs2; ADD rd rs1 rs2
        elif instr in ["add", "sub"]:
            if arguments[1] not in machine_state["register"].keys():
                source1 = 0
            else:
                source1 = machine_state["register"][arguments[1]]

            if arguments[2] not in machine_state["register"].keys():
                source2 = 0
            else:
                source2 = machine_state["register"][arguments[2]]
            if instr == "add":
                machine_state["register"][arguments[0]] = source1 + source2
            if instr == "sub":
                machine_state["register"][arguments[0]] = source1 - source2
#     SLT, SLTU (signed, unsigned compares respectively): rd ? if rs1 < rs2 : 0;
#     AND, OR, XOR (perform bitwise logical)
#     SLL, SRL, SRA (logical left, logical right, arithmetic right shifts): value in "rs1 shift rs2"
#     NOP (Instruction) := ADDI x0, x0, 0 --> NOP for Pipeline "Bubbles"
        elif instr == "nop":
            pass

# Control Transfer Instructions:
# Unconditional Jumps

#     JAL(jump and link): JAL stores the address of the instruction following the jump (pc+4) into register rd
        elif instr == "jal":
            try:
                jump = int(arguments[1])
            except:
                jump = machine_state["label"][arguments[1]]

            machine_state["register"][arguments[0]] = machine_state["pc"] + 4
            machine_state["pc"] += jump

#     JALR (indirect jump instruction): see Implementation details in spec S.21

# Conditional Jumps

# Compare two registers and takes branch if true. 12-bit B-immediate encodes signed offsets in multiples of 2 bytes. Offset is sign-extended and added to address of branch instruction.

        elif instr in ["bne", "beq", "blt", "bge"]:
            if arguments[0] not in machine_state["register"].keys():
                source1 = 0
            else:
                source1 = machine_state["register"][arguments[0]]

            if arguments[1] not in machine_state["register"].keys():
                source2 = 0
            else:
                source2 = machine_state["register"][arguments[1]]

            try:
                dest = int(arguments[2])
            except:
                dest = machine_state["label"][arguments[2]]

#     BEQ (branch equal): takes branch if rs1 and rs2 are equal
            if instr == "beq" and source1 == source2:
                machine_state["pc"] = dest
#     BNE (branch not equal): takes branch if rs1 and rs2 are not equal
            elif instr == "bne" and source1 != source2:
                machine_state["pc"] = dest
#     BLT (branch less than): takes branch if rs1 is less than rs2
            elif instr == "blt" and source1 < source2:
                machine_state["pc"] = dest
#     BGE (branch greater than): takes branch if rs1 is greater than rs2
            elif instr == "bge" and source1 > source2:
                machine_state["pc"] = dest

#     BLTU (branch less than unsigned): takes branch if rs1 is less than rs2 but unsigned
#     BGEU (branch greater than unsigned): takes branch if rs1 is greater than rs2 but unsigned

# Load/Store

#     LW: loads 32bit value from memory into rd ex.: lw s2, 55(t2)
        elif instr == "lw":
            offset = int(arguments[1])
            reg = arguments[2]
            if reg not in machine_state["register"].keys():
                ram_address = 0
            else:
                ram_address = machine_state["register"][reg] + offset

            if ram_address not in machine_state["ram"].keys():
                ram_content = 0
            else:
                ram_content = machine_state["ram"][ram_address]

            machine_state["register"][arguments[0]] = ram_content

#     SW: stores 32bit value from low bit of rs2 to memory 4byte boundary
        elif instr == "sw":
            offset = int(arguments[1])
            reg = arguments[2]
            if reg not in machine_state["register"].keys():
                ram_address = 0
            else:
                ram_address = machine_state["register"][reg] + offset
            if arguments[0] not in machine_state["register"].keys():
                content = 0
            else:
                content = machine_state["register"][arguments[0]]
            machine_state["ram"][ram_address] = content

#      HALT
        elif instr == "halt":
            # a bit hacky, a negative pc makes the rom access impossible and breaks the program
            machine_state["pc"] = -1

        else:  # Error for unknown codes
            raise Exception(f"unknown operation: {instr}\n")

        return
