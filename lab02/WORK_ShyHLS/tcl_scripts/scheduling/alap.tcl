proc alap { latency } {

 set node_start_time [list]
 set node_sorted [get_sorted_nodes]
 set node_list [ lreverse $node_sorted ]
 foreach node $node_list {
 set start_time $latency
 foreach children [ get_attribute $node children ] {
 set node_op [ get_attribute $node operation ]
 set fu [ get_lib_fu_from_op $node_op ]
 set node_delay [ get_attribute $fu delay ]
 set idx_children_start [ lsearch -index 0 $node_start_time $children ]
 set children_start_time [ lindex [ lindex $node_start_time $idx_children_start ]  1 ]
 set node_time [ expr $children_start_time - $node_delay ]
 if { $node_time < $start_time } {
 set start_time $node_time
   }
  }
 lappend node_start_time " $node $start_time "
}
 set node_final [ lreverse $node_start_time ]
 return $node_final
}
