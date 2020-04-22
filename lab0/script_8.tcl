set positive "file_record.pdf"
lappend positive "doc_0724199.pdf" "file_test.jpg" "file_test.jpg" "file_template.pdf.tmp"
foreach i $positive {
set var [ regexp {^([a-z]+_[a-z0-9]+)\.pdf$} $i matchvariable filename ]
if { $var == 1 } {
puts "$filename"
} else { 
puts "$i no pdf"
}
}



