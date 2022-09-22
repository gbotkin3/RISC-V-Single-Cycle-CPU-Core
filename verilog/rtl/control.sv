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

module control
//IO
(
  `ifdef USE_POWER_PINS
      inout vccd1,	// User area 1 1.8V supply
      inout vssd1,	// User area 1 digital ground
  `endif
  
  input  logic       clk,
  input  logic       rst_n,
  input  logic [5:0] instruction_type,
  input  logic [6:0] opcode,
  
  output logic       mem_write_output,
  output logic       reg_write_output,
  output logic       jump_jal_output,
  output logic       jump_jalr_output,
  output logic       branch_output,
  output logic       immediate_sel_output

);

  logic mem_write = 1'b0;
  logic reg_write = 1'b0;
  logic jump_jal = 1'b0;
  logic jump_jalr = 1'b0;
  logic branch = 1'b0;
  logic immediate_sel = 1'b0;

  always_comb begin
  
    mem_write = 0;
    reg_write = 0;
    jump_jal = 0;
    jump_jalr = 0;
    branch = 0;
    immediate_sel = 0;

    case (instruction_type)
      
      // R-Type
      6'b000001: begin
        reg_write = 1;
        end
      // I-Type
      6'b000010: begin
        reg_write = 1;
        if (opcode == 7'b1100111)
          jump_jalr = 1;
        else
          jump_jalr = 0;
        immediate_sel = 1;        
        end
      // S-Type
      6'b000100: begin
        mem_write = 1;
        immediate_sel = 1;        
        end
      //B-Type        
      6'b001000: begin
        branch = 1;       
        end
      //U-Type
      6'b010000: begin
        reg_write = 1;
        immediate_sel = 1;        
        end
      //J-Type  
      6'b100000: begin
        reg_write = 1;
        jump_jal = 1;     
        end
      default: begin
        mem_write = 0;
        reg_write = 0;
        jump_jal = 0;
        jump_jalr = 0;
        branch = 0;
        immediate_sel = 0;        
        end
    endcase
  end
  
  assign mem_write_output = mem_write;
  assign reg_write_output = reg_write;
  assign jump_jal_output = jump_jal;
  assign jump_jalr_output = jump_jalr;
  assign branch_output = branch;
  assign immediate_sel_output = immediate_sel;

endmodule