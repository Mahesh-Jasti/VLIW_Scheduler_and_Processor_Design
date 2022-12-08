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
  always@(posedge clk) begin
    case(op0)
      ADD: register_file[dest0] <= (valid0)?(register_file[src0_1]+register_file[src0_2]):'hz;
      MUL: register_file[dest0] <= (valid0)?(register_file[src0_1]*register_file[src0_2]):'hz;
      ADDI: register_file[dest0] <= (valid0)?(register_file[src0_1]+{13'h0000,imm0}):'hz;
      MOV: register_file[dest0] <= (valid0)?({13'h0000,imm0}):'hz;
    endcase
  end
  
  // ALU slot1
  always@(posedge clk) begin
    case(op1)
      ADD: register_file[dest1] <= (valid1)?(register_file[src1_1]+register_file[src1_2]):'hz;
      MUL: register_file[dest1] <= (valid1)?(register_file[src1_1]*register_file[src1_2]):'hz;
      ADDI: register_file[dest1] <= (valid1)?(register_file[src1_1]+{13'h0000,imm1}):'hz;
      MOV: register_file[dest1] <= (valid1)?({13'h0000,imm1}):'hz;
    endcase
  end
  
  // ALU slot2
  always@(posedge clk) begin
    case(op2)
      ADD: register_file[dest2] <= (valid2)?(register_file[src2_1]+register_file[src2_2]):'hz;
      MUL: register_file[dest2] <= (valid2)?(register_file[src2_1]*register_file[src2_2]):'hz;
      ADDI: register_file[dest2] <= (valid2)?(register_file[src2_1]+{13'h0000,imm2}):'hz;
      MOV: register_file[dest2] <= (valid2)?({13'h0000,imm2}):'hz;
    endcase
  end
  
  // ALU slot3
  always@(posedge clk) begin
    case(op0)
      ADD: register_file[dest3] <= (valid3)?(register_file[src3_1]+register_file[src3_2]):'hz;
      MUL: register_file[dest3] <= (valid3)?(register_file[src3_1]*register_file[src3_2]):'hz;
      ADDI: register_file[dest3] <= (valid3)?(register_file[src3_1]+{13'h0000,imm3}):'hz;
      MOV: register_file[dest3] <= (valid3)?({13'h0000,imm3}):'hz;
    endcase
  end
  
  // Reset condition
  always@(posedge clk) begin
    if(!rstn) begin
      /*for(int i=0;i<8;i=i+1) begin
        register_file[i] <= 32'h0000_0000;
      end*/
    end
  end
  
  
endmodule