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
    wire[31:0] current_pc;
    reg[31:0] next_pc;
    wire[31:0] instruction;
    reg[6:0] opcode;
    reg[4:0] rs1;
    reg[4:0] rs2;
    reg[4:0] rd;
    reg[31:0] alu_in_1;
    reg[31:0] alu_in_2;
    wire[31:0] rs1_dout;
    wire[31:0] rs2_dout;
    wire[31:0] imm_gen_out;
    wire[31:0] alu_result;
    wire alu_bcond;
    reg[31:0] din;
    reg[31:0] write_data;
    reg[31:0] dmem_addr;
    wire[31:0] dout;
    wire[3:0] alu_op_out;
    
    
     wire is_jal;        // output
     wire is_jalr;       // output
     wire branch;        // output
     wire mem_read;      // output
     wire mem_to_reg;    // output
     wire mem_write;     // output
     wire alu_src;       // output
     wire write_enable;     // output
     wire pc_to_reg;     // output
     wire is_ecall; 
     wire [31:0] dm_out;
     wire[31:0] ecall;
    
    
    
    
  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(next_pc),     // input
    .current_pc(current_pc)   // output
  );
  
  // ---------- Instruction Memory ----------
  InstMemory imem(
    .reset(reset),   // input
    .clk(clk),     // input
    .addr(current_pc),    // input
    .dout(instruction)     // output
  );

  // ---------- Register File ----------
  RegisterFile reg_file (
    .reset (reset),        // input
    .clk (clk),          // input
    .rs1 (rs1),          // input
    .rs2 (rs2),          // input
    .rd (rd),           // input
    .rd_din (write_data),       // input
    .write_enable (write_enable),    // input
    .ecall(ecall),
    .rs1_dout (rs1_dout),     // output
    .rs2_dout (rs2_dout)      // output
  );


  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .part_of_inst(instruction),  // input
    .is_jal(is_jal),        // output
    .is_jalr(is_jalr),       // output
    .branch(branch),        // output
    .mem_read(mem_read),      // output
    .mem_to_reg(mem_to_reg),    // output
    .mem_write(mem_write),     // output
    .alu_src(alu_src),       // output
    .write_enable(write_enable),     // output
    .pc_to_reg(pc_to_reg),     // output
    .is_ecall(is_ecall)       // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(instruction),  // input
    .imm_gen_out(imm_gen_out)    // output
  );

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .funct7(instruction[30:24]),  // input
    .funct3(instruction[14:12]),
    .opcode(instruction[6:0]),
    .inst(instruction),
    .alu_op_out(alu_op_out)         // output
  );

  // ---------- ALU ----------
  ALU alu (
    .alu_op_in(alu_op_out),      // input
    .input1(alu_in_1),    // input  
    .input2(alu_in_2),    // input
    .result_out(alu_result),  // output
    .bcond_out(alu_bcond)     // output
  );

  // ---------- Data Memory ----------
  DataMemory dmem(
    .reset (reset),      // input
    .clk (clk),        // input
    .addr (dmem_addr),       // input
    .din (din),        // input
    .mem_read (mem_read),   // input
    .mem_write (mem_write),  // input
    .dout (dm_out)        // output
  );
always @(*) begin
    //instruction = dout;
    opcode =instruction[6:0];
       //r-type
       if(opcode == `ARITHMETIC) begin
        rs1 = instruction[19:15];
        rs2 = instruction[24:20];
        rd = instruction[11:7];
      end
      else if(opcode == `ARITHMETIC_IMM || opcode ==`LOAD || opcode == `JALR ) begin
        rs1 = instruction[19:15];
        rd = instruction[11:7];
      end
      else if(opcode == `STORE) begin
        rs1 = instruction[19:15];
        rs2 = instruction[24:20]; 
      end
      //else if(opcode == `JAL) begin 
      else if(is_jal) begin
        rd = instruction[11:7];
      end
      //else if(opcode == `BRANCH) begin
      else if(branch) begin
        rs1 = instruction[19:15];
        rs2 = instruction[24:20];
      end
      else begin
        if(ecall == 10) begin
            is_halted = 1;
        end
        else begin
            is_halted = 0;
        end
      end
      /*ABOVE Instruction Decode Stage*/
      if(opcode == `ARITHMETIC || opcode == `BRANCH) begin
        alu_in_1 = rs1_dout;
        alu_in_2 = rs2_dout;
      end
      else if(opcode == `ARITHMETIC_IMM || opcode ==`LOAD || opcode == `JALR  || opcode == `STORE) begin
        alu_in_1 = rs1_dout;
        alu_in_2 = imm_gen_out;
      end
      /*ABOVE EXECUTION INPUT STAGE*/
      if(opcode == `LOAD || opcode ==`STORE) begin
        dmem_addr = alu_result;
        if(opcode == `STORE) begin
            din = rs2_dout;
        end
      end
      /*ABOVE MEM STAGE*/
      if(opcode == `ARITHMETIC || opcode == `ARITHMETIC_IMM) begin
        write_data = alu_result;
      end
      else if(opcode == `LOAD) begin
        write_data = dm_out;
      end
      //else if(opcode == `JAL || opcode == `JALR) begin
      else if(is_jal || is_jalr) begin  
        write_data = current_pc + 4;
      end
      /*ABOVE WRITE BACK STAGE*/
      if(opcode == `ARITHMETIC || opcode == `ARITHMETIC_IMM || opcode == `LOAD || opcode == `STORE) begin
        next_pc = current_pc + 4;
      end
      //else if(opcode == `JAL) begin
      else if(is_jal) begin
        next_pc = current_pc + imm_gen_out;
      end
      //else if(opcode == `JALR) begin
      else if(is_jalr) begin
        next_pc = rs1_dout + imm_gen_out;
      end
      //else if(opcode == `BRANCH) begin
      else if(branch) begin
        if(alu_bcond == 1) begin
            next_pc = current_pc + imm_gen_out;
        end
        else begin
            next_pc = current_pc + 4;
        end
      end
        
  
  end
endmodule