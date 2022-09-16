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

module DMemory
//IO
(
  input  logic         clk,
  input  logic         rst_n,
  input  logic         mem_write,
  input  logic  [4:0]  rd,
  input  logic  [2:0]  funct3,
  input  logic  [31:0] memory_address,
  input  logic  [31:0] write_data,
  
  input  logic  [3:0] la_dram_select, //Used to select ram to read from
  
  output logic [31:0]  read_data,
  
  output logic [31:0]  la_read_data //Data read from ram

);

  logic [31:0] dram[0:15];
  
  //Write to Memory
  integer i;
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      for (i=0;i<15;i=i+1) begin
        dram[i] = 32'h00000000;
      end
    end else if (mem_write) begin
      case (funct3)
        3'b000: dram[memory_address][31:0] <= {{24{1'b0}}, write_data[7:0]};
        3'b001: dram[memory_address][31:0] <= {{16{1'b0}}, write_data[15:0]};
        3'b010: dram[memory_address][31:0] <= write_data[31:0];
        default: dram[memory_address] <= write_data;
      endcase
    end 
  end
  
  //Read from Memory
  assign read_data = dram[memory_address];
  assign la_read_data = dram[la_dram_select];

endmodule