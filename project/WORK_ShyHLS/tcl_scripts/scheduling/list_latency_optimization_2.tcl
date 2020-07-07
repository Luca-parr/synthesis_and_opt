
proc brave_opt args {
###################braveopt
 array set options { -lambda 0 }
 if { [llength $args] != 2 } {
 	return -code error "use brave_opt with -lambda \$ latency_value \$"
 }
 foreach { opt val } $args { 
	if { ![info exist options($opt)] } {
		 return -code error " unknown options \"$opt\""
	}
	set options($opt) $val
 }
 set latency $options(-lambda)
###########################
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
 set node_start_res {}
 set lib_fus [get_lib_fus]
#acquire all information from library
 foreach lib_fu $lib_fus {
	 set operation [ get_attribute $lib_fu operation ]
	 set delay [ get_attribute $lib_fu delay ]
	 set id_res [ get_attribute $lib_fu id ]
	 set area_res [ get_attribute $lib_fu area ]
	 set power_res [ get_attribute $lib_fu power ]
	 lappend type_res " $operation 1 $id_res $area_res $power_res $delay "
 }
 set type_res [ lsort -real -index 5 $type_res ]

###sort resources by delay
#create list of fastest operations per type
 foreach operation $type_res {
	 set op [ lindex $operation 0 ]
	 set index [ lsearch -index 0 $one_type_res $op ]
         if { $index  < 0} {
                 lappend one_type_res $operation
         }
 }
########################################


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

##################################
#list scheduling
 while { [llength $node_start_time] < [ llength $node_alap ] } {
 set rec 0
 while { $rec == 0 } {
 foreach operation $one_type_res {
	 set num_candidate [ lindex $operation 1 ]
	 set type [ lindex $operation 0 ]
#check still running operations
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
	 foreach node_al $node_alap {
	 set node [ lindex $node_al 0 ]
		 if { [ get_attribute $node operation ] eq $type } {
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
				 set slack [ expr { [ lindex $node_al 1 ] - $l } ]
				 if { $slack < 0 } {
				 	return -code error " latency not valid. too low!"
				 }
			 	 lappend node_slack "$node $slack"
			 }
	 	}
	 }
	 set new_y 0
	 set a_new [ lindex $operation 1 ]
	 set node_slack [ lsort -real -index 1 $node_slack ]
	 foreach node $node_slack {
		 set node_s [ lindex $node 0 ]
		 if { [ lindex $node 1 ] == 0 } {
			 set new_y [ expr { $new_y + 1 } ] 
			 if { $a_new < [ expr { $uncompleted + $new_y } ] && $rec == 0 } {
#if the resources are not sufficient add one and start again
				 set a_new [ expr { $uncompleted + $new_y } ]
				 set rec 1
			 }
			 lappend node_start_time " $node_s $l "
		 } else {
			if { $a_new > [ expr { $new_y + $uncompleted } ] } { 
			 lappend node_start_time " $node_s $l "
			 set new_y [ expr { $new_y + 1 } ]
			}
		 }
 	}
		 set index [ lsearch $one_type_res $operation ]
		 set node_tmp  [ lindex $one_type_res $index ]
		 set node_tmp [ lreplace $node_tmp 1 1 $a_new ]
		 set one_type_res [ lreplace $one_type_res $index $index $node_tmp ]
 set node_slack {}  
 }
 set l [ expr { $l +1 } ]
 if { $rec== 1 } {
         set node_start_time {}
	 set l 1
#start again
         break
 }
 if { [llength $node_start_time] == [ llength $node_alap ] } {
         set rec 1
 }
 }
 }
#end scheduling
#update type_res with resources
 foreach operation $type_res {
         set id_node [lindex $operation 2 ]
         set index [ lsearch -index 2 $one_type_res $id_node ]
         if { $index  >= 0} {
                 set node_tmp  [ lindex $one_type_res $index ]
                 set index_type_res  [ lsearch $type_res $operation ]
                 set type_res [ lreplace $type_res  $index_type_res  $index_type_res $node_tmp ]
         }
 }
