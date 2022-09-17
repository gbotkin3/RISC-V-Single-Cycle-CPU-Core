# RISC-V Single Cycle Core

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

A first attempt at implementing a RV32I single-cycle risc-v core as a beginner to both verilog and system verilog, as well
as taking a RTL design through the tapeout process.

Known Issues:
1. ECALL / EBREAK are not implemented.
2. Control and Status Register Instructions are not implemented.
3. Timer and Counters as a result of issue 2 are also not implemented..

Desires and Goals to improve upon the core for future shuttles:
1. Implement a multi-cycle core
2. Implement a pipe-lined core
3. Implement a cache for data and instruction memory
4. Implement remaining extensions to classify as RV32G

Questions and Inquiries can be directed to gbotkin1999@gmail.com
