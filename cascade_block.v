
module cascade_block (
       inout    [2:0] CAS,
       input   [2:0] SLAVE_ID,
       output   [2:0] cascade_in,
       input CASCADE_IO
);

  assign CAS = (CASCADE_IO==1)?SLAVE_ID: 3'bzzz;
  
  assign cascade_in = (CASCADE_IO==0)?CAS : 3'bzzz;

endmodule 
