
module Buffer (
       input    [7:0] input_data,
       output   [7:0] internal_data_bus,
       inout    [7:0]  data_bus, 
       input enable
);

  assign data_bus = (enable==1)?input_data: 8'bzzzzzzzz;
  
  assign internal_data_bus = (enable==0)?data_bus : 8'b zzzzzzzz;




endmodule 


module buffer_DUT();
   reg  [7:0] input_data;
  
   reg enable;
   reg dir;
   wire  [7:0]  data_bus;
  wire   [7:0] internal_data_bus;
  
  
  assign data_bus =dir ? 8'b00000001:8'bzzzzzzzz; 
  
  
  initial begin
   
  enable = 1; 
  dir =0;
  input_data = 8'b10101010;
   #10;
   input_data = 8'b11111111;
   #10;
   enable =0;
   #10;
   dir =1;
  
end
  
  Buffer Bus_buffer (
  
  .input_data(input_data),
  .internal_data_bus(internal_data_bus),
  .data_bus(data_bus),
  .enable(enable)
  
  );
  
  
  
endmodule
