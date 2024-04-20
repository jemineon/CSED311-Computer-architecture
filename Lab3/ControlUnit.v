`include "Opcode.v"

module ControlUnit(
    
    input clk,
    input reset,
    input [6:0] opcode,
    input [3:0] current_state,
    input in_bcond,
    output reg PCWrite,
    output reg PCWriteNotCond,
    output reg IorD,
    output reg MemRead,
    output reg MemWrite,
    output reg IRWrite,
    output reg MemtoReg,
    output reg PCSource,
    output reg [1:0] ALUSrcB,
    output reg ALUSrcA,
    output reg RegWrite,
    output reg Ecall,
    output reg [3:0] next_state,
    output reg [5:0] microPC
    );
    
    //reg [5:0] microPC;
    reg [5:0] next_microPC;
    reg [5:0] temp_microPC;
    reg bcond;
    
    always @(posedge clk) begin
        if (reset == 1) begin
            microPC <= `MICRO_PC_INIT;
            PCWrite <= 0;
            IorD <= 0;
            MemRead <= 1;
            MemWrite <= 0;
            IRWrite <= 1;
            RegWrite <= 0;
            PCSource <= 0;
            Ecall <= 0;
        end
        else begin
            microPC <= next_microPC;
        end
    end
    
    always @(*) begin
    
        if(!reset) begin
            // Selecting Next MicroPC Logic
            temp_microPC = microPC + 1;
            
            // if current microPC indicates the WB state, next microPC is for IF
            if(temp_microPC[2:0] == 3'b101)
                temp_microPC[2:0] = 3'b000;
            
            // if next microPC is ID, microPC[5:3] is new instruction type
            if(temp_microPC[2:0] == `MICRO_PC_ID) begin
            
                //$display("opcode : %b",opcode);
                
                if(opcode == `ARITHMETIC)
                    temp_microPC = 6'b000001;
                else if(opcode == `ARITHMETIC_IMM)
                    temp_microPC = 6'b001001;
                else if(opcode == `LOAD)
                    temp_microPC = 6'b010001;
                else if(opcode == `JALR)
                    temp_microPC = 6'b011001;
                else if(opcode == `STORE)
                    temp_microPC = 6'b100001;
                else if(opcode == `BRANCH)
                    temp_microPC = 6'b101001;
                else if(opcode == `JAL)
                    temp_microPC = 6'b110001;
                else if(opcode == `ECALL)
                    temp_microPC = 6'b111001;
            end
            
            // if microPC indicates MEM state but the instruction is not S or L, advance it to WB state.
            if(temp_microPC[2:0] == `MICRO_PC_MEM) begin
                if(temp_microPC[5:3] != `MICRO_PC_S && temp_microPC[5:3] != `MICRO_PC_L)
                    temp_microPC[2:0] = `MICRO_PC_WB;
            end
            
            // if current instruction is JAL and mircroPC indicates ID state, advance it to EX state.
            if(temp_microPC[5:3] == `MICRO_PC_JAL && temp_microPC[2:0] == `MICRO_PC_ID)
                temp_microPC = 6'b110010;
                
            if(temp_microPC[5:3] == `MICRO_PC_ECALL && temp_microPC[2:0] == `MICRO_PC_EX)
                temp_microPC = 6'b111100;
                
            next_microPC = temp_microPC;
        end
    end 
    
    always @(microPC) begin
        
        if(!reset) begin
            /////////////////////////////////////////////////// IF
            if(microPC[2:0] == `MICRO_PC_IF) begin
                PCWrite = 0;
                IorD = 0;
                MemRead = 1;
                MemWrite = 0;
                IRWrite = 1;
                RegWrite = 0;
                PCSource = 0;
                Ecall = 0;
            end
            /////////////////////////////////////////////////// ID
            else if(microPC[2:0] == `MICRO_PC_ID) begin
                PCWrite = 1;
                MemRead = 0;
                MemWrite = 0;
                IRWrite = 0;
                RegWrite = 0;
                PCSource = 0;
                
                //############
                //bcond = 0;
                
                if(microPC[5:3] == `MICRO_PC_ECALL)
                    Ecall = 1;
                
                if(microPC[5:3] == `MICRO_PC_JALR) begin
                    ALUSrcA = 1;
                    ALUSrcB = 2'b10;
                end
                else begin
                    ALUSrcA = 0;
                    ALUSrcB = 2'b01;
                end
            end
            /////////////////////////////////////////////////// EX
            else if(microPC[2:0] == `MICRO_PC_EX) begin
            
                //$display("[EX] microPC : %b",microPC);
                
                MemRead = 0;
                MemWrite = 0;
                IRWrite = 0;
                RegWrite = 0;
                PCSource = 0;
                
                if(microPC[5:3] == `MICRO_PC_R || microPC[5:3] == `MICRO_PC_B) begin
                    PCWrite = 0;
                    ALUSrcA = 1;
                    ALUSrcB = 2'b00;
              
                end
                else if (microPC[5:3] == `MICRO_PC_I || microPC[5:3] == `MICRO_PC_L || microPC[5:3] == `MICRO_PC_S) begin
                    PCWrite = 0;
                    ALUSrcA = 1;
                    ALUSrcB = 2'b10;
                end
                else if (microPC[5:3] == `MICRO_PC_JAL) begin
                    PCWrite = 1;
                    ALUSrcA = 0;
                    ALUSrcB = 2'b10;
                end
                else if (microPC[5:3] == `MICRO_PC_JALR) begin
                    PCWrite = 0;
                end
                else begin
                    $display("[ControlUnit] Illegal micro pc in EX state");
                end
                
                // update bcond
                //bcond = in_bcond;
     
            end
            /////////////////////////////////////////////////// MEM
            else if(microPC[2:0] == `MICRO_PC_MEM) begin
                PCWrite = 0;
                IorD = 1;
                IRWrite = 0;
                RegWrite = 0;
                PCSource = 0;
                
                if (microPC[5:3] == `MICRO_PC_L) begin
                    MemRead = 1;
                    MemWrite = 0;
                end
                else if (microPC[5:3] == `MICRO_PC_S) begin
                    MemRead = 0;
                    MemWrite = 1;
                end
                else begin
                    $display("[ControlUnit] illegal instruction in Mem stage");
                end    
                
            end
            /////////////////////////////////////////////////// WB
            else if(microPC[2:0] == `MICRO_PC_WB) begin
                MemRead = 0;
                MemWrite = 0;
                IRWrite = 0;
                
                bcond = in_bcond;
                
                if(microPC[5:3] == `MICRO_PC_R || microPC[5:3] == `MICRO_PC_I) begin
                    PCWrite = 0;
                    MemtoReg = 0;
                    PCSource = 0;
                    RegWrite = 1;
                end
                else if(microPC[5:3] == `MICRO_PC_L ) begin
                    PCWrite = 0;
                    MemtoReg = 1;
                    PCSource = 0;
                    RegWrite = 1;
                end 
                else if(microPC[5:3] == `MICRO_PC_S ) begin
                    PCWrite = 0;
                    PCSource = 0;
                    RegWrite = 0;
                end
                else if(microPC[5:3] == `MICRO_PC_JAL || microPC[5:3] == `MICRO_PC_JALR) begin
                    PCWrite = 0;
                    MemtoReg = 0;
                    PCSource = 0;
                    RegWrite = 1;
                    ALUSrcA = 0;
                    ALUSrcB = 2'b01;
                end
                else if(microPC[5:3] == `MICRO_PC_B) begin
                    if (bcond == 1) begin
                        PCWrite = 1;
                        PCSource = 0;
                        RegWrite = 0;
                        ALUSrcA = 0;
                        ALUSrcB = 2'b10;
                    end
                    else begin
                        PCWrite = 0;
                        PCSource = 0;
                        RegWrite = 0;
                    end
                end
                else begin
                    $display("[ControlUnit] Illegal instruction type in WB state\n");
                end 
            
            end
            else begin
                $display("[ControlUnit] illegal microPC");
            end
        end
    end
    
    
endmodule
