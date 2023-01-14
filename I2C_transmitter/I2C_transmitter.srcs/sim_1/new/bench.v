`timescale 1ns / 1ns

module bench;
    reg clk = 1;
    always #5 clk = ~clk;
    
    reg ws;
    wire sd;
    reg [7:0] data_left;
    reg [7:0] data_right;
    
    i2s_transmit1 dut
    (
     .sck(clk),
     .ws(ws),
     .sd(sd),
     .data_left(data_left),
     .data_right(data_right)
     );
    
    
    // Basic simulation logic
    always @(posedge clk) ws <= 0; // $random;
  
    integer counter = 0;
    reg [7:0] buffer_send;
    
    always @(posedge clk) 
    begin
        if (counter == 0)
        begin
            buffer_send = $random; 
            data_left <= buffer_send;
            data_right <= buffer_send;
            counter <= 7;
        end
        else
            counter <= counter - 1;
    end

    reg [7:0] shift_receive;
    always @(posedge clk) shift_receive <= {shift_receive, sd};



    // Ecpected receive vs actual send
    reg [7:0] buffer_receive;
    integer num_checks = 0;
    integer num_errors = 0;
    always @(posedge clk)
    if (counter == 0)
        begin
            buffer_receive = shift_receive;     
            num_checks = num_checks+1;
            if (buffer_receive != buffer_send)
            begin
                num_errors = num_errors+1;
            end
        end	
    

endmodule