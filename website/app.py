#!/usr/bin/env python3

from flask import Flask, request, jsonify, render_template
from assembler.instruction import Instruction
from assembler.helpers import instructions2bytecode, runInstructions
from assembler.helpers import valid_registers

import argparse  # https://docs.python.org/3/library/argparse.html
import re
import copy

app = Flask(__name__)

# for the coloring of the text (pointer)
pointer_counter = -1 # -1 because of the request (we have to change the value)
bytecode = {}
machine_state = {}
compiled  = None

# A welcome message to test our server
@app.route('/')
def index():
    return render_template("index_welcome.html")

# here is the logic of the simulator
@app.route('/demo', methods=['GET', 'POST'])
def empty_form():

    # we use those variables in each episode (record the current state of the program)
    global bytecode
    global machine_state
    global compiled
    global pointer_counter

    # record the init state of the program
    machine_state_init = {}
    machine_state_step = {}
    register = {}
    ram = {}
    meta = {}
    machine_state_init["register"] = register
    machine_state_init["ram"] = ram
    machine_state_init["meta"] = meta
    codeline = ""

    instructions = request.form.get('Instructions')
    lines = None

    # switch = False # on off for demo.html for coloring

    if instructions or "compile" in request.form.keys():
        compiled  = True
        try:
            bytecode = instructions2bytecode(instructions.splitlines())
            for i in valid_registers:
                machine_state_init["register"][i] = 0
        except Exception as e:
            bytecode["error"] = str(e)
    else: # None
        instructions = ""

    if "run" in request.form.keys():
        assert compiled == True, "You should compile the program first for run!"
        try:
            machine_state_init = runInstructions(instructions.splitlines(), 1000, machine_state_=machine_state_init)
            print("\n Run machine_state_init: ", machine_state_init, "\n")
        except Exception as e:
            bytecode = {}
            bytecode["error"] = str(e)


    print(request.form.keys())
            
    if "step" in request.form.keys():
        assert compiled == True, "You should compile the program first for step!"
        
        lines = instructions.splitlines()

        if pointer_counter < 0:
            machine_state = runInstructions(instructions.splitlines(), 1000, machine_state_init, step=True)

        if pointer_counter < len(machine_state["meta"]):
            pointer_counter += 1
            machine_state_step = copy.deepcopy(machine_state["meta"][pointer_counter])

        pass # todo

    if "prev" in request.form.keys():
        assert compiled == True and pointer_counter > -1, "You should compile the program first for step and Pointer counter is less then 0!"
        
        lines = instructions.splitlines()

        if pointer_counter < 0:
            machine_state = runInstructions(instructions.splitlines(), 1000, machine_state_init, step=True)

        if pointer_counter > 0 and pointer_counter < len(machine_state["meta"]):
            pointer_counter -= 1
            machine_state_step = copy.deepcopy(machine_state["meta"][pointer_counter])

        pass # todo

    if "clear_state" in request.form.keys():
        compiled = False
        pointer_counter = -1
        machine_state = {}
        pass # todo

    print(codeline, bytecode)

    return render_template("demo.html", pointer_counter=pointer_counter, instructions=instructions, bytecode=bytecode, machine_state=machine_state, machine_state_init=machine_state_init, machine_state_step = machine_state_step, codeline = codeline)


if __name__ == '__main__':
    # Threaded option to enable multiple instances for multiple user access support
    app.run(threaded=True, port=5003, debug=True)
