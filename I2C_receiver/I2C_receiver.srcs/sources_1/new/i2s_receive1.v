`timescale 1ns / 1ps

module i2s_receive1(
    input sck,
    input ws,
    input sd,
    output reg [8:0] data_left,
    output reg [8:0] data_right
    );
    
    reg wsd = 0;
    always @ (posedge sck) wsd <= ws;
    
    reg wsd_o;
    always @ (posedge sck)  wsd_o <= wsd;
    
    wire wsp;
    assign wsp = wsd ^ wsd_o;
    
    reg [31:0] shift;
    always @(posedge sck) shift <= {shift, sd};
        
    wire data_left_en;
    assign data_left_en = wsd & wsp;
    
    wire data_right_en;
    assign data_right_en = ~wsd & wsp;
    
    always @(posedge sck)
        begin
            if (data_left_en) begin
                data_left <= shift;
                data_right <= 8'b0;
            end
            else if (data_right_en) begin
                data_left <= 8'b0;
                data_right <= shift;
            end                
        end
endmodule
