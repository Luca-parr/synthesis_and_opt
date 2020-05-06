proc list_area { res_per_op } {
 set label [list]
 set node_start_time [list]
 set l 1
 set node_sorted [get_sorted_nodes]
 set node_list [ lreverse $node_sorted ]
 set lib_fus [get_lib_fus]
 foreach lib_fu $lib_fus {
 set operation [ get_attribute $lib_fu operation ]
 set delay [ get_attribute $lib_fu delay ]
 lappend time_res " $operation $delay "
 }
 while { [llength $node_start_time] < [ llength $node_sorted ] } {

 foreach operation $res_per_op {
	 set num_candidate [ lindex $operation 1 ]
	 set type [ lindex $operation 0 ]

	 foreach scheduled $node_start_time {
		 set start [ lindex $scheduled 1 ]
		 set node [ lindex $scheduled 0 ]
		 set node_delay [ lindex [ lindex $time_res [ lsearch -index 0 $time_res $type ] ] 1 ]
		 if { [ get_attribute $node operation ] eq $type } {
			 set t [ expr { $l - $start - $node_delay } ]
			 if { $t >= 0 } {
				 set t 0

 			 } else {
				 set t 1
			 }
		 set num_candidate [ expr { $num_candidate - $t } ]
		 }
	 }


 if { $num_candidate > 0 } {
 foreach node $node_sorted {
	 if { [ get_attribute $node operation ] eq $type && $num_candidate > 0 } {
		 set flag 0
	         if { [ lsearch -index 0 $node_start_time $node ] >= 0 } {
			 set flag 1
		 }
		 if { $flag == 0 } {
			 foreach parent [get_attribute $node parents] {
			 set indice [ lsearch -index 0 $node_start_time $parent ]
			 if { $indice >= 0 } {
	 	 		 set start_parent [ lindex [ lindex $node_start_time $indice ] 1 ]
               			 set node_parent [ lindex [ lindex $node_start_time $indice ]  0 ]
				 set type_parent [ get_attribute $node_parent operation ]
               			 set node_delay_parent [ lindex [ lindex $time_res [ lsearch -index 0 $time_res $type_parent ] ] 1 ]
	 			 set t [ expr { $l - $start_parent - $node_delay_parent } ]
				 if { $t < 0 } {
					 set flag 1
                          	 }
			 } else {
		 		 set flag 1
			 }
			 }
		 }
		 if { $flag == 0 } {
		 	 lappend node_start_time "$node $l"
			 set num_candidate [ expr { $num_candidate - 1 } ]
		 }
	 }

 }
 }
 }
 set l [ expr { $l +1 } ]
 }
 puts "************************************************************************"
 return $node_start_time
}

