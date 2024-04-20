module PC(reset,       // input (Use reset to initialize PC. Initial value must be 0)
    clk,         // input
    next_pc,     // input
    current_pc,   // output
    PCWrite
  );
    input reset;
    input clk;
    input [31:0] next_pc;
    input PCWrite;
    output reg [31:0] current_pc;
    
    
    // Initialize register file (do not touch)
    always @(posedge clk) begin
    // Reset register file
        if (reset) begin
            current_pc <= 0;
        end
        else begin
            if(PCWrite == 1)
                
                current_pc <= next_pc;
//                $display("currentpc", current_pc);
        end
    end

  
endmodule

module CorrectedPC(
                    input [31:0] alu_result,
                    input [31:0] current_pc,
                    input [31:0] immediate,
                    input [31:0] ID_EX_predicted_pc,
                    input isJAL,
                    input isJALR,
                    input isBranch,
                    input bcond,
                    input is_stall,
                    output reg [31:0] corrected_pc
                    );
    
    always @(*) begin
        if(isJAL || isJALR) begin
            corrected_pc = alu_result;
        end
        else if(isBranch) begin
            if(bcond)
                corrected_pc = current_pc + immediate;
            else    
                corrected_pc = current_pc + 4;
        end
        else begin
            corrected_pc = 10'b0101010101; // for debug
        end
    end
    
endmodule
