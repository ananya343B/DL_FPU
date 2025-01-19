// Code your design here
module dl_mult(a,b,c_mul,clk,rst_n,exception_flags);
  input  [15:0]a,b;
  input clk,rst_n;
  output  reg[19:0]c_mul;
  output reg [4:0] exception_flags;
    
    reg [9:0]ma,mb; //1 extra because 1.smthng
  reg [12:0] mant;
    reg [19:0]m_temp; //after multiplication
    reg [5:0] ea,eb,e_temp,exp;
    reg sa,sb,s;
  reg [19:0] mul1;
	reg invalid, inexact, overflow, underflow, div_zero;

  always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            c_mul <= 20'b0;
            exception_flags <= 5'b0;
        end else begin
            c_mul <= c_mul1;
		exception_flags <= {invalid, inexact, overflow, underflow, div_zero};
        end
    end
  	
  always@(*) begin
    invalid =1'b0;
	    inexact = 1'b0;
	    overflow = 1'b0;
	    underflow = 1'b0;
	    div_zero = 1'b0;
        ma ={1'b1,a[8:0]};
        mb= {1'b1,b[8:0]};
        sa = a[15];
        sb = b[15];
        ea = a[14:9];
        eb = b[14:9];
  	
       //to avoid latch inference
  	e_temp = 6'b0;
  	m_temp = 20'b0;
  	mant=9'b0;
  	exp= 6'b0;
  	s=0;
	  if(ena !=4'b0010)
		  c_mul1 =20'b0;
	  else begin

		  
  	//checking for underflow/overflow
    if (  (ea + eb) <= 31 ) begin
      underflow = 1'b1;
  		c_mul1=16'b0;//pushing to zero on underflow
  	end
    else if ( (ea + eb) > 94) begin
      overflow = 1'b1;
      if( (sa ^ sb) ) begin
          c_mul1=16'hFDFE;//pushing to largest -ve number on overflow
        end
      else begin
          c_mul1=16'h7DFE;//pushing to largest +ve number on overflow
      end
    end
        
  	else if ( (ea + eb) == 94 ) begin
      invalid = 1'b1;
		c_mul1=16'hFFFF;//pushing to inf if exp is all ones
 	end
        else begin	
        e_temp = ea + eb - 31;
        m_temp = ma * mb;
		
          mant = m_temp[19] ? m_temp[18:6] : m_temp[17:5];
        exp = m_temp[19] ? e_temp+1'b1 : e_temp;	
        s=sa ^ sb;
		
 	//checking for special cases	
         if( a==16'hFFFF | b==16'hFFFF ) begin
            c_mul1 =16'hFFFF;
         end
        else begin
           c_mul1 = (a==0 | b==0) ? 0 :{s,exp,mant};
         end 
 	end 
	  if(c_mul1[16:19] != 4'b0000)
      inexact = 1'b1;
    end 
  end
	wire _unused = &{m_temp[8:0], 9'b0};
endmodule 
