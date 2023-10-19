##############love matcher

bind pub - .love Matcher

proc Matcher {nick uhost hand chan args} {
regsub -nocase -all \[{}] $args "" args
set origargs $args
set args [string tolower $args]
if {[llength $args] < 2} {
 putserv "NOTICE $nick :!04LO04Vo04E! usage .love <nick1> <nick2>"
 return
}

set counter 0
set compatmarker 0
while {$counter != [string length $args]} {
 if {[string range $args $counter $counter] == "l"} {incr compatmarker 2}
 if {[string range $args $counter $counter] == "o"} {incr compatmarker 2}
 if {[string range $args $counter $counter] == "v"} {incr compatmarker 2}
 if {[string range $args $counter $counter] == "e"} {incr compatmarker 2}
 if {[string range $args $counter $counter] == "y"} {incr compatmarker 3}
 if {[string range $args $counter $counter] == "o"} {incr compatmarker 1}
 if {[string range $args $counter $counter] == "u"} {incr compatmarker 3}
 incr counter
}

set compatability 0
if {$counter > 0} {set compatability [expr 5 - ([string length $args] /2)]}
if {$counter > 2} {set compatability [expr 10 - ([string length $args] /2)]}
if {$counter > 4} {set compatability [expr 20 - ([string length $args] /2)]}
if {$counter > 6} {set compatability [expr 30 - ([string length $args] /2)]}
if {$counter > 8} {set compatability [expr 40 - ([string length $args] /2)]}
if {$counter > 10} {set compatability [expr 50 - ([string length $args] /2)]}
if {$counter > 12} {set compatability [expr 60 - ([string length $args] /2)]}
if {$counter > 14} {set compatability [expr 70 - ([string length $args] /2)]}
if {$counter > 16} {set compatability [expr 80 - ([string length $args] /2)]}
if {$counter > 18} {set compatability [expr 90 - ([string length $args] /2)]}
if {$counter > 20} {set compatability [expr 100 - ([string length $args] /2)]}
if {$counter > 22} {set compatability [expr 110 - ([string length $args] /2)]}

if {$compatability < 0} {set compatability 0}
if {$compatability > 100} {set compatability 100}
if {$compatability < 50} {
  set loves "you can believe it.. you can not.. but it is possible that you two are not married yet. I'm sorry... :)"
} elseif {$compatability < 75} {
  set loves "It takes more effort to approach both of your hearts...!!"
} elseif {$compatability < 90} {
  set loves "good start.. getting close to your soul mate.. tweet tweet.. let's be more intimate, arghh...!!"
} else {
  set loves "It's really a match... Just get married... don't forget to invite aslpls, bro...!!"
}
putserv "privmsg $chan :14Compatibility between03 $origargs 10as big as04 $compatability% ($loves)"
return
}


putlog "lovematch.tcl modified by mabrook Loaded"
