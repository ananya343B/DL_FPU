module out_mux(input [3:0] ena, input [31:0] out_add_sub, out_mul, out_div, out_mac, out_sqrt,out_i2f, out_comp, out_sign,out_f2i, output [31:0] out_muxed);

  always@(*)
    begin
      case(ena)
        4'b0001: out_muxed = out_add_sub;
        4'b0010: out_muxed = out_mul;
        4'b0011: out_muxed = out_div;
        4'b0100: out_muxed = out_sqrt;
        4'b0101: out_muxed = out_sign;
        4'b0110: out_muxed = out_comp;
        4'b1001: out_muxed = out_mac;
        4'b0111: out_muxed = out_i2f;
        4'b1000: out_muxed = out_f2i;
        default: out_muxed = 32'b0;
      endcase
    end
endmodule
