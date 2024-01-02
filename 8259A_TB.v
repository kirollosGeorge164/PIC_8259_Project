module  A8259_TB();
  
  reg   CHIP_SELECT;
  reg   READ;
  reg   WRITE;
  
  reg [7:0] BIDIRECTIONAL_DATA_BUS_INOUT;
  reg [2:0] CASCADE_LINES_INOUT;
  reg SLAVE_PROGRAM_ENABLE_BUFFER_INOUT;
  
  wire  INTERRUPT;
  
  reg   [7:0] INTERRUPT_REQUESTS;
  reg   INTERRUPT_ACKNOWLEDGE;
  reg   AO_ADDRESS_LINE;
  




  initial begin
    CHIP_SELECT = 0;
    
    // ICW1
    AO_ADDRESS_LINE = 0;
    WRITE = 1;
    BIDIRECTIONAL_DATA_BUS_INOUT = 8'b00001011;
    #10
    //ICW2
    AO_ADDRESS_LINE = 1;
    WRITE = 1;
    BIDIRECTIONAL_DATA_BUS_INOUT = 8'b10101000;
    #10
    //ICW4
    AO_ADDRESS_LINE = 1;
    WRITE = 1;
    BIDIRECTIONAL_DATA_BUS_INOUT = 8'b00000011;
    #10
    //OCW1
    AO_ADDRESS_LINE = 1;
    WRITE = 1;
    BIDIRECTIONAL_DATA_BUS_INOUT = 8'b00000000;
    #10
    //OCW2
    AO_ADDRESS_LINE = 0;
    WRITE = 1;
    BIDIRECTIONAL_DATA_BUS_INOUT = 8'b00000000;
    #10
    //OCW3
    AO_ADDRESS_LINE = 0;
    WRITE = 1;
    BIDIRECTIONAL_DATA_BUS_INOUT = 8'b00000000;
    
     /* Int */  
    #10 INTERRUPT_REQUESTS = 8'b00000010;
    #10 INTERRUPT_ACKNOWLEDGE = 0;
    #10 INTERRUPT_ACKNOWLEDGE=1;
    #10 INTERRUPT_ACKNOWLEDGE = 0;
    #10 INTERRUPT_ACKNOWLEDGE=1;
  end

  A8259 pic(

    // A low on this pin enables RD and WR communication between the CPU and the 8259A INTA functions are independent of CS.
    .CHIP_SELECT                           (CHIP_SELECT), 
    
    // A low on this pin when CS is low enables the 8259A to release status onto the data bus
    .READ                                  (READ), 
    
    // A low on this pin when CS is low enables the 8259A to accept command words
    .WRITE                                   (WRITE), 
    
    // Control, status and interrupt-vector information is transferred via this bus.
    .BIDIRECTIONAL_DATA_BUS_INOUT           (BIDIRECTIONAL_DATA_BUS_INOUT), 
    
    /* The CAS lines form a private 8259A bus to control
     a multiple 8259A structure. These pins are outputs for a master 8259A
     and inputs for a slave 8259A. */
    .CASCADE_LINES_INOUT                   (CASCADE_LINES_INOUT), 
    
    /* This is a dual function pin.
    When in the Buffered Mode it can be used as an output to control
    buffer transceivers (EN). When not in the buffered mode it is used as
    an input to designate a master (SP e 1) or slave (SP e 0).*/
    .SLAVE_PROGRAM_ENABLE_BUFFER_INOUT    (SLAVE_PROGRAM_ENABLE_BUFFER_INOUT), 
    
    /* This pin goes high whenever a valid interrupt request is
    asserted. It is used to interrupt the CPU, thus it is connected to the
    CPU's interrupt pin. */
    .INTERRUPT                             (INTERRUPT),
    
    /* Asynchronous inputs. An interrupt request
    is executed by raising an IR input (low to high), and holding it high until
    it is acknowledged (Edge Triggered Mode), or just by a high level on an
    IR input (Level Triggered Mode). */
    .INTERRUPT_REQUESTS                   (INTERRUPT_REQUESTS),
    
    /* This pin is used to enable 8259A
    interrupt-vector data onto the data bus by a sequence of interrupt
    acknowledge pulses issued by the CPU. */
    .INTERRUPT_ACKNOWLEDGE                (INTERRUPT_ACKNOWLEDGE),
    
    /* This pin acts in conjunction with the CS, WR, and
    RD pins. It is used by the 8259A to decipher various Command Words
    the CPU writes and status the CPU wishes to read. It is typically
    connected to the CPU A0 address line (A1 for 8086, 8088). */
    .AO_ADDRESS_LINE                    (AO_ADDRESS_LINE)
    
);
  
  
endmodule
  
  