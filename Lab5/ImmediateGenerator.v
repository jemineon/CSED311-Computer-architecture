//ImmediateGenerator file
`include "Opcode.v"

module ImmediateGenerator (part_of_inst, imm_gen_out);
    // Ports Declaration
   input [31:0] part_of_inst;
   output reg [31:0] imm_gen_out;
    
   reg [6:0]opcode;

   always @(*)begin 
       //i-type
       opcode = part_of_inst[6:0]; 
       if (opcode == `ARITHMETIC_IMM || opcode ==`LOAD || opcode == `JALR ) begin 
            imm_gen_out ={{20{part_of_inst[31]}} ,part_of_inst[31:20]};
       end

       //s-type
       if (opcode == `STORE) begin 
            imm_gen_out ={{20{part_of_inst[31]}},part_of_inst[31], part_of_inst[30:25], part_of_inst[11:8], part_of_inst[7]};
       end
       
       //j-type
       if (opcode == `JAL) begin 
            imm_gen_out ={{11{part_of_inst[31]}} ,part_of_inst[31], part_of_inst[19:12], part_of_inst[20], part_of_inst[30:21],1'b0};
       end
       
       //b-type
       if (opcode == `BRANCH) begin 
            imm_gen_out ={{19{part_of_inst[31]}} ,part_of_inst[31], part_of_inst[7], part_of_inst[30:25],part_of_inst[11:8], 1'b0} ; //??0
       end

   
   //u-type
   //if (opcode == `LUI || opcode ==`AUIPC) begin
   
   //end
   
   end
  
endmodule