//`include "Cache.v"
`include "InstMemory.v"
// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify modules (except InstMemory, DataMemory, and RegisterFile)
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module CPU(input reset,       // positive reset signal
           input clk,         // clock signal
           output reg is_halted); // Whehther to finish simulation
  /***** Wire declarations *****/
  /***** Register declarations *****/
  // You need to modify the width of registers
  // In addition, 
  // 1. You might need other pipeline registers that are not described below
  // 2. You might not need registers described below
  /***** IF/ID pipeline registers *****/
  reg [31:0] IF_ID_inst;           // will be used in ID stage
  reg [31:0] wire_IF_ID_inst;
  
  reg [31:0] IF_ID_predicted_pc;
  reg IF_ID_bubble;
  reg [31:0] IF_ID_pc;
  reg [31:0] wire_IF_ID_predicted_pc;
  reg wire_IF_ID_bubble;
  //reg [31:0] wire_IF_ID_pc;
  reg IF_ID_predicted_taken;
  
  
  /***** ID/EX pipeline registers *****/
  // From the control unit
  reg ID_EX_alu_op;         // will be used in EX stage
  reg ID_EX_alu_src;        // will be used in EX stage
  reg ID_EX_mem_write;      // will be used in MEM stage
  reg ID_EX_mem_read;       // will be used in MEM stage
  reg ID_EX_mem_to_reg;     // will be used in WB stage
  reg ID_EX_reg_write;      // will be used in WB stage
  
  reg ID_EX_pc_to_reg; // ++ JALR, JAL 
  // From others
  reg [31:0] ID_EX_rs1_data;
  reg [31:0] ID_EX_rs2_data;
  reg [31:0] ID_EX_imm;
  reg [31:0] ID_EX_ALU_ctrl_unit_input;
  reg [4:0] ID_EX_rd;
  reg [4:0] ID_EX_rs1;
  reg [4:0] ID_EX_rs2;
  reg ID_EX_HALT;
  reg wire_ID_EX_HALT;
  
  wire [3:0] wire_ID_EX_alu_op;         // will be used in EX stage
  wire wire_ID_EX_alu_src;        // will be used in EX stage
  wire wire_ID_EX_mem_write;      // will be used in MEM stage
  wire wire_ID_EX_mem_read;       // will be used in MEM stage
  wire wire_ID_EX_mem_to_reg;     // will be used in WB stage
  wire wire_ID_EX_reg_write;      // will be used in WB stage
  wire wire_ID_EX_pc_to_reg; // ++ JALR, JAL 
  wire [31:0] wire_ID_EX_rs1_data;
  wire [31:0] wire_ID_EX_rs2_data;
  wire [31:0] wire_ID_EX_imm;
  reg [31:0] wire_ID_EX_ALU_ctrl_unit_input;
  reg [4:0] wire_ID_EX_rd;
  reg [4:0] wire_ID_EX_rs1;
  reg [4:0] wire_ID_EX_rs2;
  
  reg [31:0] ID_EX_predicted_pc;
  reg ID_EX_predicted_taken;
  reg ID_EX_bubble;
  reg ID_EX_IsBranch;
  reg ID_EX_IsJAL;
  reg ID_EX_IsJALR;
  reg [31:0] ID_EX_pc;
  
  reg [31:0] wire_ID_EX_predicted_pc;
  reg wire_ID_EX_predicted_taken;
  reg wire_ID_EX_bubble;
  wire wire_ID_EX_IsBranch;
  wire wire_ID_EX_IsJAL;
  wire wire_ID_EX_IsJALR;
  reg [31:0] wire_ID_EX_pc;
  
  /***** EX/MEM pipeline registers *****/
  // From the control unit
  reg EX_MEM_mem_write;     // will be used in MEM stage
  reg EX_MEM_mem_read;      // will be used in MEM stage
  reg EX_MEM_is_branch;     // will be used in MEM stage
  reg EX_MEM_mem_to_reg;    // will be used in WB stage
  reg EX_MEM_reg_write;     // will be used in WB stage
  // From others
  reg [31:0] EX_MEM_alu_out;
  reg [31:0] EX_MEM_dmem_data;
  reg [4:0] EX_MEM_rd;
  reg EX_MEM_HALT;
  reg wire_EX_MEM_HALT;
  
  
  reg wire_EX_MEM_mem_write;     // will be used in MEM stage
  reg wire_EX_MEM_mem_read;      // will be used in MEM stage
  reg wire_EX_MEM_is_branch;     // will be used in MEM stage
  reg wire_EX_MEM_mem_to_reg;    // will be used in WB stage
  reg wire_EX_MEM_reg_write;     // will be used in WB stage
  // From others
  wire [31:0]  wire_EX_MEM_alu_out;
  reg [31:0] wire_EX_MEM_dmem_data;
  reg [4:0] wire_EX_MEM_rd;
  //forwarding
  wire [1:0] ForwardA;
  wire [1:0] ForwardB;

  reg [31:0] EX_MEM_pc;
  reg [31:0] wire_EX_MEM_pc;
  reg EX_MEM_pc_to_reg;
  reg wire_EX_MEM_pc_to_reg;
  
  
  /***** MEM/WB pipeline registers *****/
  // From the control unit
  reg MEM_WB_mem_to_reg;    // will be used in WB stage
  reg MEM_WB_reg_write;     // will be used in WB stage
  // From others
  reg [31:0] MEM_WB_mem_to_reg_src_1;
  reg [31:0] MEM_WB_mem_to_reg_src_2;
  reg [4:0] MEM_WB_rd;
  reg MEM_WB_HALT;
  reg wire_MEM_WB_HALT;
 
  reg [31:0] MEM_WB_pc;
  reg [31:0] wire_MEM_WB_pc;
  reg MEM_WB_pc_to_reg;
  reg wire_MEM_WB_pc_to_reg;
 
  reg wire_MEM_WB_mem_to_reg;    // will be used in WB stage
  reg wire_MEM_WB_reg_write;     // will be used in WB stage
  // From others
  reg [31:0] wire_MEM_WB_mem_to_reg_src_1;
  reg [31:0] wire_MEM_WB_mem_to_reg_src_2;
  reg [4:0] wire_MEM_WB_rd;
  //++
  // is_ecall 
  reg ID_EX_is_ecall;         // will be used in EX stage
  reg EX_MEM_is_ecall;
  reg MEM_WB_is_ecall;
    /***** Register declarations *****/
  reg [31:0] IR; // instruction register
//  reg [31:0] MDR; // memory data register
//  reg [31:0] A; // Read 1 data register
//  reg [31:0] B; // Read 2 data register
//  reg [31:0] ALUOut; // ALU output register 
  // Do not modify and use registers declared above.
  
  reg [31:0] old_pc;
  reg [31:0] next_pc;
  reg [31:0] reg_write_data;
  reg [31:0] mem_addr;
  reg [31:0] mem_data_reg;
  reg [31:0] alu_in_1;
  reg [31:0] alu_in_2;
  reg [4:0] read_register1;
  reg [31:0] wire_alu_in_2;
  
//  wire [31:0] rs1;
//  wire [31:0] rs2;
  wire [31:0] mem_data_out;
  wire [31:0] ecall;
  wire is_stall;
  wire is_ecall;
  wire [31:0] Instruction;
  
  //wire PCWrite;//stall용
  reg PCWrite;
  wire PCWriteNotCond;
  wire IorD;
  wire MemRead;
  wire MemWrite;
  wire IRWrite;
  wire MemtoReg;
  wire PCSource;
  wire RegWrite;
  wire [31:0] ALUResult;
  wire [3:0] alu_op;
  wire bcond;
  wire [31:0] imm;
  wire [31:0] current_pc;
  wire [5:0] microPC;
  wire [31:0] dmem_out;
  
  wire [31:0] corrected_pc_out;
  wire [31:0] predicted_pc_out;
  wire predicted_taken_out;
  
  wire is_ready;
  wire is_hit;
  wire is_output_valid;
  wire cache_dout[31:0];
  wire cache_stall;
  
  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(next_pc),     // input
    .PCWrite(PCWrite),
    .current_pc(current_pc)   // output
//    .current_pc()
  );
  
  // ---------- Instruction Memory ----------
  InstMemory imem(
    .reset(reset),   // input
    .clk(clk),     // input
    .addr(current_pc),    // input
    .dout(Instruction)     // output
  );
  
 CorrectedPC corrected_pc(
    .alu_result(wire_EX_MEM_alu_out),         //input
    .current_pc(ID_EX_pc),
    .immediate(ID_EX_imm),
    .ID_EX_predicted_pc(ID_EX_predicted_pc),
    .isJAL(ID_EX_IsJAL),
    .isJALR(ID_EX_IsJALR),
    .isBranch(ID_EX_IsBranch),
    .bcond(bcond),
    .corrected_pc(corrected_pc_out)         //output
  );
  
//TwoBitGlobalPredictor two_bit_global_predictor(
GsharePredictor gshare_predictor(
    .reset(reset),                          //input
    .clk(clk),
    .current_pc(current_pc),
    .actual_pc(corrected_pc_out),
    .ID_EX_pc(ID_EX_pc),
    .ID_EX_predicted_pc(ID_EX_predicted_pc),
    .IsBranch(ID_EX_IsBranch),
    .IsJAL(ID_EX_IsJAL),
    .IsJALR(ID_EX_IsJALR),
    .bcond(bcond),
    .is_stall(is_stall),
    .predicted_pc(predicted_pc_out),         //output
    .predicted_taken(predicted_taken_out)
 );
 


  // Update IF/ID pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
        IF_ID_inst <=0;
        IF_ID_predicted_pc <= 0;
        IF_ID_bubble <= 0;
        IF_ID_pc <= 0;
        next_pc <=32'b0;
        PCWrite <=1;
        IF_ID_predicted_taken <= 0;
        
    end
    else if(cache_stall ==0)begin
        IF_ID_inst <= wire_IF_ID_inst;
        IF_ID_predicted_pc <= wire_IF_ID_predicted_pc;
        IF_ID_bubble <= wire_IF_ID_bubble;
        if(!is_stall)begin
            IF_ID_pc <= current_pc;
            IF_ID_predicted_taken <= predicted_taken_out;
        end
        else begin
            IF_ID_pc <= IF_ID_pc;
            IF_ID_predicted_taken <= IF_ID_predicted_taken;
        end
        //IF_ID_predicted_taken <= predicted_taken_out;
    end
  end

  // ---------- Register File ----------
  RegisterFile reg_file (
    .reset (reset),        // input
    .clk (clk),          // input
//   .rs1 (IF_ID_inst[19:15]),          // input
    .rs1(read_register1[4:0]),
    .rs2 (IF_ID_inst[24:20]),          // input
    .rd (MEM_WB_rd),           // input
    .rd_din (reg_write_data),       // input
    .write_enable (MEM_WB_reg_write),    // input
    .rs1_dout (wire_ID_EX_rs1_data),     // output
    .rs2_dout (wire_ID_EX_rs2_data)      // output
  );


  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .part_of_inst(IF_ID_inst[31:0]),  // input
    .is_stall(is_stall),
    .mem_read(wire_ID_EX_mem_read),      // output
    .mem_to_reg(wire_ID_EX_mem_to_reg),    // output
    .mem_write(wire_ID_EX_mem_write),     // output
    .alu_src(wire_ID_EX_alu_src),       // output
    .write_enable(wire_ID_EX_reg_write),  // output
    .pc_to_reg(wire_ID_EX_pc_to_reg),     // output
    .alu_op(wire_ID_EX_alu_op),        // output
   //is_ecall(wire_ID_EX_is_ecall)       // output (ecall inst)
    .is_ecall(is_ecall),       // output (ecall inst)
    .IsBranch(wire_ID_EX_IsBranch),
    .IsJAL(wire_ID_EX_IsJAL),
    .IsJALR(wire_ID_EX_IsJALR)
  );
  
  // ---------- Hazard Control Unit ----------
  HazardControlUnit hazard_control(
    .part_of_inst(IF_ID_inst[31:0]),  // input
    .id_ex_rd(ID_EX_rd[4:0]),                // input
   // .ex_mem_rd(EX_MEM_rd[4:0]),               // input
    .id_ex_reg_write(ID_EX_reg_write),      // input
    .id_ex_mem_read(ID_EX_mem_read),
    .ex_mem_rd(EX_MEM_rd[4:0]),
    .ex_mem_mem_read(EX_MEM_mem_read),
    .ex_mem_reg_write(EX_MEM_reg_write),        // input
    .is_stall(is_stall)                 // output
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(IF_ID_inst),  // input
    .imm_gen_out(wire_ID_EX_imm)    // output
  );
  
//  HaltControlUnit hunit(
//    .id_ex_rd(ID_EX_rd),
//    .ex_mem_rd(EX_MEM_rd),
//    .id_ex_reg_write(ID_EX_reg_write),
//    .ex_mem_reg_write(EX_MEM_reg_write),
//    .id_ex_mem_read(ID_EX_mem_read),
//    .ex_mem_mem_read(EX_MEM_mem_read),
//    .ex_alu_result(),
//    .mem_dmem_out(),
//    .mem_alu_result(),
//    .halt_data(),
 //   .is_stall(),
  //);
  
  
  
  
  

  // Update ID/EX pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
        ID_EX_alu_op <=0;
        ID_EX_alu_src <=0;
        ID_EX_mem_write <=0;
        ID_EX_mem_read <=0;
        ID_EX_mem_to_reg <=0;
        ID_EX_reg_write <=0;
        
        ID_EX_rs1_data <=0;
        ID_EX_rs2_data <=0;
        ID_EX_imm <=0;
        ID_EX_ALU_ctrl_unit_input <=0;
        ID_EX_rd <=0;
        ID_EX_rs1 <=0;
        ID_EX_rs2 <=0;
        ID_EX_is_ecall <=0; 
        ID_EX_HALT <=0;
        
        ID_EX_IsBranch <= 0;
        ID_EX_IsJAL <= 0;
        ID_EX_IsJALR <= 0;
        ID_EX_predicted_pc <= 0;
        ID_EX_bubble <= 0;
        ID_EX_pc <= 0;
        ID_EX_predicted_taken <= 0;
        ID_EX_pc_to_reg <= 0;
        
    end
    else if(cache_stall ==0)begin
        ID_EX_alu_op <= wire_ID_EX_alu_op;
        ID_EX_alu_src <=wire_ID_EX_alu_src;
        ID_EX_mem_write <=wire_ID_EX_mem_write;
        ID_EX_mem_read <= wire_ID_EX_mem_read;
        ID_EX_mem_to_reg <=wire_ID_EX_mem_to_reg;
        ID_EX_reg_write <=wire_ID_EX_reg_write;
        
        ID_EX_rs1_data <=wire_ID_EX_rs1_data;
        ID_EX_rs2_data <=wire_ID_EX_rs2_data;
        ID_EX_imm <=wire_ID_EX_imm;
        ID_EX_ALU_ctrl_unit_input <=wire_ID_EX_ALU_ctrl_unit_input; //??????
        ID_EX_rd <=wire_ID_EX_rd;
        ID_EX_rs1 <=wire_ID_EX_rs1;
        ID_EX_rs2 <=wire_ID_EX_rs2;
       // ID_EX_is_ecall = local_is_halted;
        ID_EX_HALT <= wire_ID_EX_HALT;
        ID_EX_pc_to_reg <= wire_ID_EX_pc_to_reg;
        //ID_EX_is_ecall <= wire_ID_EX_is_ecall; ////????
        
        //#####################change ||is_stall ###################
        if(IF_ID_bubble || is_stall) begin
            ID_EX_IsBranch <= 0;
            ID_EX_IsJAL <= 0;
            ID_EX_IsJALR <= 0;
            ID_EX_predicted_pc <= 0;
            ID_EX_pc <= 0;
            ID_EX_predicted_taken <= 0;
        end
        else if(cache_stall ==0) begin
            ID_EX_IsBranch <= wire_ID_EX_IsBranch;
            ID_EX_IsJAL <= wire_ID_EX_IsJAL;
            ID_EX_IsJALR <= wire_ID_EX_IsJALR;
            ID_EX_predicted_pc <= wire_ID_EX_predicted_pc;
            ID_EX_pc <= wire_ID_EX_pc;
            ID_EX_predicted_taken <= wire_ID_EX_predicted_taken;
        end
        
        ID_EX_bubble <= wire_ID_EX_bubble;
        
    end
  end

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .inst(ID_EX_ALU_ctrl_unit_input),  // input
    .alu_op_out(alu_op)         // output
  );

  // ---------- ALU ----------
  ALU alu (
    .alu_op_in(alu_op),      // input
    .input1(alu_in_1),    // input  
    .input2(wire_alu_in_2),    // input
    .result_out(wire_EX_MEM_alu_out),  // output
    .bcond_out(bcond) //output
   // .alu_zero()     // output
  );
  
  ForwardingUnit funit(
    .rs1(ID_EX_rs1), //input
    .rs2(ID_EX_rs2),
    .ex_mem_rd(EX_MEM_rd),
    .ex_mem_reg_write(EX_MEM_reg_write),
    .mem_wb_rd(MEM_WB_rd),
    .mem_wb_reg_write(MEM_WB_reg_write),
    .forwardA(ForwardA),
    .forwardB(ForwardB)
  );
  
  // Update EX/MEM pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
        EX_MEM_mem_write <=0;
        EX_MEM_mem_read <=0;
        EX_MEM_is_branch <=0;
        EX_MEM_mem_to_reg <=0;
        EX_MEM_reg_write <=0;
        
        EX_MEM_alu_out <=0;
        EX_MEM_dmem_data <=0;
        EX_MEM_rd <=0;
        EX_MEM_HALT <=0;
        
        EX_MEM_pc <= 0;
        EX_MEM_pc_to_reg <= 0;
    end
    else if(cache_stall ==0)begin
        EX_MEM_mem_write <= wire_EX_MEM_mem_write;
        EX_MEM_mem_read <=wire_EX_MEM_mem_read;
        EX_MEM_is_branch <=wire_EX_MEM_is_branch;
        EX_MEM_mem_to_reg <=wire_EX_MEM_mem_to_reg;
        EX_MEM_reg_write <=wire_EX_MEM_reg_write;
        
        EX_MEM_alu_out <=wire_EX_MEM_alu_out;
        EX_MEM_dmem_data <=wire_EX_MEM_dmem_data;
        EX_MEM_rd <=wire_EX_MEM_rd;
        EX_MEM_HALT<=wire_EX_MEM_HALT;
        
        EX_MEM_pc <= wire_EX_MEM_pc;
        EX_MEM_pc_to_reg <= wire_EX_MEM_pc_to_reg;
    end
  end

  // ---------- Data Memory ----------
//  DataMemory dmem(
//    .reset (reset),      // input
//    .clk (clk),        // input
//    .addr (EX_MEM_alu_out),       // input
//    .din (EX_MEM_dmem_data),        // input
//    .mem_read (EX_MEM_mem_read),   // input
//    .mem_write (EX_MEM_mem_write),  // input
//    .dout (dmem_out)        // output
//  );


  Cache2 cache(
//  ACache cache(
    .reset(reset),
    .clk(clk),

    .is_input_valid(is_input_valid),
    .addr(EX_MEM_alu_out),
    .mem_read(EX_MEM_mem_read),
    .mem_write(EX_MEM_mem_write),
    .din(EX_MEM_dmem_data),

    .is_ready(is_ready),
    .is_output_valid(is_output_valid),
    .dout(dmem_out),
    .is_hit(is_hit)
  
  
  
  );
  assign is_input_valid =(EX_MEM_mem_read || EX_MEM_mem_write);
  assign cache_stall = (EX_MEM_mem_read || EX_MEM_mem_write) && (!is_ready || !is_output_valid ||!is_hit);
  // Update MEM/WB pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
        MEM_WB_mem_to_reg <=0;
        MEM_WB_reg_write <=0;
        
        MEM_WB_mem_to_reg_src_1 <=0;
        MEM_WB_mem_to_reg_src_2 <=0;
        MEM_WB_rd <=0;
        MEM_WB_HALT <=0;
        
        MEM_WB_pc <= 0;
        MEM_WB_pc_to_reg <= 0;
        
    end
    else if(cache_stall ==0) begin 
        MEM_WB_mem_to_reg <=wire_MEM_WB_mem_to_reg;
        MEM_WB_reg_write <=wire_MEM_WB_reg_write;
        
        MEM_WB_mem_to_reg_src_1 <=wire_MEM_WB_mem_to_reg_src_1;
        MEM_WB_mem_to_reg_src_2 <=wire_MEM_WB_mem_to_reg_src_2;
        MEM_WB_rd <= wire_MEM_WB_rd;
        MEM_WB_HALT <= wire_MEM_WB_HALT;
        
        MEM_WB_pc <= wire_MEM_WB_pc;
        MEM_WB_pc_to_reg <= wire_MEM_WB_pc_to_reg;
    end
  end
  
//  if((IF_ID_inst[24:20] == ID_EX_rd)||(IF_ID_inst == EX_MEM_rd)) begin
      
//      end

  
//  end
//######################## MemtoReg MUX ###############################
    always @(*) begin
        if (MEM_WB_mem_to_reg == 0) begin
            reg_write_data = MEM_WB_mem_to_reg_src_2;
        end
        else begin 
            reg_write_data = MEM_WB_mem_to_reg_src_1;
        end
        
        if(MEM_WB_pc_to_reg == 1 && cache_stall ==0) begin
            reg_write_data = MEM_WB_pc + 4;
        end
    end



// ######################### IF_ID #####################################3
    always @(*) begin
        wire_IF_ID_inst = Instruction;
        
        /////////////////////next pc logic//////////////////////////
        
        
        wire_ID_EX_ALU_ctrl_unit_input = IF_ID_inst;
        //wire_ID_EX_pc = IF_ID_pc;
        
        ////////////// bubble /////////////
        if((ID_EX_IsJAL || ID_EX_IsJALR) && (ID_EX_predicted_pc != wire_EX_MEM_alu_out))
            wire_IF_ID_bubble = 1;
        //else if( ID_EX_IsBranch && ID_EX_predicted_taken == 1 && ID_EX_predicted_pc != ID_EX_pc + ID_EX_imm) // predicted taken but actually not taken
        else if( ID_EX_IsBranch && ID_EX_predicted_taken == 1 && bcond == 0)
            wire_IF_ID_bubble = 1;
        //else if( ID_EX_IsBranch && ID_EX_predicted_taken == 0 && ID_EX_predicted_pc != ID_EX_pc + 4) // predicted taken but actually not taken
        else if( ID_EX_IsBranch && ID_EX_predicted_taken == 0 && bcond == 1)
            wire_IF_ID_bubble = 1;
        else
            wire_IF_ID_bubble = 0;
        
        wire_IF_ID_predicted_pc = predicted_pc_out;
        
        if(is_stall) begin
            next_pc = current_pc; //PC UPDATE 막음. 
            wire_IF_ID_inst = IF_ID_inst; // IF_ID_inst update 막음
            wire_IF_ID_bubble = IF_ID_bubble;
        end
        else begin
            if((ID_EX_IsJAL || ID_EX_IsJALR) && (ID_EX_predicted_pc != wire_EX_MEM_alu_out))
            next_pc = corrected_pc_out;
            //else if( ID_EX_IsBranch && ID_EX_predicted_taken == 1 && ID_EX_predicted_pc != ID_EX_pc + ID_EX_imm) // predicted taken but actually not taken
            else if( ID_EX_IsBranch && ID_EX_predicted_taken == 1 && bcond == 0)
                next_pc = corrected_pc_out;
            //else if( ID_EX_IsBranch && ID_EX_predicted_taken == 0 && ID_EX_predicted_pc != ID_EX_pc + 4) // predicted taken but actually not taken
            else if( ID_EX_IsBranch && ID_EX_predicted_taken == 0 && bcond == 1)
                next_pc = corrected_pc_out;
            else if(cache_stall)
                next_pc = current_pc;
            else
                next_pc = predicted_pc_out;
            if(cache_stall)
                next_pc = current_pc;
        end
        
        if(!is_ecall)
            read_register1 = IF_ID_inst[19:15];
        if(is_ecall&&!is_stall) begin
            read_register1 = 17;
            if (wire_ID_EX_rs1_data == 10) begin
                wire_ID_EX_HALT = 1;
             //   local_is_halted = 1;
            end   
            
        end
  
    end
//########################### ID _ EX ########################################

    always @(*) begin
        wire_ID_EX_rd = 0;
        wire_ID_EX_rs1 = 0;
        wire_ID_EX_rs2 = 0;
        
        wire_ID_EX_rd = IF_ID_inst[11:7];
        wire_ID_EX_rs1 = IF_ID_inst[19:15];
        wire_ID_EX_rs2 = IF_ID_inst[24:20];
        
        ////////////// bubble /////////////
        if((ID_EX_IsJAL || ID_EX_IsJALR) && (ID_EX_predicted_pc != wire_EX_MEM_alu_out))
            wire_ID_EX_bubble = 1;
        //else if( ID_EX_IsBranch && ID_EX_predicted_taken == 1 && ID_EX_predicted_pc != ID_EX_pc + ID_EX_imm) // predicted taken but actually not taken
        else if( ID_EX_IsBranch && ID_EX_predicted_taken == 1 && bcond == 0)
            wire_ID_EX_bubble = 1;
        //else if( ID_EX_IsBranch && ID_EX_predicted_taken == 0 && ID_EX_predicted_pc != ID_EX_pc + 4) // predicted taken but actually not taken
        else if( ID_EX_IsBranch && ID_EX_predicted_taken == 0 && bcond == 1)
            wire_ID_EX_bubble = 1;
        else
            wire_ID_EX_bubble = IF_ID_bubble;
        
        wire_ID_EX_pc = IF_ID_pc;
        wire_ID_EX_predicted_pc = IF_ID_predicted_pc;
        wire_ID_EX_predicted_taken = IF_ID_predicted_taken;
        
        if(is_stall||cache_stall) begin
            wire_ID_EX_pc = ID_EX_pc;
            wire_ID_EX_predicted_pc = ID_EX_predicted_pc;
            wire_ID_EX_predicted_taken = ID_EX_predicted_taken;
            wire_ID_EX_bubble = ID_EX_bubble;
//            wire_ID_EX_JAL
        end
            
    end
    
//######################## EX _ MEM ###############################
    always @(*) begin
        //alu_in_1 = ID_EX_rs1_data;
        
        
        //################################## ALU_IN_1 MUX ######################
        if (ForwardA == 2'b00) begin
            alu_in_1 = ID_EX_rs1_data;
            // if JAL, alu_in_1 is PC
            if(ID_EX_IsJAL)
                alu_in_1 = ID_EX_pc;
        end
        else if (ForwardA == 2'b01) begin
            alu_in_1 = reg_write_data;
        end
        else if (ForwardA == 2'b10) begin
            alu_in_1 = EX_MEM_alu_out;
        end
        
        //################################## ALU_IN_2 MUX ######################
        if (ForwardB == 2'b00) begin
            alu_in_2 = ID_EX_rs2_data;
        end
        else if (ForwardB == 2'b01) begin
            alu_in_2 = reg_write_data;
        end
        else if (ForwardB == 2'b10) begin
            alu_in_2 = EX_MEM_alu_out;
        end
        
        // ############################### ALU_IN_2_MUX 2################################
        if (ID_EX_alu_src==0) begin
            wire_alu_in_2 = alu_in_2;
        end
        else begin
            wire_alu_in_2 = ID_EX_imm;
        end
        
//       if (is_ecall==1 && ID_EX_rd ==17 && wire_EX_MEM_alu_out ==10) begin
//            wire_ID_EX_HALT = 1;
//        end
    
        wire_EX_MEM_mem_write = ID_EX_mem_write;
        wire_EX_MEM_mem_read = ID_EX_mem_read;
        wire_EX_MEM_is_branch = bcond;
        wire_EX_MEM_mem_to_reg = ID_EX_mem_to_reg;
        wire_EX_MEM_reg_write = ID_EX_reg_write;
        wire_EX_MEM_pc = ID_EX_pc;
        wire_EX_MEM_pc_to_reg = ID_EX_pc_to_reg;
        
        
        
        //wire_EX_MEM_alu_out =  바로 연결
    //    wire_EX_MEM_dmem_data = ID_EX_rs2_data;
        wire_EX_MEM_dmem_data = alu_in_2;
        wire_EX_MEM_rd = ID_EX_rd;
        wire_EX_MEM_HALT = ID_EX_HALT;
        
        /*
        if(is_stall) begin
            wire_EX_MEM_mem_write = EX_MEM_mem_write;
            wire_EX_MEM_mem_read = EX_MEM_mem_read;
            wire_EX_MEM_is_branch = EX_MEM_is_branch;
            wire_EX_MEM_mem_to_reg = EX_MEM_mem_to_reg;
            wire_EX_MEM_reg_write = EX_MEM_reg_write;
            wire_EX_MEM_dmem_data = EX_MEM_dmem_data;
            wire_EX_MEM_rd = EX_MEM_rd;
            wire_EX_MEM_pc = EX_MEM_pc;
            wire_EX_MEM_pc_to_reg = EX_MEM_pc_to_reg;
        end
        */
        
        // if there is bubble flag in the pipeline register, it dosen't update PVS.
        if(ID_EX_bubble == 1) begin
            wire_EX_MEM_reg_write = 0;
            wire_EX_MEM_mem_write = 0;
        end
    end
    
    
    //######################## MEM _ WB ###############################
    always @(*) begin
        wire_MEM_WB_mem_to_reg = EX_MEM_mem_to_reg;
        wire_MEM_WB_reg_write = EX_MEM_reg_write;
       
        wire_MEM_WB_mem_to_reg_src_1 = dmem_out;
        wire_MEM_WB_mem_to_reg_src_2 = EX_MEM_alu_out;
        wire_MEM_WB_rd = EX_MEM_rd;
        wire_MEM_WB_HALT = EX_MEM_HALT;
        
        wire_MEM_WB_pc = EX_MEM_pc;
        wire_MEM_WB_pc_to_reg = EX_MEM_pc_to_reg;
        
        
//        if (is_ecall ==1 && EX_MEM_rd ==17 && EX_MEM_alu_out ==10) begin
//            wire_ID_EX_HALT =1;
//        end
    end
    
    // ####################### HALT CONDITION ######################
    always @(*) begin
        if(MEM_WB_HALT == 1)begin
            is_halted =1;
        end
    
    end
    
    //###################### cache stall 
//    always @(*) begin
//        if((EX_MEM_mem_read||EX_MEM_mem_write)&&(!is_hit || !is_output_valid || !is_ready))begin
//           cache_stall =1;
//        end
//        else cache_stall =0;
       
//    end
endmodule
    

