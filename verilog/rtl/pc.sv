// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

 module pc
//IO
(
  `ifdef USE_POWER_PINS
      inout vccd1,	// User area 1 1.8V supply
      inout vssd1,	// User area 1 digital ground
  `endif
  
  input  logic         clk,
  input  logic         rst_n,
  input  logic  [31:0] rs1_data,
  input  logic  [31:0] immediate,
  input  logic         jump_jal,
  input  logic         jump_jalr,
  input  logic         branch,
  input  logic         alu_branch,
  
  output logic  [31:0] pc_out
);
  
  logic [31:0] pc = 0;
  logic [31:0] pc_plus_4;
  logic jalr_value = 0;
  
  always_ff @(posedge clk) begin
    if (!rst_n) pc <= 32'h00000000;
    else if (jump_jal) pc <= pc_out + immediate;
    else if (jump_jalr) pc <= pc_out + $signed(((rs1_data + immediate) >> 1) << 1); 
    else if (branch && alu_branch) pc <= pc_out + immediate;
    else pc <= pc_plus_4;
  end 
  
  assign pc_plus_4 = pc+4;
  assign pc_out = pc;

endmodule