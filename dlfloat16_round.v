module dlfloat16_round ( input [31:0] in, input [3:0] ena,
                      input [2:0] rm,
                      input rst_n,
                      input clk,
                        output reg [31:0] out);
  
  reg G_bit,R_bit, S1_bit , S2_bit, S_bit;
  reg [15:0]out1;
  reg sign;
  reg [5:0] exp;
  reg [9:0] mant1;
  reg [8:0] mant;
  reg [2:0] rm1;
  reg [19:0] in1;
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      out<= 32'b0;
    end else begin
      if(ena !=4'b1000)
      out <= {16'h0000,out1}; 
      else
        out <= in;
    end
  end
    always@(*) begin 
      in1 = in [19:0];
      G_bit  = in1[3];
      R_bit  = in1[2];
      S1_bit = in1[1];
      S2_bit = in1[0];
      mant1  = {1'b0, in1[12:4]};
      exp    = in1[18:13];
      sign   = in1[19];
      rm1    = rm;
      
      S_bit  = S1_bit | S2_bit;
      
      case(rm) 
        //ROUND TO NEAREST,TIES TO EVEN
        000: begin
          if(!G_bit) begin
            mant = mant1[8:0];//no rounding
          end
          else begin
            if ( R_bit + S_bit) begin
              if(in1[4])begin //if lsb of mant is 1 add 1 and change exp accordingly
                mant1 = mant1 + 1;
                mant = mant1[8:0];
                exp = mant1[9]? exp+1'b1: exp;
              end
              else begin
                mant = mant1[8:0];//if lsb is zero leave it as it is
              end
            end
            else begin //if R+S is zero add 1 to mant
                mant1 = mant1 + 1;
                mant = mant1[8:0];
                exp = mant1[9]? exp+1'b1: exp;
            end
          end//else block
        end//case block
        
        
        //ROUND TO ZERO
        001: begin 
          mant = mant1[8:0];//truncate GRS bits and leave it 
        end  
        
       //ROUND UP  
        010: begin
          if (G_bit + R_bit + S_bit) begin
            if(!sign)begin //add 1 to mant if num is +ve
                mant1 = mant1 + 1;
                mant = mant1[8:0];
                exp = mant1[9]? exp+1'b1: exp;
            end
            else begin //nothing if num is -ve
              mant = mant1[8:0];
            end
          end
          else begin //if g+r+s is zero no rounding
            mant = mant1[8:0];
          end
       end//case block
        
        //ROUND DOWN
        011: begin
           if (G_bit + R_bit + S_bit) begin
             if(sign)begin //add 1 to mant if num is -ve
                mant1 = mant1 + 1;
                mant = mant1[8:0];
                exp = mant1[9]? exp+1'b1: exp;
             end
            else begin //nothing if num is +ve
              mant = mant1[8:0];
            end
          end
          else begin //if g+r+s is zero no rounding
            mant = mant1[8:0];
          end
          
        end//case block
        
        default: rm1 = 3'b0;
            
      endcase
       
      out1 = {sign,exp,mant}; 
    end
  
endmodule  
      
      
     
     
