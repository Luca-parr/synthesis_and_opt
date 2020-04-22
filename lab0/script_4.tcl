set seasons "winter"
lappend seasons "spring" "summer" "autumn"
foreach i $seasons {
	puts "season= $i"
}
set i [ lsearch $seasons "spring" ]
puts $i
