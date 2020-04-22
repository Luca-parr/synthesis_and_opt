source ./tcl_scripts/setenv.tcl
source ./tcl_scripts/scheduling/list_area_constrained.tcl

read_design ./data/DFGs/fir.dot
read_library ./data/RTL_libraries/RTL_lib_1.txt


set res_info " {ADD 1} {MUL 1} {LOD 3} {STR 1}"
set lib_fus [ get_lib_fus ]
foreach lib_fu $lib_fus {
 set operation [ get_attribute $lib_fu operation ]
 set delay [ get_attribute $lib_fu delay ]
 lappend time_res " $operation $delay "
}
puts $res_info
set nodes [ get_sorted_nodes ]
foreach node $nodes {
set operations [get_attribute $node operation ]
set delays [ lindex [ lindex $time_res [ lsearch -index 0 $time_res $operations ] ] 1 ]
puts "$node does $operations with delay $delays"
}

set list_schedule [list_area $res_info]
foreach pair $list_schedule {
set node_id [lindex $pair 0]
set start_time [lindex $pair 1]
puts " Node: $node_id starts $start_time "
}

print_dfg ./data/out/fir.dot
print_scheduled_dfg $list_schedule ./data/out/fir_list_area.dot


