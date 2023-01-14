
`timescale 1 ns / 1 ps

	module stopwatch_controller_v1_0 #
	(
		// Users to add parameters here
        parameter ms_limit = 100000,
		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 5
	)
	(
		// Users to add ports here
		input wire clk,
		output wire [6:0] ssd,
		output wire ssdcat,
		output wire [7:0] led,
		input wire [4:0] btn,
		input wire [7:0] switch,
		input wire enc_a,
		input wire enc_b,
		input wire enc_sw,
		input wire enc_btn,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);
	
	wire [7:0] ssd_value;
	wire [7:0] switch_db;
	wire [4:0] btn_db;
	wire enc_a_db;
	wire enc_b_db;
	wire enc_sw_db;
	wire enc_btn_db;
	
	wire [7:0] encoder_value;
	reg [31:0] timer = 0;
	
// Instantiation of Axi Bus Interface S00_AXI
	stopwatch_controller_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) stopwatch_controller_v1_0_S00_AXI_inst (
	    .slv_reg0({24'bz,ssd_value}),
	    .slv_reg1({24'bz,led}),
	    .slv_reg2({24'b0,switch_db}),
	    .slv_reg3({27'b0,btn_db}),
	    .slv_reg4({24'b0,encoder_value}),
	    .slv_reg5({31'b0,enc_sw_db}),
	    .slv_reg6({31'b0,enc_btn_db}),
	    .slv_reg7(timer),
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

	// Add user logic here

    debounce
    #(
      .width(17),
      .bounce_limit(3*ms_limit)
      )
    debounce
    (
     .clk(clk),
     .switch_in({enc_a,enc_b,enc_sw,enc_btn,
		 btn,switch}),
     .switch_out({enc_a_db,enc_b_db,enc_sw_db,enc_btn_db,
		  btn_db,switch_db}),
     .switch_rise(),
     .switch_fall()
     );
  
    ssd
       #(ms_limit)
    ssd
       (
        .clk(clk),
        .value(ssd_value),
        .ssd(ssd),
        .ssdcat(ssdcat)
        );
        
    encoder
       #(8,1)
    encoder
       (
        .clk(clk),
        .a_value(enc_a_db),
        .b_value(enc_b_db),
        .value(encoder_value)
        );
        
        reg [$clog2(ms_limit)-1:0] ms_counter = 0;
        wire ms_limit_reached = ms_counter == ms_limit-1;
        always @(posedge clk)
            if (ms_limit_reached)
                ms_counter <= 0;
            else
                ms_counter <= ms_counter+1;
                
        always @(posedge clk)
            if (ms_limit_reached)
                timer <= timer+1;

	// User logic ends

	endmodule