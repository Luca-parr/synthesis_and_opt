source ./tcl_scripts/setenv.tcl
source ./tcl_scripts/scheduling/alap.tcl

read_design ./data/DFGs/fir.dot
read_library ./data/RTL_libraries/RTL_lib_1.txt

set alap_schedule [alap 20]
foreach pair $alap_schedule {
set node_id [lindex $pair 0]
set start_time [lindex $pair 1]
puts "node $node_id starts @$start_time"

}
print_dfg ./data/out/fir_1.dot
print_scheduled_dfg $alap_schedule ./data/out/fir_alap.dot
















