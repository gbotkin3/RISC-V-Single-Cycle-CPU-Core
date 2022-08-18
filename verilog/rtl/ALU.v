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
  input wire  [31:0] i_type_immediate,
  input wire  [31:0] s_type_immediate,
  input wire  [31:0] b_type_immediate,
  input wire  [31:0] u_type_immediate,
  input wire  [31:0] j_type_immediate,
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
  always @(posedge clk or negedge rst_n) begin
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
      aluctl = 6'b001010; // ADDI
      end
    else if ((opcode == 7'b0010011) & (funct3 == 3'b100)) begin
      aluctl = 6'b001011; // XORI
      end
    else if ((opcode == 7'b0010011) & (funct3 == 3'b110)) begin
      aluctl = 6'b001100; // ORI
      end
    else if ((opcode == 7'b0010011) & (funct3 == 3'b111)) begin
      aluctl = 6'b001101; // ANDI
      end
    else if ((opcode == 7'b0010011) & (funct3 == 3'b001) & (i_type_immediate[11:5] == 0)) begin
      aluctl = 6'b001110; // SLLI
      end
    else if ((opcode == 7'b0010011) & (funct3 == 3'b101) & (i_type_immediate[11:5] == 0)) begin
      aluctl = 6'b001111; // SRLI
      end
    else if ((opcode == 7'b0010011) & (funct3 == 3'b101) & (i_type_immediate[11:5] == 6'b000001)) begin
      aluctl = 6'b010000; // SRAI
      end
    else if ((opcode == 7'b0010011) & (funct3 == 3'b010)) begin
      aluctl = 6'b010001; // SLTI
      end
    else if ((opcode == 7'b0010011) & (funct3 == 3'b011)) begin
      aluctl = 6'b010010; // SLTI (U)
      end
    
    // Load Operations
    else if ((opcode == 7'b0000011) & (funct3 == 3'b000)) begin
      aluctl = 6'b010011; // LB
      end
    else if ((opcode == 7'b0000011) & (funct3 == 3'b001)) begin
      aluctl = 6'b010100; // LH
      end
    else if ((opcode == 7'b0000011) & (funct3 == 3'b010)) begin
      aluctl = 6'b010101; // LW
      end
    else if ((opcode == 7'b0000011) & (funct3 == 3'b100)) begin
      aluctl = 6'b010110; // LBU
      end 
    else if ((opcode == 7'b0000011) & (funct3 == 3'b101)) begin
      aluctl = 6'b010111; // LHU
      end
    
    // Jump and Link Operation
    else if ((opcode == 7'b1100111) & (funct3 == 3'b000)) begin
      aluctl = 6'b011000; // JALR
      end
    
    // Environment Operations   
    else if ((opcode == 7'b1110011) & (funct3 == 3'b000) & (i_type_immediate == 0)) begin
      aluctl = 6'b011001; // ECALL  (TODO)
      end
    else if ((opcode == 7'b1110011) & (funct3 == 3'b000) & (i_type_immediate == 1)) begin
      aluctl = 6'b011010; // EBREAK (TODO)
      end
      
    // CSR Instructions

    // TODO
    
  // s-type instructions 

    else if ((opcode == 7'b0100011) & (funct3 == 3'b000)) begin
      aluctl = 6'b011011; // SB
      end
    else if ((opcode == 7'b0100011) & (funct3 == 3'b001)) begin
      aluctl = 6'b011100; // SH
      end
    else if ((opcode == 7'b0100011) & (funct3 == 3'b010)) begin
      aluctl = 6'b011101; // SW
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

  // use alu_ctl to set alu_result
  always @(*) begin
    case (aluctl)
      6'b000000: alu_result = rs1_data + rs2_data;   // ADD
      6'b000001: alu_result = rs1_data - rs2_data; // SUB
      6'b000010: alu_result = rs1_data ^ rs2_data; // XOR
      6'b000011: alu_result = rs1_data | rs2_data; // OR
      6'b000100: alu_result = rs1_data & rs2_data; // AND
      6'b000101: alu_result = rs1_data << rs2_data;  // SLL
      6'b000110: alu_result = rs1_data >> rs2_data;  // SRL
      6'b000111: alu_result = rs1_data >>> rs2_data; // SRA
      6'b001000: alu_result = (rs1_data < rs2_data) ? 1 : 0; // SLT
      6'b001001: alu_result = (rs1_data < rs2_data) ? 1 : 0; // SLTU
      6'b001010: alu_result = rs1_data + i_type_immediate; // ADDI
      6'b001011: alu_result = rs1_data ^ i_type_immediate; // XORI
      6'b001100: alu_result = rs1_data | i_type_immediate; // ORI
      6'b001101: alu_result = rs1_data & i_type_immediate; // ANDI
      6'b001110: alu_result = rs1_data << i_type_immediate[4:0]; // SLLI
      6'b001111: alu_result = rs1_data >> i_type_immediate[4:0]; // SRLI
      6'b010000: alu_result = rs1_data >>> i_type_immediate[4:0]; // SRAI 
      6'b010001: alu_result = (rs1_data < i_type_immediate) ? 1 : 0; // SLTI
      6'b010010: alu_result = (rs1_data < i_type_immediate) ? 1 : 0; // SLTIU
      6'b010011: alu_result = rs1_data + i_type_immediate; // LB
      6'b010100: alu_result = rs1_data + i_type_immediate; // LH
      6'b010101: alu_result = rs1_data + i_type_immediate; // LW
      6'b010110: alu_result = rs1_data + i_type_immediate; // LBU //NEED TO ZERO EXTEND
      6'b010111: alu_result = rs1_data + i_type_immediate; // LHU //NEED TO ZERO EXTEND
      6'b011000: alu_result = pc + 4;  // JALR
      6'b011001: alu_result = 0; // ECALL // (NOT OPERATIONAL)
      6'b011010: alu_result = 0; // EBREAK // (NOT OPERATIONAL)
      6'b011011: alu_result = rs1_data + s_type_immediate; // SB
      6'b011100: alu_result = rs1_data + s_type_immediate; // SH
      6'b011101: alu_result = rs1_data + s_type_immediate; // SW
      6'b011110: alu_result = (rs1_data == rs2_data);  // BEQ
      6'b011111: alu_result = (rs1_data != rs2_data);  // BNE
      6'b100000: alu_result = (rs1_data < rs2_data); // BLT
      6'b100001: alu_result = (rs1_data >= rs2_data);  // BGE
      6'b100010: alu_result = (rs1_data < rs2_data); // BLTU //NEED TO ZERO EXTEND
      6'b100011: alu_result = (rs1_data >= rs2_data);  // BGEU //NEED TO ZERO EXTEND
      6'b100100: alu_result = pc + 4;  // JAL
      6'b100101: alu_result = u_type_immediate;  // LUI
      6'b100110: alu_result = pc + u_type_immediate; // AUIPC
      default: alu_result = 0;
    endcase
      
  end 
  
  assign alu_output = alu_result;

endmodule