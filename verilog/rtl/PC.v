module pc
//IO
(
  input  wire         clk,
  input  wire         rst_n,
  input  wire  [31:0] rs1_data,
  input  wire  [31:0] i_type_immediate,
  input  wire  [31:0] j_type_immediate,
  input  wire  [31:0] b_type_immediate,
  input  wire         jump_jal,
  input  wire         jump_jalr,
  input  wire         branch,
  input  wire  [31:0] alu_branch,
  
  output wire  [31:0] pc_out
);
  
  reg [31:0] pc = 0;
  wire [31:0] pc_plus_4;
  reg jalr_value = 0;
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) pc <= 32'h00000000;
    else if (jump_jal) pc <= pc_out + j_type_immediate;
    else if (jump_jalr) pc <= pc_out + $signed(((rs1_data + i_type_immediate) >> 1) << 1); 
    else if (branch && alu_branch[0]) pc <= pc_out + b_type_immediate;
    else pc <= pc_plus_4;
  end 
  
  assign pc_plus_4 = pc+4;
  assign pc_out = pc;

endmodule