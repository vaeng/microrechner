#!/usr/bin/env python3

from flask import Flask, request, jsonify, render_template
from assembler.instruction import Instruction
from assembler.helpers import instructions2bytecode, runInstructions
from assembler.helpers import valid_registers

import argparse  # https://docs.python.org/3/library/argparse.html
import re

app = Flask(__name__)

# for the coloring of the text (pointer)
pointer_counter = -1 # -1 because of the request (we have to change the value)

# A welcome message to test our server
@app.route('/')
def index():
    return render_template("index_welcome.html")

@app.route('/demo', methods=['GET', 'POST'])
def empty_form():
    instructions = request.form.get('Instructions')
    bytecode = {}
    machine_state = {}

    machine_state_init = {}
    register = {}
    ram = {}
    machine_state_init["register"] = register
    machine_state_init["ram"] = ram
    lines = None

    switch = False # on off for demo.html for coloring

    if instructions or "compile" in request.form.keys():
        switch = True
        try:
            bytecode = instructions2bytecode(instructions.splitlines())
            for i in valid_registers:
                machine_state_init["register"][i] = 0
        except Exception as e:
            bytecode["error"] = str(e)
    else: # None
        instructions = ""

    if "run" in request.form.keys():
        try:
            machine_state = runInstructions(instructions.splitlines(), 1000)
            switch = False
        except Exception as e:
            bytecode = {}
            bytecode["error"] = str(e)
            
    if "step" in request.form.keys():
        print("hello")
        global pointer_counter
        lines = instructions.splitlines()
        codeline = lines[pointer_counter]
        pointer_counter += 1

        machine_state = runInstructions([codeline], 1000)

        pass # todo

    if "stop" in request.form.keys():
        pointer_counter = 0
        pass # todo

    
    return render_template("demo.html", instructions=instructions, bytecode=bytecode, reg_and_ram=machine_state, reg_and_ram2=machine_state_init, switch=switch, lines = lines)


if __name__ == '__main__':
    # Threaded option to enable multiple instances for multiple user access support
    app.run(threaded=True, port=5000)
