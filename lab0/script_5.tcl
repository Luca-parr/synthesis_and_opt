set j 0
set paragraph "write a tcl script that declares"
set list1 [ split $paragraph " " ]
foreach i $list1 {
	set j [ expr { $j +1 } ]
}
puts " numbers of words:  $j "
