// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
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
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,
    input clk

);

  wire rst_n;

  // LA
  
  assign la_data_out[127:96] = 0;
  
  // LA To Access and Read DRAM
  wire [3:0] la_dram_select;
  wire [31:0] la_read_dram_data;
  
  assign la_dram_select[3:0] = la_data_in[41:37];
  assign la_data_out[63:32] = la_read_dram_data[31:0];
  
  // LA To Access, Read, and Write IRAM
  wire la_instruction_write;
  wire [3:0] la_instruction_select;
  wire [31:0] la_instruction_input;
  wire [31:0] la_read_iram_data;
  
  assign la_instruction_write = la_data_in[36];
  assign la_instruction_select[3:0] = la_data_in[35:32];
  assign la_instruction_input[31:0] = la_data_in[31:0];
  
  assign la_data_out[31:0] = la_read_iram_data[31:0];
  
  // LA To Acces and Read Registers
  
  wire [4:0] la_reg_select;
  wire [31:0] la_read_reg_data;
  
  assign la_reg_select[4:0] = la_data_in[46:42];
  assign la_data_out[95:64] = la_read_reg_data[31:0];  
  
  // Assuming LA probes [48:47] are for controlling the clk & reset  
  assign rst_n = la_data_in[47];
    
	// Control Wires
	wire mem_write;
	wire reg_write;
	wire jump_jal;
	wire jump_jalr;
	wire branch;
  wire immediate_sel;
	
	//PC Wires
	wire [31:0] pc;
	
	//Imemory Wires
	wire [5:0] instruction_type;
	wire [6:0] opcode;
	wire [4:0] rd;
	wire [4:0] rs1;
	wire [4:0] rs2;
	wire [2:0] funct3;
	wire [6:0] funct7;
	wire [31:0] immediate;
	
	//DMemory Wires
	
	wire [31:0] read_data;
	wire [31:0] rs1_data;
	wire [31:0] rs2_data;
	
	//ALU Wires
	
	wire [31:0] alu_output;

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
 
 module pc
//IO
(

  input  wire         clk,
  input  wire         rst_n,
  input  wire  [31:0] rs1_data,
  input  wire  [31:0] immediate,
  input  wire         jump_jal,
  input  wire         jump_jalr,
  input  wire         branch,
  input  wire         alu_branch,
  
  output wire  [31:0] pc_out
);
  
  reg [31:0] pc = 0;
  wire [31:0] pc_plus_4;
  reg jalr_value = 0;
  
  always @(posedge clk) begin
    if (!rst_n) pc <= 32'h00000000;
    else if (jump_jal) pc <= pc_out + immediate;
    else if (jump_jalr) pc <= pc_out + $signed(((rs1_data + immediate) >> 1) << 1); 
    else if (branch && alu_branch) pc <= pc_out + immediate;
    else pc <= pc_plus_4;
  end 
  
  assign pc_plus_4 = pc+4;
  assign pc_out = pc;

endmodule

module ALU
//IO
(

  input wire         clk,
  input wire         rst_n,
  input wire [31:0]  pc,
  input wire         reg_write,
  input wire  [5:0]  instruction_type,
  input wire  [6:0]  opcode,
  input wire  [4:0]  rd, 
  input wire  [4:0]  rs1, 
  input wire  [4:0]  rs2, 
  input wire  [2:0]  funct3, 
  input wire  [6:0]  funct7, 
  input wire  [31:0] immediate,
  input wire         immediate_sel,
  input wire  [31:0] read_data,
  
  input  wire  [4:0] la_reg_select, //Used to select reg to read from  
  
  output wire [31:0] alu_output,
  output wire [31:0] rs1_data,
  output wire [31:0] rs2_data,
  
  output wire [31:0]  la_read_data //Data read from reg  
  
);

  //Setup 32 32-bit registers
  reg [31:0] Data_Registers[31:0];
  
  integer i;
  always @(posedge clk) begin
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
  
  assign la_read_data = Data_Registers[la_reg_select];  
  
  // ALU
  
  assign rs1_data = Data_Registers[rs1];
  assign rs2_data = Data_Registers[rs2];
  
  reg [5:0] aluctl;
  reg [31:0] alu_result;
  
  always @(*) begin
    
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
  wire a_input;
  wire b_input;
  
  assign a_input = rs1_data;
  assign b_input = immediate_sel ? immediate : rs2_data;

  // use alu_ctl to set alu_result
  always @(*) begin
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

