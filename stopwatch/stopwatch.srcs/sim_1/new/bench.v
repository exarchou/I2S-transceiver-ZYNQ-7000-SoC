`timescale 1ns / 1ns

module bench;
  reg clk = 1;
  always #5 clk = ~clk;

  reg [7:0] switch;
  wire [7:0] led;
  wire ssdcat;
  wire [6:0] ssd;
  
  top #(.ms_limit(10)) top
    (
     .clk(clk),
     .switch(switch),
     .led(led),
     .ssd(ssd),
     .ssdcat(ssdcat)
     );

  wire [7:0] digits;
  ssd_digit PmodSSD0
    (
     .enable(~ssdcat),
     .ssd(ssd),
     .value(digits[3:0])
     );
  
  ssd_digit PmodSSD1
    (
     .enable(ssdcat),
     .ssd(ssd),
     .value(digits[7:4])
     );

  wire [7:0] model_seconds;
  model
    #(.ms_limit(10))
  model
    (
     .clk(clk),
     .seconds(model_seconds)
     );

  // Basic simulation logic
  always @(posedge clk) switch <= $random;

  // Ecpected led comparions with actial led
  reg [7:0] expected_led;
  always @(posedge clk) expected_led <= switch;

  integer num_checks = 0;
  integer num_errors = 0;
  always @(posedge clk)
    begin
      num_checks = num_checks+1;
      if (expected_led != led)
        begin
          if (num_errors < 100)
            $display("ERROR: led value %0x does not match expected value %0x at time %0.0fns", led,expected_led,$realtime);
          num_errors = num_errors+1;
        end
    end	

  reg [3:0] check_digits;
  reg [3:0] check_model_digits;
  always @(posedge clk)
    begin
      check_digits = ssdcat ? digits[7:4] : digits[3:0];
      check_model_digits = ssdcat ? model_seconds[7:4] : model_seconds[3:0];
      num_checks = num_checks+1;
      if (check_digits != check_model_digits)
        begin
          if (num_errors < 100)
            $display("ERROR: check_digits value %0x does not match expected check_model_digits value %0x at time %0.0fns",
                 check_digits,check_model_digits,$realtime);
          num_errors = num_errors+1;
        end
    end	

  // Simulation logs
  initial
    begin
      wait (model_seconds == 200);
      $display("Simulation complete at time %0fns.",$realtime);
      if (num_errors > 0)
	    $display("*** Simulation FAILED %0d/%0d",num_errors,num_checks);
      else
	    $display("*** Simulation PASSED %0d/%0d",num_errors,num_checks);
      $finish;
    end

endmodule