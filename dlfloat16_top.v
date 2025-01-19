// Code your design here
module dl_top();
  input [31:0] instr;
  input [31:0] op1,op2,op3;
  output invalid, inexact, overflow,underflow, div_by_zero;
  output [31:0] result;
  input clk,rst_n;
  
  wire [3:0] ena;
  wire [2:0] rm;
  wire [2:0] sel2;
  wire [1:0] sel1;
  wire op;
  wire [15:0] src1,src2,src3;
  assign src1 = op1[15:0];
  assign src2 = op2[15:0];
  assign src3 = op3[15:0];
  wire [19:0] out_add_sub, out_mul,out_div,out_mac,out_sqrt,out_sign,out_i2f,out_comp;
  wire [31:0] out_muxed;
  wire [31:0] out_int;
  wire [4:0] excep;
  
  fp_decoder(.instr(instr), .ena(ena), .rm(rm), .sel2(sel2), .sel1(sel1), .op(op));
  
  fp_add_sub(.a(src1), .b(src2), .ena(ena), .op(op), .excep(excep), .c_out(out_add_sub));
  fp_mul(.a(src1), .b(src2), .ena(ena), .c_out(out_mul), .excep(excep));
  fp_div(.a(src1), .b(src2), .ena(ena), .c_out(out_div), .excep(excep));
  fp_sqrt(.a(src1), .ena(ena), .c_out(out_sqrt), .excep(excep));
  fp_mac(.a(src1), .b(src2), .d(src3), .c_out(out_mac), .ena(ena), .op(op), .excep(excep));
  fp_sign_inv(.a(src1), .b(src2), .ena(ena), .sel(sel1), .c_out(out_sign), .excep(excep));
  fp_int2float(.a(op1), .ena(ena), .out(out_i2f), .excep(excep));
  fp_float2int(.a(src1), .ena(ena), .out(out_int), .excep(excep));
  fp_compare(.a(src1), .b(src2), .ena(ena), .sel2(sel2), .out(out_comp), .excep(excep));
  
  fp_out_mux(.ena(ena), .out_add_sub(out_add_sub), .out_mul(out_mul), .out_div(out_div), .out_mac(out_mac), .out_sqrt(out_sqrt), .out_sign(out_sign), .out_i2f(out_i2f), .out_comp(out_comp), out_int(out_int), .out_muxed(out_muxed));
  
  fp_rounding(.rm(rm), .ena(ena), .out_muxed(out_muxed) , .result(result));
  
endmodule
