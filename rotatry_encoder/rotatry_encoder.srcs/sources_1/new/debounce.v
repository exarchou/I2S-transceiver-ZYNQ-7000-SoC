`timescale 1ns / 1ns
module debounce
  #(
    parameter width = 1,
    parameter bounce_limit = 1024
    )
  (
   input clk,
   input [width-1:0] switch_in,
   output reg [width-1:0] switch_out,
   output reg [width-1:0] switch_rise,
   output reg [width-1:0] switch_fall
   );

  genvar  i;
  generate
    for (i=0; i<width;i=i+1)
      begin
	reg [$clog2(bounce_limit)-1:0] bounce_count = 0;
	reg switch_latched = 0;
	reg switch_latched_state = 0;

	reg [1:0] switch_shift = 0;
	always @(posedge clk)
	  switch_shift <= {switch_shift,switch_in[i]};

	always @(posedge clk)
	  if (bounce_count == 0)
	    begin
	      switch_rise[i] <= switch_shift == 2'b01;
	      switch_fall[i] <= switch_shift == 2'b10;
	      switch_out[i] <= switch_shift[0];
	      if (switch_shift[1] != switch_shift[0])
		bounce_count <= bounce_limit-1;
	    end
	  else
	    begin
	      switch_rise[i] <= 0;
	      switch_fall[i] <= 0;
	      bounce_count <= bounce_count-1;
	    end
      end
  endgenerate
endmodule