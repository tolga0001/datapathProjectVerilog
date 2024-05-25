module mytest;

  reg clk;
  reg reset;

  // Instantiate your processor module here. For example:
  processor cpu (); // Ensure that you properly connect the ports if required

  integer i;

  initial begin
    // Initialize the dump file for waveform
    $dumpfile("waveform.vcd"); // Name of the VCD file
    $dumpvars(0, mytest);      // Dump all variables

    // Initialize signals
    clk = 0;
    reset = 1;
    #5 reset = 0;

    // Read initialization files
    $readmemh("initDM.dat", cpu.datmem);         // Read Data Memory
    $readmemh("initIM.dat", cpu.mem);            // Read Instruction Memory
    $readmemh("initReg.dat", cpu.registerfile);  // Read Register File

    // Display initial memory and register contents
    for (i = 0; i < 32; i = i + 1) begin
      $display("Instruction Memory[%0d]= %h  Data Memory[%0d]= %h  Register[%0d]= %h", 
                i, cpu.mem[i], i, cpu.datmem[i], i, cpu.registerfile[i]);
    end

    // Finish simulation after a certain time
    #400 $finish;
  end

  always #5 clk = ~clk;

  always @(posedge clk) begin
    if (!reset) begin
      $display("PC: %h, Instruction: %h", cpu.pc, cpu.instruc);
    end
  end

  initial begin
    #395;
    $display("Final Data Memory and Register File Contents:");
    for (i = 0; i < 32; i = i + 1) begin
      $display("Data Memory[%0d] = %h, Register[%0d] = %h", i, cpu.datmem[i], i, cpu.registerfile[i]);
    end
  end

endmodule
