source ./tcl_scripts/setenv.tcl
#source ./tcl_scripts/scheduling/list_latency_constrained.tcl
#source ./tcl_scripts/scheduling/list_latency_constrained_rec.tcl   
#source ./tcl_scripts/scheduling/list_latency_optimization.tcl
source ./tcl_scripts/scheduling/list_latency_optimization_2.tcl  
read_design ./data/DFGs/fir.dot
read_library ./data/RTL_libraries/RTL_lib_1.txt

#set node_att [list_attributes node]
#set edge_att [list_attributes edge]
#set lib_fu_att [list_attributes lib_fu]
#puts "$node_att"
#puts "$edge_att"
#puts "$lib_fu_att"
#set dfg_late {}
set start [ clock microseconds ]
set latency_schedule [ brave_opt -lambda 1250 ]
set stop [ clock microseconds ]

set node_start_time [ lindex $latency_schedule 0 ]
set node_fu [ lindex $latency_schedule 1 ]
set fu_numb [ lindex $latency_schedule 2 ]

foreach pair $node_start_time {
	set node_id [lindex $pair 0]
	set start_time [lindex $pair 1]
	puts "node $node_id starts @$start_time"
#lappend dfg_late "$node_id $start_time"
}
foreach pair $node_fu {
	set node_id [lindex $pair 0]
	set fu [lindex $pair 1]
	puts "node $node_id with fu $fu"
}
foreach pair $fu_numb {
	set fu [lindex $pair 0]
	set num [ lindex $pair 1]
	puts " $num fu $fu used"
}
set tot_time [ expr { $stop - $start } ]
puts " tot_time : $tot_time "  
print_dfg ./data/out/fir.dot
print_scheduled_dfg $latency_schedule ./data/out/fir_latency.dot
















