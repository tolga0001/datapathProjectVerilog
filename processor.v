

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
reg [7:0] datmem[0:31],mem[0:31]; //32-size data and instruction memory (8 bit(1 byte) for each location)
reg [2:0] statusregister;
wire [2:0] status;
wire [31:0] 
dataa,	//Read data 1 output of Register File
datab,	//Read data 2 output of Register File
out2,		//Output of mux with ALUSrc control-mult2
out3,		//Output of mux with MemToReg control-mult3
out4,		//Output of mux with (Branch&ALUZero) control-mult4
sum,		//ALU result
extad,	//Output of sign-extend unit
adder1out,	//Output of adder which adds PC and 4-add1
adder2out,	//Output of adder which adds PC+4 and 2 shifted sign-extend result-add2
sextad,	//Output of shift left 2 unit
outblezalmux, // added for test by Tolga time 14.05
outbalvmux, // output of outbalvmux added by Toprak  added for test by Tolga time 16.18
outcombinedmux, // added for test by Tolga time 14.06
shiftedjump32,
outbrvmux,
outjalpcmux,
nandiresult,
zeroextimm,
outnandimux;


wire [27:0]shiftedjump28; //  add two bit to the end of bits from 26 to 28

wire [5:0] inst31_26;	//31-26 bits of instruction
wire [4:0] 
inst25_21,	//25-21 bits of instruction
inst20_16,	//20-16 bits of instruction
inst15_11,	//15-11 bits of instruction
out1,		//Write data input of Register File
outbalvregdst;

wire [15:0] inst15_0;	//15-0 bits of instruction

wire [5:0] functcode;

wire [25:0] inst25_0;

wire [31:0] instruc,	//current instruction
dpack;	//Read data output of memory (data read from memory)

wire [2:0] gout;	//Output of ALU control unit

wire zout,	//Zero output of ALU
pcsrc,	//Output of AND gate with Branch and ZeroOut inputs
blezaland, // blezaland added by tolga for test time=>14.16

 // default r typelarda güncellencek, default ı typelarda güncellencek+nandi,   
//Control signals

regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop0,blezalsig,balvsig,brvsig,jalpcsig,nandisig,status_write_sig;; // added by Tolga for test case time

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
end

always @(posedge clk) begin     
    statusregister =  status_write_sig ? status : statusregister;
end   

//instruction memory
//4-byte instruction
 assign instruc={mem[pc[4:0]],mem[pc[4:0]+1],mem[pc[4:0]+2],mem[pc[4:0]+3]};
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
always @(posedge clk)
 registerfile[outbalvregdst]= regwrite ? outnandimux:registerfile[outbalvregdst];//Write data to register

//read data from memory, sum stores address
assign dpack={datmem[sum[5:0]],datmem[sum[5:0]+1],datmem[sum[5:0]+2],datmem[sum[5:0]+3]};


shift2jump shift2jump(shiftedjump28,inst25_0);//TODO check bit if 28 bits or not!!!

assign shiftedjump32 = {4'b0000,shiftedjump28}; 

zeroext zext(instruc[15:0],zeroextimm);

assign nandiresult = ~(dataa & zeroextimm); 


//multiplexers
//mux with RegDst control
mult2_to_1_5  mult1(out1, instruc[20:16],instruc[15:11],regdest);

//mux with ALUSrc control
mult2_to_1_32 mult2(out2, datab,extad,alusrc);

//mux with MemToReg control
mult2_to_1_32 mult3(out3, sum,dpack,memtoreg);

//mux with (Branch&ALUZero) control

//mult2_to_1_32 mult4(out4, adder1out,adder2out,pcsrc);


// added test for blezal added by tolga time => 14.04
mult2_to_1_32 blezalmux (outblezalmux, adder1out, adder2out, (blezaland|pcsrc));



// pcyi updatelicek veriyi seçiyoruz
mult2_to_1_32 jalpcmux (outjalpcmux, outbrvmux, adder2out, jalpcsig);//changed jalpc to jalpcsig


//registeri updatelicek veri seçiliyor
mult2_to_1_32 combineddatawritemux(outcombinedmux, out3, adder1out, (blezaland | ((statusregister[2]&balvsig)) | (jalpcsig)));

mult2_to_1_32 balvmux (outbalvmux, outblezalmux, shiftedjump32, ((statusregister[0])&balvsig)); // it will be implemented for balv

// mux with control balvsig (for selecting 31. reg as destination) added by Toprak output not yet connected!!
mult2_to_1_5 balvregdst(outbalvregdst, out1, 5'b11111, balvsig);


mult2_to_1_32 brvmux (outbrvmux, outbalvmux, registerfile[inst25_21], (brvsig&statusregister[2]));


// mux with select nandi
mult2_to_1_32 nandimux(outnandimux,outcombinedmux,nandiresult,nandisig); 









// load pc
always @(negedge clk)
#40
pc=outjalpcmux;


// alu, adder and control logic connections

//ALU unit
alu32 alu1(sum,dataa,out2,zout,gout,status);

//adder which adds PC and 4
adder add1(pc,32'h4,adder1out);

//adder which adds PC+4 and 2 shifted sign-extend result
adder add2(adder1out,sextad,adder2out);

//Control unit
control cont(instruc[31:26],functcode,regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,
aluop1,aluop0,blezalsig,balvsig,brvsig,jalpcsig,nandisig,status_write_sig);

//Sign extend unit
signext sext(instruc[15:0],extad);

//ALU control unit
alucont acont(aluop1,aluop0,instruc[4],instruc[3],instruc[2], instruc[1], instruc[0] ,gout);

//Shift-left 2 unit
shift shift2(sextad,extad);

//AND gate  
assign pcsrc=branch && zout; 

// added for test case by Tolga time : 14.10
assign blezaland=blezalsig&((dataa[31]==1 || dataa == 0) ? 1:0); //added blezaland here Toprak 2's complement???



//initialize datamemory,instruction memory and registers
//read initial data from files given in hex
initial
begin
$readmemh("initDm.dat",datmem); //read Data Memory
$readmemh("initIM.dat",mem);//read Instruction Memory
$readmemh("initReg.dat",registerfile);//read Register File

	for(i=0; i<31; i=i+1)
	$display("Instruction Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
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

