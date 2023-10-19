###################### USAGE ########################
# !roulette add <nick> - add nickname to roulette   #
# !roulette  - start the roulette					#	
# !roulette list - list of add nicknames in roulette#
###################### SCRIPT #######################




bind pub - "!roulette" roul.controler
 
proc roul.controler { nick uhost handle chan text} {
	set args [split $text]
	switch -exact [lindex $args 0] {
		"add" { roul.add $chan [lrange $args 1 end] }
		"list" { roul.list $chan }
		default { roul.run $chan }
	}
}
 
proc roul.add {chan users} {
	if {[info exists ::roul($chan)] && [llength $::roul($chan)]>0} {
		putserv "PRIVMSG $chan :roulette is already running"
		return
	}
	set ::roul($chan) {}
	set abs {}
	foreach user $users {
		putlog "test $user"
		if {[onchan $user $chan]} {
			putlog "append $user"
			lappend ::roul($chan) $user
		} else {
			putlog "refuse $user"
			lappend abs $user
		}
	}
	if {[llength $::roul($chan)]<2} {
		putserv "PRIVMSG $chan :Not enough real player"
		unset ::roul($chan)
		return
	}
	if {[expr {[llength $::roul($chan)] % 2}] != 0} {
		putserv "PRIVMSG $chan :odd number of players, aborting"
		unset ::roul($chan)
		return
	}
	if {[llength $abs]>0} {
		putserv "PRIVMSG $chan :Not kept: [join $abs ", "]"
	}
	roul.list $chan
}
 
proc roul.list {chan} {
	if {![info exists ::roul($chan)] || [llength $::roul($chan)]==0} {
		putserv "PRIVMSG $chan :roulette is empty"
		return
	}
	putserv "PRIVMSG $chan :Roulette's nick: [join $::roul($chan) ", "]"
}
 
proc roul.run {chan} {
	if {![info exists ::roul($chan)] || [llength $::roul($chan)]==0} {
		putserv "PRIVMSG $chan :Roulette is closed"
		return
	}
	putserv "PRIVMSG $chan :Mixing random roulette for nicks"
	set ind [rand [llength $::roul($chan)]]
	set vict1 [lindex $::roul($chan) $ind]
	set ::roul($chan) [lreplace $::roul($chan) $ind $ind]
	set ind [rand [llength $::roul($chan)]]
	set vict2 [lindex $::roul($chan) $ind]
	set ::roul($chan) [lreplace $::roul($chan) $ind $ind]
	putserv "PRIVMSG $chan :$vict1 vs $vict2"
	if {[llength $::roul($chan)]==0} {
		putserv "PRIVMSG $chan :Roulette is ended"
	}
}


putlog "\002ROULETTE:\002 roulette.tcl 1.0 is loaded."