
module A8259 (

    input              SUPPLY, // +5V Supply.
    input              GROUND,
    
    // A low on this pin enables RD and WR communication between the CPU and the 8259A INTA functions are independent of CS.
    input              CHIP_SELECT, 
    
    // A low on this pin when CS is low enables the 8259A to release status onto the data bus
    input              READ, 
    
    // A low on this pin when CS is low enables the 8259A to accept command words
    input              WRITE, 
    
    // Control, status and interrupt-vector information is transferred via this bus.
    inout      [7:0]   BIDIREBIDIRECTIONAL_DATA_BUS_INOUT,CTIONAL_DATA_BUS_INOUT, 
    
    /* The CAS lines form a private 8259A bus to control
     a multiple 8259A structure. These pins are outputs for a master 8259A
     and inputs for a slave 8259A. */
    inout      [2:0]   CASCADE_LINES_INOUT, 
    
    /* This is a dual function pin.
    When in the Buffered Mode it can be used as an output to control
    buffer transceivers (EN). When not in the buffered mode it is used as
    an input to designate a master (SP e 1) or slave (SP e 0).*/
    inout              SLAVE_PROGRAM_ENABLE_BUFFER_INOUT, 
    
    /* This pin goes high whenever a valid interrupt request is
    asserted. It is used to interrupt the CPU, thus it is connected to the
    CPU's interrupt pin. */
    output             INTERRUPT,
    
    /* Asynchronous inputs. An interrupt request
    is executed by raising an IR input (low to high), and holding it high until
    it is acknowledged (Edge Triggered Mode), or just by a high level on an
    IR input (Level Triggered Mode). */
    input      [7:0]   INTERRUPT_REQUESTS,
    
    /* This pin is used to enable 8259A
    interrupt-vector data onto the data bus by a sequence of interrupt
    acknowledge pulses issued by the CPU. */
    input              INTERRUPT_ACKNOWLEDGE,
    
    /* This pin acts in conjunction with the CS, WR, and
    RD pins. It is used by the 8259A to decipher various Command Words
    the CPU writes and status the CPU wishes to read. It is typically
    connected to the CPU A0 address line (A1 for 8086, 8088). */
    input              AO_ADDRESS_LINE
    
);

wire [7:0] BF_internal_data_bus;

wire       write_initial_command_word_1;
wire       write_initial_command_word_2_4;
wire       write_operation_control_word_1;
wire       write_operation_control_word_2;
wire       write_operation_control_word_3;

wire        cascade_in;
wire  [2:0] SLAVE_ID;
wire  [2:0] CASCADE_IO;

wire        read;

wire  [7:0] irr;

wire        EDGE_OR_LEVEL;

wire        HIGHEST_ISR;

wire        INT_MASK;


wire  [7:0] CTRL_LOGIC_DATA;
wire        OUT_CTRL_LOGIC_DATA;

wire  [2:0] chosen_interrupt;

wire  [7:0] EOI;
wire  [7:0] CLR_IR;

 function  [7:0] num2bit (input [2:0] source);
        case (source)
            3'b000:  num2bit = 8'b00000001;
            3'b001:  num2bit = 8'b00000010;
            3'b010:  num2bit = 8'b00000100;
            3'b011:  num2bit = 8'b00001000;
            3'b100:  num2bit = 8'b00010000;
            3'b101:  num2bit = 8'b00100000;
            3'b110:  num2bit = 8'b01000000;
            3'b111:  num2bit = 8'b10000000;
            default: num2bit = 8'b00000000;
        endcase
    endfunction
    
    
    /**********************************************************/
    /*                read_write_block                        */
    /**********************************************************/
 
