bind PUBM - * activate:pub

setudef flag activate


proc activate:pub {nick uhost hand chan arg} {
	global signore
	
	if {[lindex [split $arg] 1] eq "*!*@*"} { return }
	if {[lindex [split $arg] 1] eq ""} { return }
	if {[info exists signore($nick)]} { return }

	if {[string index $arg 0] in {! . `}} {
		set temp(cmd) [string range $arg 1 end]
		set temp(cmd) [lindex [split $temp(cmd)] 0]		
		set arg [join [lrange [split $arg] 1 end]]
	} elseif {[isbotnick [lindex [split $arg] 0]]} {
		set temp(cmd) [lindex [split $arg] 1]
		set arg [join [lrange [split $arg] 2 end]]
	} else { return 0 }

	if {[info commands $temp(cmd):pubcmd] ne ""} { $temp(cmd):pubcmd $nick $uhost $hand $chan $arg }
}

proc activate:pubcmd {nick uhost hand chan arg} {
	global signore

	set floodtime 10

	set value [lindex [split $arg] 0]

	switch -exact -- [lindex [split $arg] 0] {
		on { if {![matchattr $hand n]} { return }; activate on $value $chan $nick }
		off { if {![matchattr $hand n ]} { return }; activate off $value $chan $nick }
	}


}

proc activate {cmd value chan nick} {
	global activate

	switch -exact -- $cmd {
		"on" {
			channel set $chan +activate

			putserv "PRIVMSG $chan :\002$nick\002 - \00302Set channel mode \00306+activate\00302 on \00304$chan"
		}
		"off" {
			channel set $chan -activate

			putserv "PRIVMSG $chan :\002$nick\002 - \00302Set channel mode \00306-activate\00302 on \00304$chan"
		}
	}
}

putlog "++ \[ - \00304PUBLIC\003 - \00306loaded\003 * \00303ACTIVATE.TCL\003 \] ++"
