


module PC(reset,       // input (Use reset to initialize PC. Initial value must be 0)
    clk,         // input
    next_pc,     // input
    current_pc   // output
  );
    input reset;
    input clk;
    input [31:0]next_pc;
    output reg [31:0]current_pc;
    
    
    // Initialize register file (do not touch)
    always @(posedge clk) begin
    // Reset register file
        if (reset) begin
            current_pc <= 0;
        end
        else begin
            current_pc <= next_pc;
        end
    end

  
endmodule
