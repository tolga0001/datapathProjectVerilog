`timescale 1ns / 1ps

module alu32_tb;

    // Parameters
    parameter PERIOD = 10; // Time period for clock (in ns)

    // Inputs
    reg [31:0] a;
    reg [31:0] b;
    reg [2:0] gin;

    // Outputs
    wire [31:0] sum;
    wire zout;
    wire [2:0] status;

    // Instantiate the unit under test (UUT)
    alu32 uut (
        .sum(sum),
        .a(a),
        .b(b),
        .zout(zout),
        .gin(gin),
        .status(status)
    );

    // Clock generation
    reg clk;
    always #((PERIOD / 2)) clk = ~clk;

    // Test stimulus
    initial begin
        $monitor("Time=%0t, a=%h, b=%h, gin=%b, sum=%h, zout=%b, status=%b", $time, a, b, gin, sum, zout, status);
        $dumpfile("alu32_tb.vcd");  // Specify the VCD file name
        $dumpvars(0, alu32_tb);      // Dump variables for the entire hierarchy

        // Test case 1: ADD (ALU control line = 010)
        a = 32'h00000001;
        b = 32'h00000002;
        gin = 3'b010;
        #10;

        // Test case 2: SUB (ALU control line = 110)
        a = 32'h00000003;
        b = 32'h00000002;
        gin = 3'b110;
        #10;

        // Test case 3: SLT (ALU control line = 111)
        a = 32'h00000001;
        b = 32'h00000002;
        gin = 3'b111;
        #10;

        // Test case 4: AND (ALU control line = 000)
        a = 32'hFFFFFFFF;
        b = 32'h0000000F;
        gin = 3'b000;
        #10;

        // Test case 5: OR (ALU control line = 001)
        a = 32'hFFFFFFFF;
        b = 32'h00000000;
        gin = 3'b001;
        #10;

        // Test case 6: Zero Flag (Z)
        a = 32'h00000000;
        b = 32'h00000000;
        gin = 3'b010;
        #10;

        // Test case 7: Negative Flag (N)
        a = 32'hFFFFFFFF;
        b = 32'h00000001;
        gin = 3'b010;
        #10;

        // Test case 8: Overflow Flag (V)
        a = 32'h7FFFFFFF;
        b = 32'h00000001;
        gin = 3'b010;
        #10;

        // Add more test cases as needed
        // ...

        // Terminate simulation
        $finish;
    end

endmodule
