# app.py
from flask import Flask, request, jsonify, render_template
from assembler.instruction import Instruction
from helpers import instructions2bytecode

import argparse  # https://docs.python.org/3/library/argparse.html
import reg  # https://docs.python.org/3/library/re.html
import re


app = Flask(__name__)


@app.route('/getmsg/', methods=['GET'])
def respond():
    # Retrieve the name from url parameter
    name = request.args.get("name", None)

    # For debugging
    print(f"got name {name}")

    response = {}

    # Check if user sent a name at all
    if not name:
        response["ERROR"] = "no name found, please send a name."
    # Check if the user entered a number not a name
    elif str(name).isdigit():
        response["ERROR"] = "name can't be numeric."
    # Now the user entered a valid name
    else:
        response["MESSAGE"] = f"Welcome {name} to our awesome platform!!"

    # Return the response in json format
    return jsonify(response)


@app.route('/post/', methods=['POST'])
def post_something():
    param = request.form.get('name')
    print(param)
    # You can add the test cases you made in the previous function, but in our case here you are just testing the POST functionality
    if param:
        return jsonify({
            "Message": f"Welcome {name} to our awesome platform!!",
            # Add this option to distinct the POST request
            "METHOD": "POST"
        })
    else:
        return jsonify({
            "ERROR": "no name found, please send a name."
        })

# A welcome message to test our server
@app.route('/')
def index():
    return "<h1>Welcome to our server !!</h1>"


@app.route('/demo', methods=['GET', 'POST'])
def empty_form():
    instructions = request.form.get('instructions')
    if instructions:
        try:
            bytecode = instructions2bytecode(instructions)
        except Exception as e:
            bytecode = ["error " + str(e)]
    else:
        instructions = ""
        bytecode = ""
    return render_template("demo.html", instructions=instructions, bytecode=bytecode)


if __name__ == '__main__':
    # Threaded option to enable multiple instances for multiple user access support
    app.run(threaded=True, port=5000)
