module RISC_V_tb;

  reg  [127:0] la_data_in = 0;
  wire  [127:0] la_data_out;
  reg  [127:0] la_oenb = 0;

 user_project_wrapper user_project_wrapper (
  .la_data_in(la_data_in),
  .la_data_out(la_data_out),
  .la_oenb(la_oenb)
  );
  
  integer i;
  integer f; // output file

  initial 
  
  begin
    $dumpfile("risc_v.vcd");
    f = $fopen("output.txt","w");

    $dumpvars(0, RISC_V_tb);
    // dump iram into vcd
    for(i = 0; i < 16; i = i + 1)
      $dumpvars(0, RISC_V_tb.user_project_wrapper.RISC_V.IMemory.iram[i]);

    // dump regfile into vcd
    for(i = 0; i < 16; i = i + 1)
      $dumpvars(0, RISC_V_tb.user_project_wrapper.RISC_V.DMemory.dram[i]);

    // dump dram into vcd
    for(i = 0; i < 32; i = i + 1)
      $dumpvars(0, RISC_V_tb.user_project_wrapper.RISC_V.ALU.Data_Registers[i]);
	
    

    la_data_in[51] = 0;
    la_data_in[50] = 0;
    la_data_in[36] = 0;
    la_data_in[45] = 1;
    #2 la_data_in[50] = 1;
  end

  always
    #1 la_data_in[51] = ~la_data_in[51];
    
  initial begin
  
  #500
  la_data_in[50] = 0; // RST_N
  la_data_in[51] = 1; // Write
  for (i = 0; i < 15; i = i + 1) begin
      la_data_in[35:32] = i;
      la_data_in[31:0] = 32'b 000000000001_00001_000_00001_0010011;
      #2;
  end
 
  end  
  
  initial begin
  
  #550
  la_data_in[50] = 1; // RST_N
  la_data_in[51] = 0; // Write

  end

  initial begin
    // Write to file  
    #1000 $finish;
  end
endmodule