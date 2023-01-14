set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN Y9 [get_ports clk]
create_clock -period 10.000 [get_ports clk]

set_property IOSTANDARD LVCMOS33 [get_ports sck]
set_property IOSTANDARD LVCMOS33 [get_ports ws]
set_property IOSTANDARD LVCMOS33 [get_ports sd]
set_property PACKAGE_PIN AB7 [get_ports sck]
set_property PACKAGE_PIN AB6 [get_ports ws] 
set_property PACKAGE_PIN Y4 [get_ports sd] 

set_property IOSTANDARD LVCMOS33 [get_ports {data_left[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_left[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_left[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_left[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_left[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_left[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_left[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_left[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_right[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_right[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_right[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_right[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_right[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_right[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_right[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_right[0]}]
set_property PACKAGE_PIN T22 [get_ports {data_left[0]}]
set_property PACKAGE_PIN T21 [get_ports {data_left[1]}]
set_property PACKAGE_PIN U22 [get_ports {data_left[2]}]
set_property PACKAGE_PIN U21 [get_ports {data_left[3]}]
set_property PACKAGE_PIN V22 [get_ports {data_left[4]}]
set_property PACKAGE_PIN W22 [get_ports {data_left[5]}]
set_property PACKAGE_PIN U19 [get_ports {data_left[6]}]
set_property PACKAGE_PIN U14 [get_ports {data_left[7]}]
set_property PACKAGE_PIN F22 [get_ports {data_right[0]}]
set_property PACKAGE_PIN G22 [get_ports {data_right[1]}]
set_property PACKAGE_PIN H22 [get_ports {data_right[2]}]
set_property PACKAGE_PIN F21 [get_ports {data_right[3]}]
set_property PACKAGE_PIN H19 [get_ports {data_right[4]}]
set_property PACKAGE_PIN H18 [get_ports {data_right[5]}]
set_property PACKAGE_PIN H17 [get_ports {data_right[6]}]
set_property PACKAGE_PIN M15 [get_ports {data_right[7]}]