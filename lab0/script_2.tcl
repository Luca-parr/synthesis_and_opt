set a 1
set b -2
set c -15
set delta [expr $b * $b - 4 * $a * $c]
if { $delta > 0 } {
	set x1 [expr sqrt( $delta )]
	set x2 [expr 0 - sqrt( $delta )]
	set x1 [expr ($x1 - $b) / ( 2 * $a)]
	set x2 [expr ($x2 - $b) / (2 * $a)]
	puts "sol_1: $x1"
	puts "sol_2: $x2"
} else {
	puts "no real solutions"
}
