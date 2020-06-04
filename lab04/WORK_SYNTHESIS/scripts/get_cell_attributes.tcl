proc cmd_get_cell_attributes {par1} {
set cell_list_name
set cell_list_ref {}   
set cell_list_area {}   
set cell_list_leakage {}
set cell_list_dynamic {}                                                                      

set tot_power 0 


set cell_list_name [get_attribute $point_cell full_name]
set cell_list_ref [get_attribute $point_cell ref_name]
set cell_list_area [get_attribute $point_cell area]
set cell_list_leakage [get_attribute $point_cell gate_leakage_power ]
set cell_list_dynamic [get_attribute $point_cell dynamic_power  ]

set tot_power [expr { $cell_list_leakage + $cell_list_dynamic } ]

}
lsort -real -index 1 $names_leak
puts "final $cell_list_name"
puts "final $cell_list_ref"
puts "final $cell_list_area"
puts "final $cell_list_leakage"
puts "final $cell_list_dynamic"
puts "final $names_leak"
puts "final $chip_area"
puts "final $chip_leakage"
puts "final $chip_dynamic"
}
