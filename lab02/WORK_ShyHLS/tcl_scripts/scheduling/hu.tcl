proc hu_schedule { a } {
 set label [list]
 set node_start_time [list]
 foreach node [ lreverse [get_sorted_nodes] ] {
 if { llength [ get_attribute $node n_children ] == 0 }
 {
 set l 1
 } else {
 set max_label 1
 foreach child [ get_attribute $node children ] {
 set indice [ lsearch -index 0 $node $child ]
 set label_temp [ lindex [ lindex $list_label $indice ] 1 ]
 if { $label_tmp > $max_label } {
   set max_label $label_tmp
  }
 }
 set l [expr {$max_label + 1}]
 }
 lappend list_label "$node $l"
 }
 set list_label [lsort -integer -index 1 $list_label]
 set a 1
 set tmp_scheduling 1
 set hw_util 0
 foreach node [ lreverse $list_label ] {
 incr hw_util
 lappend node_start_time " [lindex $node 0] $tmp_scheduling "
 if { $hw_util == $a } {
   incr tmp_scheduling
   set hw_util 0
  }
 }
 return $node_start_time
}
