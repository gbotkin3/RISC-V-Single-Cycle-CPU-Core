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
  output wire       branch_output

);

  reg mem_write = 0;
  reg reg_write = 0;
  reg jump_jal = 0;
  reg jump_jalr = 0;
  reg branch = 0;

  always @(*) begin

    case (instruction_type)
      // R-Type
      6'b000001: begin
        mem_write <= 0;
        reg_write <= 1;
        jump_jal <= 0;
        jump_jalr <= 0;
        branch <= 0;
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
        end
      // S-Type
      6'b000100: begin
        mem_write <= 1;
        reg_write <= 0;
        jump_jal <= 0;
        jump_jalr <= 0;
        branch <= 0;
        end
      //B-Type        
      6'b001000: begin
        mem_write <= 0;
        reg_write <= 0;
        jump_jal <= 0;
        jump_jalr <= 0;
        branch <= 1;
        end
      //U-Type
      6'b010000: begin
        mem_write <= 0;
        reg_write <= 1;
        jump_jal <= 0;
        jump_jalr <= 0;
        branch <= 0;
        end
      //J-Type  
      6'b100000: begin
        mem_write <= 0;
        reg_write <= 1;
        jump_jal <= 1;
        jump_jalr <= 0;
        branch <= 0;
        end
      default: begin
        mem_write <= 0;
        reg_write <= 0;
        jump_jal <= 0;
        jump_jalr <= 0;
        branch <= 0;
        end
    endcase
  end
  
  assign mem_write_output = mem_write;
  assign reg_write_output = reg_write;
  assign jump_jal_output = jump_jal;
  assign jump_jalr_output = jump_jalr;
  assign branch_output = branch;

endmodule