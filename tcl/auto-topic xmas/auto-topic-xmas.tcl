# set the name and date for the convention here
# convention name mm/dd/yy
set conventions {
  "Christmas Day 12/25/23"
  "New Year's Day 01/01/2024"
}

# channel
set convchan #christmas

bind pub -|- !topconv pubconv
bind time - "0 0 * * *" convtime

proc pubconv {nick uhost hand chan text} {
 settopic
}

proc convtime {min hour day month year} {
 settopic
}

proc settopic {} {
 foreach c $::conventions {
  set conv [lrange $c 0 end-1]
  set when [clock scan [lindex $c end]]
  set days [expr ($when-[clock seconds])/86400]
  lappend topic "0,4 $days 0,3 days 1,0 till 6[join $conv]1!"
 }
 putserv "TOPIC $::convchan :[join $topic {, }]"
}


putlog "Auto Topic Script Tcl ...Loaded"