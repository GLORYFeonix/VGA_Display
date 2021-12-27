set_property PACKAGE_PIN P17 [get_ports clk]
set_property PACKAGE_PIN P15 [get_ports rst_n]

set_property PACKAGE_PIN D7 [get_ports hsync]
set_property PACKAGE_PIN C4 [get_ports vsync]

set_property PACKAGE_PIN B7 [get_ports vga_r]
set_property PACKAGE_PIN D8 [get_ports vga_g]
set_property PACKAGE_PIN E7 [get_ports vga_b]

set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

set_property IOSTANDARD LVCMOS33 [get_ports hsync]
set_property IOSTANDARD LVCMOS33 [get_ports vsync]

set_property IOSTANDARD LVCMOS33 [get_ports vga_r]
set_property IOSTANDARD LVCMOS33 [get_ports vga_g]
set_property IOSTANDARD LVCMOS33 [get_ports vga_b]

set_property -dict {PACKAGE_PIN P3 IOSTANDARD LVCMOS33} [get_ports {s[5]}]
set_property -dict {PACKAGE_PIN P2 IOSTANDARD LVCMOS33} [get_ports {s[4]}]
set_property -dict {PACKAGE_PIN R2 IOSTANDARD LVCMOS33} [get_ports {s[3]}]
set_property -dict {PACKAGE_PIN M4 IOSTANDARD LVCMOS33} [get_ports {s[2]}]
set_property -dict {PACKAGE_PIN N4 IOSTANDARD LVCMOS33} [get_ports {s[1]}]
set_property -dict {PACKAGE_PIN R1 IOSTANDARD LVCMOS33} [get_ports {s[0]}]