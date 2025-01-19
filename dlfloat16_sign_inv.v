module dlfloat16_sign_inv (
  input [15:0] in1, 
  input [15:0] in2,  
  input [1:0] sel,
  input clk,rst_n
  output reg [15:0] out,
	output reg [4:0] exceptions,
	 input [3:0] ena
);
  reg [15:0] out_comb;

  always @(*) begin
	  if(ena !=4'b0101)
		  out_comb = 16'b0;
	  else begin
    case (sel)
      2'b00: out_comb = {~in1[15], in1[14:0]}; // invert
      2'b01: out_comb = {in1[15], in2[14:0]};  // sign injection normalized
      2'b10: out_comb = {~in1[15], in2[14:0]}; // sign injection inverse
      2'b11: out_comb = {in1[15] ^ in2[15], in2[14:0]}; // sign injection xor
      default: out_comb = 16'h0000;
    endcase
  end
  end

always @(posedge clk or negedge rst_n) begin
  exceptions <= 5'b0;
        if (!rst_n) begin
            out <= 16'b0;
            
        end else begin
            out <= out_comb;
		
        end
    end
endmodule
