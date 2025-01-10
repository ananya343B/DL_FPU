// Code your design here
module dlfloat16_comp (
  input [15:0] a1,
  input [15:0] b1,
  input [2:0] sel,
  input clk,
  input rst_n,
  output [4:0] exceptions,
  output reg [15:0] c_out
);
  reg s1, s2;
  reg [5:0] exp1, exp2;
  reg [8:0] mant1, mant2;
  reg lt, gt, eq;
  reg [15:0] c_1;
   reg invalid, inexact, overflow, underflow, div_zero;


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            c_out <= 20'b0;
            exception_flags <= 5'b0;
        end else begin
            c_out <= c_1;
		exception_flags <= {invalid, inexact, overflow, underflow, div_zero};
        end
    end
  always @(*) begin
     invalid =1'b0;
	    inexact = 1'b0;
	    overflow = 1'b0;
	    underflow = 1'b0;
	    div_zero = 1'b0;
    // Extract fields
    s1 = a1[15];
    s2 = b1[15];
    exp1 = a1[14:9];
    exp2 = b1[14:9];
    mant1 = a1[8:0];
    mant2 = b1[8:0];
    lt = 0;
    gt = 0;
    eq = 0;
    c_1 = 16'h0000;
  
    
    // Compare logic
    if (s1 != s2) begin
      if (s1) begin
        lt = 1;
      end else begin
        gt = 1;
      end
    end else begin
      if (exp1 > exp2) begin
        gt = !s1;
        lt = s1;
      end else if (exp1 < exp2) begin
        lt = !s1;
        gt = s1;
      end else begin
        if (mant1 > mant2) begin
          gt = !s1;
          lt = s1;
        end else if (mant1 < mant2) begin
          lt = !s1;
          gt = s1;
        end else begin
          eq = 1;
        end
      end
    end
  
    // Generate output based on opcode
    case (sel)
      3'b001: c_1 = (lt ==1'b1)?a1:b1;//min
      3'b010: c_1 = (gt ==1'b1)?a1:b1;//max
      3'b011: c_1 = {16{eq}};//set eq
      3'b100: c_1 = {16{lt}};//set less than
      3'b101: c_1 = (lt ==1'b1 || eq ==1'b1):16'hffff:16'h0000;//set less than equal
      default: c_1 = 16'b0;
    endcase
    if (c_1 == 16'h0000)
      underflow =1'b1;
    if(c_1 == 16'hffff)
      overflow = 1'b1;
  end



endmodule