read_write_block read_write_block (

        // Inputs
        .chip_select_n                      (CHIP_SELECT),
        .read_enable_n                      (READ),
        .write_enable_n                     (WRITE),
        .address                            (AO_ADDRESS_LINE),
        .data_bus_in                        (data_bus_in),

        // Outputs
        .internal_data_bus                  (BF_internal_data_bus),
        .write_initial_command_word_1       (write_initial_command_word_1),
        .write_initial_command_word_2_4     (write_initial_command_word_2_4),
        .write_operation_control_word_1     (write_operation_control_word_1),
        .write_operation_control_word_2     (write_operation_control_word_2),
        .write_operation_control_word_3     (write_operation_control_word_3),
        .read                               (read)
);


Buffer Bus_buffer (  
    .input_data(CTRL_LOGIC_DATA),
    .internal_data_bus(BF_internal_data_bus),
    .data_bus(BIDIRECTIONAL_DATA_BUS_INOUT),
    .enable(OUT_CTRL_LOGIC_DATA)  
  );
  
    /**********************************************************/
    /*                      PIC_controlLogic                  */
    /**********************************************************/
    
PIC_controlLogic PIC_controlLogic (

        // Inputs from R/W logic
        .internal_data_bus                  (BF_internal_data_bus),
        .write_ICW_1                        (write_initial_command_word_1),
        .write_ICW_2_4                      (write_initial_command_word_2_4),
        .write_OCW_1                        (write_operation_control_word_1),
        .write_OCW_2                        (write_operation_control_word_2),
        .write_OCW_3                        (write_operation_control_word_3),
        .read                               (read),

        // Inputs from cascade
        .cascade_in                         (cascade_in),
        .SLAVE_ID                           (SLAVE_ID),
        .CASCADE_IO                         (CASCADE_IO),

        // INPUTS FROM DETECTION LOGIC
        .INTERRUPT                          (num2bit(chosen_interrupt)),

        // INPUTS FROM PROCESSOR
        .ACK                                (INTERRUPT_ACKNOWLEDGE),

        // Output from ICW1
        .EDGE_OR_LEVEL                      (EDGE_OR_LEVEL),

        //OUTPUT OF OCW
        .INT_MASK                           (INT_MASK),
        
        // Output from Interrupt part
        .EOI                                (EOI),
        .CLR_IR                             (CLR_IR),
        
                
        // OUT FOR INTERNAL BUS
        .OUT_CTRL_LOGIC_DATA                (OUT_CTRL_LOGIC_DATA),
        .CTRL_LOGIC_DATA                    (CTRL_LOGIC_DATA),
        
        // OUTPUT FOR READ SIGNALL
        //.EN_READ_REG                        (EN_READ_REG),
        //.READ_REG_ISR_OR_IRR                (READ_REG_ISR_OR_IRR),
        
        // OUTPUT FROM CONTROL LOGIC
        .INT                                (INTERRUPT)
    );
    
   cascade_block cascade_block(
       .CAS   (CASCADE_LINES_INOUT),
       .SLAVE_ID  (SLAVE_ID),
       .cascade_in  (cascade_in),
       .CASCADE_IO (CASCADE_IO)
);

    /**********************************************************/
    /*                         IRR                            */
    /**********************************************************/
    
IRR IRR (

        // Inputs from control logic
        .Level_Edge_flag                    (EDGE_OR_LEVEL),
        .Mask                               (INT_MASK),


        //  inputs
        .I_0                                 (INTERRUPT_REQUESTS[0]),
        .I_1                                 (INTERRUPT_REQUESTS[1]),
        .I_2                                 (INTERRUPT_REQUESTS[2]),
        .I_3                                 (INTERRUPT_REQUESTS[3]),
        .I_4                                 (INTERRUPT_REQUESTS[4]),
        .I_5                                 (INTERRUPT_REQUESTS[5]),
        .I_6                                 (INTERRUPT_REQUESTS[6]),
        .I_7                                 (INTERRUPT_REQUESTS[7]),
        
        // Outputs
        .IRR                                 (irr)
    );
    

    /**********************************************************/
    /*                Priority_Resolver                       */
    /**********************************************************/

Priority_Resolver Priority_Resolver (

        // Inputs
        .IRR                                 (irr),

        // Outputs
        .chosen_interrupt                    (chosen_interrupt)
        
 );
 


    
endmodule