# RISC-V Single Cycle Core

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![UPRJ_CI]

A first attempt at implementing a RV32I single-cycle risc-v core as a beginner to both verilog and system verilog, as well
as taking a RTL design through the tapeout process.

Known Issues:
1. ECALL / EBREAK are not implemented.
2. Control and Status Register Instructions are not implemented.
3. Timer and Counters as a result of issue 2 are also not implemented.
4. Memory is currently writing on the next cycle instead of current cycle.

Desires and Goals to improve upon the core in the future (not in any specific order):
1. Implement a multi-cycle core
2. Implement a pipe-lined core
3. Implement a cache for data and instruction memory
4. Implement remaining extensions to classify as RV32G

Questions and Inquiries can be directed to gbotkin1999@gmail.com

Flow Process:

First clone the depository using:

Git Clone https://github.com/gbotkin3/RISC-V-Single-Cycle-CPU-Core

Then CD in the director and run:

source .source_efabless

(To Be Finished)
