`timescale 1ns/1ns

module bcd_digit
  #(
    parameter modulus = 10
    )
  (
   input clk,
   input carry_in,
   input reset,
   output reg [$clog2(modulus)-1:0] digit,
   output carry_out
   );

  initial digit = 0;

  assign carry_out = carry_in && digit == modulus-1;

  always @(posedge clk)
    if (reset)
      digit <= 0;
    else if (carry_in)
      if (carry_out)
	   digit <= 0;
      else
	   digit <= digit+1;

endmodule