# step#0: Define output directory location.
set current_dir [pwd]
create_project -in_memory
set obj [current_project]
set_property -name "board_part_repo_paths" -value "[file normalize "/home/cotton/.Xilinx/Vivado/2022.2/xhub/board_store/xilinx_board_store"]" -objects $obj
set_property -name "board_part" -value "digilentinc.com:zybo-z7-20:part0:1.0" -objects $obj
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj


set_property board_part digilentinc.com:zybo-z7-20:part0:1.0 [current_project]
set_property -name "ip_repo_paths" -value "./ip/myip_1_0" -objects $obj


read_xdc ./src/const/test.xdc
import_ip ./src/ip/my_ip/design_1_myip_0_0.xci
upgrade_ip  -vlnv  user.org:user:myip:1.0 [get_ips design_1_myip_0_0] 

set outputDir ./synth_tmp
file mkdir $outputDir
# print get_parts
# puts "get_parts: [get_parts]"
# set_part digilentinc.com:zybo-z7-20:part0:1.0

# step#1: Setup design sources and constraints.
# check whether the design is already created
set design_name design_1
source ./blockdesign/$design_name.tcl
generate_target all [get_files  .srcs/sources_1/bd/design_1/design_1.bd] -force

# check whether the wrapper is already created

make_wrapper -files [get_files  .srcs/sources_1/bd/design_1/design_1.bd] -top -force


read_verilog -sv [ glob .gen/sources_1/bd/design_1/hdl/design_1_wrapper.v ]
set top_module_name design_1_wrapper
set_property top $top_module_name [current_fileset]

# 
#read_verilog [ glob ./ip/pll/*.v ]

# step#2: Run synthesis, report utilization and timing estimates, write checkpoint design.

synth_design  -verilog_define SYNTHESIS
write_checkpoint -force $outputDir/post_synth
report_timing_summary -file $outputDir/post_synth_timing_summary.rpt
report_power -file $outputDir/post_synth_power.rpt
report_clock_interaction -delay_type min_max -file $outputDir/post_synth_clock_interaction.rpt
report_high_fanout_nets -fanout_greater_than 200 -max_nets 50 -file $outputDir/post_synth_high_fanout_nets.rpt

# step#3: Run placement and logic optimization, report utilization and timing estimates, write checkpoint design.

opt_design
place_design
phys_opt_design
write_checkpoint -force $outputDir/post_place
report_timing_summary -file $outputDir/post_place_timing_summary.rpt


# step#4: Run router, report actual utilization and timing, write checkpoint design, run drc, write verilog and xdc out.


route_design
write_checkpoint -force $outputDir/post_route
report_timing_summary -file $outputDir/post_route_timing_summary.rpt
report_timing -max_paths 100 -path_type summary -slack_lesser_than 0 -file $outputDir/post_route_setup_timing_violations.rpt
report_clock_utilization -file $outputDir/clock_util.rpt
report_utilization -file $outputDir/post_route_util.rpt
report_power -file $outputDir/post_route_power.rpt
report_drc -file $outputDir/post_imp_drc.rpt
write_verilog -force $outputDir/top_impl_netlist.v
write_xdc -no_fixed_only -force $outputDir/top_impl.xdc

update_compile_order -fileset sim_1
set_property top pattern_tb [current_fileset -simset]

# step#5: Generate a bitstream.
write_bitstream -force $outputDir/$top_module_name.bit

write_hw_platform -fixed -include_bit -force -file ./dist/$top_module_name.xsa
