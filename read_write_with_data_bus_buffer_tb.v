module read_write_block_with_DBF_tb;

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
    
    //for data bus buffer
       reg  [7:0] BF_input_data;  
       reg BF_enable;
       reg BF_dir;
       wire  [7:0]  BF_data_bus;
       wire   [7:0] BF_internal_data_bus;

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
    
    
   Buffer Helmy (  
    .input_data(BF_input_data),
    .internal_data_bus(BF_internal_data_bus),
    .data_bus(BF_data_bus),
    .enable(BF_enable)  
  );
  
  always @* begin
    BF_input_data = internal_data_bus;
  end
  
  assign BF_data_bus =BF_dir ? data_bus_in:8'bzzzzzzzz;

    // Test stimulus
    initial begin

      
      
    
    
        // Test scenario 1
        BF_enable = 0; 
        BF_dir =0;        
        chip_select_n = 1'b0;
        read_enable_n = 1'b1;
        write_enable_n = 1'b0;
        address = 8'b00000000;
        data_bus_in = 8'b10101010;
        #10;
        data_bus_in = 8'b11111111;
        #10;
        BF_enable =1;
        #10;
        BF_dir =1;
        #10;
      
        data_bus_in = 8'b11110000;
        #10;

        

        
        


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
