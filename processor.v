`include "mult2_to_1_5.v"
`include "mult2_to_1_32.v"
`include "alu32.v"
`include "adder.v"
`include "control.v"
`include "signext.v"
`include "zeroext.v"
`include "alucont.v"
`include "shift.v"
`include "shift2jump.v"


module processor;
reg [31:0] pc; //32-bit prograom counter
reg clk; //clock
reg [7:0] datmem[0:31],instmem[0:31]; //32-size data and instruction memory (8 bit(1 byte) for each location)
wire [2:0] status;
reg [2:0] statusregister;
wire [31:0] 
dataa,	//Read data 1 output of Register File
datab,	//Read data 2 output of Register File
out2,		//Output of mux with ALUSrc control-mult2
out3,		//Output of mux with MemToReg control-mult3
out4,		//Output of mux with (Branch&ALUZero) control-mult4
out5,       //Output of mux with jalpc control-mult5 Added by Tolga
outnandimux,  //  output of outnandimux added by Toprak
outblezalmux, // output of outblezalmux added by Toprak
outbalvmux, // output of outbalvmux added by Toprak
outbrvmux,  // output of outbrvmux added by Toprak
outjalpcmux, //output of outjalpcmux added by Toprak
jmxorout, //output of jmxorout added by Toprak
outjmxoraddress, // //output of outjmxoraddress added by Toprak
outcombinedmux,
jmxorxor, //output of jmxorxor added by Toprak
sum,		//ALU result
extad,	//Output of sign-extend unit
zeroext, // output of zero extend unit written by Tolga
adder1out,	//Output of adder which adds PC and 4-add1
adder2out,	//Output of adder which adds PC+4 and 2 shifted sign-extend result-add2
sextad,	//Output of shift left 2 unit
zeroextadr, // Output of shift by 2 unit written by Tolga
nandiresult,
zeroextaddr,
signextnandi,
shiftedjump32;

wire [27:0]shiftedjump28; //  add two bit to the end of bits from 26 to 28



wire [5:0] inst31_26;	//31-26 bits of instruction
wire [25:0] inst25_0; 
wire [4:0] 
inst25_21,	//25-21 bits of instruction
inst20_16,	//20-16 bits of instruction
inst15_11,	//15-11 bits of instruction
out1,		//Write data input of Register File
outjmxorregdst, // output of jmxorregdest added by Toprak
outbalvregdst;  // output of outbalvregdst added by Toprak

wire [15:0] inst15_0;	//15-0 bits of instruction
wire [5:0] functcode;

wire [31:0] instruc,	//current instruction
dpack;	//Read data output of memory (data read from memory)

wire [2:0] gout;	//Output of ALU control unit

wire zout,	//Zero output of ALU
pcsrc,	//Output of AND gate with Branch and ZeroOut inputs

//Control signals
regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop0,brvsig,blezalsig,jalpcsig,nandisig,balvsig,jmxorsig;

//32-size register file (32 bit(1 word) for each register)
reg [31:0] registerfile[0:31];

integer i;

// datamemory connections

always @(posedge clk)
//write data to memory
if (memwrite)
begin 
//sum stores address,datab stores the value to be written
datmem[sum[4:0]+3]=datab[7:0];
datmem[sum[4:0]+2]=datab[15:8];
datmem[sum[4:0]+1]=datab[23:16];
datmem[sum[4:0]]=datab[31:24];
//datmem[outjmxoraddress[4:0]+3]=datab[7:0];//jmxor deciding what data to store
//datmem[outjmxoraddress[4:0]+2]=datab[15:8];
//datmem[outjmxoraddress[4:0]+1]=datab[23:16];
//datmem[outjmxoraddress[4:0]]=datab[31:24];
end

always @(posedge clk) begin
    statusregister <= alu1.status;
 end   

//instruction memory
//4-byte instruction
 assign instruc={instmem[pc[4:0]],instmem[pc[4:0]+1],instmem[pc[4:0]+2],instmem[pc[4:0]+3]};
 assign inst31_26=instruc[31:26];
 assign inst25_21=instruc[25:21];
 assign inst20_16=instruc[20:16];
 assign inst15_11=instruc[15:11];
 assign inst15_0=instruc[15:0];
 assign inst25_0=instruc[25:0];
 assign functcode=instruc[5:0];


// registers

assign dataa=registerfile[inst25_21];//Read register 1
assign datab=registerfile[inst20_16];//Read register 2

//assign blezaland=blezalsig&(dataa[31]==1 ? 1:0); //added blezaland here Toprak 2's complement???
//assign jmxorxor=dataa^datab; //added jmxorxor here Toprak, TODO check if ^ is xor

always @(posedge clk)
 registerfile[out1]= regwrite ? out3:registerfile[out1];//Write data to register
 //registerfile[outbalvregdst]= regwrite ? outnandimux:registerfile[outbalvregdst];//Write data to register depending on our muxes

