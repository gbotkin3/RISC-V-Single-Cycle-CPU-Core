# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

set ::env(PDK) $::env(PDK)
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) RISC_V

set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/RISC_V.sv \
	$script_dir/../../verilog/rtl/ALU.sv \
	$script_dir/../../verilog/rtl/control.sv \
	$script_dir/../../verilog/rtl/DMemory.sv \
	$script_dir/../../verilog/rtl/IMemory.sv \
	$script_dir/../../verilog/rtl/pc.sv"
  
set ::env(DESIGN_IS_CORE) 0

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) 1000

set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) "0 0 2500 2500"

set ::env(PL_TARGET_DENSITY) "0.52"
set ::env(GLB_RT_ADJUSTMENT) "0.25"

set ::env(SYNTH_MAX_FANOUT) 10

set ::env(ROUTING_CORES) 4

# Maximum layer used for routing is metal 4.
# This is because this macro will be inserted in a top level (user_project_wrapper) 
# where the PDN is planned on metal 5. So, to avoid having shorts between routes
# in this macro and the top level metal 5 stripes, we have to restrict routes to metal4.  
# 
set ::env(RT_MAX_LAYER) {met4}

# You can draw more power domains if you need to 
set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]

set ::env(DIODE_INSERTION_STRATEGY) 4 
# If you're going to use multiple power domains, then disable cvc run.
set ::env(RUN_CVC) 1