#create node_start_res
 foreach node_start $node_start_time {
	 set node [ lindex $node_start 0]
	 set operation [ get_attribute $node operation ]
	 set resource [ lindex [ lindex $one_type_res [ lsearch -index 0 $one_type_res $operation ] ] 2 ]
	 lappend node_start_res " $node_start $resource "
 }
#puts operations not present to 0
 foreach operation $type_res {
 	 if { [ lsearch -index 2 $node_start_res [ lindex $operation 2 ] ] < 0 } {
                 set index [ lsearch $type_res $operation ]
		 set operation [ lreplace $operation 1 1 0 ]
		 set type_res [ lreplace $type_res $index $index $operation ]
	 }

 }
 set node_start_temp $node_start_res
 set node_start_original $node_start_res
 set t_last [ lindex [ lindex $node_start_time [expr { [ llength $node_start_time ] - 1 } ] ] 1 ]
 set type_res_original $type_res
 set area_old 0
 set power_old 0
 foreach res $type_res {
 	set mul [ expr { [ lindex $res 3 ] * [ lindex $res 1 ] } ]
	set area_old [ expr { $mul + $area_old } ]
 }
 foreach res $node_start_temp {
	set index [ lsearch -index 2 $type_res [ lindex $res 2 ] ]
 	set power_old [ expr { $power_old + [ lindex [ lindex $type_res $index ] 4 ] * [ lindex [ lindex $type_res $index ] 5 ] } ]
 }
#create area old and power old with fastest resources
set power_old [ expr { $power_old / ( $latency + 0.0000 ) } ]
 set flag_sub 0
 set flag 0
 set area_new 0
 set power_new 0
 set flag_critical 0
 set index_last -1
 set node_modified {}
 set res_to_sub_list {}
 set index_res_to_sub_list 0
 set list_op {}
 set list_op_count -1
 set res_to_sub {}
 set res_to_sub_temp {}
 set op_critical {}
 set index_res_to_sub 1
 set index_to_replace -1
 set index_res_op_to_opt 1
#start optimization
#create list_op and res_to_sub
#puts "node_start_time: $node_start_time"

 foreach operation $one_type_res {
	 set ind [ lsearch -index 0 $type_res [ lindex $operation 0] ]
	 if { [ lindex [ lindex $type_res $ind] 1 ] == 0 } {
		 set flag 1
	 }
	 if { $flag == 0 } {
	 	 foreach res $type_res {
			if { [ lindex $res 0 ] == [ lindex $operation 0 ] } {
			 	 lappend list_op_to_opt $res
			 }
		 }
	 if { [llength $list_op_to_opt ] > 0 } {
		 set op  [ lindex $operation 0 ]
		 lappend list_op "$op"
		 set num_res [ lindex $operation 1 ]
		 for {set i 0} { $i <  $num_res } { incr i } {
			 set op [lindex $list_op_to_opt 0]
			 lappend res_to_sub "$op 0"
			 lappend res_to_sub_temp "$op 0"
		 }

		 }
	 }
	  set flag 0
	  set list_op_to_opt {}
 }
