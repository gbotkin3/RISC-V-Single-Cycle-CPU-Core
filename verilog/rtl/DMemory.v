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
  
  input  wire  [7:0] la_dram_select, //Used to select ram to read from
  
  output wire [31:0]  read_data,
  
  output wire [31:0]  la_read_data //Data read from ram

);

  reg [31:0] dram[0:255];
  
  //Write to Memory
  integer i;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (i=0;i<256;i=i+1)
        dram[i] = 32'h00000000;
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