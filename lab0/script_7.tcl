set positive "pit" 
set negative "pt"
lappend negative "Pot" "peat" "part"
lappend positive "spot" "spate" "slap two" "respite"
set var [ regexp {^[rs]|pit} $positive ]
puts $var
set var [ regexp {^[rs]|pit} $negative ]
puts $var

set positive "can"
set negative "dan"
lappend negative "man" "fan"
lappend positive "ran" "pan"
set var [ regexp {^[cam]an} $positive ]
puts $var
set var [ regexp {^[cam]an} $negative ]
puts $var

set positive "aaaabcc"
set negative "a"
lappend positive "aabbbbc" "aacc"
set var [ regexp {^[a]+[abc]} $positive ]
puts $var
set var [ regexp {^[a]+[abc]} $negative ]
puts $var

set positive "1. abc"
set negative "4.abc"
lappend positive "2.  abc" "3.   abc"
lappend positive " abc" "5 abc"
set var [ regexp {^[12345]\. abc} $positive ]
puts $var
set var [ regexp {^[12345]\. abc]} $negative ]
puts $var
