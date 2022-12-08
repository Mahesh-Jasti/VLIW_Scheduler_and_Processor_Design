// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

module vliw_tb;
  
  reg clk, rstn;
  reg [127:0] vliw_instr;
  
  VLIW_processor_4slot DUT(.clk(clk),.rstn(rstn),.vliw_instr(vliw_instr));
  
  initial begin
    clk = 1'b0;
    rstn = 1'b0;
    vliw_instr = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
  end
  
  always #5 clk = ~clk;
  
  initial begin
    $dumpfile("vliw.vcd");
    $dumpvars(0,vliw_tb);
    #17 rstn = 1'b1;
    #10 vliw_instr = 128'b10000000000001100101000000101100100000000000111010100000001001001000000111011010000000000001110010000001001100010011000000010100;
    #10 vliw_instr = 128'b00000000000000000000000000000000000000000000000000000000000000001000000110100110111100000000010010000001001110001000000000110100;
    #50 $display("R0 = %d",DUT.register_file[0]);
    $display("R1 = %d",DUT.register_file[1]);
    $display("R2 = %d",DUT.register_file[2]);
    $display("R3 = %d",DUT.register_file[3]);
    $display("R4 = %d",DUT.register_file[4]);
    $display("R5 = %d",DUT.register_file[5]);
    $display("R6 = %d",DUT.register_file[6]);
    $display("R7 = %d",DUT.register_file[7]);
    $finish;
  end
  
endmodule
