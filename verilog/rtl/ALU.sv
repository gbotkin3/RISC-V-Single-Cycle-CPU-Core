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

module ALU
//IO
(
  `ifdef USE_POWER_PINS
      inout vccd1,	// User area 1 1.8V supply
      inout vssd1,	// User area 1 digital ground
  `endif
  
  input logic         clk,
  input logic         rst_n,
  input logic  [31:0] pc,
  input logic         reg_write,
  input logic  [5:0]  instruction_type,
  input logic  [6:0]  opcode,
  input logic  [4:0]  rd, 
  input logic  [4:0]  rs1, 
  input logic  [4:0]  rs2, 
  input logic  [2:0]  funct3, 
  input logic  [6:0]  funct7, 
  input logic  [31:0] immediate,
  input logic         immediate_sel,
  input logic  [31:0] read_data,
  
  input  logic [4:0]  la_reg_select, //Used to select logic to read from  
  
  output logic [31:0] alu_output,
  output logic [31:0] rs1_data,
  output logic [31:0] rs2_data,
  
  output logic [31:0] la_read_data //Data read from logic  
  
);

  //Setup 32 32-bit registers
  logic [31:0] Data_Registers[31:0];
  
  integer i;
  always_ff @(negedge clk) begin
    if (!rst_n) begin
      for (i=0;i<32;i=i+1)
        Data_Registers[i] = 0;
    end else begin
      if (reg_write && (rd != 0)) begin
        if (instruction_type == 6'b000010 && opcode == 7'b0000011) begin
          case (funct3)
            3'b000: Data_Registers[rd] <= {{24{read_data[7]}}, read_data[7:0]};
            3'b001: Data_Registers[rd] <= {{16{read_data[7]}}, read_data[15:0]};
            3'b010: Data_Registers[rd] <= read_data[31:0];
            3'b100: Data_Registers[rd] <= {{24{1'b0}}, read_data[7:0]};
            3'b101: Data_Registers[rd] <= {{16{1'b0}}, read_data[15:0]};
            default: Data_Registers[rd] <= read_data[31:0];
          endcase 
        end else begin
          Data_Registers[rd] = alu_output;
        end
      end
    end
  end
  
  always_ff @(posedge clk) begin 
    la_read_data <= Data_Registers[la_reg_select];  
  end
  
  // ALU
  always_ff @(posedge clk) begin  
    rs1_data <= Data_Registers[rs1];
    rs2_data <= Data_Registers[rs2];
  end  
  
  logic [5:0] aluctl;
  logic [31:0] alu_result;
  
  always_comb begin
    
  // r type instructions
    if ((opcode == 7'b0110011) & (funct3 == 3'b000) & (funct7 == 7'b0000000)) begin
      aluctl = 6'b000000; // ADD
      end
    else if ((opcode == 7'b0110011) & (funct3 == 3'b000) & (funct7 == 7'b0100000)) begin
      aluctl = 6'b000001; // SUB
      end
    else if ((opcode == 7'b0110011) & (funct3 == 3'b100) & (funct7 == 7'b0000000)) begin
      aluctl = 6'b000010; // XOR
      end
    else if ((opcode == 7'b0110011) & (funct3 == 3'b110) & (funct7 == 7'b0000000)) begin
      aluctl = 6'b000011; // OR
      end  
    else if ((opcode == 7'b0110011) & (funct3 == 3'b111) & (funct7 == 7'b0000000)) begin
      aluctl = 6'b000100; // AND
      end
    else if ((opcode == 7'b0110011) & (funct3 == 3'b001) & (funct7 == 7'b0000000)) begin
      aluctl = 6'b000101; // SLL (Shift Left Logical)
      end
    else if ((opcode == 7'b0110011) & (funct3 == 3'b101) & (funct7 == 7'b0000000)) begin
      aluctl = 6'b000110; // SRL (Shift Right Logical)
      end
    else if ((opcode == 7'b0110011) & (funct3 == 3'b101) & (funct7 == 7'b0100000)) begin
      aluctl = 6'b000111; // SRA (Shift Right Arith)      
      end
    else if ((opcode == 7'b0110011) & (funct3 == 3'b010) & (funct7 == 7'b0000000)) begin
      aluctl = 6'b001000; // SLT (Set Less Than)
      end
    else if ((opcode == 7'b0110011) & (funct3 == 3'b011) & (funct7 == 7'b0000000)) begin
      aluctl = 6'b001001; // SLT (U) (Set Less Than Unsigned)
      end
      
  // i-type instructions

    // Mathmatic Operations
    else if ((opcode == 7'b0010011) & (funct3 == 3'b000)) begin
      aluctl = 6'b000000; // ADDI
      end
    else if ((opcode == 7'b0010011) & (funct3 == 3'b100)) begin
      aluctl = 6'b000010; // XORI
      end
    else if ((opcode == 7'b0010011) & (funct3 == 3'b110)) begin
      aluctl = 6'b000011; // ORI
      end
    else if ((opcode == 7'b0010011) & (funct3 == 3'b111)) begin
      aluctl = 6'b000100; // ANDI
      end
    else if ((opcode == 7'b0010011) & (funct3 == 3'b001) & (immediate[11:5] == 0)) begin
      aluctl = 6'b000101; // SLLI
      end
    else if ((opcode == 7'b0010011) & (funct3 == 3'b101) & (immediate[11:5] == 0)) begin
      aluctl = 6'b000110; // SRLI
      end
    else if ((opcode == 7'b0010011) & (funct3 == 3'b101) & (immediate[11:5] == 6'b000001)) begin
      aluctl = 6'b000111; // SRAI
      end
    else if ((opcode == 7'b0010011) & (funct3 == 3'b010)) begin
      aluctl = 6'b001000; // SLTI
      end
    else if ((opcode == 7'b0010011) & (funct3 == 3'b011)) begin
      aluctl = 6'b001001; // SLTI (U)
      end
    
    // Load Operations
    else if ((opcode == 7'b0000011) & (funct3 == 3'b000)) begin
      aluctl = 6'b000000; // LB
      end
    else if ((opcode == 7'b0000011) & (funct3 == 3'b001)) begin
      aluctl = 6'b000000; // LH
      end
    else if ((opcode == 7'b0000011) & (funct3 == 3'b010)) begin
      aluctl = 6'b000000; // LW
      end
    else if ((opcode == 7'b0000011) & (funct3 == 3'b100)) begin
      aluctl = 6'b000000; // LBU
      end 
    else if ((opcode == 7'b0000011) & (funct3 == 3'b101)) begin
      aluctl = 6'b000000; // LHU
      end
    
    // Jump and Link Operation
    else if ((opcode == 7'b1100111) & (funct3 == 3'b000)) begin
      aluctl = 6'b011000; // JALR
      end
    
    // Environment Operations   
    else if ((opcode == 7'b1110011) & (funct3 == 3'b000) & (immediate == 0)) begin
      aluctl = 6'b011001; // ECALL  (TODO)
      end
    else if ((opcode == 7'b1110011) & (funct3 == 3'b000) & (immediate == 1)) begin
      aluctl = 6'b011010; // EBREAK (TODO)
      end
      
    // CSR Instructions

    // TODO
    
  // s-type instructions 

    else if ((opcode == 7'b0100011) & (funct3 == 3'b000)) begin
      aluctl = 6'b000000; // SB
      end
    else if ((opcode == 7'b0100011) & (funct3 == 3'b001)) begin
      aluctl = 6'b000000; // SH
      end
    else if ((opcode == 7'b0100011) & (funct3 == 3'b010)) begin
      aluctl = 6'b000000; // SW
      end

  // b-type instructions

    else if ((opcode == 7'b1100011) & (funct3 == 3'b000)) begin
      aluctl = 6'b011110; // BEQ
      end
    else if ((opcode == 7'b1100011) & (funct3 == 3'b001)) begin
      aluctl = 6'b011111; // BNE
      end
    else if ((opcode == 7'b1100011) & (funct3 == 3'b100)) begin
      aluctl = 6'b100000; // BLT  
      end
    else if ((opcode == 7'b1100011) & (funct3 == 3'b101)) begin
      aluctl = 6'b100001; // BGE
      end
    else if ((opcode == 7'b1100011) & (funct3 == 3'b110)) begin
      aluctl = 6'b100010; // BLTU
      end
    else if ((opcode == 7'b1100011) & (funct3 == 3'b111)) begin
      aluctl = 6'b100011; // BGEU 
      end
      
  // j-type instructions

    else if ((opcode == 7'b1101111)) begin
      aluctl = 6'b100100; // JAL  
      end
    
  // u-type instructions

    else if ((opcode == 7'b0110111)) begin
      aluctl = 6'b100101; // LUI  
      end
    else if ((opcode == 7'b0010111)) begin
      aluctl = 6'b100110; // AUIPC  
      end
      
    else aluctl = 6'b111111; // Error
      
  end
   
  //Selects input to ALU
  logic a_input;
  logic b_input;
  
  assign a_input = rs1_data;
  assign b_input = immediate_sel ? immediate : rs2_data;

  // use alu_ctl to set alu_result
  always_comb begin
    case (aluctl)
      6'b000000: alu_result = a_input + b_input;   // ADD / ADDI / LB / LH / LW / LBU / LHU / SB / SH / SW
      6'b000001: alu_result = a_input - b_input; // SUB
      6'b000010: alu_result = a_input ^ b_input; // XOR / XORI
      6'b000011: alu_result = a_input | b_input; // OR / ORI
      6'b000100: alu_result = a_input & b_input; // AND / ANI
      6'b000101: alu_result = a_input << b_input;  // SLL / SLLI
      6'b000110: alu_result = a_input >> b_input;  // SRL / SRLI
      6'b000111: alu_result = a_input >>> b_input; // SRA / SRAI
      6'b001000: alu_result = (a_input < b_input) ? 1 : 0; // SLT / SLTI
      6'b001001: alu_result = (a_input < b_input) ? 1 : 0; // SLTU / SLTIU
      6'b011000: alu_result = pc + 4;  // JALR
      6'b011001: alu_result = 0; // ECALL // (NOT OPERATIONAL)
      6'b011010: alu_result = 0; // EBREAK // (NOT OPERATIONAL)
      6'b011110: alu_result = (a_input == b_input);  // BEQ
      6'b011111: alu_result = (a_input != b_input);  // BNE
      6'b100000: alu_result = (a_input < b_input); // BLT
      6'b100001: alu_result = (a_input >= b_input);  // BGE
      6'b100010: alu_result = (a_input < b_input); // BLTU //NEED TO ZERO EXTEND
      6'b100011: alu_result = (a_input >= b_input);  // BGEU //NEED TO ZERO EXTEND
      6'b100100: alu_result = pc + 4;  // JAL
      6'b100101: alu_result = b_input;  // LUI
      6'b100110: alu_result = pc + b_input; // AUIPC
      default: alu_result = 0;
    endcase
      
  end 
  
  assign alu_output = alu_result;

endmodule