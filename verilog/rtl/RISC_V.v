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
    input  [127:0] la_oenb

);

  wire clk;
  wire rst_n;

  // LA
  
  assign la_data_out[127:96] = 0;
  
  // LA To Access and Read DRAM
  wire [7:0] la_dram_select;
  wire [31:0] la_read_dram_data;
  
  assign la_dram_select[7:0] = la_data_in[44:37];
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
  
  assign la_reg_select[4:0] = la_data_in[49:45];
  assign la_data_out[95:64] = la_read_reg_data[31:0];  
  
  // Assuming LA probes [51:50] are for controlling the clk & reset  
  assign clk = la_data_in[51];
  assign rst_n = la_data_in[50];
    
	// Control Wires
	wire mem_write;
	wire reg_write;
	wire jump_jal;
	wire jump_jalr;
	wire branch;
	
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
	wire [31:0] i_type_immediate;
	wire [31:0] s_type_immediate;
	wire [31:0] b_type_immediate;
	wire [31:0] u_type_immediate;
	wire [31:0] j_type_immediate;
	
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
	.branch_output(branch)
	);

	pc pc_module (
	//Inputs
	.clk(clk),
	.rst_n(rst_n),
	.rs1_data(rs1_data),
	.i_type_immediate(i_type_immediate),
	.j_type_immediate(j_type_immediate),
	.b_type_immediate(b_type_immediate),
	.jump_jal(jump_jal),
	.jump_jalr(jump_jalr),
	.branch(branch),
	.alu_branch(alu_output),
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
	.i_type_immediate(i_type_immediate),
	.s_type_immediate(s_type_immediate),
	.b_type_immediate(b_type_immediate),
	.u_type_immediate(u_type_immediate),
	.j_type_immediate(j_type_immediate),
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
	.i_type_immediate(i_type_immediate),
	.s_type_immediate(s_type_immediate),
	.b_type_immediate(b_type_immediate),
	.u_type_immediate(u_type_immediate),
	.j_type_immediate(j_type_immediate),
	.read_data(read_data),
  .la_reg_select(la_reg_select),  
  
		
	//Outputs
	.alu_output(alu_output),
	.rs1_data(rs1_data),
	.rs2_data(rs2_data),
  .la_read_data(la_read_reg_data)  
	);
  
 endmodule