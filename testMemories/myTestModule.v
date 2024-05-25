module myTestModule;
  reg clk;
  reg reset;
  reg [31:0] pc;
  wire [31:0] instruction;
  wire [31:0] status;
  wire [31:0] regfile [0:31];
  wire [31:0] datamem [0:255];
  
  // Instantiate CPU module
  processor uut (
    .clk(clk),
    .reset(reset),
    .pc(pc),
    .instruction(instruction),
    .status(status)
  );
  
  initial begin
    // Initialize clock and reset
    clk = 0;
    reset = 1;
    #5 reset = 0;
    
    // Load initial values into registers, data memory, and instruction memory
    $readmemh("initReg", regfile);
    $readmemh("initDM", datamem);
    $readmemh("initIM", instruction_memory);

    // Set initial PC
    pc = 0;
    
    // Run the simulation
    #1000 $finish;
  end
  
  // Clock generation
  always #5 clk = ~clk;
  
  // Monitor the PC
  always @(posedge clk) begin
    if (!reset) begin
      $display("PC: %h, Instruction: %h, Status: %h", pc, instruction, status);
    end
  end
endmodule
