import argparse
from assembler.instruction import Instruction


def instructions2bytecode(input_text):

    outputlines = []
    instructions = []  # store each instruction memory
    ram_position = 0  # for the pc
    label_position = {}
    print("in the function")
    print(input_text)
    for line in input_text.splitlines():
        assCode = ""

        # print(line, type(line))
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
            print(instruction.address)
        outputlines.append("{:20s} {:32s}".format(
            str(hex(instruction.ram_position)), instruction.get_byte_code()))
    return outputlines
