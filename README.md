## Processor

## What is a ISA (short)
_"A Processor must execute a sequence of instructions, where each instruction performs some primitive operation, such as adding two numbers. An instruction is encoded in binary form as a sequence of 1 or more bytes. The instructions supported by a particular processor and their byte-level encodings are known as its instruction set architecture (ISA). Different “families” of processors, such as Intel IA32 and x86-64, IBM/Freescale Power, and the ARM processor family, have different ISAs. A program compiled for one type of machine will not run on another. On the other hand, there are many dif- ferent models of processors within a single family. Each manufacturer produces processors of ever-growing performance and complexity, but the different models remain compatible at the ISA level. Popular families, such as x86-64, have pro- cessors supplied by multiple manufacturers. Thus, the **ISA provides a conceptual/functional layer of abstraction between compiler writers, who need only know what instructions are permitted and how they are encoded, and processor designers, who must build machines that execute those instructions. (E.Bryant, Computer Systems (2016))**_

## How to build one?
  _Defining an instruction set architecture, such as RISC-V, includes defining the different components of its state, the set of instructions and their encodings, a set of programming conventions, and the handling of exceptional events. So the instruction set is used as a target for our processor implementations._


## CISC vs. RISC

| CISC        | RISC           |
| ------------- |:------------- |
| A large number of instructions| Many fewer instructions—typically less than 100 |
| Variable-size encodings. x86-64 instructions can range from 1 to 15 bytes      |    Fixed-length encodings. Typically all instructions are encoded as 4 bytes. |
| Arithmetic and logical operations can directly manipulate the RAM | Arithmetic and logical operations only use register operands (loa/store architecure      |

And many more....

## Encoding of the Instruction set
The encoding of a Instruction is there, because the Machine (CPU) doesn't understand any text.
So to resolve this the text must be encoded in a specific byte format (in RISC 32 Bit). So: Text -transform-> Byte -Input-> CPU.
% TODO

## Decoding of the Instruction set
The decoding plays a role in the CPU to "decode" the byte sequence via an AddressDecode (Demultiplexer). So if
we chunked the byte sequence, the demultiplexer gives those bytes to the other components of the CPU (like PC, ALU, Registerfile, ....)
% TODO


## Plan (objective)
Because the RISC-V architecture is flexible (backward -and forwardcompatible) we could extends a subset of one RISV-V
architecture with a subset of Instructions for ML based operations, i.e. [convulutions](https://en.wikipedia.org/wiki/Convolution) for CNNs, .... (Take ideas from the [Paper](ideas/ISA_ML.pdf))
% TODO




