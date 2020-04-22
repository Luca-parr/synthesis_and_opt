set fiD [open "./WORK_SYNTHESIS/tech/STcmos65/CORE65LPSVT_bc_1.30V_m40C.lib" r]
set cellreflist { "HS65_LS_IVX2" "HS65_LS_NAND2X2" "HS65_LS_NOR3X2" }
set pin_list [list]
set capacitance_list [list]
set state "cell"
set c_flag 1

while { $c_flag == 1 } {

if { [ gets $fiD line ] >= 0 } {
	set c_flag 1
} else {
	set c_flag 0
}

if { $state == "cell" } {
	set res [ regexp {\s*cell\(([A-Z0-9_]+)\)} $line matchvar cellname ]
	if { $res == 1 } {
	if { [ lsearch $cellreflist $cellname ] > -1 } {
	append pin_list $cellname
	set state "pin"
	}
	}
}
if { $state == "pin" } {
        set res [ regexp {\s*pin\(([A-Z0-9_]+)\)} $line matchvar pin ]
        if { $res == 1 } {
	if { $pin == "Z" } {
        set state "cell"
	} else {
        set state "capacitance"
	}
	}
}
if { $state == "capacitance" } {
	set res [ regexp {\s*capacitance\s:\s([0-9.]+)\;} $line matchvar capacitance ]
        if { $res == 1 } {
        append capacitance_list $capacitance
	set state "pin"
	}
}
}
puts $pin_list
puts $capacitance_list
