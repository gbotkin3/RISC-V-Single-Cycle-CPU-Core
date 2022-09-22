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

module IMemory
//IO
(
  `ifdef USE_POWER_PINS
      inout vccd1,	// User area 1 1.8V supply
      inout vssd1,	// User area 1 digital ground
  `endif
  
  input  logic        clk,
  input  logic        rst_n,
  input  logic [31:0] pc,
  
  input  logic [31:0] la_instruction_input,  //Used to write instructions
  input  logic [3:0]  la_instruction_select, //Used to select which instruction
  input  logic        la_instruction_write,  //Enable instruction writing

  output logic [5:0]  instruction_type_output,
  output logic [6:0]  opcode,
  output logic [4:0]  rd,
  output logic [4:0]  rs1,
  output logic [4:0]  rs2,
  output logic [2:0]  funct3,
  output logic [6:0]  funct7,
  output logic [31:0] immediate,
  
  output logic [31:0] la_instruction_read

);

  logic [31:0] iram[0:16];
  logic [31:0] instruction;
  
  always_ff  @(negedge clk) begin
    if (!rst_n && !la_instruction_write) begin
    
      /*
      RISC-V Instruction Format Broken Out Into Binary Below:
      R-Type: (funct7 / rs2 / rs1 / funct3 / rd / opcode)
      32'b 0000000_00000_00000_000_00000_0000000;
      I-Type: (imm[11:0] / rs1 / funct3 / rd / opcode)
      32'b 000000000000_00000_000_00000_0000000;
      S-Type: (imm[11:5] / rs2 / rs1 / funct3 / imm[4:0] / opcode)
      32'b 0000000_00000_00000_000_00000_0000000;
      B-Type: (imm[12] / imm[10:5] / rs2 / rs1 / funct3 / imm[4:1] / imm[11] / opcode)
      32'b 0_000000_00000_00000_000_0000_0_0000000;         
      U-Type: (imm[31:12] / rd / opcode)
      32'b 00000000000000000000_00000_0000000;
      J-Type: (imm[20] / imm[10:1] / imm[11] / imm[19:12] / rd / opcode)
      32'b 0_0000000000_0_00000000_00000_0000000;     
      */
    
      iram[0] <= 32'b 000000111100_00000_000_00001_0010011; // addi x1, x0, 60
      iram[1] <= 32'b 0000000_00000_00000_010_00000_0100011; // sw x0, x0(0)
      iram[2] <= 32'b 000000000000_00000_010_00010_0000011; //lw x2, x0(0)
      iram[3] <= 32'b 0_000000_00010_00001_000_1000_0_1100011; //beq x1, x2, 4
      iram[4] <= 32'b 000000000001_00010_000_00010_0010011; // addi x2, x2, 1
      iram[5] <= 32'b 0000000_00010_00000_010_00000_0100011; // sw x2, x0(0)
      iram[6] <= 32'b 111111110000_00000_000_00000_1100111; // jalr x0, -16
      iram[7] <= 32'h 00000000;
      iram[8] <= 32'h 00000000;
      iram[9] <= 32'h 00000000;
      iram[10] <= 32'h 00000000;
      iram[11] <= 32'h 00000000;
      iram[12] <= 32'h 00000000;
      iram[13] <= 32'h 00000000;
      iram[14] <= 32'h 00000000;
      iram[15] <= 32'b 1_1111100010_1_11111111_00000_1101111; //jal x0, -60 (reset to 0)
      
    end else if (la_instruction_write) begin
      iram[la_instruction_select] <= la_instruction_input;
    end
  end
 
  always_ff  @(posedge clk) begin 
    la_instruction_read <= iram[la_instruction_select];
    instruction <= iram[(pc>>2)];
  end

  
  logic r_type;
  logic i_type;
  logic s_type;
  logic b_type;
  logic u_type;
  logic j_type;
  logic [5:0] instruction_type;
  
  always_comb begin
   
    r_type = (opcode == 7'b0110011) ? 1 : 0;
    i_type = ((opcode == 7'b0010011) || (opcode == 7'b0000011) || (opcode == 7'b1100111)
        || (opcode == 7'b1110011)) ? 1 : 0;
    s_type = (opcode == 7'b0100011) ? 1 : 0;
    b_type = (opcode == 7'b1100011) ? 1 : 0;
    u_type = ((opcode == 7'b0110111) || (opcode == 7'b0010111)) ? 1 : 0;
    j_type = (opcode == 7'b1101111) ? 1 : 0;
    instruction_type = {j_type, u_type, b_type, s_type, i_type, r_type};
  
  end
  
  assign instruction_type_output = instruction_type;
  
  //Wires to break out instruction for various different instruction types
  assign opcode = instruction[6:0];
  
  assign rd = instruction[11:7];
  
  assign rs1 = instruction[19:15];
  assign rs2 = instruction[24:20];
  
  assign funct3 = instruction[14:12];
  assign funct7 = instruction[31:25];
  
  //All immediates are sign extended
  
  assign i_type_immediate = {{20{instruction[31]}}, instruction[31:20]};
  
  assign s_type_immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
  
  assign b_type_immediate = {{19{instruction[31]}}, instruction[31], instruction[7], 
      instruction[30:25], instruction[11:8], {1{1'b0}}};
  
  assign u_type_immediate = {instruction[31:12], {12{1'b0}}};
  
  assign j_type_immediate = {{11{instruction[31]}}, instruction[31], instruction[19:12], 
      instruction[20], instruction[30:21], {1{1'b0}}};

  logic immediate_reg;
  assign immediate = immediate_reg;

  always_comb begin

    case (instruction_type)
      // R-Type
      6'b000001: begin
        immediate_reg = 0;
        end
      // I-Type
      6'b000010: begin
        immediate_reg = i_type_immediate;
        end
      // S-Type
      6'b000100: begin
        immediate_reg = s_type_immediate;
        end
      //B-Type        
      6'b001000: begin
        immediate_reg = b_type_immediate;
        end
      //U-Type
      6'b010000: begin
        immediate_reg = u_type_immediate;
        end
      //J-Type  
      6'b100000: begin
        immediate_reg = j_type_immediate;
        end
      default: begin
        immediate_reg = 0;
        end
    endcase
  end

endmodule