# app.py
from flask import Flask, request, jsonify, render_template
from assembler.instruction import Instruction
from assembler.helpers import instructions2bytecode, runInstructions

import argparse  # https://docs.python.org/3/library/argparse.html
import reg  # https://docs.python.org/3/library/re.html
import re


app = Flask(__name__)

# A welcome message to test our server
@app.route('/')
def index():
    return "<h1>Welcome to our server !!</h1>"


@app.route('/demo', methods=['GET', 'POST'])
def empty_form():
    instructions = request.form.get('instructions')
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
        try:
            machine_state = runInstructions(instructions.splitlines(), 1000)
        except Exception as e:
            bytecode = {}
            bytecode["error"] = str(e)
    return render_template("demo.html", instructions=instructions, bytecode=bytecode, reg_and_ram=machine_state)


if __name__ == '__main__':
    # Threaded option to enable multiple instances for multiple user access support
    app.run(threaded=True, port=5000)
