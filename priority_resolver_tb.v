module tb_Priority_Resolver;

    reg [7:0] IRR;
    wire [2:0] chosen_interrupt;

    // Instantiate the Priority_Resolver module
    Priority_Resolver uut (
        .IRR(IRR),
        .chosen_interrupt(chosen_interrupt)
    );

    // Initial stimulus
    initial begin
        // Initialize inputs
        IRR = 8'b00000000;
        

        // Test Case 1: Automatic Rotation Mode
        
        #10 $display("Test Case 1: Automatic Rotation Mode");
        #10 IRR = 8'b01100000; // Set interrupt 5,6
        #10 IRR = 8'b00000010; // Set interrupt 1
        #10 IRR = 8'b00000000; // Clear interrupts
        

        // Test Case 2: Fully Nested Mode
        #10 $display("Test Case 2: Fully Nested Mode");
        #10 IRR = 8'b00010000; // Set interrupt 4
        #10 IRR = 8'b00001000; // Set interrupt 3
        #10 IRR = 8'b00000100; // Set interrupt 2
        #10 IRR = 8'b00000001; // Set interrupt 0
        #10 IRR = 8'b00000000; // Clear interrupts
        

        // Test Case 3: No Interrupt
        #10 $display("Test Case 3: No Interrupt");
        

        // Wait for simulation to finish
        #100 $finish;
    end

endmodule