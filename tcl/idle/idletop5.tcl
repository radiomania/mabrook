#############################################################################################
#                                                                                           #
# Idle Top 5!                                                                               #
# Based on Idle King script by Ozh.                                                         #
# That script was originally named "Idle des jeunes" in French, which is funny as hell.     #
#                                                                                           #
# Contact stuff :                                                                           #
# TrashF, TrashF@iki.fi, QuakeNet.                                                          #
#                                                                                          #
#############################################################################################

#just type !idlers on channel to get the top 5 idlers

setudef flag idlers

bind pub - !idlers idle_getnick

proc idle_getnick {nick mask hand chan args} {
global botnick
if {![channel get $chan idlers]} { return }
	set idlaajia 0	
	set idle_1 "0"
	set idle_2 "0"
	set idle_3 "0"
	set idle_4 "0"
	set idle_5 "0"
	set idle_1_nick "N/A"
	set idle_2_nick "N/A"
	set idle_3_nick "N/A"
	set idle_4_nick "N/A"
	set idle_5_nick "N/A"
	foreach mec [chanlist $chan] {
		set idle_idle [getchanidle $mec $chan]
		if {$idle_idle > $idle_1 && $mec != $botnick && $mec != "L"} {set idle_1 $idle_idle ; set idle_1_nick $mec ; incr idlaajia }
	}
	foreach mec [chanlist $chan] {
		set idle_idle [getchanidle $mec $chan]
		if {$idle_idle > $idle_2 && $mec != $idle_1_nick && $mec != $botnick && $mec != "L"} {set idle_2 $idle_idle ; set idle_2_nick $mec ; incr idlaajia}
	}
	foreach mec [chanlist $chan] {
		set idle_idle [getchanidle $mec $chan]
		if {$idle_idle > $idle_3 && $mec != $idle_1_nick && $mec != $idle_2_nick && $mec != $botnick && $mec != "L"} {set idle_3 $idle_idle ; set idle_3_nick $mec ; incr idlaajia}
	}
	foreach mec [chanlist $chan] {
		set idle_idle [getchanidle $mec $chan]
		if {$idle_idle > $idle_4 && $mec != $idle_1_nick && $mec != $idle_2_nick && $mec != $idle_3_nick && $mec != $botnick && $mec != "L"} {set idle_4 $idle_idle ; set idle_4_nick $mec ; incr idlaajia}
	}
	foreach mec [chanlist $chan] {
		set idle_idle [getchanidle $mec $chan]
		if {$idle_idle > $idle_5 && $mec != $idle_1_nick && $mec != $idle_2_nick && $mec != $idle_3_nick && $mec != $idle_4_nick && $mec != $botnick && $mec != "L"} {set idle_5 $idle_idle ; set idle_5_nick $mec ; incr idlaajia}
	}

proc return_time {get_time} {
set seconds [expr $get_time % 60]
set days [expr $get_time/86400]
set hours [expr [expr $get_time/3600] % 24];
set minutes [expr [expr $get_time / 60] % 60]
 
if {[string length $hours] == "1"} {
set hours "0${hours}"
}
if {[string length $minutes] == "1"} {
set minutes "0${minutes}"
}
if {[string length $seconds] == "1"} {
set seconds "0${seconds}"
}
set output "${days}d:${hours}h:${minutes}m:${seconds}s"
if {$get_time <= 0} {
return 0
} else {
return $output
}
}

#here you can change the output method if you want.
if {$idlaajia > "5"} {set idlaajia 5}
if {$idle_1_nick != "N/A"} { putchan $chan "\00300,06 Top Idlers: \003 \00304#1.\003\00302$idle_1_nick\003 \[[return_time [expr $idle_1 * 60]]\]; \00304#2.\003\00302$idle_2_nick\003 \[[return_time [expr $idle_2 * 60]]\]; \00304#3.\003\00302$idle_3_nick\003 \[[return_time [expr $idle_3 * 60]]\]; \00304#4.\003\00302$idle_4_nick\003\[[return_time [expr $idle_4 * 60]]\]; \00304#5.\003\00302$idle_5_nick\003\[[return_time [expr $idle_5 * 60]]\]" }
}

putlog "Idle Top 5 by TrashF @ QNet loaded."