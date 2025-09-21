// Code your design here
`timescale 1ns/1ps

module VLIW_processor_4slot(input clk, input rstn, input [127:0] vliw_instr);
  // Register file
  reg [31:0] register_file[7:0];
  
  // Fetch stage registers
  reg [31:0] slot0_instr;
  reg [31:0] slot1_instr;
  reg [31:0] slot2_instr;
  reg [31:0] slot3_instr;
  
  // Decode stage registers
  reg [2:0] dest0, src0_1, src0_2, op0;
  reg [2:0] dest1, src1_1, src1_2, op1;
  reg [2:0] dest2, src2_1, src2_2, op2;
  reg [2:0] dest3, src3_1, src3_2, op3;
  reg [18:0] imm0, imm1, imm2, imm3;
  reg valid0, valid1, valid2, valid3;
  
  // ALU parameters
  parameter ADD=3'b000, MUL=3'b001, ADDI=3'b010, MOV=3'b100;
  
  // ALU registers
  reg [31:0] slot_dest0;
  reg [31:0] slot_dest1;
  reg [31:0] slot_dest2;
  reg [31:0] slot_dest3;
  
  // Fetch Stage
  always@(posedge clk) begin
    slot0_instr <= vliw_instr[31:0];
    slot1_instr <= vliw_instr[63:32];
    slot2_instr <= vliw_instr[95:64];
    slot3_instr <= vliw_instr[127:96];
  end
  
  /////////////////////// DECODE STARTS ///////////////////
  
  // Decode Stage slot0
  always@(posedge clk) begin
    op0 <= slot0_instr[2:0];
    dest0 <= slot0_instr[5:3];
    src0_1 <= slot0_instr[8:6];
    src0_2 <= slot0_instr[11:9];
    imm0 <= slot0_instr[30:12];
    valid0 <= slot0_instr[31];
  end
  
  // Decode Stage slot1
  always@(posedge clk) begin
    op1 <= slot1_instr[2:0];
    dest1 <= slot1_instr[5:3];
    src1_1 <= slot1_instr[8:6];
    src1_2 <= slot1_instr[11:9];
    imm1 <= slot1_instr[30:12];
    valid1 <= slot1_instr[31];
  end
  
  // Decode Stage slot2
  always@(posedge clk) begin
    op2 <= slot2_instr[2:0];
    dest2 <= slot2_instr[5:3];
    src2_1 <= slot2_instr[8:6];
    src2_2 <= slot2_instr[11:9];
    imm2 <= slot2_instr[30:12];
    valid2 <= slot2_instr[31];
  end
  
  // Decode Stage slot3
  always@(posedge clk) begin
    op3 <= slot3_instr[2:0];
    dest3 <= slot3_instr[5:3];
    src3_1 <= slot3_instr[8:6];
    src3_2 <= slot3_instr[11:9];
    imm3 <= slot3_instr[30:12];
    valid3 <= slot3_instr[31];
  end
  
  ///////////////////////// DECODE ENDS ///////////////////
  
  // ALU slot0
  always@(*) begin
    case(op0)
      ADD: slot_dest0 = register_file[src0_1]+register_file[src0_2];
      MUL: slot_dest0 = register_file[src0_1]*register_file[src0_2];
      ADDI: slot_dest0 = register_file[src0_1]+{13'h0000,imm0};
      MOV: slot_dest0 = {13'h0000,imm0};
    endcase
  end
  
  // ALU slot1
  always@(*) begin
    case(op1)
      ADD: slot_dest1 = register_file[src1_1]+register_file[src1_2];
      MUL: slot_dest1 = register_file[src1_1]*register_file[src1_2];
      ADDI: slot_dest1 = register_file[src1_1]+{13'h0000,imm1};
      MOV: slot_dest1 = {13'h0000,imm1};
    endcase
  end
  
  // ALU slot2
  always@(*) begin
    case(op2)
      ADD: slot_dest2 = register_file[src2_1]+register_file[src2_2];
      MUL: slot_dest2 = register_file[src2_1]*register_file[src2_2];
      ADDI: slot_dest2 = register_file[src2_1]+{13'h0000,imm2};
      MOV: slot_dest2 = {13'h0000,imm2};
    endcase
  end
  
  // ALU slot3
  always@(*) begin
    case(op3)
      ADD: slot_dest3 = register_file[src3_1]+register_file[src3_2];
      MUL: slot_dest3 = register_file[src3_1]*register_file[src3_2];
      ADDI: slot_dest3 = register_file[src3_1]+{13'h0000,imm3};
      MOV: slot_dest3 = {13'h0000,imm3};
    endcase
  end
  
  // Reset condition
  always@(posedge clk) begin
    if(!rstn) begin
      register_file[0] <= 32'h0000_0000;
      register_file[1] <= 32'h0000_0000;
      register_file[2] <= 32'h0000_0000;
      register_file[3] <= 32'h0000_0000;
      register_file[4] <= 32'h0000_0000;
      register_file[5] <= 32'h0000_0000;
      register_file[6] <= 32'h0000_0000;
      register_file[7] <= 32'h0000_0000;
    end
    /*else begin
      register_file[dest0] <= (valid0)?slot_dest0:register_file[dest0];
      register_file[dest1] <= (valid1)?slot_dest1:((valid0 && dest0==3'b000)?slot_dest0:register_file[dest1]);
      register_file[dest2] <= (valid2)?slot_dest2:((valid0 && dest0==3'b000)?slot_dest0:((valid1 && dest1==3'b000)?slot_dest1:register_file[dest2]));
      register_file[dest3] <= (valid3)?slot_dest3:((valid0 && dest0==3'b000)?slot_dest0:((valid1 && dest1==3'b000)?slot_dest1:((valid2 && dest2==3'b000)?slot_dest2:register_file[dest3])));
    end*/
    else begin
      if(valid0) register_file[dest0] <= slot_dest0;
      if(valid1) register_file[dest1] <= slot_dest1;
      if(valid2) register_file[dest2] <= slot_dest2;
      if(valid3) register_file[dest3] <= slot_dest3;
    end
  end
  
  

endmodule
