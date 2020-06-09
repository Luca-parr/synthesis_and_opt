source ./tcl_scripts/setenv.tcl
#source ./tcl_scripts/scheduling/list_latency_constrained.tcl
source ./tcl_scripts/scheduling/list_latency_constrained_rec.tcl   
read_design ./data/DFGs/fir.dot
read_library ./data/RTL_libraries/RTL_lib_1.txt

#set node_att [list_attributes node]
#set edge_att [list_attributes edge]
#set lib_fu_att [list_attributes lib_fu]
#puts "$node_att"
#puts "$edge_att"
#puts "$lib_fu_att"
set dfg_late {}
set latency_schedule [list_latency 32]
foreach pair $latency_schedule {
set node_id [lindex $pair 0]
set node_op [ get_attribute $node_id operation ]
set node_delay [ lindex $pair 2 ]
set start_time [lindex $pair 1]
puts "node $node_id doing $node_op with delay $node_delay starts @$start_time"
lappend dfg_late "$node_id $start_time"
}
print_dfg ./data/out/fir.dot
print_scheduled_dfg $dfg_late ./data/out/fir_latency.dot
