#add first configuration to res_to_sub_list
#puts "res_to_sub_start: $res_to_sub list_op_start: $list_op "
 lappend res_to_sub_list " $res_to_sub "
 while { [ llength $list_op ] > 0 } {
#start scheduling with new configuration 
 set t 1
 while { $t <= $latency } {
#create list with node and slack
	foreach operation $one_type_res {
		if { [ lsearch -index 0 $res_to_sub [ lindex $operation 0 ] ] >= 0 } {
 			foreach node $node_start_temp {
				 if { [ get_attribute [ lindex $node 0 ] operation ] == [ lindex $operation 0 ] } {
					if { [ lindex $node 1 ] == $t } {
					 set node_name [ lindex $node 0 ]
					 set time_node_al  [ lindex [ lindex $node_alap [ lsearch -index 0 $node_alap $node_name ] ] 1 ]
					 set slack [ expr { $time_node_al - $t } ]
					 lappend node_slack " $node_name $slack "
					}
				 }
			}
		}
	set node_slack [ lsort -integer -index 1 $node_slack ]
#foreach node with slack
	foreach node $node_slack {
	 	set start_res [ lsearch -index 0 $res_to_sub [ lindex $operation 0 ] ]
		set index 0
	 	 while { $index <  [ lindex $operation 1 ] } {
			set index_res [ expr { $start_res + $index } ]
			set res_check [ lindex $res_to_sub $index_res ]
			set index_node_start [ lsearch -index 0 $node_start_temp [ lindex $node 0 ] ] 
			set flag 0
			set node_to_replace [ lindex $node_start_temp $index_node_start ] 
				if { [ lindex $res_check 6 ] <= $t } {
#we consider if delay and slack are compatible when we assign a new fu
					set delta_delay [ expr { [ lindex $res_check  5 ] - [ lindex $operation 5] } ]

					if { $delta_delay <= [ lindex $node 1 ] } {
						set node_finish [ expr { [ lindex $node_to_replace 1 ] + [ lindex $res_check  5 ] } ]
						set res_check [ lreplace $res_check 6 6 $node_finish ]
						set res_to_sub [ lreplace $res_to_sub $index_res $index_res  $res_check ]

						if { ( [ lindex $res_check 2 ] != [ lindex $node_to_replace 2 ] ) } {
							set node_to_replace [ lreplace $node_to_replace 2 2  [ lindex $res_check 2 ] ]
							lappend node_modified " $node_to_replace $node_finish "
							set node_start_temp [ lreplace $node_start_temp $index_node_start $index_node_start $node_to_replace ]
						}
						set flag 1
						break
					}
				}

			incr index
		}
		if { $flag == 0 } {
#if not compatible and slack greater than zero we delay by 1 unit the start_time
			if { [ lindex $node 1 ] > 0 } {
				set node_to_replace [ lreplace $node_to_replace 1 1 [ expr { [ lindex $node_to_replace 1 ] + 1 } ] ]
				set node_finish [ expr { [ lindex $node_to_replace 1 ] + [ lindex $operation  5 ] } ]
				lappend node_modified " $node_to_replace $node_finish "
				set node_start_temp [ lreplace $node_start_temp $index_node_start $index_node_start $node_to_replace ]
			} else {
#otherwise we enter in critical mode
				set op_critical $operation
				set flag_critical 1
				break
			}
		}

	}
	set node_slack {}
	}
 	incr t
#increase cycle
	set end_time 0
	set node_modified [ lsort -real -index 3 $node_modified ]
if { [ llength $node_modified ] > 0 } {
#puts "node_m: $node_modified"
}
	if { $flag_critical == 0 } {
#if not critical we check the delay of the sons and we propagate it
		foreach node $node_start_temp {
			set node_name [ lindex $node 0 ]
			foreach parent [get_attribute $node_name parents] { 
				set index_par [ lsearch -index 0 $node_modified $parent ]
				if { $index_par > -1 } {
					set end_time_temp [ lindex [ lindex $node_modified $index_par ] 3 ]
					if { $end_time_temp > $end_time } {
						set end_time $end_time_temp
					}
				}

			}
			if { $end_time > [ lindex $node 1 ] } {
				set op [get_attribute $node_name operation]
				set delay_op [ lindex [ lindex $one_type_res [ lsearch -index 0 $one_type_res $op ] ] 5 ]
				set end_time_son [ expr { $delay_op + $end_time } ]
				set index [ lsearch $node_start_temp $node ]
				set node [ lreplace $node 1 1 $end_time ] 
				set node_start_temp [ lreplace $node_start_temp $index $index $node ]
				lappend node_modified " $node $end_time_son "

			}


		}

	} else {
		#critical
		break
	}
	set node_modified {}
#node_modified resetted
 }
 if {  $flag_critical == 1 } {
#critical mode
	set flag_critical 0
	set node_start_temp $node_start_original
	if { $index_res_to_sub_list == [ expr { [ llength $res_to_sub_list ] - 2 } ] && $index_res_to_sub_list >= 0  } {
#if index to res_to_sub_list is at max means is first time critical
		set index_start [ lsearch -index 0 $res_to_sub [ lindex $list_op $list_op_count ] ]  
		set index_last_cr [ expr { $index_start + [ lindex [ lindex $one_type_res [ lsearch -index 0 $one_type_res [ lindex $list_op $list_op_count ] ] ] 1 ] - 1 } ]
                set id_last_op [ lindex [ lindex $res_to_sub $index_last_cr ] 2 ]
		set index_last_op [ lsearch -index 2 $type_res $id_last_op ]
		incr index_last_op 1
#if it is a new resource that we are trying to substitute use it again
		if { $index_last_cr == $index_last } {
			incr index_last_op -1
		}
                set index_to_replace [ lsearch -start $index_last_op -index 0 $type_res [ lindex $list_op $list_op_count ] ] 
              	if { $index_to_replace < 0 } {
			set list_op [ lreplace $list_op $list_op_count $list_op_count ]
			set res_to_sub $res_to_sub_temp
			incr list_op_count -1
#if there are no more resources
                } else {
			set operation_to_replace [ lindex $type_res $index_to_replace ]
			set res_to_sub [ lindex $res_to_sub_list $index_res_to_sub_list ]
			set res_to_sub [ lreplace $res_to_sub $index_last_cr $index_last_cr $operation_to_replace ]
			incr index_res_to_sub_list -1
#if there are
		}
	} elseif { $index_res_to_sub_list < 0 } {
		set list_op [ lreplace $list_op $list_op_count $list_op_count ]
		incr list_op_count -1
#if not compatible even with previous resources use last configuration saved
		set res_to_sub $res_to_sub_temp
		set index_res_to_sub_list [ expr { [ llength $res_to_sub_list ] - 2 } ]
	} else {
                set res_to_sub [ lindex $res_to_sub_list $index_res_to_sub_list ]
		set res_to_sub [ lreplace $res_to_sub $index_last_cr $index_last_cr $operation_to_replace ]
		incr index_res_to_sub_list -1
#else keep searching for a configuration
	}
 } else {
#not critical
	 set area_new 0
	 set power_new 0
	 set flag_not_opt 0
#set flag and area values to 0
	 foreach res $res_to_sub {
		set area_new [ expr { $area_new + [ lindex $res 3 ] } ]
		set index [ lsearch $res_to_sub $res ]
                set res [ lreplace $res 6 6 0 ] 
                set res_to_sub [ lreplace $res_to_sub $index $index $res ]
	 }
#res_to_sub end time to zero
	 foreach res $type_res {
		 if { [ lsearch -index 0 $res_to_sub [ lindex $res 0 ] ] < 0 } {
			set mul [ expr { [ lindex $res 3 ] * [ lindex $res 1 ] } ]
	 	 	set area_new [ expr { $mul + $area_new } ]
		 }
	 }
	 set delta_area [ expr { $area_old - $area_new } ]
	 set gain_area [ expr { $delta_area * 100 / ( $area_old + 0.0000 ) }]
	 foreach res $node_start_temp {
		 set index [ lsearch -index 2 $type_res_original [ lindex $res 2 ] ]
		 set power_new [ expr { $power_new + [ lindex [ lindex $type_res_original $index ] 4 ] * [ lindex [ lindex $type_res_original $index ] 5 ] } ]
	 }
	 set power_new [ expr { $power_new / ( $latency +0.0000 ) } ]
	 set delta_power [ expr { $power_old - $power_new } ]
	 set gain_power [ expr { $delta_power * 100 / ( $power_old + 0.0000 ) } ]
#finding gain values for power and area
	 if { $gain_power < 0 && $gain_area < 0 } {
		set flag_not_opt 1
	 } elseif { $gain_power < 0 } {
		 if { [ expr { 0.00 - $gain_power } ] > $gain_area } {
			set flag_not_opt 1
		 }
	 } elseif { $gain_area < 0 } {
		 if { [ expr { 0.00 - $gain_area } ] > $gain_power } { 
                       set flag_not_opt 1
		 }
	 } elseif { $gain_area == 0 && $gain_power == 0 } {
		 set flag_not_opt 1
	 }
#evaluate if better configuration or not
	 if { $flag_not_opt > 0 } {
#remove functional unit
		 set res_to_sub $res_to_sub_temp
		 set node_start_temp $node_start_original
		 if { $index_to_replace != -1 } {
			 set type_res [ lreplace $type_res $index_to_replace $index_to_replace ]
		}

	 } else {
#save the configuration
		 set res_to_sub_temp $res_to_sub 
		 lappend res_to_sub_list "$res_to_sub_temp"
#puts "node_start_temp_ok: $node_start_temp"
		 set node_start_res $node_start_temp
                 set node_start_temp $node_start_original  
		 set area_old $area_new
		 set power_old $power_new
	 }
         set index_res_to_sub_list [ expr { [ llength $res_to_sub_list ] - 2 } ]
#next operation to optimize
	 set list_op_count [ expr  { $list_op_count + 1 } ]
	 if { $list_op_count >= [ llength $list_op ] } {
		set list_op_count 0
	 }  
	 set operation [ lindex $list_op $list_op_count ] 
	 set index_start [ lsearch -index 0 $res_to_sub [ lindex $operation 0 ] ]
#puts "list_op: $list_op res_to_sub: $res_to_sub index_start: $index_start operatiom: $operation"
	 set index_last [ expr { $index_start + [ lindex [ lindex $one_type_res [ lsearch -index 0 $one_type_res [ lindex $operation 0] ] ] 1 ] - 1 } ]
#we need to find the correct position of last slowest resource
#we compare id of the next operations to see if they match 
#if they don't change the fu in that position
	 set i 0
	 while { $flag_sub == 0 } {
		if { $index_last == 0 } {
			set flag_sub 1
		} else {
			incr i -1
			if { [ lindex [ lindex $res_to_sub [ expr { $index_last + $i } ] ] 0 ] == [ lindex [ lindex $res_to_sub [ expr { $index_last + $i + 1 } ] ] 0 ]  } {
				if { [ lindex [ lindex $res_to_sub [ expr { $index_last + $i } ] ] 2 ] !=  [ lindex [ lindex $res_to_sub [ expr { $index_last + $i + 1 } ] ] 2 ] } {
					set index_last [ expr { $index_last + $i } ]
					set flag_sub 1
				}
		 	} else {
			 set flag_sub 1
			}
		}

	 }
	 set flag_sub 0
	 set index_last_op [ lsearch -index 2 $type_res [ lindex [ lindex $res_to_sub $index_last ] 2 ] ]
	 set index_last_op [ expr { $index_last_op + 1 } ]
	 set index [ lsearch -index 0 $list_op [ lindex $operation 0 ] ] 
	 set index_to_replace [ lsearch -start $index_last_op -index 0 $type_res [ lindex $operation 0 ] ]
	 if { $index_to_replace < 0 } {
#if there are no more resources available we delete the operation
		set list_op [ lreplace $list_op $index $index ]
		set list_op_count [ expr { $list_op_count - 1 } ]
	 } else {
#else we continue
		set operation_to_replace [ lindex $type_res $index_to_replace ]
		set res_to_sub [ lreplace $res_to_sub $index_last $index_last $operation_to_replace ]
	 }
 }
 }
#end of optimization
#create the lists necessary
#puts "node_start_res: $node_start_res"
 set node_start_time {}
 foreach node $node_start_res {
	 set start_time [ lindex $node 1 ]
	 set id_fu [ lindex $node 2 ]
 	 set id_node [ lindex $node 0 ]
 	 lappend node_start_time " $id_node $start_time "
	 lappend node_fu "$id_node $id_fu"
 }
 foreach node $type_res_original {
	 set operation [ lindex $node 0 ]
	 set id_fu [ lindex $node 2 ]
	 set op [ lsearch -index 0 $res_to_sub $operation ]
	 if { $op < 0 } {
		 set number [ lindex $node 1 ]
	 } else {
		 set index [ lsearch -all -index 2 $res_to_sub $id_fu ]
		 if { $index < 0 } {
			set number 0
		} else {
 		 set number [ llength $index ]
		}
 	}
	 lappend type_res_final " $id_fu $number "
 }
#puts "res_to_sub: $res_to_sub"
#puts "type_res_original: $type_res_original"
#puts "type_res: $type_res"
 return [list $node_start_time $node_fu $type_res_final]
}
