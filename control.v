module control(in,regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop2,brvsig,blezalsig,jalpcsig,nandisig,balvsig,jmxorsig);
input [5:0] in;
output regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop2,brvsig,blezalsig,jalpcsig,nandisig,balvsig,jmxorsig;// added data path signals to controller here
wire rformat,lw,sw,beq;
assign rformat=~|in;
assign lw=in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];
assign sw=in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];
assign beq=~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);
assign regdest=rformat;
assign alusrc=(lw|sw)&(~brvsig) ;//alusrc is 0 when brvsig is 1
assign memtoreg=lw;
assign regwrite=rformat|lw|blezalsig;//added blezalsig to regwrite
assign memread=lw;
assign memwrite=sw;
assign branch=beq;
assign aluop1=rformat;
assign aluop2=beq;
assign brvsig=//TODO check opcode and funct part for r types!!
assign jmxorsig=//TODO check opcode and funct part for r types!!
assign blezalsig=in[5]&(~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);//100100 is the opcode
assign balvsig=in[5]&(~in[4])&(~in[3])&(~in[2])&(~in[1])&(~in[0]);//100000 is the opcode
assign jalpcsig=(~in[5])&in[4]&in[3]&in[2]&in[1]&in[0];//011111 is the opcode
assign nandisig=(~in[5])&in[4]&(~in[3])&(~in[2])&(~in[1])&(~in[0]);//010000 is the opcode
endmodule
