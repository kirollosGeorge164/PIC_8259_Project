module Priority_Resolver (
    input [7:0] IRR,             // from IRR
    output reg [2:0] chosen_interrupt // to ISR
);

    reg [2:0] priority_status [0:7];  // Array for priority status
    reg [2:0] chosen ;
    reg [2:0] iterator0 ;
    reg [2:0] iterator1 ;
    reg [2:0] iterator2 ;
    reg [2:0] iterator3 ;
    reg [2:0] iterator4 ;
    reg [2:0] iterator5 ;
    reg [2:0] iterator6 ;
    reg [2:0] iterator7 ;

    always @* begin
        // Initialize priority status
        priority_status[0] = 0;
        priority_status[1] = 1;
        priority_status[2] = 2;
        priority_status[3] = 3;
        priority_status[4] = 4;
        priority_status[5] = 5;
        priority_status[6] = 6;
        priority_status[7] = 7;

        // Automatic Rotation mode
        // highest priority
        iterator0 = (priority_status[0] == 0) ? 0 :
                     (priority_status[1] == 0) ? 1 :
                     (priority_status[2] == 0) ? 2 :
                     (priority_status[3] == 0) ? 3 :
                     (priority_status[4] == 0) ? 4 :
                     (priority_status[5] == 0) ? 5 :
                     (priority_status[6] == 0) ? 6 : 7;
        // 2nd
        iterator1 = (priority_status[0] == 1) ? 0 :
                     (priority_status[1] == 1) ? 1 :
                     (priority_status[2] == 1) ? 2 :
                     (priority_status[3] == 1) ? 3 :
                     (priority_status[4] == 1) ? 4 :
                     (priority_status[5] == 1) ? 5 :
                     (priority_status[6] == 1) ? 6 : 7;
        // 3rd
        iterator2 = (priority_status[0] == 2) ? 0 :
                     (priority_status[1] == 2) ? 1 :
                     (priority_status[2] == 2) ? 2 :
                     (priority_status[3] == 2) ? 3 :
                     (priority_status[4] == 2) ? 4 :
                     (priority_status[5] == 2) ? 5 :
                     (priority_status[6] == 2) ? 6 : 7;
        // 4th
        iterator3 = (priority_status[0] == 3) ? 0 :
                     (priority_status[1] == 3) ? 1 :
                     (priority_status[2] == 3) ? 2 :
                     (priority_status[3] == 3) ? 3 :
                     (priority_status[4] == 3) ? 4 :
                     (priority_status[5] == 3) ? 5 :
                     (priority_status[6] == 3) ? 6 : 7;
        // 5th
        iterator4 = (priority_status[0] == 4) ? 0 :
                     (priority_status[1] == 4) ? 1 :
                     (priority_status[2] == 4) ? 2 :
                     (priority_status[3] == 4) ? 3 :
                     (priority_status[4] == 4) ? 4 :
                     (priority_status[5] == 4) ? 5 :
                     (priority_status[6] == 4) ? 6 : 7;
        // 6th
        iterator5 = (priority_status[0] == 5) ? 0 :
                     (priority_status[1] == 5) ? 1 :
                     (priority_status[2] == 5) ? 2 :
                     (priority_status[3] == 5) ? 3 :
                     (priority_status[4] == 5) ? 4 :
                     (priority_status[5] == 5) ? 5 :
                     (priority_status[6] == 5) ? 6 : 7;
        // 7th
        iterator6 = (priority_status[0] == 6) ? 0 :
                     (priority_status[1] == 6) ? 1 :
                     (priority_status[2] == 6) ? 2 :
                     (priority_status[3] == 6) ? 3 :
                     (priority_status[4] == 6) ? 4 :
                     (priority_status[5] == 6) ? 5 :
                     (priority_status[6] == 6) ? 6 : 7;
        // least priority
        iterator7 = (priority_status[0] == 7) ? 0 :
                     (priority_status[1] == 7) ? 1 :
                     (priority_status[2] == 7) ? 2 :
                     (priority_status[3] == 7) ? 3 :
                     (priority_status[4] == 7) ? 4 :
                     (priority_status[5] == 7) ? 5 :
                     (priority_status[6] == 7) ? 6 : 7;

        if (IRR[iterator0] == 1'b1) begin
            chosen_interrupt  = 0; 
            chosen = iterator0;
        end else if (IRR[iterator1] == 1'b1) begin
            chosen_interrupt = 1; 
            chosen = iterator1;
        end else if (IRR[iterator2] == 1'b1) begin
            chosen_interrupt  = 2; 
            chosen = iterator2;
        end else if (IRR[iterator3] == 1'b1) begin
            chosen_interrupt = 3; 
            chosen = iterator3;
        end else if (IRR[iterator4] == 1'b1) begin
            chosen_interrupt = 4; 
            chosen = iterator4;
        end else if (IRR[iterator5] == 1'b1) begin
            chosen_interrupt = 5; 
            chosen = iterator5;
        end else if (IRR[iterator6] == 1'b1) begin
            chosen_interrupt = 6; 
            chosen = iterator6;
        end else if (IRR[iterator7] == 1'b1) begin
            chosen_interrupt = 7;
            chosen = iterator7; 
        end

        // rotation
        priority_status[chosen] = 7;
        chosen = (chosen) > 0 ? (chosen - 1) : 7;
        priority_status[chosen] = 6;
        chosen = (chosen) > 0 ? (chosen - 1) : 7;
        priority_status[chosen] = 5;
        chosen = (chosen) > 0 ? (chosen - 1) : 7;
        priority_status[chosen] = 4;
        chosen = (chosen) > 0 ? (chosen - 1) : 7;
        priority_status[chosen] = 3;
        chosen = (chosen) > 0 ? (chosen - 1) : 7;
        priority_status[chosen] = 2;
        chosen = (chosen) > 0 ? (chosen - 1) : 7;
        priority_status[chosen] = 1;
        chosen = (chosen) > 0 ? (chosen - 1) : 7;
        priority_status[chosen] = 0;
     
        // fully nested mode
        if (IRR[0] == 1'b1) begin
            chosen_interrupt = 0;
        end else if (IRR[1] == 1'b1) begin
            chosen_interrupt = 1;
        end else if (IRR[2] == 1'b1) begin
            chosen_interrupt = 2;
        end else if (IRR[3] == 1'b1) begin
            chosen_interrupt = 3;
        end else if (IRR[4] == 1'b1) begin
            chosen_interrupt = 4;
        end else if (IRR[5] == 1'b1) begin
            chosen_interrupt = 5;
        end else if (IRR[6] == 1'b1) begin
            chosen_interrupt = 6;
        end else if (IRR[7] == 1'b1) begin
            chosen_interrupt = 7;
        end else begin 
            // default no interrupt
        end
    end

    
endmodule