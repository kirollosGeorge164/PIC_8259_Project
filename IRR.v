module IRR (
 input Level_Edge_flag , //from control
 input [7:0] Mask, //from control

 input I_0, 
 input I_1,
 input I_2,
 input I_3,
 input I_4,
 input I_5,
 input I_6,
 input I_7,

 output reg[7:0] IRR //to priority resolver

 );

reg Prev_I0,Prev_I1,Prev_I2,
  Prev_I3,Prev_I4,Prev_I5,
  Prev_I6,Prev_I7;  
  
  initial begin
  Prev_I0 = 0;
  Prev_I1 = 0;
  Prev_I2 = 0;
  Prev_I3 = 0;
  Prev_I4 = 0;
  Prev_I5 = 0;
  Prev_I6 = 0;
  Prev_I7 = 0;
end

 always @* begin
    if (!Level_Edge_flag) begin
    IRR[0] <= (I_0 & ~Mask[0]);
    IRR[1] <= (I_1 & ~Mask[1]);
    IRR[2] <= (I_2 & ~Mask[2]);
    IRR[3] <= (I_3 & ~Mask[3]);
    IRR[4] <= (I_4 & ~Mask[4]);
    IRR[5] <= (I_5 & ~Mask[5]);
    IRR[6] <= (I_6 & ~Mask[6]);
    IRR[7] <= (I_7 & ~Mask[7]);
  end

  // Edge-sensitive Logic
  else begin
    IRR[0] <= (I_0 & ~Prev_I0);
    IRR[1] <= (I_1 & ~Prev_I1);
    IRR[2] <= (I_2 & ~Prev_I2);
    IRR[3] <= (I_3 & ~Prev_I3);
    IRR[4] <= (I_4 & ~Prev_I4);
    IRR[5] <= (I_5 & ~Prev_I5);
    IRR[6] <= (I_6 & ~Prev_I6);
    IRR[7] <= (I_7 & ~Prev_I7);
  end

  // Update Previous Input values
  Prev_I0 <= I_0;
  Prev_I1 <= I_1;
  Prev_I2 <= I_2;
  Prev_I3 <= I_3;
  Prev_I4 <= I_4;
  Prev_I5 <= I_5;
  Prev_I6 <= I_6;
  Prev_I7 <= I_7;
end



endmodule



module IRR_tb();

// Declare the IRR module
reg Level_Edge_flag;
reg[7:0] Mask;

reg I_0, I_1, I_2, I_3, I_4, I_5, I_6, I_7;

wire [7:0] IRR;



initial begin
  // Reset signals
  Level_Edge_flag = 0;
  Mask = 8'h00;
  
  
  I_0 = 0;
  I_1 = 0;
  I_2 = 0;
  I_3 = 0;
  I_4 = 0;
  I_5 = 0;
  I_6 = 0;
  I_7 = 0;
  #10;
  
  I_0 =1;
  #10;


 
end

IRR uut (
  .Level_Edge_flag(Level_Edge_flag),
  .Mask(Mask),
 
  .I_0(I_0),
  .I_1(I_1),
  .I_2(I_2),
  .I_3(I_3),
  .I_4(I_4),
  .I_5(I_5),
  .I_6(I_6),
  .I_7(I_7),
  
  .IRR(IRR)

);

endmodule