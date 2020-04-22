set var 1
lappend var 2 3 4 5 6 7 8 9 10
foreach i  $var {
	puts "value of var is: $var\t "
	puts "value of i is: $i\t "

}
foreach j { 1 2 3 4 5 6 7 8 9 10 } {
	if { $j == 5 } {
	set i $j
	}
	if { $j == 10 } {
	set i [ expr { $i + $j } ]
	}
}
puts "value of i is: $i\t "
lappend var $i
puts "value of var is: $var\t "
