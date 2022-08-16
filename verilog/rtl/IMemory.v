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
  output wire [31:0] i_type_immediate,
  output wire [31:0] s_type_immediate,
  output wire [31:0] b_type_immediate,
  output wire [31:0] u_type_immediate,
  output wire [31:0] j_type_immediate,
  
  output wire [31:0] la_instruction_read

);

  reg [31:0] iram[0:16];
  wire [31:0] instruction;
  
  always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
    
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


endmodule