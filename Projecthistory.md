# Microrechner

## Projektplan

#### Projektplan 28.10.21
- PDF Lesen (RSB Prak, VHDL-Crash, [introCArch](https://tams.informatik.uni-hamburg.de/research/vlsi/vhdl/doc/ajmMaterial/introCArch.pdf)) bis zum nächsten Treffen
- RISC V sachen angucken (Ideen sammeln); Was ist RISC V?
- Befehlssatz Überlegen und verstehen was eine ISA ist?
  - Was sind Opcodes, Register(=bank), FlipFLops, Assembler vs. Assembly, Pipelining **Optional: Compiler (Aufbau Scanner --> Parser --> Assembly --> Opcode --> Hardware), Transitor, LUTs**
  - Logisim, Hades testen
- **HW (VHDL):** Bottom-Up Verfahren ALU, Register,.... (Jeder Block/Komponente in eine einzelne vhd Datei) --UP--> Chipsatz (Idee)
- **Software:** Python, Java, C, .... --schreiben--> Assembler --durch Funktion/Methoden (Decode, ....)--> Opcode (32-Bit dargestellt) (ISA-Simulator)

**(Eventuell Komponenten in Prozessen beschreiben ----- Speicher: Bereitstellung von generischen Speichermodel)**

#### Projektplan 4.11.21
  - Weiter lesen von den oberen sachen und zusätzlich mit dem Spec vertraut machen von RISCV RV32I base Integer ISA.
  - Bis nächste Woche ungefähr (11.11.21) einen ISA subset von RV32I bauen (natürlich nur spezifikation, also alles einhalten nicht nötig und möglich)
  - Programmers Perspective Kapitel 4 durchlesen (Mischung aus RISC und CISC)
