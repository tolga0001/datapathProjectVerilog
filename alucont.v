module alucont(aluop1,aluop0,f4,f3,f2,f1,f0,gout);//Figure 4.12 
input aluop1,aluop0,f4,f3,f2,f1,f0;
output [2:0] gout;
reg [2:0] gout;
always @(aluop1 or aluop0 or f4 or f3 or f2 or f1 or f0)
begin
if(~(aluop1|aluop0))  gout=3'b010; //if not r format-->add for load or store 
if(aluop0)gout=3'b110; //
if(aluop1)//R-type
begin
	if (~(f3|f2|f1|f0))gout=3'b010; 	//function code=0000,ALU control=010 (add)
	if ((f3 & f2 & f1 &f0)) //20 => 010100 
	if (f1&f3)gout=3'b111;			//function code last 4 bits=1x1x,ALU control=111 (set on less than)
	if (f1&~(f3))gout=3'b110;		//function code last 4 bits=0x10,ALU control=110 (sub)
	if (f2&f0)gout=3'b001;			//function code last 4 bits=x1x1,ALU control=001 (or)
	if((f4)&(~f3)&(f2)&(~f1)&(~f0))	gout=3'b010; // function code last 5 bits=010100  ALU control=010 (add) (brv adding 0)
	if (f2&~(f0))gout=3'b000;		//function code=01x0,ALU control=000 (and) // 100100
end
end
endmodule
