`include "Opcode.v"

module TwoBitGlobalPredictor( 
                                input reset,
                                input clk,
                                input [31:0] current_pc,
                                input [31:0] actual_pc,
                                input [31:0] ID_EX_pc,
                                input [31:0] ID_EX_predicted_pc,
                                input IsBranch,
                                input IsJAL,
                                input IsJALR,
                                input bcond,
                                input is_stall,
                                output reg [31:0] predicted_pc,
                                output reg predicted_taken
                                );

//    reg [57:0] BTB [0:31];
    reg [59:0] BTB [0:31];
    reg [1:0] predictor_state;
    integer i;
    
    reg [24:0] tag;
    reg [4:0] index;
    reg taken;
    reg correct_prediction;
    
    always @(*) begin
    
        // setting proper reg values
        
        tag = current_pc[31:7];
        index = ID_EX_pc[6:2];
        
        if (IsJAL || IsJALR || (IsBranch && bcond))
            taken = 1;
        else
            taken = 0;
        
        // actual_pc == ID_EX_predicted_pc
        if (actual_pc == ID_EX_predicted_pc)
            correct_prediction = 1;
        else
            correct_prediction = 0;
        
            
    end
    
    always @(*) begin
         if((current_pc[31:7] == BTB[current_pc[6:2]][56:32]) && (predictor_state == 2'b10 ||predictor_state== 2'b11) && (BTB[current_pc[6:2]][57] == 1)) begin
                predicted_pc = BTB[current_pc[6:2]][31:0];
                predicted_taken = 1;
         end
         else begin
            predicted_pc = current_pc + 4;
            predicted_taken = 0;
         end
    end
    
    always @(posedge clk) begin
        // reset BTB and 2-bit predictor state
        
        if(reset) begin
            predictor_state <= 0;
            for(i = 0; i< 32 ; i = i + 1)
                BTB[i][59:0] <= 0;
        end
        else begin

            if((IsBranch || IsJAL || IsJALR) && !is_stall ) begin
            
                //BTB[index][57] <= 1;
                //BTB[index][56:32] <= tag;
                
                //if(correct_prediction)
                    //BTB[index][31:0] <= actual_pc;
                //else
                    //BTB[index][31:0] <= ID_EX_predicted_pc;
                
                if(taken) begin
                    BTB[index][57] <= 1;
                    //BTB[index][56:32] <= tag;
                    BTB[index][56:32] <= ID_EX_pc[31:7];
                    BTB[index][31:0] <= actual_pc;
                end
                
                case(predictor_state)
                    2'b00: begin
                        if(taken)predictor_state <= 2'b01;
                        else predictor_state<= 2'b00;
                    end
                    2'b01: begin
                        if(taken) predictor_state <= 2'b10;
                        else predictor_state <= 2'b00;
                    end
                    2'b10: begin
                        if(taken)predictor_state <= 2'b11;
                        else predictor_state <= 2'b01;
                    end
                    2'b11: begin
                        if(taken) predictor_state <= 2'b11;
                        else predictor_state <= 2'b10;
                    end
                endcase
            end
        end
    end

endmodule

module GsharePredictor( 
                        input reset,
                        input clk,
                        input [31:0] current_pc,
                        input [31:0] actual_pc,
                        input [31:0] ID_EX_pc,
                        input [31:0] ID_EX_predicted_pc,
                        input IsBranch,
                        input IsJAL,
                        input IsJALR,
                        input bcond,
                        input is_stall,
                        output reg [31:0] predicted_pc,
                        output reg predicted_taken
                        );
    
//    reg [57:0] BTB [0:31];
    //reg [62:0] BTB [0:31];     
    reg[64:0] BTB [0:31];
    integer i;   
    reg [1:0] predictor_state;
         
    reg [24:0] current_tag;
    reg [24:0] ID_EX_tag;
    reg [4:0] current_index;
    reg [4:0] ID_EX_index;
    reg [4:0] current_XORindex;
    reg [4:0] ID_EX_XORindex;
    reg [4:0] BHSR;
    reg taken;
    
    always @(*) begin
    
        // setting proper reg values
        
        current_tag = current_pc[31:7];
        ID_EX_tag = ID_EX_pc[31:7];
        current_index = current_pc[6:2];
        ID_EX_index = ID_EX_pc[6:2];
        current_XORindex = current_index ^ BHSR;
        ID_EX_XORindex = ID_EX_index ^ BHSR;
        
        if (IsJAL || IsJALR || (IsBranch && bcond))
            taken = 1;
        else
            taken = 0;    
            
        
    end
    
    always @(*) begin
         if((current_tag == BTB[current_XORindex][56:32]) && (BTB[ID_EX_XORindex][64:63] == 2'b10 || BTB[ID_EX_XORindex][64:63] == 2'b11)&& (BTB[current_XORindex][57] == 1)&&(BTB[current_XORindex][62:58]==current_pc[6:2] )) begin
                predicted_pc = BTB[current_XORindex][31:0];
                predicted_taken = 1;
         end
         else begin
            predicted_pc = current_pc + 4;
            predicted_taken = 0;
         end
    end
    
    always @(posedge clk) begin
        // reset BTB and 2-bit predictor state
        
        if(reset) begin
            BHSR <= 0;
            predictor_state <=0;
            for(i = 0; i< 32 ; i = i + 1)
                BTB[i][57:0] <= 0;
                BTB[i][62:58] <= 0;
                BTB[i][64:63] <=0;
                
        end
        else begin

            if((IsBranch || IsJAL || IsJALR) && !is_stall ) begin
         
                if(taken) begin
                    
                    BTB[ID_EX_XORindex][62:58] <= ID_EX_pc[6:2];
                    
                    BTB[ID_EX_XORindex][57] <= 1;
                    BTB[ID_EX_XORindex][56:32] <= ID_EX_tag;
                    BTB[ID_EX_XORindex][31:0] <= actual_pc;
                end
                
                
                if(taken)begin
                    BHSR <= {BHSR[3:0],1'b1};
                end
                else begin
                    BHSR <= {BHSR[3:0],1'b0};
                end
                case(BTB[ID_EX_XORindex][64:63])
                    2'b00: begin
                        if(taken) BTB[ID_EX_XORindex][64:63] <= 2'b01;
                        else BTB[ID_EX_XORindex][64:63] <= 2'b00;
                    end
                    2'b01: begin
                        if(taken) BTB[ID_EX_XORindex][64:63] <= 2'b10;
                        else BTB[ID_EX_XORindex][64:63] <= 2'b00;
                    end
                    2'b10: begin
                        if(taken) BTB[ID_EX_XORindex][64:63] <= 2'b11;
                        else BTB[ID_EX_XORindex][64:63] <= 2'b01;
                    end
                    2'b11: begin
                        if(taken) BTB[ID_EX_XORindex][64:63] <= 2'b11;
                        else BTB[ID_EX_XORindex][64:63] <= 2'b10;
                    end
                endcase
            end
        end
        end
endmodule