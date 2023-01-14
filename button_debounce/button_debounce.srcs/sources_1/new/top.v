`timescale 1ns / 1ns
module top
#(
  parameter default_ms_limit = 100000,
  parameter ms_limit = default_ms_limit
) (
   input clk,
   input [7:0] switch,
   input [4:0] btn,
   output reg [7:0] led,
   output reg [6:0] ssd,
   output reg ssdcat
   );

  wire btnl = btn[0];
  wire btnu = btn[1];
  wire btnr = btn[2];
  wire btnd = btn[3];
  wire btnc = btn[4];

  wire btnc_debounced;
  debounce #(.bounce_limit(ms_limit*3)) db_bntc
    (
     .clk(clk),
     .switch_in(btnc),
     .switch_out(btnc_debounced),
     .switch_rise(),
     .switch_fall()
     );

  reg [1:0] btnl_shift;
  always @(posedge clk)
    btnl_shift <= {btnl_shift,btnl};
  wire btnl_rise = btnl_shift == 2'b01;
  wire btnl_fall = btnl_shift == 2'b10;
  
  reg [1:0] btnc_shift;
  always @(posedge clk)
    btnc_shift <= {btnc_shift,switch[7] ? btnc : btnc_debounced};
  wire btnc_rise = btnc_shift == 2'b01;
  wire btnc_fall = btnc_shift == 2'b10;
  
  reg [1:0] btnr_shift;
  always @(posedge clk)
    btnr_shift <= {btnr_shift,btnr};
  wire btnr_rise = btnr_shift == 2'b01;
  wire btnr_fall = btnr_shift == 2'b10;

  wire [3:0]  digit;
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

  reg [0:$clog2(ms_limit)-1] count = 0;
  always @(posedge clk) count <= count+1;
  always @(posedge clk) ssdcat <= count[0];

  localparam bounce_milliseconds = 10;
  localparam bounce_limit = bounce_milliseconds*ms_limit;
  localparam default_bounce_limit = bounce_milliseconds*default_ms_limit;
  reg [$clog2(default_bounce_limit)-1:0] bounce_count = 0;
  wire bounce_limit_reached = bounce_count == bounce_limit-1;
  reg [$clog2(default_bounce_limit)-1:0] period0 = 0;
  reg [$clog2(default_bounce_limit)-1:0] period1 = 0;

  reg triggered_rise = 0;
  reg triggered_fall = 0;

  localparam idle_state = 0;
  localparam wait_1st_state = 1;
  localparam wait_2nd_state = 2;
  localparam triggered_state = 3;
  integer state = idle_state;

  always @(posedge clk)
    case(state)
      idle_state:
	begin
	  bounce_count <= 1;
	  period0 <= 0;
	  period1 <= 0;
	  triggered_rise <= 0;
	  triggered_fall <= 0;
	  if (btnc_fall || btnc_rise)
	    begin
	      triggered_rise <= btnc_rise;
	      triggered_fall <= btnc_fall;
	      state <= wait_1st_state;
	    end
	end
      wait_1st_state:
	begin
	  bounce_count <= bounce_count+1;
	  if (bounce_limit_reached)
	    begin
	      state <= idle_state;
	    end
	  else if (btnc_rise || btnc_fall)
	    begin
	      period0 <= bounce_count;
	      bounce_count <= 1;
	      state <= wait_2nd_state;
	    end
	end
      wait_2nd_state:
	begin
	  bounce_count <= bounce_count+1;
	  if (btnc_rise || btnc_fall)
	    begin
	      period1 <= bounce_count;
	      state <= triggered_state;
	    end
	end
      triggered_state:
	if (btnl_rise)
	  begin
	    state <= idle_state;
	  end
    endcase

  reg [7:0] ssd_byte;
  always @(*)
    case (1'b1)
      switch[5]: ssd_byte = period1[$clog2(default_bounce_limit)-1:16];
      switch[4]: ssd_byte = period1[15:8];
      switch[3]: ssd_byte = period1[7:0];
      switch[2]: ssd_byte = period0[$clog2(default_bounce_limit)-1:16];
      switch[1]: ssd_byte = period0[15:8];
      switch[0]: ssd_byte = period0[7:0];
      default: ssd_byte = 0;
    endcase

  assign digit = count[0] ? ssd_byte[7:4] : ssd_byte[3:0];

  wire waiting = state == idle_state;
  always @(posedge clk)
    led <= {btnc_fall,btnc_rise,waiting,triggered_fall,triggered_rise};

endmodule