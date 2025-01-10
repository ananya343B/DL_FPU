// Code your design here
module dl_exception();
  input [4:0] exceptions;
  output reg invalid, inexact, overflow, underflow, div_zero;
  always@(*)
  begin
    div_zero = exceptions[0];
    underflow =  exceptions[1];
    overflow =  exceptions[2];
    inexact =  exceptions[3]; 
    invalid =  exceptions[4];
  end
endmodule
