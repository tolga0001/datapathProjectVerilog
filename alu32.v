module alu32(sum,a,b,zout,gin,status);//ALU operation according to the ALU control line values
output [31:0] sum;
input [31:0] a,b; 
input [2:0] gin;//ALU control line
reg [31:0] sum;
reg [31:0] less;
output zout;
reg zout;
output reg [2:0] status; // 210=>nzv
always @(a or b or gin)
begin
status = 3'b000; // Initialize status
	case(gin)
	3'b010: begin // ALU control line = 010, ADD
           sum = a + b;
            if ((a[31] == b[31]) && (sum[31] != a[31])) // Overflow check
                status[0] = 1'b1;
      end

	3'b110: begin // ALU control line = 110, SUB
            sum=a+1+(~b);
            if ((a[31] != b[31]) && (sum[31] != a[31])) // Overflow check
                status[0] = 1'b1;
      end
	3'b111: begin // ALU control line = 111, SLT
           less=a+1+(~b);
            if (less[31])
                sum = 32'b1;
            if ((a[31] != b[31]) && (less[31] != a[31])) // Overflow check
                status[0] = 1'b1;
      end
	3'b000: sum=a & b;	//ALU control line=000, AND
	3'b001: sum=a|b;		//ALU control line=001, OR
	default: sum=31'bx;	
	endcase
zout=~(|sum);
status[1]=zout; // zero flag
status[2]=sum[31];      // negative flag
end
endmodule