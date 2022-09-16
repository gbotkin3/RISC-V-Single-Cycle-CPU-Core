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

set ::env(DESIGN_NAME) IMemory

set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/IMemory.sv"

set ::env(DESIGN_IS_CORE) 0

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "20"

set ::env(PL_BASIC_PLACEMENT) 0
set ::env(PL_TARGET_DENSITY) "0.52"
set ::env(GLB_RT_ADJUSTMENT) "0.25"
set ::env(FP_CORE_UTIL) 10
#set ::env(SYNTH_STRATEGY) "AREA 0"

set ::env(SYNTH_MAX_FANOUT) 25
set ::env(PL_RESIZER_MAX_SLEW_MARGIN) 40
set ::env(GLB_RESIZER_MAX_SLEW_MARGIN) 20

set ::env(PL_RESIZER_MAX_CAP_MARGIN) 40
set ::env(GLB_RESIZER_MAX_CAP_MARGIN) 20

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