//read data from memory, sum stores address
assign dpack={datmem[sum[5:0]],datmem[sum[5:0]+1],datmem[sum[5:0]+2],datmem[sum[5:0]+3]};

//multiplexers
//mux with RegDst control
mult2_to_1_5  mult1(out1, instruc[20:16],instruc[15:11],regdest);

// mux with control jmxorsig (for selecting 31. reg as destination) added by Toprak output not yet connected!!
mult2_to_1_5 jmxorregdst(outjmxorregdst, out1, 5'b11111, jmxorsig);

// mux with control balvsig (for selecting 31. reg as destination) added by Toprak output not yet connected!!
mult2_to_1_5 balvregdst(outbalvregdst, outjmxorregdst, 5'b11111, balvsig);

//mux with ALUSrc control
mult2_to_1_32 mult3(out2, datab,extad,alusrc);

//mux with MemToReg control 
mult2_to_1_32 mult4(out3, sum,dpack,memtoreg);

//mux with (Branch&ALUZero) control will not be used anymore
mult2_to_1_32 mult6 (out4, adder1out,adder2out,pcsrc);

// mux with select nandi
//mult2_to_1_32 nandimux(outnandimux,nandiresult,outcombinedmux,nandisig); 

// mux with (blezalmux) control added by Toprak
mult2_to_1_32 blezalmux (outblezalmux, adder1out, adder2out, (blezaland|pcsrc));

// mux with (balv) control added by Tolga
//mult2_to_1_32 balvmux (outbalvmux, outblezalmux, shiftedjump32, ((statusregister[0])&balvsig)); // it will be implemented for balv

// mux with (Brv) control added by Tolga
//mult2_to_1_32 brvmux (outbrvmux, outbalvmux, sum, (brvsig&statusregister[0])); 

// mux with (jalpc) control added by Tolga
//mult2_to_1_32 jalpcmux (outjalpcmux, outbrvmux, adder1out, jalpcsig);//changed jalpc to jalpcsig 

// mux with control (jmxormux)
//mult2_to_1_32 jmxormux (outjmxormux, outjalpcmux, dpack, jmxorsig);

// mux with control (alu result and address connected by jmxorsig) added by Toprak
//mult2_to_1_32 jmxoraddressmux(outjmxoraddress, sum, jmxorxor, jmxorsig);

// mux with control (jmxor, jalpc,(balvsig&status[0]) selecting data to be written)
//mult2_to_1_32 combineddatawritemux(outcombinedmux, out3, adder1out, (jmxorsig|jalpcsig|(balvsig&statusregister[0])));

// load pc
always @(negedge clk)
//pc=out4;
pc=outblezalmux;//temporary
//pc=outjmxormux; //last version!!

// alu, adder and control logic connections

//ALU unit
alu32 alu1(sum,dataa,out2,zout,gout,status);//status added here toprak



//adder which adds PC and 4
adder add1(pc,32'h4,adder1out);

//adder which adds PC+4 and 2 shifted sign-extend result
adder add2(adder1out,sextad,adder2out);

control cont(instruc[31:26],functcode,regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,
aluop1,aluop0,brvsig,blezalsig,jalpcsig,nandisig,balvsig,jmxorsig);

//Sign extend unit
signext sext(instruc[15:0],extad);

// zero extend unit
//zeroext zext(instruc[15:0],zeroextaddr);

// sign extend for nandi instruction
signext sextnandi(instruc[15:0],signextnandi);

//ALU control unit
alucont acont(aluop1,aluop0,instruc[3],instruc[2], instruc[1], instruc[0] ,gout);

//Shift-left 2 unit for sign extend
shift shift2(sextad,extad);

//shift shift2()

shift2jump shift2jump(shiftedjump28,inst25_0);//TODO check bit if 28 bits or not!!!


//AND gate
assign pcsrc=(branch && zout); //|| jalpc; // added by Tolga

assign nandiresult = ~(instruc[25:21] & signextnandi); 

assign shiftedjump32 = {pc[31:28],shiftedjump28};  

// sign extension of 

//nandi gate for instruction tolga added


//initialize datamemory,instruction memory and registers
//read initial data from files given in hex
initial
begin
$readmemh("initDm.dat",datmem); //read Data Memory
$readmemh("initIM.dat",instmem);//read Instruction Memory
$readmemh("initReg.dat",registerfile);//read Register File

	for(i=0; i<31; i=i+1)
	$display("Instruction Memory[%0d]= %h  ",i,instmem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
	"Register[%0d]= %h",i,registerfile[i]);
end

initial
begin
pc=0;
#400 $finish;
	
end
initial
begin
clk=0;
//40 time unit for each cycle
forever #20  clk=~clk;
end
initial 
begin
  $monitor($time,"PC %h",pc,"  SUM %h",sum,"   INST %h",instruc[31:0],
"   REGISTER %h %h %h %h ",registerfile[4],registerfile[5], registerfile[6],registerfile[1] );
end
endmodule