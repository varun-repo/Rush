
module inst_mem(input clk, 
		        output reg [15:0] pc,
                output reg [31:0] inst);
                
reg [15:0] opcode;
reg[4:0] r_des;
reg[4:0] r_src1;
reg[4:0] r_src2;
//reg[3:0] pc;  
//reg enable;
reg[2:0] state;    
reg[1:0] ns;        
parameter ADD= 4'b001 , SUB= 4'b010 , NAND= 4'b011 , NOR= 4'b100;
parameter s0=  2'b00 , s1= 2'b01 , s2= 2'b10 , s3= 2'b11 , s4=3'b100;

reg enable = 1'b0;

 always @(negedge clk)
 begin
  if(!enable)
     begin
         state <= s0;
         enable <=1;
      end   
      
else
     
begin
       
 case(state)
 
 s0:
        begin
        pc <=4'd0;
        r_des  <= 4'd3;
        r_src1 <= 4'd2;
        r_src2 <= 4'd1;
        opcode <= { 13'b0, ADD};
        state <=s1;
        end
        
 s1:    begin  
        pc <=4'd4;
        r_des  <= 4'd6;
        r_src1 <= 4'd5;
        r_src2 <= 4'd3;
        opcode <= { 13'b0, SUB};
        state <=s2;
        end
        
 s2:     
        begin
            pc <= 4'd8;
        r_des  <= 4'd8;
        r_src1 <= 4'd3;
        r_src2 <= 4'd6;
        opcode <= { 13'b0 , NAND};
        state <=s3;
        end
        
 s3:    
        begin
            pc <= 4'd12;
        r_des  <= 4'd11;
        r_src1 <= 4'd9;
        r_src2 <= 4'd10;
        opcode <= { 13'b0, NOR};
        state <=s4;    
        end
 s4:
       begin  
       pc <= pc+ 4'd4 ;  
       state <=s4;
       end       
     endcase
     end   
 end 
  always @ (state)
  begin
        inst <= {opcode , r_des , r_src1 , r_src2 };
  end      
  endmodule   
                             
module if_id(  input clk ,
               input  [31:0] inst , 
               output reg [16:0] if_id_opcode ,
               output reg [14:0] if_id_ir ,
               output reg [4:0] if_id_portC,
               output reg [4:0] if_id_portA,
               output reg [4:0] if_id_portB
               );
               
  
  always@ (posedge clk)
  begin  
  
      if_id_ir[14:0]     <= inst[14:0];
      if_id_opcode <= inst[31:15];
      if_id_portB  <= inst[4:0];
      if_id_portA  <= inst[9:5];
      if_id_portC  <= inst[14:10];
  end
  
 /* always@ (negedge clk)
  begin
  portC_addr1 <= inst[15:10];
  end
  */
 endmodule    


module regfile( input clk ,
                input [14:0] if_id_ir , 
                input [4:0] if_id_portB,
                input [4:0] if_id_portA,
                input [4:0] if_id_portC,
                output reg [4:0]  portC_addr ,
                output reg [4:0]  portA_addr ,
                output reg [4:0]  portB_addr ,           
                output reg enableportA ,
                output reg enableportB ,
                output reg enableportC ,
                output reg [31:0] dataA ,
                output reg [31:0] dataB ,
                output reg [31:0] dataC ,
                input [31:0] ALUout ,
                input [4:0] id_ex_portC ,
                //output reg [4:0] id_ex_portC ,
                output reg matchA ,
                output reg matchB 
               );      
 
 reg [31:0] Regfile [31:0];
 //reg [4:0] tempA;
 //reg [4:0] tempB;
 //reg [4:0] tempC;
 //reg a;
 //reg b;
 initial
 begin
     Regfile[1] =  32'd40;
     Regfile[2] =  32'd60;
     Regfile[3] =  32'd0;
     Regfile[4] =  32'd60;
     Regfile[5] =  32'd120;
     Regfile[6] =  32'd0;
     Regfile[7] =  32'hFFFF856D;
     Regfile[8] =  32'hEEEE3721;
     Regfile[9] =  32'hFFFF765E;
     Regfile[10] = 32'h1FFF756F;
     Regfile[11] = 32'h0;
    
 end

 always @(posedge clk)
       begin
                 enableportA = 1'b1;
                 enableportB = 1'b1;
                 enableportC = 1'b1;
                 matchA =1'b0;
                 matchB= 1'b0;
       end   

 always @( id_ex_portC)
 begin
 //id_ex_portC = portC_addr;
 //id_ex_portC_temp = id_ex_portC;
 // comparator logic
 if (id_ex_portC == if_id_ir[9:5] ) 
 begin
 matchA =1'b1;
 matchB = 1'b0;
 end
 
 if (id_ex_portC == if_id_ir[4:0]) 
 begin
 matchA = 1'b0;
 matchB =1'b1;
 end
 
 else
 begin
 matchA =1'b0;
 matchB =1'b0;
 end
 
 end
 
 always@ (negedge clk)
 begin
     if(enableportA)
     begin
     portA_addr <= if_id_ir[9:5]; 
     dataA <= Regfile[if_id_ir[9:5]];
     //id_ex_portCA = portA_addr;
     end
     if(enableportB)
     begin
     portB_addr <= if_id_ir[4:0];
     dataB <= Regfile[if_id_ir[4:0]];
     //id_ex_portCB = portB_addr;
     end
   
     if(enableportC)
     begin   
      dataC <= ALUout ;
      portC_addr <= if_id_ir[14:10];
    // Regfile[portC_addr1] <= dataC;
     end
 end
 
 
 
 //end
 endmodule 

module id_ex(input clk,
             input [15:0] if_id_opcode ,
             input [31:0] dataA ,
             input [31:0] dataB , 
             input [4:0] portC_addr,            
             output reg [31:0] id_ex_A,
             output reg [31:0] id_ex_B,
             output reg [4:0] id_ex_portC,
             output reg [15:0] id_ex_opcode
            );

always @(posedge clk)
    begin
            id_ex_A <= dataA;
            id_ex_B <= dataB;
            id_ex_portC <= portC_addr ;
            id_ex_opcode <= if_id_opcode;
         
    end    
    

endmodule

module ALU ( input clk,
             input [31:0] id_ex_A,
             input [31:0] id_ex_B,
             input [15:0] id_ex_opcode,
             input matchA,
             input matchB, 
            // input [31:0] tempA,
             // input [31:0] tempB,
             // output reg [31:0] tempA1,
             //output reg [31:0] tempB1,
             //output reg temp_matchA,
             //output reg temp_matchB,
             
             output reg [31:0] result);
             
integer i,j;  
reg countA;
reg countB;           
//reg [15:0] temp;


always @(negedge clk)
begin
countA= matchA;
countB= matchB;

if(countA)
begin
case(id_ex_opcode)
 3'b001: begin        
          result = id_ex_A + id_ex_B;
         end  
 3'b010: begin 
           result = ~id_ex_B + result + 1;
          end   
 
 3'b011: begin
          for(i=0; i<32 ; i=i+1)
          begin
          result[i] = !( result[i] & id_ex_B[i]);
          end
         end
         
 3'b100: begin
           for(j=0; j<32 ; j=j+1)
           begin
           result[j] = !( result[j] | id_ex_B[j]);
           end
         end 
endcase
end
if(countB)
begin
case(id_ex_opcode)
 3'b001: begin        
          result = id_ex_A + id_ex_B;
         end  
 3'b010: begin 
           result = ~result + id_ex_A + 1;
          end   
 
 3'b011: begin
          for(i=0; i<32 ; i=i+1)
          begin
          result[i] = !( id_ex_A[i] & result[i]);
          end
         end
         
 3'b100: begin
           for(j=0; j<32 ; j=j+1)
           begin
           result[j] = !( id_ex_A[j] | result[j]);
           end
         end 
endcase
end
else
begin
case(id_ex_opcode)
 3'b001: begin        
          result = id_ex_A + id_ex_B;
         end  
 3'b010: begin 
           result = ~id_ex_B + id_ex_A + 1;
          end   
 
 3'b011: begin
          for(i=0; i<32 ; i=i+1)
          begin
          result[i] = !( id_ex_A[i] & id_ex_B[i]);
          end
         end
         
 3'b100: begin
           for(j=0; j<32 ; j=j+1)
           begin
           result[j] = !( id_ex_A[j] | id_ex_B[j]);
           end
         end 
endcase
end
end
endmodule

module ex_mem( input clk ,
               input[31:0] result ,
               //input [4:0] temp,
               output reg [31:0] ex_mem_ALUout 
               //output reg [31:0] dataC ,
               //output reg [4:0] ex_mem_portC 
               );

always @(posedge clk)
begin
    ex_mem_ALUout <= result;
   // ex_mem_portC <= temp;
end

endmodule

module writeback ( input clk,
                   input [31:0] ex_mem_ALUout,
                  // input [31:0] ex_mem_portC,
                   output reg [31:0] ALUout
                  // output reg [31:0] portC_addr3
                   );
                   
always @(negedge clk)  
begin
   // portC_addr3 <= ex_mem_portC;
         ALUout <= ex_mem_ALUout;
end   

endmodule


module main(input clk);
wire [15:0] pc;
wire [31:0] inst;
wire [15:0] if_id_opcode ;
wire [14:0] if_id_ir ;
//wire [4:0]  portC_addr;
wire [4:0]  if_id_portC;
wire [4:0]  if_id_portA;
wire [4:0]  if_id_portB;
wire enableportA , enableportB , enableportC;
wire [4:0] portC_addr;
wire [4:0] portA_addr;
wire [4:0] portB_addr;
wire [31:0] dataA ;
wire [31:0] dataB ;
wire [31:0] dataC ;
wire [4:0] id_ex_portC;
wire [31:0] id_ex_A;
wire [31:0] id_ex_B;
wire matchA;
wire matchB;
wire [15:0] id_ex_opcode;
wire [31:0] result;
//wire [4:0] ex_mem_portC;
wire [31:0] ex_mem_ALUout;
wire [31:0] ALUout;
//wire countA;
//wire countB;
/*wire [31:0] tempA;
wire [31:0] tempB;
wire [31:0] tempA1;
wire [31:0] tempB1;
wire temp_matchA;
wire temp_matchB; */
//reg [31:0] result;
//wire [4:0] id_ex_portC_temp;
//assign id_ex_portC = portC_addr;

inst_mem F1(clk, pc, inst);
if_id F2(clk ,inst , if_id_opcode ,if_id_ir , if_id_portC , if_id_portA , if_id_portB );
regfile F3( clk ,if_id_ir , if_id_portB , if_id_portA , if_id_portC , portC_addr , portA_addr , portB_addr , enableportA , 
enableportB ,enableportC, dataA , dataB , dataC , ALUout ,id_ex_portC , matchA ,matchB);
id_ex F4(clk, if_id_opcode , dataA ,dataB , portC_addr , id_ex_A , id_ex_B , id_ex_portC , id_ex_opcode);
ALU F5(clk, id_ex_A, id_ex_B,id_ex_opcode,matchA, matchB, result); 
ex_mem F6( clk , result , ex_mem_ALUout );
writeback F7( clk, ex_mem_ALUout , ALUout );

endmodule


