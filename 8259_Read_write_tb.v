/*******************************************************************/
                        //TEST_BENCH//
/*******************************************************************/

module read_write_block_tb;

    reg chip_select_n;
    reg read_enable_n;
    reg write_enable_n;
    reg [7:0] address;
    reg [7:0] data_bus_in;

    wire [7:0] internal_data_bus;
    wire write_initial_command_word_1;
    wire write_initial_command_word_2_4;
    wire write_operation_control_word_1;
    wire write_operation_control_word_2;
    wire write_operation_control_word_3;
    wire read;

    // Instantiate DUT (Design Under Test)
    read_write_block uut (
        .chip_select_n(chip_select_n),
        .read_enable_n(read_enable_n),
        .write_enable_n(write_enable_n),
        .address(address),
        .data_bus_in(data_bus_in),
        .internal_data_bus(internal_data_bus),
        .write_initial_command_word_1(write_initial_command_word_1),
        .write_initial_command_word_2_4(write_initial_command_word_2_4),
        .write_operation_control_word_1(write_operation_control_word_1),
        .write_operation_control_word_2(write_operation_control_word_2),
        .write_operation_control_word_3(write_operation_control_word_3),
        .read(read)
    );

    // Test stimulus
    initial begin
        // Test scenario 1
        chip_select_n = 1'b0;
        read_enable_n = 1'b1;
        write_enable_n = 1'b0;
        address = 8'b11111111;
        data_bus_in = 8'b01010101;
        #20; // Allow some time for internal signals to stabilize


        
        // Test scenario 2
        chip_select_n = 1'b1;
        read_enable_n = 1'b0;
        write_enable_n = 1'b1;
        address = 8'b10101010;
        data_bus_in = 8'b11110000;
        #20;
        
        /******************************************************/
        chip_select_n = 1'b0;       // Chip select active
        read_enable_n = 1'b1;       // Read disabled
        write_enable_n = 1'b0;      // Write enabled
        address = 8'b10101010;      // Address (assuming this address satisfies the condition)
        data_bus_in = 8'b01010101;  // Data to be written
        #20;
        /********************************************************/
        // Test scenario 3
        chip_select_n = 1'b1;
        read_enable_n = 1'b1;
        write_enable_n = 1'b1;
        address = 8'b00000000;
        data_bus_in = 8'b00000000;
        #20;
        
        // scenario for writing data 
        // Writing data to a specific address
        chip_select_n = 1'b0;       // Chip select active
        read_enable_n = 1'b1;       // Read disabled
        write_enable_n = 1'b0;      // Write enabled
        address = 8'b11001100;      // Address to write data to
        data_bus_in = 8'b10101010;  // Data to be written
        #20;
        
        // Reading data from a specific address
        chip_select_n = 1'b1;       // Chip select active
        read_enable_n = 1'b0;       // Read enabled
        write_enable_n = 1'b1;      // Write disabled
        address = 8'b01010101;      // Address to read data from
        #20;
        
        
        // Idle state scenario
        chip_select_n = 1'b0;       // Chip select inactive (idle state)
        read_enable_n = 1'b1;       // Read disabled
        write_enable_n = 1'b1;      // Write disabled
        address = 8'b00000000;      // Any address (not used in idle state)
        #20;
        
        // Writing data without chip select
        chip_select_n = 1'b1;       // Chip select inactive
        read_enable_n = 1'b1;       // Read disabled
        write_enable_n = 1'b0;      // Write enabled
        address = 8'b11001100;      // Address to write data to
        data_bus_in = 8'b10101010;  // Data to be written
        #20;
        
        // Reading data without chip select
        chip_select_n = 1'b0;       // Chip select inactive
        read_enable_n = 1'b0;       // Read enabled
        write_enable_n = 1'b1;      // Write disabled
        address = 8'b01010101;      // Address to read data from
        #20;
        
        


        // Finish simulation
        #20 $finish;
    end

    // Monitor for internal signals
    initial begin
        $monitor("Time=%0t, Internal Data Bus=%b, Write_ICW_1=%b, Write_ICW_2_4=%b, Write_OCW_1=%b, Write_OCW_2=%b, Write_OCW_3=%b, Read=%b",
                 $time, internal_data_bus, write_initial_command_word_1, write_initial_command_word_2_4,
                 write_operation_control_word_1, write_operation_control_word_2, write_operation_control_word_3, read);
    end

endmodule
