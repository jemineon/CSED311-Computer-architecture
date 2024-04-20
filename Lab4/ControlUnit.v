`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/23 17:15:28
// Design Name: 
// Module Name: ControlUnit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "Opcode.v"

module ControlUnit(
    input [31:0] part_of_inst,  // input
    input is_stall,
    output reg mem_read,      // output
    output reg mem_to_reg,    // output
    output reg mem_write,     // output
    output reg alu_src,       // output
    output reg write_enable,     // output
    output reg pc_to_reg,     // output
    output reg alu_op,
    output reg is_ecall       // output (ecall inst)
  );
  
   // Ports Declaration
   reg [6:0] opcode;
   
   always @(*)begin
        opcode = part_of_inst[6:0];
        mem_read = 0;
        mem_to_reg=0;
        mem_write=0;
        alu_src=0;
        write_enable=0;
        pc_to_reg=0;
        is_ecall=0;
        alu_op = 0;
        
        
        if(opcode ==`STORE)begin
            mem_write=1;
        end
        
        if(opcode ==`LOAD)begin
            mem_read =1;
            mem_to_reg =1;
        end
        
        if(opcode ==`ARITHMETIC_IMM || opcode == `LOAD || opcode == `JALR || opcode == `STORE)begin
            alu_src=1;
            
        end
        
        if(opcode !=`STORE && opcode !=`BRANCH) begin
            write_enable=1;
        end
        
        if(opcode ==`JAL || opcode ==`JALR) begin
            pc_to_reg =1;
        end
        
        if(opcode ==`ECALL)begin
            is_ecall=1;
        end
        //HALT?????
        //if (part_of_inst[11:7] == 17) begin
        //    is_ecall =1;
        //end
        
        if (is_stall ==1)begin           
            mem_read = 0;
            mem_to_reg=0;
            mem_write=0;
            write_enable=0;
            pc_to_reg=0;
            //is_ecall=0;
            //alu_op = 0; 
            //alu_src=0;
        
        end

   end   
  
endmodule

module HazardControlUnit( // Ecall 도 여기서 판단? 
    input [31:0] part_of_inst,  // input
    input [4:0] id_ex_rd,
    input id_ex_mem_read,
    input [4:0] ex_mem_rd,
    input ex_mem_mem_read,
    output reg is_stall      // output
  );
  
  reg [4:0] rs1;
  reg [4:0] rs2;
  reg [6:0] opcode;
  reg use_rs1;
  reg use_rs2;
  
  always @(*) begin
    rs1 = part_of_inst[19:15];
    rs2 = part_of_inst[24:20];
    opcode = part_of_inst[6:0];
    use_rs1 = 0;
    use_rs2 = 0;
    is_stall =0;
    
    //############################## R-type, S-type, SB-type #####################3
    if (opcode ==`ARITHMETIC || opcode == `STORE || opcode == `BRANCH) begin
        if (rs1!=0) begin
            use_rs1 = 1;
        end
        if (rs2 !=0) begin
            use_rs2 =1;
        end
    end
    
    //############################## I-type #####################################
    if (opcode ==`ARITHMETIC_IMM || opcode == `LOAD || opcode == `JALR) begin
        if (rs1!=0) begin
            use_rs1 = 1;
        end
    end
    
    //############################# J-type ###########################################
    if (opcode == `JAL ) begin
        use_rs1 = 0;
        use_rs2 = 0;
    end
    
    
    //########################## E-CALL ########################################3
    if (opcode == `ECALL ) begin
        use_rs1 = 0;
        use_rs2 = 0;
        if (ex_mem_mem_read ==1 && ex_mem_rd ==17) begin
            is_stall =1;
        end
        if (id_ex_mem_read ==1 && id_ex_rd ==17) begin
            is_stall =1;
        end
    end
    
    if (rs1 == id_ex_rd && use_rs1 ==1 && id_ex_mem_read ==1) begin
        is_stall =1;
    end
    if (rs2 == id_ex_rd && use_rs2 ==1 && id_ex_mem_read ==1) begin
        is_stall =1;
    end
  
  end
endmodule


//module HaltControlUnit(
//    input [4:0] id_ex_rd,
//    input [4:0] ex_mem_rd,
//    //input [4:0] mem_wb_rd,
//    input id_ex_reg_write,
//    input ex_mem_reg_write,
//    //input mem_wb_reg_write,
//    input id_ex_mem_read,
//    input ex_mem_mem_read,
//    //input mem_wb_mem_read,
//    input [31:0] ex_alu_result,
//    input [31:0] mem_dmem_out,
//    input [31:0] mem_alu_result,
    
//    output reg [31:0]  halt_data,      // output    // output (ecall inst)
//    output reg is_stall,
//  );
  
//  always @(*) begin
//    is_stall =0;
    
    //#####################EX STAGE######################################
//    if (id_ex_rd == 17 && id_ex_reg_write ==1) begin
        //############## EX STAGE에 LOAD #########################
//        if (id_ex_mem_read ==1) begin
//            is_stall = 1;
//        end
        //############### LOAD 제외 ########################
//        else begin
//            halt_data = ex_alu_result;
//        end
//    end
    
    //#####################MEM STAGE######################################
//    else if (ex_mem_rd ==17 && ex_mem_reg_write ==1) begin
  //      if (ex_mem_mem_read ==1) begin
    //        halt_data = mem_dmem_out;
      //  end
 //       else begin
 //           halt_data = mem_alu_result;
 //       end
    
 //   end
    
    //### WB STAGE WRITE DONE. OK.###########
    
    
 //   else begin
 //       halt_data = 0;
 //   end
 // end
  
  
  
  
 //endmodule