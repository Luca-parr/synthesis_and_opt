source ./tcl_scripts/setenv.tcl
#source ./tcl_scripts/scheduling/list_latency_constrained.tcl
#source ./tcl_scripts/scheduling/list_latency_constrained_rec.tcl   
#source ./tcl_scripts/scheduling/list_latency_optimization.tcl
source ./tcl_scripts/scheduling/list_latency_optimization_test.tcl  
read_design ./data/DFGs/fir.dot
read_library ./data/RTL_libraries/RTL_lib_1.txt

set fp [ open "./data/out/test_final_opt_5000_lat.txt" w]
close $fp
set fp [ open "./data/out/test_final_opt_5000_lat.txt" a]
#puts "file"
#set node_att [list_attributes node]
#set edge_att [list_attributes edge]
#set lib_fu_att [list_attributes lib_fu]
#puts "$node_att"
#puts "$edge_att"
#puts "$lib_fu_att"
#set dfg_late {}
set i 0
for {set i 22} { $i <  5002 } { incr i } {
set start [ clock microseconds ]
set latency_schedule [ brave_opt -lambda $i ]
set stop [ clock microseconds ]
set tot_time [ expr { $stop - $start } ] 
puts "Optimization succesfully completed with latency imposed at: $i !"
puts $fp "Optimization succesfully completed with latency imposed at: $i !" 
puts "Total time of the execution : $tot_time us"
puts $fp "Total time of the execution : $tot_time us"
set old_lat [ lindex $latency_schedule 0 ]
set new_lat [ lindex $latency_schedule 1 ]
set power_gain [ lindex $latency_schedule 2 ]
set area_gain [ lindex $latency_schedule 3 ]
puts "The configuration started with $old_lat and was optimized to a new latency of $new_lat."
puts $fp "The configuration started with $old_lat and was optimized to a new latency of $new_lat."
puts "This configuration produced an optimization of $area_gain % of the area and $power_gain % of the power from the first schedule. "
puts $fp "This configuration produced an optimization of $area_gain % of the area and $power_gain % of the power from the first schedule. "
}
close $fp
#print_dfg ./data/out/fir.dot
#print_scheduled_dfg $latency_schedule ./data/out/fir_latency.dot
















