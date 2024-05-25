`timescale 1ns / 1ps

module statusCheck_tb;

  // Declare a processor instance
  reg clk;
  reg reset;
  wire [2:0] statusP;
  
  processor uut (
    .clk(clk),
    .statusP(statusP)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #20 clk = ~clk;  // 40 time units period (20 time units high, 20 time units low)
  end

  // Test procedure
  initial begin
    // Initialize input signals
    reset = 1;
    
    // Wait for a few clock cycles for initialization
    #100;
    reset = 0;
    
    // Run for a certain number of clock cycles
    #400;

    // Finish simulation
    $finish;
  end

  // Monitor important signals
  initial begin
    $monitor($time, " PC: %h, SUM: %h, INST: %h, STATUS: %b", uut.pc, uut.sum, uut.instruc, uut.statusP);
  end

  // Initial memory and register contents
  initial begin
    $readmemh("initDm.dat", uut.datmem); // Read Data Memory
    $readmemh("initIM.dat", uut.mem);    // Read Instruction Memory
    $readmemh("initReg.dat", uut.registerfile); // Read Register File

    for (integer i = 0; i < 32; i = i + 1) begin
      $display("Instruction Memory[%0d] = %h", i, uut.mem[i]);
      $display("Data Memory[%0d] = %h", i, uut.datmem[i]);
      $display("Register[%0d] = %h", i, uut.registerfile[i]);
    end
  end

endmodule
