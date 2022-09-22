###############################################################################
# Created by write_sdc
# Tue Sep 20 18:49:11 2022
###############################################################################
current_design control
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk -period 1000.0000 [get_ports {clk}]
set_clock_transition 0.1500 [get_clocks {clk}]
set_clock_uncertainty 0.2500 clk
set_propagated_clock [get_clocks {clk}]
set_input_delay 200.0000 -clock [get_clocks {clk}] -add_delay [get_ports {instruction_type[0]}]
set_input_delay 200.0000 -clock [get_clocks {clk}] -add_delay [get_ports {instruction_type[1]}]
set_input_delay 200.0000 -clock [get_clocks {clk}] -add_delay [get_ports {instruction_type[2]}]
set_input_delay 200.0000 -clock [get_clocks {clk}] -add_delay [get_ports {instruction_type[3]}]
set_input_delay 200.0000 -clock [get_clocks {clk}] -add_delay [get_ports {instruction_type[4]}]
set_input_delay 200.0000 -clock [get_clocks {clk}] -add_delay [get_ports {instruction_type[5]}]
set_input_delay 200.0000 -clock [get_clocks {clk}] -add_delay [get_ports {opcode[0]}]
set_input_delay 200.0000 -clock [get_clocks {clk}] -add_delay [get_ports {opcode[1]}]
set_input_delay 200.0000 -clock [get_clocks {clk}] -add_delay [get_ports {opcode[2]}]
set_input_delay 200.0000 -clock [get_clocks {clk}] -add_delay [get_ports {opcode[3]}]
set_input_delay 200.0000 -clock [get_clocks {clk}] -add_delay [get_ports {opcode[4]}]
set_input_delay 200.0000 -clock [get_clocks {clk}] -add_delay [get_ports {opcode[5]}]
set_input_delay 200.0000 -clock [get_clocks {clk}] -add_delay [get_ports {opcode[6]}]
set_input_delay 200.0000 -clock [get_clocks {clk}] -add_delay [get_ports {rst_n}]
set_output_delay 200.0000 -clock [get_clocks {clk}] -add_delay [get_ports {branch_output}]
set_output_delay 200.0000 -clock [get_clocks {clk}] -add_delay [get_ports {immediate_sel_output}]
set_output_delay 200.0000 -clock [get_clocks {clk}] -add_delay [get_ports {jump_jal_output}]
set_output_delay 200.0000 -clock [get_clocks {clk}] -add_delay [get_ports {jump_jalr_output}]
set_output_delay 200.0000 -clock [get_clocks {clk}] -add_delay [get_ports {mem_write_output}]
set_output_delay 200.0000 -clock [get_clocks {clk}] -add_delay [get_ports {reg_write_output}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {branch_output}]
set_load -pin_load 0.0334 [get_ports {immediate_sel_output}]
set_load -pin_load 0.0334 [get_ports {jump_jal_output}]
set_load -pin_load 0.0334 [get_ports {jump_jalr_output}]
set_load -pin_load 0.0334 [get_ports {mem_write_output}]
set_load -pin_load 0.0334 [get_ports {reg_write_output}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {clk}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {rst_n}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {instruction_type[5]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {instruction_type[4]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {instruction_type[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {instruction_type[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {instruction_type[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {instruction_type[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {opcode[6]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {opcode[5]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {opcode[4]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {opcode[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {opcode[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {opcode[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {opcode[0]}]
set_timing_derate -early 0.9500
set_timing_derate -late 1.0500
###############################################################################
# Design Rules
###############################################################################
set_max_fanout 10.0000 [current_design]
