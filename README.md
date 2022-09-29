# RISC-V Single Cycle Core

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

An implementation of a RV32I Single-Cycle Risc-V Core in System Verilog, as well
as taking a RTL design through the tapeout process in collaboration with Google and Efabless in the [Open MPW-7 Shuttle](https://platform.efabless.com/open_shuttle_program/7).

Known Issues:
1. ECALL / EBREAK are not implemented.
2. Control and Status Register Instructions are not implemented.
3. Timer and Counters as a result of issue 2 are also not implemented.

Desires and Goals to improve upon the core for future shuttles:
1. Implementing pipeling
2. Implementing data fowarding
3. Implementing Branch Prediction
4. Implementing Out of Order Execution
5. Implement remaining extensions to classify as RV32G

Questions and Inquiries can be directed to gbotkin1999@gmail.com

![image](https://user-images.githubusercontent.com/43323668/191842323-e9a00a59-504b-4b7b-8e08-63cccccec57a.png)
