`timescale 1ns / 1ns

module ssd_digit
  (
   input enable,
   input [6:0] ssd,
   output reg [3:0] value
   );

  always @(*)
    if (enable)
      case (ssd)
        7'b1111110: value = 0;
        7'b0110000: value = 1;
        7'b1101101: value = 2;
        7'b1111001: value = 3;
        7'b0110011: value = 4;
        7'b1011011: value = 5;
        7'b1011111: value = 6;
        7'b1110000: value = 7;
        7'b1111111: value = 8;
        7'b1110011: value = 9;
        7'b1110111: value = 10;
        7'b0011111: value = 11;
        7'b1001110: value = 12;
        7'b0011001: value = 12;
        7'b0111101: value = 13;
        7'b1001111: value = 14;
        7'b1000111: value = 15;
        default: value = 'bx;
      endcase
  
endmodule