module tb2;
reg clk;

main DUT(clk);
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

initial
 begin
  clk=0;
 end

always

#5 clk = !clk;


endmodule

