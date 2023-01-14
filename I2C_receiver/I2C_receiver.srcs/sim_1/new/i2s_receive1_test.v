`timescale 1ns/1ns
module i2s_receive1_test;

  reg sck = 0;
  always #50 sck = ~sck;
  
  reg reset = 1;
  initial
    begin
      repeat(10) @(posedge sck);
      reset <= 0;
    end

  reg ws = 1;
  reg sd;
  wire [8:0] data_left, data_right;

  i2s_receive1 dut
    (
     .sck(sck),
     .ws(ws),
     .sd(sd),
     .data_left(data_left),
     .data_right(data_right)
     );
  
  reg [8:0] expected_left, expected_right, sent_left, sent_right;
  reg [0:16] shift_data;

  common_test_util #(32) util(sck);

  reg stimulus_complete=0;
  event check_left_output;
  event check_right_output;
  
  initial
    begin
      wait (!reset);
      sd <= 0;
      ws <= 0;
      repeat (100)
	begin
	  @(negedge sck);

	  shift_data = {{$random}, {$random}};
	  sent_left = shift_data[0:31];
	  sent_right = shift_data[32:63];
	  
	  repeat (31)
	    begin
	      sd <= shift_data[0];
	      shift_data <= shift_data<<1;
	      @(negedge sck);
	    end
	    
	  expected_left = sent_left;
	  ->check_left_output;
	  ws <= 1;
	  repeat (32)
	    begin
	      sd <= shift_data[0];
	      shift_data <= shift_data<<1;
	      @(negedge sck);
	    end
	  expected_right = sent_right;
	  ->check_right_output;
	  sd <= shift_data[0];
	  ws <= 0;
	end
      stimulus_complete = 1;
    end

  always @(check_left_output)
    begin
      repeat (2) @(negedge sck);
      util.check(data_left,expected_left);
    end

  always @(check_right_output)
    begin
      repeat (2) @(negedge sck);
      util.check(data_right,expected_right);
    end
  
  initial
    begin
      util.init();

      wait (stimulus_complete);

      repeat (10) @(negedge sck);
      util.wrapup();
      $finish;
    end

endmodule