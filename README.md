# Caravel User Project

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![UPRJ_CI](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml) [![Caravel Build](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml)

A first attempt at implementing a RV32I single-cycle risc-v core as a beginner to both verilog and system verilog, as well
as taking a RTL design through the tapeout process.

Known Issues:
1. ECALL / EBREAK are not operational
2. Control and Status Register Instructions are also not working
3. Timer and Counters as a result of 2 are also not working

Desires and Goals to improve upon the core in the future (not in any specific order):
1. Implement a multi-cycle core
2. Implement a pipe-lined core
3. Implement a cache for data memory
4. Implement remaning extenstions to classify as RV32G

Questions and Inquiries can be directed to gbotkin1999@gmail.com
