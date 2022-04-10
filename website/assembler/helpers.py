import argparse
from sqlite3 import register_adapter
from assembler.instruction import Instruction


valid_registers = [
            "zero",  # Hard-wired zero
            "ra",  # Return address
            "sp",  # Stack pointer
            "gp",  # Global pointer
            "tp",  # Thread pointer
            "t0",  # Temporary link register
            "t1",  # Temporaries
            "t2",  # Temporaries
            "s0",  # Saved register/frame pointer
            "fp",  # Saved register/frame pointer
            "s1",  # Saved register
            "a0",  # Function arguments/return values
            "a1",
            "a2",  # Function arguments
            "a3",
            "a4",
            "a5",
            "a6",
            "a7",
            "s2",  # Saved registers
            "s3",
            "s4",
            "s5",
            "s6",
            "s7",
            "s8",
            "s9",
            "s10",
            "s11",
            "t3",  # Temporaries
            "t4",
            "t5",
            "t6"
        ]

machine_state = {}
register = {}
for i in valid_registers:
        register[i] = 0

def instructions2bytecode(input_text_array):

    outputlines = {}
    instructions = []  # store each instruction memory object
    ram_position = 0  # for the pc
    label_position = {}
    for line in input_text_array:
        assCode = ""
        line = line.strip()
        if ":" in line:
            label_position[line.replace(':', '')] = ram_position
            continue
        elif line == "":
            continue
        else:
            inst = Instruction(ram_position, line)
            instructions.append(inst)
            ram_position += 4

    # replace labels with adresses
    for instruction in instructions:
        label = instruction.label
        if label is not None:
            instruction.set_address(label_position[label])
        outputlines[str(hex(instruction.ram_position))] = instruction.get_byte_code()
    return outputlines


def instructions2rom(input_text_array, machine_state_={}):
    global machine_state

    
    if len(machine_state_) != 0:
        machine_state_ = machine_state
    else:
        machine_state_ = {}
    

    rom = {}
    instructions = []  # store each instruction memory object
    ram_position = 0  # for the pc
    label_position = {}
    for line in input_text_array:
        assCode = ""
        line = line.strip()
        if ":" in line:
            print("line", line)
            label_position[line.replace(':', '')] = ram_position
            continue
        elif line == "":
            continue
        else:
            inst = Instruction(ram_position, line)
            instructions.append(inst)
            ram_position += 4

    # replace labels with adresses
    for instruction in instructions:
        label = instruction.label
        if label is not None:
            instruction.set_address(label_position[label]) # label taggen zur ziel addresse e.g. beq r1, r2, dest_label
        rom[instruction.ram_position] = instruction
    machine_state_["rom"] = rom
    machine_state_["label"] = label_position
    return machine_state_ # dict


def runInstructions(input_text_array, instruction_limit, machine_state_={}):
    switch = None
    global register
    global machine_state

    
    if len(machine_state_) != 0:
        machine_state_ = machine_state
        switch = False
    else:
        machine_state_ = {}
        switch = True
    


    if switch == True:
        register = {} # initialize register to zeroes
        for i in valid_registers:
            register[i] = 0

    # empy ram:
    ram = {}
    machine_state_ = instructions2rom(input_text_array, machine_state_)
    machine_state_["register"] = register
    machine_state_["ram"] = ram
    machine_state_["pc"] = 0 # nochmal ueberdenken ob == 0, da ROM und RAM bereiche im speicher sind (somit eigentlich adddress(rom)<adddress(ram))

    for _ in range(instruction_limit):
        pc = machine_state_["pc"]
        # no more instructions, halt sets pc to -1. thus breaking this loop
        if pc not in machine_state_["rom"].keys():
            break
        machine_state_["rom"][pc].execute_command(machine_state_) # here "instruction" object method invoke

        # instruction has not changed pc, because the order of execution for every instruction is everytime e.g. addi rd, rs1, imm: rd←rs1+immi, pc←pc+4 (pc is incremented after the "end")
        if machine_state_["pc"] == pc:
            machine_state_["pc"] += 4

    return machine_state_
