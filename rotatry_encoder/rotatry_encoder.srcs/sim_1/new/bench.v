`timescale 1ns / 1ns
module bench;
  reg clk = 1;
  always #5 clk = ~clk;

  reg [4:0] btn = 0;
  reg [7:0] switch = 0;
  wire [7:0] led;
  wire 	     ssdcat;
  wire [6:0] ssd;
  
  top #(.ms_limit(100)) top
    (
     .clk(clk),
     .btn(btn),
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

  task press_button;
    input integer button;
    input integer bounce0;
    input integer bounce1;
    begin
      btn[button] <= 1;
      if (bounce0 > 0)
	begin
	  repeat(bounce0) @(posedge clk);
	  btn[button] <= 0;
	  repeat(bounce1) @(posedge clk);
	  btn[button] <= 1;
	end
    end
  endtask

  task release_button;
    input integer button;
    input integer bounce0;
    input integer bounce1;
    begin
      btn[button] <= 0;
      if (bounce0 > 0)
	begin
	  repeat(bounce0) @(posedge clk);
	  btn[button] <= 1;
	  repeat(bounce1) @(posedge clk);
	  btn[button] <= 0;
	end
    end
  endtask

  task clear_trigger;
    begin
      press_button(0,0,0);
      repeat (10) @(posedge clk);
      release_button(0,0,0);
      repeat (10) @(posedge clk);
    end
  endtask

  task read_period;
    input which;
    output integer value;
    integer base;
    begin
      base = which*3;
      switch <= 0;
      switch[base] <= 1;
      @(ssdcat);
      @(ssdcat);
      repeat (10) @(posedge clk);
      value = digits;
      switch <= 0;
      switch[base+1] <= 1;
      @(ssdcat);
      @(ssdcat);
      repeat (10) @(posedge clk);
      value = value | digits<<8;
      switch <= 0;
      switch[base+2] <= 1;
      @(ssdcat);
      @(ssdcat);
      repeat (10) @(posedge clk);
      value = value | digits<<16;
    end
  endtask

  integer num_checks = 0;
  integer num_errors = 0;

  task test_button;
    input integer button;
    integer period[1:0];
    integer expected_period[1:0];
    begin
      expected_period[0] = {$random}%(top.bounce_limit-10)+10;
      expected_period[1] = {$random}%(top.bounce_limit-10)+10;
      if (btn[button])
	begin
	  release_button(button,expected_period[0],expected_period[1]);
	  wait(led[1]);
	end
      else
	begin
	  press_button(button,expected_period[0],expected_period[1]);
	  wait(led[0]);
	end
      read_period(0,period[0]);
      read_period(1,period[1]);
      num_checks = num_checks+1;
      if (period[0] != expected_period[0])
	begin
	  $display("*** ERROR: period[0] value %0d does not match expected value of %0d",
		   period[0],expected_period[0]);
	  num_errors = num_errors+1;
	end
      num_checks = num_checks+1;
      if (period[1] != expected_period[1])
	begin
	  $display("*** ERROR: period[1] value %0d does not match expected value of %0d",
		   period[1],expected_period[1]);
	  num_errors = num_errors+1;
	end
      clear_trigger;
    end
  endtask
  
  initial
    begin
      repeat (10) @(posedge clk);
      repeat (100) test_button(4);
      repeat (10) @(posedge clk);
      $display("Simulation complete at time %0fns.",$realtime);
      if (num_errors > 0)
	   $display("*** Simulation FAILED %0d/%0d",num_errors,num_checks);
      else
	   $display("*** Simulation PASSED %0d/%0d",num_errors,num_checks);
      $finish;
    end

endmodule