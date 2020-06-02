##	+----------------------------------------------------------------
##	|		 Synthesis and Optimization of Digital Circuits			|
##	|				Politecnico di Torino - TO - Italy				|
##	|						DAUIN - EDA GROUP						|
##	+----------------------------------------------------------------
##	|	author: andrea calimera										|
##	|	mail:	andrea.calimera@polito.it							|
##	|	title:	pt_analysis.tcl										|
##	+----------------------------------------------------------------
##	| 	Copyright 2015 DAUIN - EDA GROUP							|
##	+----------------------------------------------------------------

######################################################################
##
## SPECIFY LIBRARIES
##
######################################################################

# SOURCE SETUP FILE
source "./tech/STcmos65/synopsys_pt.setup"

# SUPPRESS WARNING MESSAGES
suppress_message RC-004
suppress_message PTE-003
suppress_message UID-401
suppress_message ENV-003
suppress_message UITE-489
suppress_message CMD-041

set blockName "aes_cipher_top"
set report_default_significant_digits 6
set power_enable_analysis true

# DEFINE INPUT FILES
set dir "./saved/${blockName}/synthesis"
set in_verilog_filename "${dir}/${blockName}_postsyn.v"
set in_sdc_filename "${dir}/${blockName}_postsyn.sdc"
read_verilog $in_verilog_filename
read_sdc -version 1.3 $in_sdc_filename
######################################################
set cell_list_name {}
set cell_list_ref {}
set cell_list_area {}
set cell_list_leakage {}
set cell_list_dynamic {}
set chip_leakage 0
set chip_area 0
set chip_dynamic 0
foreach_in_collection point_cell [get_cells] {
lappend cell_list_name [get_attribute $point_cell full_name]
lappend cell_list_ref [get_attribute $point_cell ref_name]
lappend cell_list_area [get_attribute $point_cell area]
lappend cell_list_leakage [get_attribute $point_cell gate_leakage_power ]
lappend cell_list_dynamic [get_attribute $point_cell dynamic_power  ]
set name [get_attribute $point_cell full_name]
set leak [get_attribute $point_cell gate_leakage_power ]
lappend names_leak "$name $leak"
set chip_area [expr { $chip_area + [get_attribute $point_cell area] }]
set chip_leakage [expr { $chip_leakage + [get_attribute $point_cell  gate_leakage_power ] } ]
set chip_dynamic [expr { $chip_dynamic + [get_attribute $point_cell  dynamic_power ] } ]
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
#report_power

