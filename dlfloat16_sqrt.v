// Code your design here
module dlfloat16_sqrt (
	input [3:0] ena,
	input clk,rst_n,
    input  [15:0] dl_in,              
	output reg [31:0] dl_out_fin,         
    output reg [4:0] exception_flags  
);
    wire sign = dl_in[15];                
    wire [5:0] exp_in = dl_in[14:9];      
    wire [8:0] mant_in = dl_in[8:0];      

  
  reg [12:0] x, x_next;  // Current and next estimates for the square root of mantissa
  reg [12:0] diff;      
reg done;              //convergence flag
  reg [12:0] remainder; 
   
    wire [9:0] mant_norm = (exp_in == 0) ? {1'b0, mant_in} : {1'b1, mant_in};

   
    reg [5:0] exp_out;      
    reg [12:0] mant_sqrt;    
    integer i;
  reg [5:0] ier;
	reg [19:0] dl_out;
    reg invalid, overflow, underflow, inexact;
    wire div_by_zero = 1'b0;

	 always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dl_out_fin <= 32'b0;
            exception_flags <= 5'b0;
        end else begin
		dl_out_fin <= {12'b0,dl_out};
		exception_flags <= {invalid, inexact, overflow, underflow, div_zero};
        end
    end

    always @(*) begin
       
        invalid = 0;
        overflow = 0;
        underflow = 0;
        inexact = 0;
		ier = 6'b0;
      mant_sqrt = 13'b0;
	    if (ena!=4'b0100) 
		    dl_out = 20'b0; 
	    else begin
	    
        //special cases
        if (dl_in == 16'h0000) begin
            // Zero input
            dl_out = 20'h00000;  // Output is zero
        end else if (sign == 1'b1) begin
            // Negative input
            dl_out = 20'hFFFFF;  // NaN representation
            invalid = 1'b1;
        end else begin

          if (exp_in == 6'b0) begin//Denormalized input
                exp_out = 6'b0;  
            end else begin
              if(exp_in[0] ==1'b1)
                begin
                  ier = (exp_in+1)/2;
                  mant_norm = mant_norm >> 1;
                end
              else
                ier = exp_in/2;
            end
			exp_out = ier +31; // Add bias
            // square root of mantissa
             // Edge case handling
          if (mant_norm == 0) begin
        mant_sqrt = 0;
          end else if (mant_norm == 1) begin
        mant_sqrt = 1;
         for (integer i = 0; i < 8 && !done; i = i + 1) begin
           x_next = (x + (mant_norm / x)) >> 1; // New estimate= average of x and num/x
            diff = (x > x_next) ? (x - x_next) : (x_next - x); 

            if (diff <= 1) begin
                done = 1; 
            end

            x = x_next; 
        end

            mant_sqrt = x;
            remainder = mant_norm - (x * x); //remainder calculated for better approximation
            
            if (remainder >= (2 * x )) begin // round up if remainder is large
            mant_sqrt = mant_sqrt + 1;
        end
            
            // Check for inexact result
            if (mant_sqrt * mant_sqrt != (mant_norm << 3)) begin
                inexact = 1'b1;
            end

            // Check for overflow and underflow
            if (exp_out > 6'b111110) begin
                overflow = 1'b1;
                dl_out = 20'h7DFE0;  
            end else if (exp_out == 6'b0 && mant_sqrt == 13'b0) begin
                underflow = 1'b1;
                dl_out = 20'h00000;  
            end else begin
            
                dl_out = {1'b0, exp_out, mant_sqrt};
            end
        end
	end
       
       
    end
endmodule
