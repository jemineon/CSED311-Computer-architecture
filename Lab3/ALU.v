`include "Opcode.v"

module ALUControlUnit(  input [31:0] inst,
                        input [5:0] microPC,
                        output reg [3:0] alu_op_out
                     );
                                
        reg [6:0] opcode;
        reg [6:0] funct7;
        reg [2:0] funct3;
                     
    always @(*) begin
    
        opcode = inst[6:0];
        funct7 = inst[31:25];
        funct3 = inst[14:12];    
       
        if(opcode == `BRANCH) begin
            if(funct3 == `FUNCT3_BEQ)
                alu_op_out = `ALU_BEQ;
            else if(funct3 == `FUNCT3_BNE)
                alu_op_out = `ALU_BNE;
            else if(funct3 == `FUNCT3_BLT)
                alu_op_out = `ALU_BLT;
            else if(funct3 == `FUNCT3_BGE)
                alu_op_out = `ALU_BGE;
                //$display("[ALUControlUnit] branch:funct3 error\n");
            
            // if the current instruction is BRANCH and now in WB state, OPCODE is ADD
            //$display("[ALUControlUnit] branch microPC : %b \n",microPC);
            if(microPC[2:0] == 3'b100) begin
                //$display("[ALUControlUnit] here \n",microPC);
                //alu_op_out = `ALU_ADDB;
                alu_op_out = `ALU_ADD;
            end
            
        end
        else if(opcode == `ARITHMETIC) begin //arithmetic of logical
            if(inst[30] == 1) begin
                alu_op_out = `ALU_SUB;
               end
            else if(funct3 == `FUNCT3_ADD && inst[30] == 0) begin
                alu_op_out = `ALU_ADD;
;
                    //$display("[ALUControlUnit] funct7 error\n");
            end
            else if(funct3 == `FUNCT3_SLL)
                alu_op_out = `ALU_SLL;
            else if(funct3 == `FUNCT3_XOR)
                alu_op_out = `ALU_XOR;
            else if(funct3 == `FUNCT3_OR)
                alu_op_out = `ALU_OR;
            else if(funct3 == `FUNCT3_AND)
                alu_op_out = `ALU_AND;
            else if(funct3 == `FUNCT3_SRL)
                alu_op_out = `ALU_SRL;
                //$display("[ALUControlUnit] arithmetic:funct3 error\n");
        end
        else if(opcode == `ARITHMETIC_IMM) begin
            if(funct3 == `FUNCT3_ADD)
                alu_op_out = `ALU_ADD;
            else if(funct3 == `FUNCT3_XOR)
                alu_op_out = `ALU_XOR;
            else if(funct3 == `FUNCT3_OR)
                alu_op_out = `ALU_OR;
            else if(funct3 == `FUNCT3_AND)
                alu_op_out = `ALU_AND;
            else if(funct3 == `FUNCT3_SLL)
                alu_op_out = `ALU_SLL;
            else if(funct3 == `FUNCT3_SRL)
                alu_op_out = `ALU_SRL;
                //$display("[ALUControlUnit] arithmetic_imm:funct3 error\n");
        end
        else if (opcode == `STORE)
            alu_op_out = `ALU_ADD;
        else if (opcode == `LOAD)
            alu_op_out = `ALU_ADD;
        else if (opcode == `JAL)
            alu_op_out = `ALU_ADD;
            //$display("[ALUControlUnit] opcode error\n");

    end
    
endmodule

module ALU( input [3:0] alu_op_in,
            input [31:0] input1,
            input [31:0] input2,
            input [1:0] ALUSrcB,
            output reg [31:0] result_out,
            output reg bcond_out
          );
    
    always @(*) begin
        
        result_out = 0;
        //bcond_out = 0;
    
        if(alu_op_in == `ALU_ADD || ALUSrcB == 2'b01) begin
            result_out = input1 + input2;
        end
        else if(alu_op_in == `ALU_SUB) begin
            result_out = input1 - input2;
        end
        else if(alu_op_in == `ALU_SLL) begin
            result_out = input1 << input2;
        end
        else if(alu_op_in == `ALU_XOR) begin
            result_out = input1 ^ input2;
        end
        else if(alu_op_in == `ALU_OR) begin
            result_out = input1 | input2;
        end
        else if(alu_op_in == `ALU_AND) begin
            result_out = input1 & input2;
        end
        else if(alu_op_in == `ALU_SRL) begin
            result_out = input1 >> input2;
        end
        else if(alu_op_in == `ALU_BEQ) begin
            if(input1 == input2)
                bcond_out = 1;
            else
                bcond_out = 0;
        end
        else if(alu_op_in == `ALU_BNE) begin
            if(input1 != input2)
                bcond_out = 1;
            else
                bcond_out = 0;
        end
        else if(alu_op_in == `ALU_BLT) begin
            if(input1 < input2)
                bcond_out = 1;
            else
                bcond_out = 0;
        end
        else if(alu_op_in == `ALU_BGE) begin
            if(input1 >= input2)
                bcond_out = 1;
            else
                bcond_out = 0;
        end
        /*
        else if (alu_op_in == `ALU_ADDB) begin
            result_out = input1 + input2 - 4;
        end
        */
            //$display("[ALU] opcode error\n");
            
    end
    
endmodule