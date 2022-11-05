import argparse
from sqlite3 import register_adapter
from assembler.instruction import Instruction
import copy


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
#for i in valid_registers:
#        register[i] = 0

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

    # if len(machine_state_) != 0:
    #     machine_state_ = machine_state
    # else:
    #     machine_state_ = {}
    
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


def runInstructions(input_text_array, instruction_limit, machine_state_={}, step = False):
    global machine_state
    
    
    if len(machine_state_) == 2:
        machine_state = copy.deepcopy(machine_state_) # only register and ram is init
    else:
        machine_state = copy.deepcopy(machine_state_)
    
    machine_state = instructions2rom(input_text_array, machine_state)
    machine_state["pc"] = 0 # nochmal ueberdenken ob == 0, da ROM und RAM bereiche im speicher sind (somit eigentlich adddress(rom)<adddress(ram))

    for i in range(instruction_limit):
        pc = machine_state["pc"]
        # no more instructions, halt sets pc to -1. thus breaking this loop
        if pc not in machine_state["rom"].keys():
            break
        machine_state["rom"][pc].execute_command(machine_state) # here "instruction" object method invoke
        
        if step != False:
            # store each state of the machine (the process of the machine)
            machine_state["meta"][i] = without_keys(copy.deepcopy(machine_state), {"meta"})

        # instruction has not changed pc, because the order of execution for every instruction is everytime e.g. addi rd, rs1, imm: rd←rs1+immi, pc←pc+4 (pc is incremented after the "end")
        if machine_state["pc"] == pc:
            machine_state["pc"] += 4

    return machine_state


"""remove keys of a dict
"""
def without_keys(d, keys):
    return {x: d[x] for x in d if x not in keys}

