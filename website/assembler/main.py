#!/usr/bin/env python3

import argparse  # https://docs.python.org/3/library/argparse.html
import reg  # https://docs.python.org/3/library/re.html
import re
from instruction import Instruction


label_position = {}
last_used_registers = [None, None, None, None]


# J, B types are control hazards
INSTRUCTIONS_CAUSING_HAZARDS = ["jal", "jalr",
                                "beq", "bne", "blt", "bge", "bltu", "bgeu"]

# hexstring starting with x to binary string of length n
# example hex2binary("t3", 8) -> "00101000" t3 = x28 lui rd, bin(2)


def hex2binary(hexString, binLength):
    s = "{0:0" + str(binLength) + "b}"
    return s.format(int(hexString[1:], base=16))  # hexString


def whenHasWrittenToRegisterLast(register):
    last_used = -1

    if register in last_used_registers and register is not None:
        last_used = last_used_registers.index(register)

    last_used_registers.pop(0)
    last_used_registers.append(register)

    return last_used


def main():

    parser = argparse.ArgumentParser(description='Assembles to byte code.')
    parser.add_argument('input_file', type=str,
                        help='Path to the file that will be assembled.')
    parser.add_argument('output_file', type=str,
                        help='Name of the file to output the bytecode to.')

    args = parser.parse_args()
    outputlines = []
    instructions = []  # store each instruction memory
    ram_position = 0  # for the pc

    try:
        with open(args.input_file, "r") as file_object:
            print('Assembling', args.input_file)
            for line in file_object.readlines():
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
                    no_op_count = -1

                    index = whenHasWrittenToRegisterLast(inst.write_register)

                    # TODO: Aktuell werden nur Register in die geschrieben wird betrachtet.
                    # Es muss aber auch bei Registern geprüft werden, wo nur lesend drauf zugegriffen wird.
                    if inst.instruction in INSTRUCTIONS_CAUSING_HAZARDS:
                        no_op_count = 3

                    if index != -1:
                        print(line, index)
                        no_op_count = index

                    # Überprüfen ob die Instruction zu einem Hazard führen könnte.
                    # Falls ja, füge drei NO_OP Instructions ein.
                    if no_op_count > 0:
                        for i in range(no_op_count):
                            ram_position += 4
                            noop_inst = Instruction(ram_position, "nop")
                            # Müssen das hier nochmal aufrufen, damit letzte Register aktuallisiert werden
                            whenHasWrittenToRegisterLast(None)
                            instructions.append(noop_inst)

                    instructions.append(inst)
                    ram_position += 4

    except FileNotFoundError:
        print(args.input_file, 'could not be found.')

    # replace labels with adresses
    for instruction in instructions:
        label = instruction.label
        if label is not None:
            instruction.set_address(label_position[label])
            print(instruction.address)
        outputlines.append("{:20s} {:32s}\n".format(
            str(hex(instruction.ram_position)), instruction.get_byte_code()))

    # write it
    try:
        with open(args.output_file, "w") as f:
            for line in outputlines:
                f.writelines(line)
    except FileNotFoundError:
        print(args.output_file, 'could not be found.')


if __name__ == "__main__":
    main()
