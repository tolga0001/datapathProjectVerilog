module myTestModule;
  reg clk;
  reg reset;

  processor cpu ();  

  integer i;  

  initial begin
    clk = 0;
    reset = 1;
    #5 reset = 0;

    $readmemh("initDM.dat", cpu.datmem); // Read Data Memory
    $readmemh("initIM.dat", cpu.instmem); // Read Instruction Memory
    $readmemh("initReg.dat", cpu.registerfile); // Read Register File

    for (i = 0; i < 32; i = i + 1) begin
      $display("Instruction Memory[%0d]= %h  Data Memory[%0d]= %h  Register[%0d]= %h", 
                i, cpu.instmem[i], i, cpu.datmem[i], i, cpu.registerfile[i]);
    end

    #400 $finish;
  end

  always #5 clk = ~clk;

  always @(posedge clk) begin
    if (!reset) begin
      $display("PC: %h, Instruction: %h, Status: %h", cpu.pc, cpu.instruc, cpu.statusregister);
    end
  end

  initial begin
    #395;
    $display("Final Data Memory and Register File Contents:");
    for (i = 0; i < 32; i = i + 1) begin
      $display("Data Memory[%0d] = %h", i, cpu.datmem[i], " Register[%0d] = %h", i, cpu.registerfile[i]);
    end
  end

endmodule

