// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify the module.
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

`include "Memory.v"
`include "RegisterFile.v"
`include "ControlUnit.v"
`include "ImmediateGenerator.v"
`include "PC.v"
`include "ALU.v"

module CPU(input reset,       // positive reset signal
           input clk,         // clock signal
           output reg is_halted); // Whehther to finish simulation
  /***** Wire declarations *****/

  /***** Register declarations *****/
  reg [31:0] IR; // instruction register
  reg [31:0] MDR; // memory data register
  reg [31:0] A; // Read 1 data register
  reg [31:0] B; // Read 2 data register
  reg [31:0] ALUOut; // ALU output register 
  // Do not modify and use registers declared above.
  
  reg [31:0] old_pc;
  reg [31:0] next_pc;
  reg [31:0] reg_write_data;
  reg [31:0] mem_addr;
  reg [31:0] mem_data_reg;
  reg [31:0] alu_in_1;
  reg [31:0] alu_in_2;
  
  wire [31:0] rs1;
  wire [31:0] rs2;
  wire [31:0] mem_data_out;
  wire [31:0] ecall;
  
  wire PCWrite;
  wire PCWriteNotCond;
  wire IorD;
  wire MemRead;
  wire MemWrite;
  wire IRWrite;
  wire MemtoReg;
  wire PCSource;
  wire [1:0] ALUSrcB;
  wire ALUSrcA;
  wire RegWrite;
  wire Ecall;
  wire [31:0] ALUResult;
  wire [3:0] alu_op;
  wire bcond;
  wire [31:0] imm;
  wire [31:0] current_pc;
  wire [5:0] microPC;

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(next_pc),     // input
    .PCWrite(PCWrite),      // input
    .current_pc(current_pc)   // output
  );

  // ---------- Register File ----------
  RegisterFile reg_file(
    .reset(reset),        // input
    .clk(clk),          // input
    .rs1(IR[19:15]),          // input
    .rs2(IR[24:20]),          // input
    .rd(IR[11:7]),           // input
    .rd_din(reg_write_data),       // input
    .write_enable(RegWrite),    // input
    .ecall(ecall),
    .rs1_dout(rs1),     // output
    .rs2_dout(rs2)      // output
  );

  // ---------- Memory ----------
  Memory memory(
    .reset(reset),          // input
    .clk(clk),              // input
    .addr(mem_addr),        // input
    .din(B),                // input
    .mem_read(MemRead),     // input
    .mem_write(MemWrite),   // input
    .dout(mem_data_out)     // output
  );

  // ------------- Control Unit ----------------
  ControlUnit ctrl_unit(

    ////////// input ////////
    .clk(clk),             
    .reset(reset),           
    .opcode(IR[6:0]),  
    .in_bcond(bcond),                      
    ////////// output ////////        
    .PCWrite(PCWrite),
    .PCWriteNotCond(PCWriteNotCond),
    .IorD(IorD),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .IRWrite(IRWrite),
    .MemtoReg(MemtoReg),
    .PCSource(PCSource),
    .ALUSrcB(ALUSrcB),
    .ALUSrcA(ALUSrcA),
    .RegWrite(RegWrite),
    .Ecall(Ecall),
    .microPC(microPC)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(IR),  // input
    .imm_gen_out(imm)    // output
  );

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit(
    .inst(IR),  // input
    .microPC(microPC),
    .alu_op_out(alu_op)         // output
  );

  // ---------- ALU ----------
  ALU alu(
    .alu_op_in(alu_op),      // input
    .input1(alu_in_1),    // input  
    .input2(alu_in_2),    // input
    .ALUSrcB(ALUSrcB),
    .result_out(ALUResult),  // output
    .bcond_out(bcond)     // output
  );
  
  always @(*) begin
    
    if(microPC[2:0] == 3'b000)
        old_pc = current_pc;
        
    
    
    ALUOut = ALUResult;
    
    A = rs1;
    B = rs2;
    
    if(MemRead)
        mem_data_reg = mem_data_out;
  
    //####################### reset ######################################
    if(reset) begin
        IR = 0; // instruction register
        MDR = 0; // memory data register
        A = 0; // Read 1 data register
        B = 0; // Read 2 data register
        ALUOut = 0; // ALU output register    
        next_pc = 0;
        reg_write_data = 0;
        mem_addr = 0;
        mem_data_reg = 0;
        alu_in_1 = 0;
        alu_in_2 = 0;
        is_halted = 0;
    end
    
    //######################## when to halt ################################
    if(Ecall == 1 && ecall == 10)
            is_halted = 1;
    
    //######################## IRWrite Control ###############################
    if(IRWrite == 1)
        IR = mem_data_out;
    
    //######################## IorD MUX ###############################
    if(IorD == 0)
        mem_addr = current_pc;
    else
        mem_addr = ALUOut;
        
    //######################## ALUSrcA MUX ###############################
    if(ALUSrcA == 0) begin
        alu_in_1 = current_pc;
        if(microPC[5:3] == `MICRO_PC_JAL || microPC[5:3] == `MICRO_PC_B)
            alu_in_1 = old_pc;
    end
    else
        alu_in_1 = A;
    
    //######################## ALUSrcB MUX ###############################
    if(ALUSrcB == 2'b00)
        alu_in_2 = B;
    else if (ALUSrcB == 2'b01)
        alu_in_2 = 4;
    else
        alu_in_2 = imm;
        
    //######################## PCSource MUX ###############################
    if (PCSource == 0)
        next_pc = ALUResult;
    else
        next_pc = ALUOut;
        
     //######################## MemtoReg MUX ###############################
     if (MemtoReg == 0)
        reg_write_data = ALUOut;
     else
        reg_write_data = mem_data_reg;
  
  end

endmodule
