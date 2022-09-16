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

module RISC_V 
// IO
(
  `ifdef USE_POWER_PINS
      inout vccd1,	// User area 1 1.8V supply
      inout vssd1,	// User area 1 digital ground
  `endif

    // Logic Analyzer Signals
    input  logic [127:0] la_data_in,
    output logic [127:0] la_data_out,
    input  logic [127:0] la_oenb,
    input  logic clk

);

  logic rst_n;

  // LA
  
  assign la_data_out[127:96] = 0;
  
  // LA To Access and Read DRAM
  logic [3:0] la_dram_select;
  logic [31:0] la_read_dram_data;
  
  assign la_dram_select[3:0] = la_data_in[41:37];
  assign la_data_out[63:32] = la_read_dram_data[31:0];
  
  // LA To Access, Read, and Write IRAM
  logic la_instruction_write;
  logic [3:0] la_instruction_select;
  logic [31:0] la_instruction_input;
  logic [31:0] la_read_iram_data;
  
  assign la_instruction_write = la_data_in[36];
  assign la_instruction_select[3:0] = la_data_in[35:32];
  assign la_instruction_input[31:0] = la_data_in[31:0];
  
  assign la_data_out[31:0] = la_read_iram_data[31:0];
  
  // LA To Acces and Read Registers
  
  logic [4:0] la_reg_select;
  logic [31:0] la_read_reg_data;
  
  assign la_reg_select[4:0] = la_data_in[46:42];
  assign la_data_out[95:64] = la_read_reg_data[31:0];  
  
  // Assuming LA probes [48:47] are for controlling the clk & reset  
  assign rst_n = la_data_in[47];
    
	// Control Wires
	logic mem_write;
	logic reg_write;
	logic jump_jal;
	logic jump_jalr;
	logic branch;
  logic immediate_sel;
	
	//PC Wires
	logic [31:0] pc;
	
	//Imemory Wires
	logic [5:0] instruction_type;
	logic [6:0] opcode;
	logic [4:0] rd;
	logic [4:0] rs1;
	logic [4:0] rs2;
	logic [2:0] funct3;
	logic [6:0] funct7;
	logic [31:0] immediate;
	
	//DMemory Wires
	
	logic [31:0] read_data;
	logic [31:0] rs1_data;
	logic [31:0] rs2_data;
	
	//ALU Wires
	
	logic [31:0] alu_output;

	control control(
  
	//Inputs
	.clk(clk),
	.rst_n(rst_n),
	.instruction_type(instruction_type),
	.opcode(opcode),
	//Outputs
	.mem_write_output(mem_write),
	.reg_write_output(reg_write),
	.jump_jal_output(jump_jal),
	.jump_jalr_output(jump_jalr),
	.branch_output(branch),
  .immediate_sel_output(immediate_sel)
	);

	pc pc_module (
  
	//Inputs
	.clk(clk),
	.rst_n(rst_n),
	.rs1_data(rs1_data),
	.immediate(immediate),
	.jump_jal(jump_jal),
	.jump_jalr(jump_jalr),
	.branch(branch),
	.alu_branch(alu_output[0]),
	//Outputs
	.pc_out(pc)
	);

	IMemory IMemory (
  
	//Inputs
	.clk(clk),
	.rst_n(rst_n),
	.pc(pc),
  .la_instruction_input(la_instruction_input),
  .la_instruction_select(la_instruction_select),
  .la_instruction_write(la_instruction_write),
	//Outputs
	.instruction_type_output(instruction_type),
	.opcode(opcode),
	.rd(rd),
	.rs1(rs1),
	.rs2(rs2),
	.funct3(funct3),
	.funct7(funct7),
	.immediate(immediate),
  .la_instruction_read(la_read_iram_data)

	);

	DMemory DMemory (
  
	//Inputs
	.clk(clk),
	.rst_n(rst_n),
	.mem_write(mem_write),
	.rd(rd),
	.funct3(funct3),
	.memory_address(alu_output),
	.write_data(rs2_data),
  .la_dram_select(la_dram_select),
	//Outputs
	.read_data(read_data),
  .la_read_data(la_read_dram_data)
	);

	ALU ALU (
  
	//Inputs
	.clk(clk),
	.rst_n(rst_n),
	.pc(pc),
	.reg_write(reg_write),
	.instruction_type(instruction_type),
	.opcode(opcode),
	.rd(rd),
	.rs1(rs1),
	.rs2(rs2),
	.funct3(funct3),
	.funct7(funct7),
	.immediate(immediate),
  .immediate_sel(immediate_sel),
	.read_data(read_data),
  .la_reg_select(la_reg_select),  
  
		
	//Outputs
	.alu_output(alu_output),
	.rs1_data(rs1_data),
	.rs2_data(rs2_data),
  .la_read_data(la_read_reg_data)  
	);
  
 endmodule