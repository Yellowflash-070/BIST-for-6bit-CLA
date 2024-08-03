# BIST-for-6bit-CLA
A Built in Self Test (BIST) controller is created in Verilog HDL to test a 6-bit Carry Lookahead Adder (CLA) utilising a 4-bit Signature Output Response Analyser (ORA).

<br>

## What is a Carry Lookahead Adder?

A Carry Lookahead Adder (CLA) is a digital circuit used in computer arithmetic to perform fast addition of multi-bit numbers. Unlike simpler adders like the Ripple Carry Adder (RCA), which can be slow for large inputs due to the propagation delay of carry bits, a CLA reduces this delay by generating carry signals for each bit position in parallel. This parallel generation allows the carry signal for each bit position to be determined independently of the carry-in signal, resulting in faster addition. CLAs are widely used in digital design for applications requiring high-speed arithmetic operations, such as microprocessors and digital signal processors.

<br>

## Structure of a BIST Controller

![image](https://github.com/user-attachments/assets/0781b7e5-0980-496b-b4a0-5e3aed3378a2) <br> Fig 1: Block Diagram of a BIST Controller <br><br>

Our BIST controller Works in the following two modes: <br><br>
**Mode 0 (Normal Mode) :** In this mode, the CLA generates the output leading to Golden Signature <br>
**Mode 1 (Test Mode) :** In this mode, the CLA generates the output leading to the Faulty Signature and the comparison takes place with the Golden signature. <br>

We have taken two LFSR (type1) to generate test vectors for both the inputs of CLA (A & B - CUT), we have kept an ENL signal which enables both the type 1 LFSR’s. <br>

The Output of the CUT(CLA) goes into SISR (LFSR type 2) which generates a 4bit signature when ENS (Enable SISR) signal is enable. <br>

The ENC signal functions as a flag during signature generation in the Serial Input Shift Register (SISR). When processing a specific pattern, the ENC signal is initially low. Upon completion of signature
generation, the ENC signal transitions to a high state. Consequently, the detection of a high ENC signal by the comparator or memory indicates that a signature has been successfully generated at
the output of the SISR. <br> <br>

## Simulation Waveform

![image](https://github.com/user-attachments/assets/9a9cd20b-97dc-4dbf-922f-2a3cd90b5c54)  <br> Fig 2: Simulation Waveform <br><br>

In this simulation, we implement a Built-In Self-Test (BIST) architecture with two modes. In the first mode, we create 14 distinct patterns using Linear Feedback Shift Register (LFSR) and
obtain corresponding golden signatures for each pattern. These golden signatures are stored in a memory array of size 4 x 14. <br>

In the second mode, we introduce a fault in the carry-out of the Carry Look-Ahead (CLA) circuit. We then generate signatures for each pattern using the LFSR and compare them against
the golden signatures to classify Integrated Circuits (ICs) as either functioning properly or faulty. <br>





