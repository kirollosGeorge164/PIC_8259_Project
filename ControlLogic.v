module PIC_controlLogic(
    // Inputs from R/W logic
    input  [7:0] internal_data_bus,
    input   write_ICW_1   ,
    input   write_ICW_2_4 ,
    input   write_OCW_1   ,
    input   write_OCW_2   ,
    input   write_OCW_3   ,
    input   read          ,
    
    output [2:0] InitState , /* Testing */
    
    // Inputs from cascade
    input   [2:0] cascade_in    ,
    output reg [2:0] SLAVE_ID   ,
    output  CASCADE_IO          ,
    
    // INPUTS FROM DETECTION LOGIC
    input   [7:0]   INTERRUPT   ,
    input   [7:0]   HIGHEST_ISR ,
    
    // INPUTS FROM PROCESSOR
    input ACK ,
    
    // Output from ICW1
    output  EDGE_OR_LEVEL ,          
    // Output from ICW4
    output  FULLY_NESTED_MODE , 
    
    //OUTPUT OF OCW
    output reg [7:0]INT_MASK,  
    
    // Output from Interrupt part
    output  LATCH_IN_SERVICE,
    output  FREEZE ,

    output reg [7:0]   EOI             , 
    output reg [2:0]   PRIORITY_ROTATE ,
    output     [7:0]   CLR_IR          ,

    // OUT FOR INTERNAL BUS
    output  reg OUT_CTRL_LOGIC_DATA     ,
    output  reg [7:0] CTRL_LOGIC_DATA   ,
    
    // OUTPUT FOR READ SIGNALL
    output  reg           EN_READ_REG,
    output  reg           READ_REG_ISR_OR_IRR,

        
    // OUTPUT FROM CONTROL LOGIC
    output  reg INT 

);
/**************************** USED FUNCTIONS *******************************/
function  [2:0] bit2num (input [7:0] source);
        if      (source[0] == 1'b1) bit2num = 3'b000;
        else if (source[1] == 1'b1) bit2num = 3'b001;
        else if (source[2] == 1'b1) bit2num = 3'b010;
        else if (source[3] == 1'b1) bit2num = 3'b011;
        else if (source[4] == 1'b1) bit2num = 3'b100;
        else if (source[5] == 1'b1) bit2num = 3'b101;
        else if (source[6] == 1'b1) bit2num = 3'b110;
        else if (source[7] == 1'b1) bit2num = 3'b111;
        else                        bit2num = 3'b111;
endfunction


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
/**************************** Variables Definition *************************/
// Init Block --> ICW
parameter CMD_READY  = 0 ;
parameter WRITE_ICW1 = 1 ; 
parameter WRITE_ICW2 = 2 ;
parameter WRITE_ICW3 = 3 ;
parameter WRITE_ICW4 = 4 ;
reg [2:0] command_state  ;
reg [2:0] next_command_state ; 

// 01- ICW1 Reg bits 
reg ICW1_B0_SET_ICW4;
reg ICW1_B1_SINGLE_OR_CASCADE;
reg ICW1_B2_CALL_ADDRESS_INTERVAL;
reg ICW1_B3_LEVEL_OR_EDGE;
// 02- ICW2 Reg bits (FOR 8086) 
reg[4:0] ICW2_B3_7_VECTOR_ADDRES;
// 03- ICW3 Reg bits
reg[7:0] ICW3_CASCADE_CONFIG ;
// 04- ICW4 Reg bits
reg ICW4_B4_SPECIALLY_FULLY_NEST_CONFIG ;
reg ICW4_B1_AUTO_END_INTERRUPT;
reg ICW4_B0_PROCESSOR_MODE;



    assign    write_ICW_2 = (command_state == WRITE_ICW2) & write_ICW_2_4;
    assign    write_ICW_3 = (command_state == WRITE_ICW3) & write_ICW_2_4;
    assign    write_ICW_4 = (command_state == WRITE_ICW4) & write_ICW_2_4;
    assign    write_OCW_1_FLAG = (command_state == CMD_READY) & write_OCW_1;
    assign    write_OCW_2_FLAG = (command_state == CMD_READY) & write_OCW_2;
    assign    write_OCW_3_FLAG = (command_state == CMD_READY) & write_OCW_3;

// ICW Registers

// ICW 1
/********************* ICW1_B0_SET_ICW4 ************************/
    always @(posedge write_ICW_1) begin
        if (write_ICW_1 == 1'b1)
            ICW1_B0_SET_ICW4 <= internal_data_bus[0];
        else
            ICW1_B0_SET_ICW4 <= ICW1_B0_SET_ICW4;
    end
/***************** ICW1_B1_SINGLE_OR_CASCADE *******************/
    always@(posedge write_ICW_1) begin
         if (write_ICW_1 == 1'b1)
            ICW1_B1_SINGLE_OR_CASCADE <= internal_data_bus[1];
        else
            ICW1_B1_SINGLE_OR_CASCADE <= ICW1_B1_SINGLE_OR_CASCADE;
    end
    
/************** ICW1_B2_CALL_ADDRESS_INTERVAL ******************/
    always@(posedge write_ICW_1) begin
        if (write_ICW_1 == 1'b1)
            ICW1_B2_CALL_ADDRESS_INTERVAL <= internal_data_bus[2];
        else
            ICW1_B2_CALL_ADDRESS_INTERVAL <= ICW1_B2_CALL_ADDRESS_INTERVAL;
    end
/************** ICW1_B3_LEVEL_OR_EDGE **************************/
    always@(posedge write_ICW_1) begin
        if (write_ICW_1 == 1'b1)
            ICW1_B3_LEVEL_OR_EDGE <= internal_data_bus[3];
        else
            ICW1_B3_LEVEL_OR_EDGE <= ICW1_B3_LEVEL_OR_EDGE;
    end

// 02- ICW2
/************** ICW2_B3_7_VECTOR_ADDRES  ***********************/
  // T7-T3 (8086, 8088)
    always@(posedge write_ICW_2,posedge write_ICW_1) begin
        if (write_ICW_2 == 1'b1)
            ICW2_B3_7_VECTOR_ADDRES[4:0] <= internal_data_bus[7:3];
        else
            ICW2_B3_7_VECTOR_ADDRES[4:0] <= internal_data_bus[7:3];
    end
/***************************************************************/  
 
// ICW3
// S7-S0 (MASTER) or ID2-ID0 (SLAVE)
/************* ICW3_CASCADE_CONFIG *****************************/
    always@(posedge write_ICW_3,posedge write_ICW_1) begin
         if (write_ICW_1 == 1'b1)
            ICW3_CASCADE_CONFIG <= 8'b00000000;
        else if (write_ICW_3 == 1'b1)
            ICW3_CASCADE_CONFIG <= internal_data_bus;
        else
            ICW3_CASCADE_CONFIG <= ICW3_CASCADE_CONFIG;
    end
/***************************************************************/

// ICW4
/*********** ICW4_B4_SPECIALLY_FULLY_NEST_CONFIG ***************/
    always@(posedge write_ICW_4,posedge write_ICW_1) begin
        if (write_ICW_1 == 1'b1)
            ICW4_B4_SPECIALLY_FULLY_NEST_CONFIG <= 1'b0;
        else if (write_ICW_4 == 1'b1)
            ICW4_B4_SPECIALLY_FULLY_NEST_CONFIG <= internal_data_bus[4];
        else
            ICW4_B4_SPECIALLY_FULLY_NEST_CONFIG <= ICW4_B4_SPECIALLY_FULLY_NEST_CONFIG;
    end

/*********** ICW4_B1_AUTO_END_INTERRUPT ***********************/
    always@(posedge write_ICW_4,posedge write_ICW_1) begin
        if (write_ICW_1 == 1'b1)
            ICW4_B1_AUTO_END_INTERRUPT <= 1'b0;
        else if (write_ICW_4 == 1'b1)
            ICW4_B1_AUTO_END_INTERRUPT <= internal_data_bus[1];
        else
            ICW4_B1_AUTO_END_INTERRUPT <= ICW4_B1_AUTO_END_INTERRUPT;
    end
/*********** ICW4_B0_PROCESSOR_MODE ***************************/
    always@(posedge write_ICW_4 ,posedge write_ICW_1) begin
        if (write_ICW_1 == 1'b1)
            ICW4_B0_PROCESSOR_MODE <= 1'b0;
        else if (write_ICW_4 == 1'b1)
            ICW4_B0_PROCESSOR_MODE <= internal_data_bus[0];
        else
            ICW4_B0_PROCESSOR_MODE <= ICW4_B0_PROCESSOR_MODE;
    end   
    
    
    
    
    
    
/********************** Block ************************/ 
always@(next_command_state) begin
          command_state <= next_command_state;
end
always@(posedge write_ICW_2_4,posedge write_ICW_1)begin
    if(write_ICW_1==1)
      next_command_state <= WRITE_ICW2 ;
    else if (write_ICW_2_4 == 1'b1) begin
          case(command_state)
              WRITE_ICW2: begin
                if (ICW1_B1_SINGLE_OR_CASCADE == 1'b0)begin
                    next_command_state <= WRITE_ICW3;
                  end
                else if (ICW1_B0_SET_ICW4 == 1'b1)begin
                    next_command_state <= WRITE_ICW4;
                    $monitor("next_command_state = %d", next_command_state);
                  end
                else
                    next_command_state <= CMD_READY;
                end
              WRITE_ICW3: begin
                if (ICW1_B0_SET_ICW4 == 1'b1)
                    next_command_state <= WRITE_ICW4;
                else
                    next_command_state <= CMD_READY;
                end
              WRITE_ICW4: begin
                    next_command_state <= CMD_READY;
                end
              default: begin
                    next_command_state <= CMD_READY;
              end
           endcase
    end
    else
          next_command_state <= CMD_READY;
end
    /********************** END Block ************************/
    
     
    
    
    
    
    
 /********************* INTERRUPT PART *******************/
    reg   PREV_ACK_n;

    always@(ACK,posedge write_ICW_1) begin
        if (write_ICW_1==1)
            PREV_ACK_n <= 1'b1;
        else
            PREV_ACK_n <= ACK;
    end

    
    reg    NEG_EDGE_ACK; 
    always@(ACK)begin
        NEG_EDGE_ACK =  PREV_ACK_n & ~ACK;
    end
    
    reg    POS_EDGE_ACK;
    always@(ACK)begin
        POS_EDGE_ACK =  ~PREV_ACK_n & ACK;
    end
    
    
    parameter CTL_READY = 0 ;
    parameter ACK1 = 1 ; 
    parameter ACK2 = 2 ;
    parameter X = 3;
    
    reg [2:0]NEXT_CTL_STATE;
    reg [2:0]CTL_STATE;
    
    // State machine
    always@(CTL_STATE) begin
        case (CTL_STATE)
            CTL_READY: begin
                    NEXT_CTL_STATE <= ACK1;
            end
            ACK1: begin
                    NEXT_CTL_STATE <= ACK2;
            end
            ACK2: begin
                    NEXT_CTL_STATE = CTL_READY;
            end
            default: begin
                    NEXT_CTL_STATE <= NEXT_CTL_STATE;
            end
        endcase
    end
    
    always@(negedge ACK , posedge write_ICW_1) begin
        if (write_ICW_1 == 1'b1)begin
            CTL_STATE <= CTL_READY;
            NEXT_CTL_STATE <= ACK1;
          end
        else
            CTL_STATE <= NEXT_CTL_STATE;
    end
    /******************************* CASCADE ***********************************/    
    reg CASCADE_MODE ;
    always@(*) begin
        if (ICW1_B1_SINGLE_OR_CASCADE == 1'b1)
            CASCADE_MODE = 1'b0;
        else
            CASCADE_MODE = 1'b1;
    end
    
    
    // SLAVE
    reg SLAVE_MATCH ;
    always@(cascade_in)begin
        if (ICW3_CASCADE_CONFIG[2:0] == cascade_in)
            SLAVE_MATCH = 1'b1;
    end  
    
   
    
    
    
    // MASTER  
    reg CASCADE_OUT_ACK2;
    
    
    reg [7:0] INT_FROM_DEVICE;
    
    always@(posedge write_ICW_1,INTERRUPT)begin
      if(write_ICW_1==1)
          INT_FROM_DEVICE = 0;
      else if(CASCADE_MODE)
          INT_FROM_DEVICE = INTERRUPT;
      else
          INT_FROM_DEVICE = INT_FROM_DEVICE;
    end
    
    reg INT_FROM_SLAVE ;
    
    always@(INT_FROM_DEVICE,posedge write_ICW_1)begin
        if(write_ICW_1)
             INT_FROM_SLAVE = 0;
        else
          INT_FROM_SLAVE =(INT_FROM_DEVICE & ICW3_CASCADE_CONFIG) != 8'b00000000;
    end
    
    always@(posedge write_ICW_1,posedge SLAVE_MATCH) begin
        if(write_ICW_1==1)
            CASCADE_OUT_ACK2 = 1'b0;
        else if (SLAVE_MATCH == 1'b1)
            CASCADE_OUT_ACK2 = 1'b1;
        else if ((CASCADE_MODE == 1'b0) && (INT_FROM_SLAVE == 1'b0))
            CASCADE_OUT_ACK2 = 1'b0;
        else
            CASCADE_OUT_ACK2 = 1'b0;
    end
    
    // Output slave id
    
    always@(CTL_STATE) begin
      
        if(CTL_STATE==ACK2)
            SLAVE_ID <= bit2num(INT_FROM_DEVICE);
    end
    
  
    
    
   
   /******************************** INTERRUPT CONTROL ***************************/
    // Interrupt control signals
    
    // End of acknowledge sequence
    reg    EOI_SEQUENCE ;    
    always@(CTL_STATE,NEXT_CTL_STATE)begin
       EOI_SEQUENCE =  ((CTL_STATE != CTL_READY) & (NEXT_CTL_STATE == CTL_READY));

    end
        
    reg [2:0] IR;
    // INT
    reg INT_TO_CPU;
    always@(posedge write_ICW_1,INTERRUPT,posedge EOI_SEQUENCE) begin
        if (write_ICW_1 == 1'b1)begin
            INT <= 1'b0;
            EOI_SEQUENCE = 0 ;  
          end
        else if (EOI_SEQUENCE == 1'b1)
            INT<= 1'b0;
        else if (INTERRUPT != 8'b00000000)begin
            INT <= 1'b1;
            IR = bit2num (INTERRUPT);
            
          end
        else
            INT <= INT;
    end
    
    // control_logic_data
    always@(CTL_STATE)begin
        if (ACK == 1'b0) begin
            // Acknowledge
            case (CTL_STATE)
                CTL_READY: begin
                    if (CASCADE_MODE == 1'b0) begin
                            OUT_CTRL_LOGIC_DATA = 1'b0;
                            CTRL_LOGIC_DATA     = 8'b00000000;
                        end
                    else begin
                        OUT_CTRL_LOGIC_DATA = 1'b0;
                        CTRL_LOGIC_DATA     = 8'b00000000;
                    end
                end
                ACK1: begin
                        OUT_CTRL_LOGIC_DATA = 1'b0;
                        CTRL_LOGIC_DATA     = 8'b00000000;
                end
                ACK2: begin
                     
                        
                    
                        OUT_CTRL_LOGIC_DATA = 1'b1;
                        CTRL_LOGIC_DATA     = ICW2_B3_7_VECTOR_ADDRES[4:0]+IR;
    
                    
                end
                
                default: begin
                    OUT_CTRL_LOGIC_DATA = 1'b0;
                    CTRL_LOGIC_DATA     = 8'b00000000;
                end
            endcase
        end
        else begin
            // Nothing
            OUT_CTRL_LOGIC_DATA = 1'b0;
            CTRL_LOGIC_DATA     = 8'b00000000;
        end
    end
    
     always@(posedge SLAVE_MATCH)begin
        OUT_CTRL_LOGIC_DATA = 1'b1;
        CTRL_LOGIC_DATA     = ICW2_B3_7_VECTOR_ADDRES[4:0]+IR;

    end  
    /********************************* LATCH *************************************/
    reg LATCH ;

    always@(*)begin
        if (write_ICW_1 == 1'b1)
            LATCH = 1'b0;
        else if ((CTL_STATE == CTL_READY))
            LATCH = 1'b1;
        else if (CASCADE_MODE == 1'b0)
            LATCH = (CTL_STATE == CTL_READY) & (NEXT_CTL_STATE != CTL_READY);
        else
            LATCH = (CTL_STATE == ACK2) & (SLAVE_MATCH == 1'b1) & (NEG_EDGE_ACK == 1'b1);
    end
    
    
     // freeze
    reg INTERNAL_FREEZE;
    always@(*) begin
        if (NEXT_CTL_STATE == CTL_READY)
            INTERNAL_FREEZE <= 1'b0;
        else
            INTERNAL_FREEZE <= 1'b1;
    end

    // clear_interrupt_request
    reg [7:0] INTERNAL_CLR_IR ;
    always@(*)begin
        if (write_ICW_1 == 1'b1)
            INTERNAL_CLR_IR = 8'b11111111;
        else if (LATCH == 1'b0)
            INTERNAL_CLR_IR = 8'b00000000;
        else
            INTERNAL_CLR_IR = INTERRUPT;
    end

    // interrupt buffer
    /*always @(*) begin
        if (write_ICW_1 == 1'b1)
            INT_FROM_DEVICE <= 8'b00000000;
        else if (EOI_SEQUENCE)
            INT_FROM_DEVICE <= 8'b00000000;
        else if (LATCH == 1'b1)
            INT_FROM_DEVICE <= INTERRUPT;
        else
            INT_FROM_DEVICE <= INT_FROM_DEVICE;
    end*/

    // interrupt buffer
    reg   [7:0]   INT_WHEN_ACK1;

    always@(*) begin
        if (write_ICW_1 == 1'b1)
            INT_WHEN_ACK1 <= 8'b00000000;
        else if (CTL_STATE == ACK1)
            INT_WHEN_ACK1 <= INTERRUPT;
        else
            INT_WHEN_ACK1 <= INT_WHEN_ACK1;
    end
    
     /***********************  OCW REG config *****************/
     // BLOCK REG DEF
      reg AUTO_ROTATE_MODE;
    
    // Operation control word 1

   always @(posedge write_OCW_1) begin
        
         if (write_ICW_1 == 1'b1)
            INT_MASK <= 8'b11111111;
        else if ((write_OCW_1_FLAG == 1'b1) )
            INT_MASK <= internal_data_bus;
        else
            INT_MASK <= INT_MASK;
    end

   

    // Auto rotate mode
   always @(posedge write_OCW_2) begin
        
         if (write_OCW_1 == 1'b1)
            AUTO_ROTATE_MODE <= 1'b0;
        else if (write_OCW_2 == 1'b1) begin
            case (internal_data_bus[7:5])
                3'b000:  AUTO_ROTATE_MODE <= 1'b0;
                3'b100:  AUTO_ROTATE_MODE <= 1'b1;
                default: AUTO_ROTATE_MODE <= AUTO_ROTATE_MODE;
            endcase
        end
        else
            AUTO_ROTATE_MODE <= AUTO_ROTATE_MODE;
    end
    // Rotate
   always @(posedge write_OCW_2) begin
           PRIORITY_ROTATE <= internal_data_bus[2:0];
    end

    
    // RR/RIS
   always @(posedge write_OCW_3) begin
        
         if (write_OCW_1 == 1'b1) begin
            EN_READ_REG     <= 1'b1;
            READ_REG_ISR_OR_IRR <= 1'b0;
        end
        else if (write_OCW_3_FLAG == 1'b1) begin
            EN_READ_REG     <= internal_data_bus[1];
            READ_REG_ISR_OR_IRR <= internal_data_bus[0];
        end
        else begin
            EN_READ_REG     <= EN_READ_REG;
            READ_REG_ISR_OR_IRR <= READ_REG_ISR_OR_IRR;
        end
    end
    
    
    
    /*************************  END BLOCK *******************/ 
    
// Assign Outputs
assign EDGE_OR_LEVEL     = ICW1_B3_LEVEL_OR_EDGE ;
assign FULLY_NESTED_MODE = ICW4_B4_SPECIALLY_FULLY_NEST_CONFIG ;
assign CASCADE_IO        = CASCADE_MODE;
assign LATCH_IN_SERVICE  = LATCH       ;
assign FREEZE            = INTERNAL_FREEZE ;
assign InitState = command_state ;

assign CLR_IR            =  INTERNAL_CLR_IR ;


endmodule