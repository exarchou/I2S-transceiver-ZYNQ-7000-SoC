`timescale 1ns / 1ns

module top
#(
  parameter ms_limit = 100000
) (
   input clk,
   input [7:0] switch,
   input [4:0] btn,
   output reg [7:0] led,
   output reg [6:0] ssd,
   output reg ssdcat
   );

  always @(posedge clk) led <= switch;

  wire btnl = btn[0];
  wire btnu = btn[1];
  wire btnr = btn[2];
  wire btnd = btn[3];
  wire btnc = btn[4];

  reg [0:$clog2(ms_limit)-1] ssdcat_count = 0;
  always @(posedge clk)
    ssdcat_count <= ssdcat_count+1;
  
  initial ssdcat = 0;
  always @(posedge clk)
    ssdcat <= ssdcat_count[0];

  reg [1:0] btnl_shift;
  always @(posedge clk)
    btnl_shift <= {btnl_shift,btnl};
  wire btnl_rise = btnl_shift == 2'b01;
  
  reg [1:0] btnc_shift;
  always @(posedge clk)
    btnc_shift <= {btnc_shift,btnc};
  wire btnc_rise = btnc_shift == 2'b01;
  
  reg [1:0] btnr_shift;
  always @(posedge clk)
    btnr_shift <= {btnr_shift,btnr};
  wire btnr_rise = btnr_shift == 2'b01;

  reg count_enable = 1;
  always @(posedge clk)
    if (btnr_rise)
      count_enable <= 1;
    else if (btnc_rise)
      count_enable <= 0;

  integer count = 0;
  wire ms_pulse = count == ms_limit-1;
  always @(posedge clk)
    if (btnl_rise)
      count <= 0;
    else if (count_enable)
      if (ms_pulse)
	   count <= 0;
      else
	   count <= count+1;

  localparam num_digits = 3 + 2 + 2 + 2;
  wire [num_digits*4-1:0] time_digits;
  wire [num_digits:0] carry;
  assign carry[0] = ms_pulse;


  localparam wrap_at_six = 9'b001010000;

  genvar i;
  generate
    for (i=0; i<num_digits; i=i+1)
      bcd_digit #(wrap_at_six[i] ? 6 : 10) bcd_digit
	(
	 .clk(clk),
	 .carry_in(carry[i]),
	 .reset(btnl_rise),
	 .digit(time_digits[i*4+:4]),
	 .carry_out(carry[i+1])
	 );
  endgenerate

  reg [3:0]   digit;
  always @(*)
    case(1'b1)
      switch[3]: digit = ssdcat_count[0] ? time_digits[35:32] : time_digits[31:28];
      switch[2]: digit = ssdcat_count[0] ? time_digits[27:24] : time_digits[23:20];
      switch[1]: digit = ssdcat_count[0] ? time_digits[19:16] : time_digits[15:12];
      switch[0]: digit = ssdcat_count[0] ? time_digits[11: 8] : time_digits[7 :4 ];
      default:   digit = ssdcat_count[0] ? time_digits[19:16] : time_digits[15:12];
    endcase

  always @(posedge clk)
    case (digit)
      0: ssd <= 7'b1111110;
      1: ssd <= 7'b0110000;
      2: ssd <= 7'b1101101;
      3: ssd <= 7'b1111001;
      4: ssd <= 7'b0110011;
      5: ssd <= 7'b1011011;
      6: ssd <= 7'b1011111;
      7: ssd <= 7'b1110000;
      8: ssd <= 7'b1111111;
      9: ssd <= 7'b1110011;
      10: ssd <= 7'b1110111;
      11: ssd <= 7'b0011111;
      12: ssd <= 7'b1001110;
      13: ssd <= 7'b0111101;
      14: ssd <= 7'b1001111;
      15: ssd <= 7'b1000111;
    endcase

endmodule