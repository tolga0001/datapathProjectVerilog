module shift2jump(shout,shin);
input [25:0]shin;
output [27:0]shout;

assign shout = {shin, 2'b00}; // Concatenate 2'b00 to the right of shin

endmodule
 
