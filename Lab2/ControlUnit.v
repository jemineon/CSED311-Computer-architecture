`include "opcodes.v"

module ControlUnit(
    part_of_inst,  // input
    is_jal,        // output
    is_jalr,       // output
    branch,        // output
    mem_read,      // output
    mem_to_reg,    // output
    mem_write,     // output
    alu_src,       // output
    write_enable,     // output
    pc_to_reg,     // output
    is_ecall       // output (ecall inst)
  );
  
   // Ports Declaration
   input [31:0] part_of_inst;
   output reg is_jal; //dd
   output reg is_jalr; //dd
   output reg branch; //
   output reg mem_read; //isLoad
   output reg mem_to_reg; //isLoad
   output reg mem_write; //isStore
   output reg alu_src;  //alu_src isItype or isStype
   output reg write_enable; //register write? !isStore && !isBR
   output reg pc_to_reg; //jal, jalr (at register rd)
   output reg is_ecall; //dd
   
   reg [6:0] opcode;
   
   always @(*)begin
        opcode = part_of_inst[6:0];
        is_jal=0;
        is_jalr = 0;
        branch=0;
        mem_read = 0;
        mem_to_reg=0;
        mem_write=0;
        alu_src=0;
        write_enable=0;
        pc_to_reg=0;
        is_ecall=0;
        
        
        if(opcode == `ARITHMETIC) begin
            write_enable = 1;
        end
        else if(opcode == `ARITHMETIC_IMM) begin
            write_enable = 1;
            alu_src=1;
        end
        else if(opcode == `LOAD) begin
            write_enable = 1;
            mem_read =1;
            mem_to_reg =1;
            alu_src=1;
        end
        else if(opcode == `JALR) begin
            write_enable = 1;
            is_jalr =1;
            alu_src=1;
            pc_to_reg =1;
        end
        else if(opcode == `STORE) begin
            mem_write=1;
            alu_src=1;
        end
        else if(opcode == `BRANCH) begin
            branch=1;
        end
        else if(opcode == `JAL) begin
            write_enable = 1;
            is_jal=1;
            pc_to_reg =1;
        end
        else if(opcode == `ECALL) begin
            is_ecall=1;
        end
        else begin
        end

   end   
  
endmodule