module control(in,functcode,regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop2,brvsig,blezalsig,jalpcsig,nandisig,balvsig,jmxorsig);
input [5:0] in;
input [5:0] functcode; 
output regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop2,brvsig,blezalsig,jalpcsig,nandisig,balvsig,jmxorsig;// added data path signals to controller here
wire rformat,lw,sw,beq;
assign rformat=~|in;
assign lw=in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];
assign sw=in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];
assign beq=~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);
assign regdest=rformat;
//assign alusrc=(lw|sw)&(~brvsig) ;//alusrc is 0 when brvsig is 1
assign alusrc=(lw|sw)
assign memtoreg=lw;
//assign regwrite=(rformat|lw|blezalsig|jalpcsig|nandisig|balvsig|jmxorsig);//added blezalsig to regwrite
assign regwrite=rformat
assign memread=lw;
assign memwrite=sw;
assign branch=beq;
assign aluop1=rformat; 
assign aluop2=beq;

assign jalpc =~in[5]& (in[4])&(in[3])&(in[2])&in[1]&in[0];  // 011111 jalpc instuction
assign brvsig=(~functcode[5])&(functcode[4])&(~functcode[3])&(functcode[2])&(~functcode[1])&(~functcode[0]); //010100=>20
assign jmxorsig=(functcode[5])&(~functcode[4])&(~functcode[3])&(~functcode[2])&(functcode[1])&(~functcode[0]); //100010=>34
assign blezalsig=in[5]&(~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);//100100 is the opcode
assign balvsig=in[5]&(~in[4])&(~in[3])&(~in[2])&(~in[1])&(~in[0]);//100000 is the opcode
assign jalpcsig=(~in[5])&in[4]&in[3]&in[2]&in[1]&in[0];//011111 is the opcode
assign nandisig=(~in[5])&in[4]&(~in[3])&(~in[2])&(~in[1])&(~in[0]);//010000 is the opcode
endmodule
    