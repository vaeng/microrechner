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
    register = {}
    # empy ram:
    ram = {}
    machine_state = instructions2rom(input_text_array)
    machine_state["register"] = register
    machine_state["ram"] = ram
    machine_state["pc"] = 0

    for _ in range(instruction_limit):
        pc = machine_state["pc"]
        # no more instructions, halt sets pc to -1. thus breaking this loop
        if pc not in machine_state["rom"].keys():
            break
        machine_state["rom"][pc].execute_command(machine_state)
        # instruction has not changed pc
        if machine_state["pc"] == pc:
            machine_state["pc"] += 4

    return machine_state
