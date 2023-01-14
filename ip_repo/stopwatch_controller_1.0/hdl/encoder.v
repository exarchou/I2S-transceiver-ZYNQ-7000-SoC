`timescale 1ns / 1ns
module encoder
 #(
     parameter width = 8,
     parameter a_rest_state = 1
  )
  (
    input clk,
    input a_value,
    input b_value,
    output reg [width-1:0] value
  );
    reg [1:0] a_shift = {2 {a_rest_state[0]}};
    always @(posedge clk) a_shift <= {a_shift,a_value};
    initial value = 0;
    always @(posedge clk)
      if (a_shift == 2'b01)
        if (!b_value)
      value <= value-1;
        else
      value <= value+1;
endmodule