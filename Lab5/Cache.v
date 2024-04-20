`include "CLOG2.v"
`include "DataMemory.v"
module Cache #(parameter LINE_SIZE = 16,
               parameter NUM_SETS = 16,/* Your choice */
               parameter NUM_WAYS = 1/* Your choice */) (
    input reset,
    input clk,

    input is_input_valid,
    input [31:0] addr,
    input mem_read,
    input mem_write,
    input [31:0] din,

//    output reg is_ready,
    output is_ready,
    output reg is_output_valid,
    output reg [31:0] dout,
    output reg is_hit);
    reg[127:0] total_count;
    reg[127:0] hit_count;
//  initial begin
//    $monitor("Total : %d Hit: %d",total_count, hit_count);
//  end
  // Wire declarations
  wire is_data_mem_ready;
  wire wire_is_output_valid;
  //wire is_data_mem_ready;
  wire [127:0]dmem_dout;
  // Reg declarations
  // You might need registers to keep the status.
  reg [154:0] CACHE [0:15];
  reg [3:0]index;
  reg [23:0]tag;
  reg [1:0]blockoffset;
  reg wire_mem_read;
  reg wire_mem_write;
  reg [127:0]wire_din; // 128bit
  reg [31:0]wire_addr; // 32bit
  reg [2:0]cache_state; // 3bit
  wire is_valid;
  wire is_dirty;
  wire is_tag;
  reg replacement;
  reg [23:0]cache_tag; // 24bit
  reg [127:0]cache_data; //128bit
  reg wire_is_data_mem_ready;
  reg is_dmem_input_valid;
  integer i;
  reg finish;
  reg check;
  reg output_ready;
  reg write_check;
  reg read_check;
  reg hit_check;
  
  assign is_ready = is_data_mem_ready||output_ready;
  assign is_tag = CACHE[addr[7:4]][154:131] == addr[31:8];
  assign is_dirty = CACHE[addr[7:4]][128] == 1;
  assign is_valid = CACHE[addr[7:4]][129] == 1;
//  assign is_ready = wire_is_data_mem_ready;

  // Instantiate data memory
  DataMemory #(.BLOCK_SIZE(LINE_SIZE)) data_mem(
    .reset(reset),
    .clk(clk),

    .is_input_valid(is_dmem_input_valid),
    .addr({wire_addr>>4}),        // NOTE: address must be shifted by CLOG2(LINE_SIZE)
    .mem_read(wire_mem_read),
    .mem_write(wire_mem_write),
    .din(wire_din),

    // is output from the data memory valid?
    .is_output_valid(wire_is_output_valid),
    .dout(dmem_dout),
    // is data memory ready to accept request?
    .mem_ready(is_data_mem_ready)
  );
  
  always @(*) begin
//        is_hit =0;
//        is_output_valid=0;
    check =0;
//    is_dmem_input_valid=0;
       if((mem_read||mem_write) && is_input_valid) begin
       
//           is_data_mem_valid = is_data_mem_ready;

      
            tag = addr[31:8];
            index = addr[7:4];
//           blockoffset = addr[3:2];
//           is_valid =CACHE[addr[7:4]][129];
//           is_dirty =CACHE[addr[7:4]][128];
           
//           is_valid =CACHE[index][129];
//           is_dirty =CACHE[index][128];
            cache_tag = CACHE[addr[7:4]][154:131];
