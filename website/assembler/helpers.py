import argparse
from sqlite3 import register_adapter
from assembler.instruction import Instruction


def instructions2bytecode(input_text_array):

    outputlines = {}
    instructions = []  # store each instruction memory
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
        outputlines[str(hex(instruction.ram_position))
                    ] = instruction.get_byte_code()
    return outputlines


def instructions2rom(input_text_array):
    machine_state = {}
    rom = {}
    instructions = []  # store each instruction memory
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
        rom[instruction.ram_position] = instruction
    machine_state["rom"] = rom
    machine_state["label"] = label_position
    return machine_state


def runInstructions(input_text_array, instruction_limit):
    machine_state = {}
    # initialize register to zeroes
    register = {
        "zero": 0,  # Hard-wired zero
        "ra": 0,  # Return address
        "sp": 0,  # Stack pointer
        "gp": 0,  # Global pointer
        "tp": 0,  # Thread pointer
        "t0": 0,  # Temporary link register
        "t1": 0,  # Temporaries
        "t2": 0,  # Temporaries
        "s0": 0,  # Saved register/frame pointer
        "fp": 0,  # Saved register/frame pointer
        "s1": 0,  # Saved register
        "a0": 0,  # Function arguments/return values
        "a1": 0,
        "a2": 0,  # Function arguments
        "a3": 0,
        "a4": 0,
        "a5": 0,
        "a6": 0,
        "a7": 0,
        "s2": 0,  # Saved registers
        "s3": 0,
        "s4": 0,
        "s5": 0,
        "s6": 0,
        "s7": 0,
        "s8": 0,
        "s9": 0,
        "s10": 0,
        "s11": 0,
        "t3": 0,  # Temporaries
        "t4": 0,
        "t5": 0,
        "t6": 0,
    }
    register = {}
    # empy ram:
    ram = {}
    machine_state = instructions2rom(input_text_array)
    machine_state["register"] = register
    machine_state["ram"] = ram
    machine_state["pc"] = 0

    for _ in range(instruction_limit):
        pc = machine_state["pc"]
        # no more instructions
        if pc not in machine_state["rom"].keys():
            break
        machine_state["rom"][pc].execute_command(machine_state)
        # instruction has not changed pc
        if machine_state["pc"] == pc:
            machine_state["pc"] += 4

    return machine_state
