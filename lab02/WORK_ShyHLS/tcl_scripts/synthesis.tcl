source ./tcl_scripts/setenv.tcl
source ./tcl_scripts/scheduling/asap.tcl

read_design ./data/DFGs/fir.dot
read_library ./data/RTL_libraries/RTL_lib_1.txt

set asap_schedule [asap]
foreach pair $asap_schedule {
set node_id [lindex $pair 0]
set start_time [lindex $pair 1]
puts "node $node_id starts @$start_time"

}
print_dfg ./data/out/fir.dot
print_scheduled_dfg $asap_schedule ./data/out/fir_asap.dot
