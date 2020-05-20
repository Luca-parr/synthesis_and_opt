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

# DEFINE OPTIONS
set report_default_significant_digits 6
set power_enable_analysis true

# SUPPRESS WARNING MESSAGES
suppress_message RC-004
suppress_message PTE-003
suppress_message UID-401
suppress_message ENV-003
suppress_message UITE-489
suppress_message CMD-041
######################################################################
##
## READ DESIGN
##
######################################################################
# DEFINE CIRCUITS
set blockName "aes_cipher_top"

# DEFINE INPUT FILES
set dir "./saved/${blockName}/synthesis"
set in_verilog_filename "${dir}/${blockName}_postsyn.v"
set in_sdc_filename "${dir}/${blockName}_postsyn.sdc"

# READ
read_verilog $in_verilog_filename
read_sdc -version 1.3 $in_sdc_filename


update_timing -full

######################################################################
##
## TIMING ANALYSIS
##
######################################################################
# SETUP TIME
report_timing -delay_type max

# SLACK CONDITION
report_timing -delay_type min -slack_lesser_than 0.1 -max_paths 2
report_timing -delay_type max -slack_lesser_than 0.0 -max_paths 2

######################################################################
##
## POWER ANALYSIS
##
######################################################################

report_power

######################################################################
##
## WRITE REPORTS
##
######################################################################

# SET REPORT FILE NAME
foreach_in_collection point_cell [get_cells] {
set cell_name [get_attribute $point_cell full_name]
set cell_type [get_attribute $point_cell is_combinational]
if { $cell_type == true } {
puts "$cell_name is combinational"
} else {
puts "$cell_name is not combinational"
}
}

######################################################################
##
## EXIT
##
######################################################################

#exit
