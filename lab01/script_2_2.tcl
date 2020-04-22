set fiD [open "./WORK_SYNTHESIS/tech/STcmos65/CORE65LPSVT_bc_1.30V_m40C.lib" r]
set cellreflist { "HS65_LS_IVX2" "HS65_LS_IVX213" "HS65_LS_NAND2AX14" }
set pin_list [list]
set tech_list { "area" "cell_leakage_power" "fall_transition" "rise_transition" }
set state "cell"
set tech "fall_transition"
set c_flag 1
set value_list [list]
set value 0

while { $c_flag == 1 } {

if { [ gets $fiD line ] >= 0 } {
        set c_flag 1
} else {
        set c_flag 0
}

switch  $state	{
	"cell" {
        set res [ regexp {\s*cell\(([A-Z0-9_]+)\)} $line matchvar cellname ]
        if { $res == 1 } {
        if { [ lsearch $cellreflist $cellname ] > -1 } {
        lappend pin_list $cellname
        set state $tech
        }
        }
	}
	"area"  {
        set res [ regexp {\s*area : ([0-9.]+)\;} $line matchvar value ]
        if { $res == 1 } {
        set state "cell"
	lappend value_list $value
	}
	}
	"cell_leakage_power"  {
	set res [ regexp {\s*cell_leakage_power : ([0-9e-.]+)\;} $line matchvar value ]
	if { $res == 1 } {
        set state "cell"
	lappend value_list $value
        }
	}

	"fall_transition"  {

	set res [ regexp {\s*cell\(([A-Z0-9_]+)\)} $line matchvar cellname ]
        if { $res == 1 } {
	lappend value_list $value
	set value 0
        if { [ lsearch $cellreflist $cellname ] > -1 } {
        lappend pin_list $cellname
        set state $tech
	} else { 
	set state "cell"
	}
	}


       set res [ regexp {\s*fall_transition\(table_[0-9]+\)} $line matchvar cellname ]
       if { $res == 1 } {
	set i "6"
	while { $i > 0 } {
	gets $fiD line
	set i [ expr { $i - 1 } ]
        }
#	puts $line
	split $line ","
	set res [ regexp {\s*([0-9.]+)\"\)\;} $line matchvar new_value ]
#	puts $new_value
	if { $new_value > $value } {
	set value $new_value
	}
	}
	}
	"rise_transition"  {

        set res [ regexp {\s*cell\(([A-Z0-9_]+)\)} $line matchvar cellname ]
        if { $res == 1 } {
        lappend value_list $value
        set value 0
        if { [ lsearch $cellreflist $cellname ] > -1 } {
        append pin_list $cellname
        set state $tech
        } else {
        set state "cell"
        }
	}


       set res [ regexp {\s*rise_transition\(table_[0-9]+\)} $line matchvar cellname ]
       if { $res == 1 } {
	set i "6"
        while { $i > 0 } {
        gets $fiD line
        set i [ expr { $i - 1 } ]
        }
#        puts $line
        split $line ","
	set res [ regexp {\s*([0-9.]+)\"\)\;} $line matchvar new_value ]
#        puts $new_value
        if { $new_value > $value } {
        set value $new_value
        }
	}
	}
}
}
puts $pin_list
puts $tech
puts $value_list





