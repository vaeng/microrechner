#!/usr/bin/env python3

import sys
sys.path.append("lib/python3.9/site-packages/")

from flask import Flask, request, jsonify, render_template
from assembler.instruction import Instruction
from assembler.helpers import instructions2bytecode, runInstructions

import argparse  # https://docs.python.org/3/library/argparse.html
import re

app = Flask(__name__)

# A welcome message to test our server
@app.route('/')
def index():
    return "<h1>Welcome to our server !!</h1>"


@app.route('/demo', methods=['GET', 'POST'])
def empty_form():
    instructions = request.form.get('Instructions')
    bytecode = {}
    machine_state = {}
    if instructions:
        try:
            bytecode = instructions2bytecode(instructions.splitlines())
        except Exception as e:
            bytecode["error"] = str(e)
    else:
        instructions = ""
    if "run" in request.form.keys():
        machine_state = runInstructions(instructions.splitlines(), 1000)
    return render_template("demo.html", instructions=instructions, instrbytecode=bytecode, reg_and_ram=machine_state)


if __name__ == '__main__':
    # Threaded option to enable multiple instances for multiple user access support
    app.run(threaded=True, port=5001)
