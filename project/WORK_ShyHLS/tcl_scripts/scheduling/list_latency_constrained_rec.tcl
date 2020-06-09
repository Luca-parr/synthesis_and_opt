
proc list_latency { latency } {
puts "start"
 set node_sorted [get_sorted_nodes]
 set node_list [ lreverse $node_sorted ]
 set node_slack {}
 set resources {}
 set time_res {}
 set t 0
 set rec 0
 set type_res {}
 set one_type_res {}
 set node_start_time [list]
 set l 1
 set lib_fus [get_lib_fus]
#acquire all information from library
 foreach lib_fu $lib_fus {
	 set operation [ get_attribute $lib_fu operation ]
	 set delay [ get_attribute $lib_fu delay ]
	 set id_res [ get_attribute $lib_fu id ]
	 set area_res [ get_attribute $lib_fu area ]
	 set power_res [ get_attribute $lib_fu power ]
	 lappend type_res " $operation 0 $id_res $area_res $power_res $delay "
 }
 set type_res [ lsort -real -index 5 $type_res ]
puts "test_1 all resources"
#puts "$type_res"
#puts "$lib_fus"
###sort resources by delay

 foreach operation $type_res {
	 set op [ lindex $operation 0 ]
	 set index [ lsearch -index 0 $one_type_res $op ]
	 if { $index  < 0} {
		 lappend one_type_res $operation
	 }
 }
########################################

puts "test_2 one type resources"

#alap
###############################

 set node_start_time_alap [list]
 foreach node $node_list {
         set start_time  $latency
         set node_op [ get_attribute $node operation ]
	 set fu [ lindex [ lindex $one_type_res [ lsearch -index 0 $one_type_res $node_op ] ] 2 ]
	 set node_delay [ get_attribute $fu delay ]   
         foreach children [ get_attribute $node children ] {
                 set idx_children_start [ lsearch -index 0 $node_start_time_alap $children ]
                 set children_start_time [ lindex [ lindex $node_start_time_alap $idx_children_start ]  1 ]
                 set node_time [ expr $children_start_time - $node_delay ]
                 if { $node_time < $start_time } {
                         set start_time $node_time
                 }
          }
	 if { [ llength [ get_attribute $node children ] ] == 0 } {
		  set start_time [ expr { $start_time - $node_delay } ]
	 }
                 lappend node_start_time_alap " $node $start_time "
}
 set node_alap [  lsort -real -index 1 $node_start_time_alap  ]
puts "test_2 alap"
puts "$node_alap"
##################################

 while { [llength $node_start_time] < [ llength $node_alap ] } {
set rec 0
puts "esce_ciclo"
while { $rec == 0 } {
 foreach operation $one_type_res {
	 set num_candidate [ lindex $operation 1 ]
	 set type [ lindex $operation 0 ]

	 foreach scheduled $node_start_time {
		 set start [ lindex $scheduled 1 ]
		 set node [ lindex $scheduled 0 ]
		 set node_delay [ lindex [ lindex $one_type_res [ lsearch -index 0 $one_type_res $type ] ] 5 ]
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
	 set uncompleted [ expr { [ lindex $operation 1 ] - $num_candidate } ]
#numcandidate=ar-T
#puts "test_3"
#puts "$type"
	 foreach node_al $node_alap {
	 set node [ lindex $node_al 0 ]
		 if { [ get_attribute $node operation ] eq $type } {
#set opera [ get_attribute $node operation ]
#puts "$node $opera  $type"
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
               				 set node_delay_parent [ lindex [ lindex $one_type_res [ lsearch -index 0 $one_type_res $type_parent ] ] 5 ]
#puts "$node_al"
#puts "$t"  


	 				 set t [ expr { $l - $start_parent - $node_delay_parent } ]
					 if { $t < 0 } {
						 set flag 1
#puts "parenti:$parent $t"
                          		 }
				 } else {
		 			 set flag 1
#puts "test_3.3"
				 }
				 }
			 }
			 if { $flag == 0 } {
				 set slack [ expr { [ lindex $node_al 1 ] - $l } ]
				 if { $slack < 0 } {
				 	return -code error " latency not valid. too low!"
				 }
			 	 lappend node_slack "$node $slack"
			 }
	 	}
	 }
#puts "test_4"
	 set new_y 0
	 set a_new [ lindex $operation 1 ]
	 set node_slack [ lsort -real -index 1 $node_slack ]
#puts "$node_slack"
	 foreach node $node_slack {
		 set node_s [ lindex $node 0 ]
		 if { [ lindex $node 1 ] == 0 } {
			 set new_y [ expr { $new_y + 1 } ] 
			 if { $a_new < [ expr { $uncompleted + $new_y } ] } {
				 set a_new [ expr { $uncompleted + $new_y } ]
puts "a_new_updated:$a_new"
set rec 1
			 }
#############################################################
#puts "slack_0:$node un:$uncompleted new_y:$new_y time:$l"
set op [ get_attribute $node operation ]
set index [ lsearch -index 0 $one_type_res $op ]
set del [ lindex [ lindex $one_type_res $index ] 5 ]
lappend  node_start_time " $node_s $l $del"
###########################################################
#			 lappend node_start_time " $node_s $l "
		 } else {
			if { $a_new > [ expr { $new_y + $uncompleted } ] } {
#############################################################
#puts "slack_pos:$node  un:$uncompleted new_y:$new_y time:$l"  
set op [ get_attribute $node operation ] 
set index [ lsearch -index 0 $one_type_res $op ]
set del [ lindex [ lindex $one_type_res $index ] 5 ]
lappend  node_start_time " $node_s $l $del" 
#			 lappend node_start_time " $node_s $l "
			 set new_y [ expr { $new_y + 1 } ]
			}
		 }
 	}
		 set index [ lsearch $one_type_res $operation ]
#puts "a_new $a_new"
#puts "index=$index"
		 set node_tmp  [ lindex $one_type_res $index ]
		 set node_tmp [ lreplace $node_tmp 1 1 $a_new ]
		 set one_type_res [ lreplace $one_type_res $index $index $node_tmp ]
#set node  [ lindex $one_type_res $index ]
#puts "node: $node"
 set node_slack {}
#puts "test_5"  
 }
 set l [ expr { $l +1 } ]
 if { $rec== 1 } {
         set node_start_time {}
	 set l 1
puts "out"
         break
 }
 if { [llength $node_start_time] == [ llength $node_alap ] } {
         set rec 1
 }
 }
 }

 foreach operation $type_res {
         set id_node [lindex $operation 2 ]
         set index [ lsearch -index 2 $one_type_res $id_node ]
         if { $index  >= 0} {
                 set node_tmp  [ lindex $one_type_res $index ]
                 set index_type_res  [ lsearch $type_res $operation ]
                 set type_res [ lreplace $type_res  $index_type_res  $index_type_res $node_tmp ]
         }
 }
#puts "$one_type_res"
 puts "************************************************************************"
 puts "$type_res"
 puts "$node_alap"
 return $node_start_time
}