//           cache_data = CACHE[addr[7:4]][127:0];
           if (cache_state[2:0] == 3'b000) begin
                wire_din =4294967295;
                wire_addr =4294967295;
                wire_mem_read=0;
                wire_mem_write=0;
                hit_check=0;
//                is_dmem_input_valid =0;
//                is_hit =0;
//                is_output_valid =0;
//                finish =0;
//                is_ready =0;
                
           end
           
           //######### cache hit check #################
           else if (cache_state[2:0] == 3'b001) begin    
                wire_din =4294967295;
                wire_addr =4294967295;
                wire_mem_read=0;
                wire_mem_write=0;
//               is_dmem_input_valid =0;
                if (is_valid && (addr[31:8]== CACHE[addr[7:4]][154:131])) begin
//                    is_hit =1;
//                    cache_state =3'b100;
                end


           end
          // 010 Write Back
          else if(cache_state[2:0] ==3'b010) begin
               wire_din = CACHE[addr[7:4]][127:0];
               
               wire_addr = {CACHE[addr[7:4]][154:131],addr[7:4], 4'b0000}; // 4bit shift
               wire_mem_read = 0;
               wire_mem_write = 1;
               hit_check =1;
               //0526
//               if(is_ready) is_dmem_input_valid =1;
//               else is_dmem_input_valid =0;
   //0526
               
          end
          //011 Allocate
          else if(cache_state ==3'b011) begin
               wire_din =4294967295; //NO DIN  
               wire_addr = addr;
               wire_mem_read =1;
               wire_mem_write =0;
               is_dmem_input_valid=1;
               hit_check=1;
               //0526
//               if(is_ready) is_dmem_input_valid =1;
//               else is_dmem_input_valid =0;
                //0526
          end

          else if(cache_state ==3'b100) begin
                wire_din =4294967295; //NO DIN  
                wire_addr = 4294967295;
                wire_mem_read =0;
                wire_mem_write = 0;
                //is_dmem_input_valid =0;
               case(addr[3:2]) 
                2'b00: begin
                    dout = CACHE[addr[7:4]][31:0];
                end
                2'b01: begin
                    dout = CACHE[addr[7:4]][63:32];
                end
                2'b10: begin
                    dout = CACHE[addr[7:4]][95:64];
                end
                2'b11: begin
                    dout = CACHE[addr[7:4]][127:96];
                end
                endcase
                if(mem_read)begin
                
//                 $display("READ### idx : %d tag :%x, data : %x",addr[7:4], addr[31:8], dout);
                 
                      
                end
                if(!hit_check)begin
                    hit_count = hit_count+1;
                    hit_check =0;
                end
//                is_data_mem_valid =0;
//                is_hit = 1;
//                is_ready =1;
//                finish =1;
//                is_output_valid = 1;
//                cache_state =0;
                total_count = total_count +1;
                $monitor("T : %d t: %d",total_count, hit_count);

          end


       
      end 
  end
  
  always @(posedge clk)begin
       //######## initialize ##########################
       if(reset) begin
//       $display("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
            cache_state <= 0;
              index[3:0]<=0;
              tag[23:0]<=0;
             
//              blockoffset[1:0]<=0;
              wire_mem_read<=0;
              wire_mem_write<=0;
              wire_din[127:0]<=0; // 128bit
              wire_addr[31:0]<=0; // 32bit
              replacement<=0;
              cache_tag[23:0]<=0; // 24bit
              cache_data[127:0]<=0; //128bit
              wire_is_data_mem_ready<=0;
//              is_ready <=0;
              finish <= 0;
              total_count<=0;
              hit_count<=0;
              is_hit<=0;
              is_dmem_input_valid<=0;
              output_ready<=0;
                write_check<=0;
                read_check <=0;
                hit_check <=0;
            for(i = 0; i< 16 ; i = i + 1)
                // CACHE[i][154:0] <= 0;
                CACHE[i] = 0;
       end
       
      else if(is_input_valid&&(mem_read||mem_write)) begin
            case(cache_state)
                    3'b000: begin

//                        if(!finish && is_input_valid)cache_state <= 3'b001;
                        if(is_input_valid)cache_state <= 3'b001;
                        
//                        else if(finish && is_input_valid) begin
//                        cache_state<= 3'b000; //#########여기 있다가 새로운 request 들어오면 다시 01로 이동 해야됨. 
//                        finish<=0;
//                        //////
//                        is_hit<=0;
//                        is_output_valid<=0;
//                        ///////
//                        end
                        
                        
                        else begin
                        finish<=0;
                        end
                        
                    end
                    //################# Compare tag #######################
                    3'b001: begin
//                         if(is_hit&&mem_read) begin
//                             cache_state <= 3'b100;
// //                            is_ready <=1;
//                             is_output_valid <=1;        
//                         end
//                         if(is_hit&&mem_write) begin
//                                 cache_state <= 3'b100;
// //                                is_ready <=1;
//                                 is_output_valid <=1;
//                                 //dirty
//                                 //write at block
    
//                         end
                        if(is_valid && is_tag)begin
                         cache_state <=3'b100;
                         is_hit <=1;
                         is_output_valid<=1;
                         output_ready<=1;
//                         is_ready <=1;
                         
                         end
//                        else if(!is_valid)begin
//                         cache_state <= 3'b011;
//                         is_dmem_input_valid <=1;
//                         is_hit <=0;
//                         read_check<=1;
//                        end
                        else if(is_dirty)begin
                         cache_state <= 3'b010;
                         is_hit <=0;
                          wire_din <= CACHE[addr[7:4]][127:0];
                           wire_addr <= {CACHE[addr[7:4]][154:131],addr[7:4], 4'b0000}; // 4bit shift
                           wire_mem_read <= 0;
                           wire_mem_write <= 1;
                           is_dmem_input_valid <=1;
                            write_check <=1;
                         end
                        else if(!is_dirty)begin 
                        cache_state <=3'b011;
                        is_dmem_input_valid <=1;
                        is_hit <=0;
                         read_check<=1;
                        end
//                        else begin
//                        is_dmem_input_valid <=0;
//                        end
                    end
                    //################### Write - Back #################
                    3'b010: begin //######################################....# 메모리에 다 쓰고나면
                        //if(is_ready)
                        if(is_data_mem_ready&&!write_check)begin
                            is_dmem_input_valid<=1;
                            read_check<=1;
                            cache_state <= 3'b011;
                            
                            
                        end
                        else cache_state <= 3'b010;
                        is_dmem_input_valid <=0;
                        write_check<=0;
                    end
                    // ################# Allocate ####################### ....#메모리에서 읽어와야됨.
                    3'b011: begin
                        //if(is_ready)
                        if(is_data_mem_ready&&wire_is_output_valid&&!read_check)begin
                            cache_state <= 3'b001;
                
                            CACHE[addr[7:4]][154:131] <= addr[31:8]; //tag
                            CACHE[addr[7:4]][127:0]<=dmem_dout[127:0]; //data
                            CACHE[addr[7:4]][128]<=0; //dirty
                            CACHE[addr[7:4]][129]<=1; //valid 
                            CACHE[addr[7:4]][130]<=0; // 2WAY 중에 업데이트 되는에만 1. 
                 //0526
                            is_dmem_input_valid <=0;
                        end
                        else begin
                         cache_state <= 3'b011;
                        is_dmem_input_valid <=0;
                        read_check<=0;
                        end
                    end

                    3'b100: begin
                        output_ready<=0;
                        if(mem_write) begin
                        is_dmem_input_valid <=0;
                            cache_state<=0;
                            is_output_valid <=0;
                            finish <=1;
                            is_hit <=0;              
                            
                            CACHE[addr[7:4]][128]<=1;//dirty                           
//                            CACHE[addr[7:4]][129]<=1;//valid
                            
                            //write at block
                            case(addr[3:2])
                                2'b00: begin
                                    CACHE[addr[7:4]][31:0]<=din[31:0];
//                                    CACHE[addr[7:4]][127:0] <= 
                                end
                                2'b01: begin
                                    CACHE[addr[7:4]][63:32]<=din[31:0];
                                end
                                2'b10: begin
                                    CACHE[addr[7:4]][95:64]<=din[31:0];
                                end
                                2'b11: begin
                                    CACHE[addr[7:4]][127:96]<=din[31:0];
                                end
                            endcase
//                            $display("WRITE#### idx : %d tag :%x, data : %x",addr[7:4],CACHE[addr[7:4]][154:131],CACHE[addr[7:4]][127:0] );
                   

                        end
                        else begin
//                            is_dmem_input_valid <=0;
                            cache_state<=0;
                            is_output_valid <=0;
                            finish <=1;
                            is_hit <=0;

                        end
                    end
            endcase
       
       end
      else  begin
            if(finish) finish <=0;
      end
  end
endmodule

module Cache2 #(parameter LINE_SIZE = 16,
               parameter NUM_SETS = 8,/* Your choice */
               parameter NUM_WAYS = 2/* Your choice */) (
    input reset,
    input clk,

    input is_input_valid,
    input [31:0] addr,
    input mem_read,
    input mem_write,
    input [31:0] din,

//    output reg is_ready,
    output is_ready,
    output reg is_output_valid,
    output reg [31:0] dout,
    output reg is_hit);
    reg[127:0] total_count;
    reg[127:0] hit_count;
  initial begin
    $monitor("Total : %d Hit: %d",total_count, hit_count);
  end
  // Wire declarations
  wire is_data_mem_ready;
  wire wire_is_output_valid;
  //wire is_data_mem_ready;
  wire [127:0]dmem_dout;
  // Reg declarations
  // You might need registers to keep the status.
  reg [154:0] CACHE [0:15];
  reg [311:0] TWOWAYCACHE[0:7];
  reg [2:0]index;
  reg [24:0]tag;
  reg [1:0]blockoffset;
  reg wire_mem_read;
  reg wire_mem_write;
  reg [127:0]wire_din; // 128bit
  reg [31:0]wire_addr; // 32bit
  reg [2:0]cache_state; // 3bit
  reg cache_way;
  wire is_valid;
  wire is_dirty;
  wire is_tag;
  reg replacement;
  reg [24:0]cache_tag; // 24bit
  reg [127:0]cache_data; //128bit
  reg wire_is_data_mem_ready;
  reg is_dmem_input_valid;
  integer i;
  reg finish;
  reg check;
  reg output_ready;
  reg write_check;
  reg read_check;
  reg hit_check;
  reg cache_select;
  
  assign is_ready = is_data_mem_ready||output_ready;
  assign is_tag_1 = TWOWAYCACHE[addr[6:4]][152:128] == addr[31:7];
  assign is_dirty_1 = TWOWAYCACHE[addr[6:4]][154] == 1;
  assign is_valid_1 = TWOWAYCACHE[addr[6:4]][155] == 1;
  assign is_replace_1 = TWOWAYCACHE[addr[6:4]][153] == 1;
  
  assign is_tag_2 = TWOWAYCACHE[addr[6:4]][308:284] == addr[31:7];
  assign is_dirty_2 = TWOWAYCACHE[addr[6:4]][310] == 1;
  assign is_valid_2 = TWOWAYCACHE[addr[6:4]][311] == 1;
  assign is_replace_2 = TWOWAYCACHE[addr[6:4]][309] == 1;
  
//  assign is_tag = is_tag_1||is_tag_2;
//  assign is_dirty = is_dirty_1||is_dirty_2;
//  assign is_valid = is_valid_1||is_valid_2;
  
  
//  assign is_ready = wire_is_data_mem_ready;

  // Instantiate data memory
  DataMemory #(.BLOCK_SIZE(LINE_SIZE)) data_mem(
    .reset(reset),
    .clk(clk),

    .is_input_valid(is_dmem_input_valid),
    .addr({wire_addr>>4}),        // NOTE: address must be shifted by CLOG2(LINE_SIZE)
    .mem_read(wire_mem_read),
    .mem_write(wire_mem_write),
    .din(wire_din),

    // is output from the data memory valid?
    .is_output_valid(wire_is_output_valid),
    .dout(dmem_dout),
    // is data memory ready to accept request?
    .mem_ready(is_data_mem_ready)
  );
  
  always @(*) begin
//        is_hit =0;
//        is_output_valid=0;
    check =0;
//    is_dmem_input_valid=0;
       if((mem_read||mem_write) && is_input_valid) begin
       
//           is_data_mem_valid = is_data_mem_ready;

      
//            tag = addr[31:7];
//            index = addr[6:4];
//            cache_tag = TWOWAUCACHE[addr[6:4]][154:131];
//            cache_data = TWOWAYCACHE[addr[6:4]][154:131];
            
//           blockoffset = addr[3:2];
//           is_valid =CACHE[addr[7:4]][129];
//           is_dirty =CACHE[addr[7:4]][128];
           
//           is_valid =CACHE[index][129];
//           is_dirty =CACHE[index][128];
            
//           cache_data = CACHE[addr[7:4]][127:0];
           if (cache_state[2:0] == 3'b000) begin
                wire_din =4294967295;
                wire_addr =4294967295;
                wire_mem_read=0;
                wire_mem_write=0;
                hit_check=0;
//                is_dmem_input_valid =0;
//                is_hit =0;
//                is_output_valid =0;
//                finish =0;
//                is_ready =0;
                
           end
           
           //######### cache hit check #################
           else if (cache_state[2:0] == 3'b001) begin    
//                wire_din =4294967295;
//                wire_addr =4294967295;
//                wire_mem_read=0;
//                wire_mem_write=0;



//               is_dmem_input_valid =0;
//                if (is_valid && (addr[31:8]== CACHE[addr[7:4]][154:131])) begin
////                    is_hit =1;
////                    cache_state =3'b100;
//                end


           end
          // 010 Write Back
          else if(cache_state[2:0] ==3'b010) begin
            
//               wire_din = CACHE[addr[7:4]][127:0];
//               wire_addr = {CACHE[addr[7:4]][154:131],addr[7:4], 4'b0000}; // 4bit addr
               
               wire_din = cache_data;
               wire_addr = {cache_tag,index, 4'b0000}; // 4bit shift
               wire_mem_read = 0;
               wire_mem_write = 1;
               hit_check =1;
               //0526
//               if(is_ready) is_dmem_input_valid =1;
//               else is_dmem_input_valid =0;
   //0526
               
          end
          //011 Allocate
          else if(cache_state ==3'b011) begin
               wire_din =4294967295; //NO DIN  
               wire_addr = addr;
               wire_mem_read =1;
               wire_mem_write =0;
//               is_dmem_input_valid=1;
               hit_check=1;
               //0526
//               if(is_ready) is_dmem_input_valid =1;
//               else is_dmem_input_valid =0;
                //0526
          end

          else if(cache_state ==3'b100) begin
                wire_din =4294967295; //NO DIN  
                wire_addr = 4294967295;
                wire_mem_read =0;
                wire_mem_write = 0;
                //is_dmem_input_valid =0;
                if(cache_select==0)begin
                    case(addr[3:2]) 
                    2'b00: begin
                        dout = TWOWAYCACHE[addr[6:4]][31:0];
                    end
                    2'b01: begin
                        dout = TWOWAYCACHE[addr[6:4]][63:32];
                    end
                    2'b10: begin
                        dout = TWOWAYCACHE[addr[6:4]][95:64];
                    end
                    2'b11: begin
                        dout = TWOWAYCACHE[addr[6:4]][127:96];
                    end
                    endcase
                
                end
                
                
                else if (cache_select == 1)begin
                    case(addr[3:2]) 
                    2'b00: begin
    //                    dout = CACHE[addr[6:4]][31:0];
                        dout = TWOWAYCACHE[addr[6:4]][187:156];
                    end
                    2'b01: begin
    //                    dout = CACHE[addr[6:4]][63:32];
                       dout = TWOWAYCACHE[addr[6:4]][219:188];
                    end
                    2'b10: begin
    //                    dout = CACHE[addr[6:4]][95:64];
                        dout = TWOWAYCACHE[addr[6:4]][251:220];
                    end
                    2'b11: begin
    //                    dout = CACHE[addr[6:4]][127:96];
                        dout = TWOWAYCACHE[addr[6:4]][283:252];
                    end
                    endcase
                end
                
               
                if(mem_read)begin
                
//                 $display("READ### idx : %d tag :%x, data : %x",addr[7:4], addr[31:8], dout);
                 
                      
                end
                if(!hit_check)begin
                    hit_count = hit_count+1;
                    hit_check =0;
                end
//                is_data_mem_valid =0;
//                is_hit = 1;
//                is_ready =1;
//                finish =1;
//                is_output_valid = 1;
//                cache_state =0;
                total_count = total_count +1;

          end


       
      end 
  end
  
  always @(posedge clk)begin
       //######## initialize ##########################
       if(reset) begin
//       $display("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
            cache_state <= 0;
              index[3:0]<=0;
              tag[23:0]<=0;
             
//              blockoffset[1:0]<=0;
              wire_mem_read<=0;
              wire_mem_write<=0;
              wire_din[127:0]<=0; // 128bit
              wire_addr[31:0]<=0; // 32bit
              replacement<=0;
              cache_tag[23:0]<=0; // 24bit
              cache_data[127:0]<=0; //128bit
              wire_is_data_mem_ready<=0;
//              is_ready <=0;
              finish <= 0;
              total_count<=0;
              hit_count<=0;
              is_hit<=0;
              is_dmem_input_valid<=0;
              output_ready<=0;
                write_check<=0;
                read_check <=0;
                hit_check <=0;
                cache_way <=0;
                cache_select<=0;
            for(i = 0; i< 16 ; i = i + 1)
                // CACHE[i][154:0] <= 0;
                CACHE[i] = 0;
            for(i = 0; i< 8 ; i = i + 1)
                // CACHE[i][154:0] <= 0;
                TWOWAYCACHE[i] = 0;
       end
       
      else if(is_input_valid&&(mem_read||mem_write)) begin
            case(cache_state)
                    3'b000: begin

//                        if(!finish && is_input_valid)cache_state <= 3'b001;
                        if(is_input_valid)begin
                            cache_state <= 3'b001;
                            cache_select <=0;
                        end    
//                        else if(finish && is_input_valid) begin
//                        cache_state<= 3'b000; //#########      ??     ο  request         ?  01    ?   ?? . 
//                        finish<=0;
//                        //////
//                        is_hit<=0;
//                        is_output_valid<=0;
//                        ///////
//                        end
                        
                        
                        else begin
                        finish<=0;
                        end
                        
                    end
                    //################# Compare tag #######################
                    3'b001: begin
                       
                        if(is_valid_1 && is_tag_1)begin
                             cache_state <=3'b100;
                             is_hit <=1;
                             is_output_valid<=1;
                             output_ready<=1;
                             cache_select<=0;
                             end
                         else if(is_valid_2 && is_tag_2)begin
                             cache_state <=3'b100;
                             is_hit <=1;
                             is_output_valid<=1;
                             output_ready<=1;
                             /// 2
                             cache_select<=1;
                         end
//                        else if(!is_valid)begin
//                         cache_state <= 3'b011;
//                         is_dmem_input_valid <=1;
//                         is_hit <=0;
//                         read_check<=1;
//                        end
                        else if(is_replace_1 && is_dirty_1)begin
                             cache_state <= 3'b010;
                             //@@@@@@@@@@@@@@@@@     ? 
                             cache_select <= 0;
                             //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                             is_hit <=0;
                             index <=addr[6:4];
                             cache_tag <=TWOWAYCACHE[addr[6:4]][152:128];
                             cache_data<=TWOWAYCACHE[addr[6:4]][127:0];
                              wire_din <= TWOWAYCACHE[addr[6:4]][127:0];
                               wire_addr <= {TWOWAYCACHE[addr[6:4]][152:128],addr[6:4], 4'b0000}; // 4bit shift
                               wire_mem_read <= 0;
                               wire_mem_write <= 1;
                               is_dmem_input_valid <=1;
                                write_check <=1;
                         end
                         else if(is_replace_2 && is_dirty_2)begin
                             cache_state <= 3'b010;
                             //@@@@@@@@@@@@@@@@@     ? 
                             cache_select <= 1;
                             //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                             is_hit <=0;
                             index <=addr[6:4];
                             cache_tag <=TWOWAYCACHE[addr[6:4]][308:284];
                             cache_data<=TWOWAYCACHE[addr[6:4]][283:156];
                              wire_din <=  TWOWAYCACHE[addr[6:4]][283:156];
                               wire_addr <= { TWOWAYCACHE[addr[6:4]][308:284],addr[6:4], 4'b0000}; // 4bit shift
                               wire_mem_read <= 0;
                               wire_mem_write <= 1;
                               is_dmem_input_valid <=1;
                                write_check <=1;
                         end
                        else if(is_replace_1&&!is_dirty_1)begin 
                            cache_state <=3'b011;
                            cache_select <=0; 
                            wire_addr=addr;
                            wire_mem_read <= 1;
                            wire_mem_write <= 0;
                            is_dmem_input_valid <=1;
                            is_hit <=0;
                            read_check<=1;
                        end
                        else if(is_replace_2&&!is_dirty_2)begin 
                            cache_select <=1;
                            cache_state <=3'b011;
                            wire_addr=addr;
                            wire_mem_read <= 1;
                               wire_mem_write <= 0;
                            is_dmem_input_valid <=1;
                            is_hit <=0;
                             read_check<=1;
                        end
                        else if(!is_replace_1 && !is_replace_2) begin
                            cache_select <=0;
                            cache_state <=3'b011;
                            wire_addr=addr;
                            wire_mem_read <= 1;
                               wire_mem_write <= 0;
                            is_dmem_input_valid <=1;
                            is_hit <=0;
                             read_check<=1;
                        end
                        else begin
                            if (is_valid_1 == 0) begin
                                cache_select <=0;
                                cache_state <=3'b011;
                                wire_addr=addr;
                                wire_mem_read <= 1;
                                wire_mem_write <= 0;
                                is_dmem_input_valid <=1;
                                is_hit <=0;
                                read_check<=1;
                            end
                            else begin
                                cache_select <=1;
                                cache_state <=3'b011;
                                wire_addr=addr;
                                wire_mem_read <= 1;
                                wire_mem_write <= 0;
                                is_dmem_input_valid <=1;
                                is_hit <=0;
                                read_check<=1;
                            end
                            
                        end
                       

                    end
                    //################### Write - Back #################
                    3'b010: begin //######################################....#  ??             
                        //if(is_ready)
                        if(is_data_mem_ready&&!write_check)begin
                            is_dmem_input_valid<=1;
                            read_check<=1;
                            cache_state <= 3'b011;
                        end
                        else begin 
                        cache_state <= 3'b010;
                        is_dmem_input_valid <=0;
                        write_check<=0;
                        end
                    end
                    // ################# Allocate ####################### ....# ??     о ;? .
                    3'b011: begin
                        //if(is_ready)
                        if(is_data_mem_ready&&wire_is_output_valid&&!read_check&&cache_select==0)begin
                            cache_state <= 3'b001;
                            TWOWAYCACHE[addr[6:4]][152:128] <= addr[31:7]; //tag
                            TWOWAYCACHE[addr[6:4]][127:0]<=dmem_dout[127:0]; //data
                            TWOWAYCACHE[addr[6:4]][154]<=0; //dirty
                            TWOWAYCACHE[addr[6:4]][155]<=1; //valid 
                            TWOWAYCACHE[addr[6:4]][153]<=0; // 2WAY  ?        ?  ?¿    1. 
                            TWOWAYCACHE[addr[6:4]][309]<=1; // 2WAY  ?        ?  ?¿    1. 
                 //0526
                            is_dmem_input_valid <=0;
                        end
                        
                        else if(is_data_mem_ready&&wire_is_output_valid&&!read_check&&cache_select==1)begin
                            cache_state <= 3'b001;
                            TWOWAYCACHE[addr[6:4]][308:284] <= addr[31:7]; //tag
                            TWOWAYCACHE[addr[6:4]][283:156]<=dmem_dout[127:0]; //data
                            TWOWAYCACHE[addr[6:4]][310]<=0; //dirty
                            TWOWAYCACHE[addr[6:4]][311]<=1; //valid 
                            TWOWAYCACHE[addr[6:4]][153]<=1; // 2WAY  ?        ?  ?¿    1. 
                            TWOWAYCACHE[addr[6:4]][309]<=0; // 2WAY  ?        ?  ?¿    1. 
                            
                            is_dmem_input_valid <=0;
                        end
                        
                        else begin
                         cache_state <= 3'b011;
                         is_dmem_input_valid <=0;
                        read_check<=0;
                         end
                        
                        
                    end

                    3'b100: begin
                        output_ready<=0;
                        cache_way<=0;
                        if(mem_write) begin
                        is_dmem_input_valid <=0;
                            cache_state<=0;
                            is_output_valid <=0;
                            finish <=1;
                            is_hit <=0;              
                            
                            //write at cache block
                            if(cache_select ==0) begin
                            TWOWAYCACHE[addr[6:4]][154]<=1;//dirty   
                            case(addr[3:2])
                                2'b00: begin
                                    TWOWAYCACHE[addr[6:4]][31:0]<=din[31:0];
//                                    CACHE[addr[7:4]][127:0] <= 
                                end
                                2'b01: begin
                                    TWOWAYCACHE[addr[6:4]][63:32]<=din[31:0];
                                end
                                2'b10: begin
                                    TWOWAYCACHE[addr[6:4]][95:64]<=din[31:0];
                                end
                                2'b11: begin
                                    TWOWAYCACHE[addr[6:4]][127:96]<=din[31:0];
                                end
                            endcase
                            end
                            
                            else if(cache_select ==1) begin
                            TWOWAYCACHE[addr[6:4]][310]<=1;//dirty   
                            case(addr[3:2])
                                2'b00: begin
                                    TWOWAYCACHE[addr[6:4]][187:156]<=din[31:0];
//                                    CACHE[addr[7:4]][127:0] <= 
                                end
                                2'b01: begin
                                    TWOWAYCACHE[addr[6:4]][219:188]<=din[31:0];
                                end
                                2'b10: begin
                                    TWOWAYCACHE[addr[6:4]][251:220]<=din[31:0];
                                end
                                2'b11: begin
                                    TWOWAYCACHE[addr[6:4]][283:252]<=din[31:0];
                                end
                            endcase
                            end
//                            $display("WRITE#### idx : %d tag :%x, data : %x",addr[7:4],CACHE[addr[7:4]][154:131],CACHE[addr[7:4]][127:0] );
                   

                        end
                        else begin
//                            is_dmem_input_valid <=0;
                            cache_state<=0;
                            is_output_valid <=0;
                            finish <=1;
                            is_hit <=0;

                        end
                    end
            endcase
       
       end
      else  begin
            if(finish) finish <=0;
      end
  end
endmodule