module IMemory
//IO
(

  input  wire        clk,
  input  wire        rst_n,
  input  wire [31:0] pc,
  
  input  wire [31:0] la_instruction_input,  //Used to write instructions
  input  wire [3:0]  la_instruction_select, //Used to select which instruction
  input  wire        la_instruction_write,  //Enable instruction writing

  output wire [5:0]  instruction_type_output,
  output wire [6:0]  opcode,
  output wire [4:0]  rd,
  output wire [4:0]  rs1,
  output wire [4:0]  rs2,
  output wire [2:0]  funct3,
  output wire [6:0]  funct7,
  output wire [31:0] immediate,
  
  output wire [31:0] la_instruction_read

);

  reg [31:0] iram[0:16];
  wire [31:0] instruction;
  
  always @ (posedge clk) begin
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
      iram[la_instruction_select] = la_instruction_input;
    end
  end
  
  assign la_instruction_read = iram[la_instruction_select];
  
  //read instruction
  assign instruction = iram[(pc>>2)];
  
  reg r_type;
  reg i_type;
  reg s_type;
  reg b_type;
  reg u_type;
  reg j_type;
  reg [5:0] instruction_type;
  
  always @(*) begin
   
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

  reg immediate_reg;
  assign immediate = immediate_reg;

  always @(*) begin

    case (instruction_type)
      // R-Type
      6'b000001: begin
        immediate_reg <= 0;
        end
      // I-Type
      6'b000010: begin
        immediate_reg <= i_type_immediate;
        end
      // S-Type
      6'b000100: begin
        immediate_reg <= s_type_immediate;
        end
      //B-Type        
      6'b001000: begin
        immediate_reg <= b_type_immediate;
        end
      //U-Type
      6'b010000: begin
        immediate_reg <= u_type_immediate;
        end
      //J-Type  
      6'b100000: begin
        immediate_reg <= j_type_immediate;
        end
      default: begin
        immediate_reg <= 0;
        end
    endcase
  end


endmodule

module DMemory
//IO
(
  input  wire         clk,
  input  wire         rst_n,
  input  wire         mem_write,
  input  wire  [4:0]  rd,
  input  wire  [2:0]  funct3,
  input  wire  [31:0] memory_address,
  input  wire  [31:0] write_data,
  
  input  wire  [3:0] la_dram_select, //Used to select ram to read from
  
  output wire [31:0]  read_data,
  
  output wire [31:0]  la_read_data //Data read from ram

);

  reg [31:0] dram[0:15];
  
  //Write to Memory
  integer i;
  always @(posedge clk) begin
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

module control
//IO
(

  input  wire       clk,
  input  wire       rst_n,
  input  wire [5:0] instruction_type,
  input  wire [6:0] opcode,
  
  output wire       mem_write_output,
  output wire       reg_write_output,
  output wire       jump_jal_output,
  output wire       jump_jalr_output,
  output wire       branch_output,
  output wire       immediate_sel_output

);

  reg mem_write = 0;
  reg reg_write = 0;
  reg jump_jal = 0;
  reg jump_jalr = 0;
  reg branch = 0;
  reg immediate_sel = 0;

  always @(*) begin

    case (instruction_type)
      // R-Type
      6'b000001: begin
        mem_write <= 0;
        reg_write <= 1;
        jump_jal <= 0;
        jump_jalr <= 0;
        branch <= 0;
        immediate_sel <= 0;
        end
      // I-Type
      6'b000010: begin
        mem_write <= 0;
        reg_write <= 1;
        jump_jal <= 0;
        if (opcode == 7'b1100111)
          jump_jalr <= 1;
        else
          jump_jalr <= 0;
        branch <= 0;
        immediate_sel <= 1;        
        end
      // S-Type
      6'b000100: begin
        mem_write <= 1;
        reg_write <= 0;
        jump_jal <= 0;
        jump_jalr <= 0;
        branch <= 0;
        immediate_sel <= 1;        
        end
      //B-Type        
      6'b001000: begin
        mem_write <= 0;
        reg_write <= 0;
        jump_jal <= 0;
        jump_jalr <= 0;
        branch <= 1;
        immediate_sel <= 0;        
        end
      //U-Type
      6'b010000: begin
        mem_write <= 0;
        reg_write <= 1;
        jump_jal <= 0;
        jump_jalr <= 0;
        branch <= 0;
        immediate_sel <= 1;        
        end
      //J-Type  
      6'b100000: begin
        mem_write <= 0;
        reg_write <= 1;
        jump_jal <= 1;
        jump_jalr <= 0;
        branch <= 0;
        immediate_sel <= 0;        
        end
      default: begin
        mem_write <= 0;
        reg_write <= 0;
        jump_jal <= 0;
        jump_jalr <= 0;
        branch <= 0;
        immediate_sel <= 0;        
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
