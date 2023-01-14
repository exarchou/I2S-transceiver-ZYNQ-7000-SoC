`timescale 1ns / 1ps

module i2s_transmit1(
    input sck,
    input ws,
    output reg sd,
    input [7:0] data_left,
    input [7:0] data_right
    );
    
    reg wsd = 0;
    always @ (posedge sck) wsd <= ws;
    
    reg wsd_o;
    always @ (posedge sck)  wsd_o <= wsd;
    
    wire wsp;
    assign wsp = wsd ^ wsd_o;
    
    reg [7:0] shift_register;
        
    integer counter = 0;
    
            

    always @(posedge sck)
        begin
            if (counter == 0)
                begin
                    if (!wsd) 
                        shift_register <= data_left;
                    else
                        shift_register <= data_right;  
                    counter <= 7;           
                end
            else
                counter <= counter - 1;
         end
                    
    
//    always @(posedge sck) shift_register <= {shift_register, 0};
         
    always @(negedge sck) sd <= shift_register[counter];
        
endmodule
