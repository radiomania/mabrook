####################################################################
#
#	Black Scrabble 1.2.1 TCL - en version
#
#A game in which you are given letters and you have to make words with them
#
#Commands :
#
#!scrabble <on> / <off> - enable / disable Scrabble
#!scrabble - start game
#!scrabble stop - stop jocul
#!scrabble reset - reset top
#!top <general> / <round> - vizualizezi topurile.
#!won <user> - view user statistics.
#!game - show the current letters from which you will form words.
#
#INSTALL :
#
#Put Scrabble.db and the BlackScrabble.tcl file in scripts
#Add in config 	source scripts/BlackScrabble.tcl
#
#								have Fun
#
#					BLackShaDoW ProductionS
#	Translate by Nik		   WwW.TclScripts.Net
####################################################################

#Set here which flags can enable / disable / reset Scrabble

set scrabble(flags) "mn|mM"

#Here you set after how many rounds in which there is no activity 
#to stop the automatic game?

set scrabble(end_rounds) "5"

#After how many correct answers the eggdrop to show again the letters ?
set scrabble(correct_answers_show) "3"

#Random round for double points 
#(will choose a random round from the maximum set below)

set scrabble(double_points_round) "5"

###
#Select mask to use for users
#1 - *!*@$host
#2 - *!$ident@$host
#3 - $user!$ident@$host
#4 - $user!*@*
#5 - *!$ident@*
set scrabble(userhost) "1"

#####################################################################
#
#							The End is Near :)
#
#####################################################################

bind pub - !scrabble start:scrabble
bind pubm - * preia:cuvant
bind pub - !top top:scrabble
bind pub - !won won:scrabble
bind pub - !game arata:litere
bind join - * top:3:join

set scrabble(file) "scripts/Scrabble.db"
set scrabble(userfile) "Scrabble_stats.db"
setudef flag scrabble

if {![file exists $scrabble(userfile)]} {
		set file [open $scrabble(userfile) w]
		close $file
}

if {![file exists $scrabble(file)]} {
		set file [open $scrabble(file) w]
		close $file
}

###
proc arata:litere {nick host hand chan arg} {
	global scrabble
	
if {![channel get $chan scrabble]} {
	puthelp "NOTICE $nick :\00312Scrabble\003 is not activated."
	return 0
}		
if {[info exists scrabble(word:$chan)]} {
	puthelp "PRIVMSG $chan :\00301The current letters :\003 \00300,12$scrabble(word:$chan)\003"
	}	
}

###
proc won:scrabble {nick host hand chan arg} {
	global scrabble
	set user [lindex [split $arg] 0]

if {![channel get $chan scrabble]} {
	puthelp "NOTICE $nick :\00312Scrabble\003 is not activated."
	return 0
}
	
if {$user == ""} { set user $nick }

	set file [open $scrabble(userfile) "r"]
	set data [read -nonewline $file]
	close $file
	set words [split $data "\n"]	

foreach line $words {
	set channel [lindex [split $line] 1]
	set get_nick [lindex [split $line] 0]

if {[string match -nocase $chan $channel] && [string match -nocase $get_nick $user]} {	
	set found_nrg 1
	lappend points [join [lindex [split $line] 3]]
	lappend rounds [join [lindex [split $line] 4]]
				}	
			}
if {[info exists found_nrg]} {
	puthelp "PRIVMSG $chan :\00312$user\003 \00301has\003 \00304$points\003 \00301points and\003 \00304$rounds\003 \00301rounds won.\003"
		} else {
	puthelp "NOTICE $nick :\00301I did not find any information...\003"
	}
}	

###
proc top:scrabble {nick host hand chan arg} {
	global scrabble
	
	set option [lindex [split $arg] 0]
	
if {![channel get $chan scrabble]} {
	puthelp "NOTICE $nick :\00312Scrabble\003 is not activated."
	return 0
}
	
if {$option == ""} {

	puthelp "NOTICE $nick :\00301Use\003 \00312!top <general> / <round>\003"
	return 0
}

switch -exact -- $option {
general {
	puthelp "PRIVMSG $chan :Top \00312Scrabble\003 General is :"
	afiseaza:topscrabble $chan "general"
}
round {
	puthelp "PRIVMSG $chan :Top \00312Scrabble\003 Round is :"
	afiseaza:topscrabble $chan "round"
	}
default {
	puthelp "NOTICE $nick :\00301Use\003 \00312!top <general> / <round>\003"
	}
	
	}	
}

###
proc afiseaza:topscrabble {chan type} {
	global scrabble
	set counter 0
	array set topscr [list]
	set file [open $scrabble(userfile) "r"]
	set data [read -nonewline $file]
	close $file
	set words [split $data "\n"]
foreach line $words {
	set channel [lindex [split $line] 1]
	set nick [lindex [split $line] 0]
if {$type == "general"} { set top_point [lindex [split $line] 3] } else { set top_point [lindex [split $line] 4] }

if {[string match -nocase $channel $chan]} {
if {$top_point != "0"} {	
	lappend topscr($top_point) $nick
		}
	}
}
foreach t_scr [lsort -integer -decreasing [array names topscr]] {
	set counter [expr $counter + 1]
if {$counter < 11} {	
	lappend the_line \00304- $counter -\003 : [join $topscr($t_scr) ,] \00312\[$t_scr\]\003
}
}
if {[info exists the_line]} {
	puthelp "PRIVMSG $chan :[join $the_line]"
} else {
	puthelp "PRIVMSG $chan :None" 

	}
}

###
proc start:scrabble {nick host hand chan arg} {
	global scrabble
	set option [lindex [split $arg] 0]
if {[matchattr $hand $scrabble(flags) $chan]} {
if {[string equal -nocase "reset" $option]} {

	set file [open $scrabble(userfile) "r"]
	set data [read -nonewline $file]
	close $file
	set words [split $data "\n"]

foreach line $words {			
	set channel [lindex [split $line] 1]
if {[string match -nocase $channel $chan]} {
	lappend arguments [join $channel]
	}		
}	
if {[info exists arguments]} {
resetare:top $chan $arguments
}
	puthelp "NOTICE $nick :\00301Reset top..\003"	
	return 0
}
if {[string equal -nocase "on" $option]} {
	channel set $chan +scrabble
	puthelp "PRIVMSG $chan :\00312Scrabble\003 is activated. To play type \00304!scrabble\003"
	return 0
}

if {[string equal -nocase "off" $option]} {
	channel set $chan -scrabble
	scrabble:stop $chan
	puthelp "PRIVMSG $chan :\00312Scrabble\003 is not activated."
	return 0
	}
}
	
if {![channel get $chan scrabble]} {
	puthelp "NOTICE $nick :\00312Scrabble\003 is activated."
	return 0
}
	
if {[string equal -nocase "version" $option]} {
	puthelp "PRIVMSG $chan :Version \00312Scrabble 1.2\003 by \0034BLaCkShaDoW\003. For other informations -> \00312WwW.TclScripts.Net\003 - Translate By Nik - #Scramble @ Undernet"
	return 0
}

if {[string equal -nocase "stop" $option]} {

	puthelp "PRIVMSG $chan :\00312Scrabble\003 stoped."
	scrabble:stop $chan
	return 0
}
if {[info exists scrabble($chan:run)]} {
			puthelp "NOTICE $nick :\00301Scrabble is already running.\003"
			return 0
}

	puthelp "PRIVMSG $chan :Start the game \00312Scrabble\003..."
	afiseaza:scrabble $chan
	set scrabble($chan:run) 1
}

###
proc afiseaza:scrabble {chan} {
	global scrabble
	
if {[info exists scrabble(stop:it:$chan)]} {
	unset scrabble(stop:it:$chan)
	return 0
}
if {[info exists scrabble(double_round_now)]} {
	unset scrabble(double_round_now)
}
if {[info exists scrabble($chan:nr_correct_word)]} {
	unset scrabble($chan:nr_correct_word)
}
if {![info exists scrabble(double_round)]} {
	set scrabble(double_round) [expr [rand $scrabble(double_points_round)] + 1]
}
if {![info exists scrabble(rand_game_counter)]} {
	set scrabble(rand_game_counter) 1
} elseif {$scrabble(rand_game_counter) <  $scrabble(double_round)} {
	incr scrabble(rand_game_counter)
}
if {$scrabble(rand_game_counter) == $scrabble(double_round)} {
	set scrabble(double_round_now) 1
	unset scrabble(rand_game_counter)
	unset scrabble(double_round)
}
	set file [open $scrabble(file) "r"]
	set data [read -nonewline $file]
	close $file
	set words [split $data "\n"]
	set valid_words ""
foreach line $words {
if {[string length $line] > 3} {
	lappend valid_words $line
	}
}
	set scrabble(current_word:$chan) [lindex $words [rand [llength $valid_words]]]
	set scrabble(word:$chan) [scrabble:process $scrabble(current_word:$chan)]
	set length_word [string length $scrabble(current_word:$chan)]
	
	switch -exact -- $length_word {
	3 {
	set timer_seconds 50
	}
	4 {
	set timer_seconds 60
	}	
	5 {
	set timer_seconds 65
	}
	6 {
	set timer_seconds 75
	}
	7 {
	set timer_seconds 85
	}
	8 {
	set timer_seconds 95
	}
	9 {
	set timer_seconds 100
	}
	default {
	set timer_seconds 120
	}
}
	
if {$data == ""} {
		puthelp "PRIVMSG $chan :There are no words in the database. \00312Scrabble\003 stoped."

		scrabble:stop $chan

		return 0		
}
	set scrabble($chan:timer_seconds) $timer_seconds
if {[info exists scrabble(double_round_now)]} {
	puthelp "PRIVMSG $chan :\[\002DOUBLE GAME\002\] Guess at least 3 letters : \00300,12$scrabble(word:$chan)\003 - \00304$timer_seconds\003 seconds available."
} else {
	puthelp "PRIVMSG $chan :Guess at least 3 letters : \00300,12$scrabble(word:$chan)\003 - \00304$timer_seconds\003 seconds available."
}
	utimer $timer_seconds [list again:scrabble $chan]
	set scrabble($chan:the_time) $timer_seconds
}

###
proc again:scrabble {chan} {
	global scrabble
	alege:castigator $chan
	verifica:top:3 $chan
	reset:for:new $chan
	afiseaza:scrabble $chan
}

###
proc verifica:top:3 {chan} {
	global scrabble
if {![botisop $chan]} {return}
	array set topscr [list]
	set counter 0
	set file [open $scrabble(userfile) "r"]
	set data [read -nonewline $file]
	close $file
	set words [split $data "\n"]
	
foreach line $words {
	set channel [lindex [split $line] 1]
	set host [lindex [split $line] 2]
set top_point [lindex [split $line] 3]
if {[string match -nocase $channel $chan]} {
	lappend topscr($top_point) $host
	}
}

foreach t_scr [lsort -integer -decreasing [array names topscr]] {
set counter [expr $counter + 1]
if {$counter <= 3} {
lappend top_3 [join $topscr($t_scr)]
	}
}

if {[info exists top_3]} {
foreach read_host $top_3 {
foreach user [chanlist $chan] {
	set get_host *!*@[lindex [split [getchanhost $user $chan] "@"] 1]
if {[string match -nocase $read_host $get_host]} {
lappend valid_users [join $user]
		}
	}
}

if {[info exists valid_users]} {
foreach user $valid_users {
if {(![isop $user $chan]) && (![isvoice $user $chan])} { 
	pushmode $chan +v $user
	lappend now_voice [join $user]
		}
	}
}
if {[info exists now_voice]} {
if {[llength $now_voice] > 1} {
	puthelp "PRIVMSG $chan :\00312[join $now_voice ", "]\003 receive \00304VOICE (+)\003 because it is at the \00312Top 3 Scrabble\003 ."
} else {
	puthelp "PRIVMSG $chan :\00312$now_voice\003 receives \00304VOICE (+)\003 because it is at the \00312Top 3 Scrabble\003 ."
			}
		}
	}
}

###
proc top:3:join {nick host hand chan} {
	global scrabble
if {![channel get $chan scrabble]} {
	return 0
}
if {![botisop $chan]} {return}
	set get_host "*!*@[lindex [split $host @] 1]"
	array set topscr [list]
	set counter 0
	set file [open $scrabble(userfile) "r"]
	set data [read -nonewline $file]
	close $file
	set words [split $data "\n"]
	
foreach line $words {
	set channel [lindex [split $line] 1]
	set host [lindex [split $line] 2]
set top_point [lindex [split $line] 3]
if {[string match -nocase $channel $chan]} {
	lappend topscr($top_point) $host
	}
}
foreach t_scr [lsort -integer -decreasing [array names topscr]] {
set counter [expr $counter + 1]
if {$counter <= 3} {
lappend top_3 [join $topscr($t_scr)]
	}
}

if {[info exists top_3]} {
foreach read_host $top_3 {
if {[string match -nocase $get_host $read_host]} {
	set found_reg 1
	utimer 3 [list pushmode $chan +v $nick]
	}	
}
if {[info exists found_reg]} {
	utimer 3 [list puthelp "PRIVMSG $chan :\00312$nick\003 receives \00304VOICE (+)\003 because it is at the \00312Top 3 Scrabble\003 ."]
		}
	}	
}

###
proc alege:castigator {chan} {
	global scrabble
	array set winner [list]
	set nicks ""
if {[info exists scrabble($chan:round_players)]} {
foreach m $scrabble($chan:round_players) {
	set host [lindex $m 1]
	set nick [lindex $m 0]
if {[info exists scrabble($host:current_points)]} {
	lappend winner($scrabble($host:current_points)) [list $nick $host]
	}
}

foreach eq [lsort -integer -increasing [array names winner]] {
	set max "$eq"
}
if {[info exists max]} {
foreach item $winner($max) {
	set nick [lindex $item 0]
	lappend nicks $nick
		}
	puthelp "PRIVMSG $chan :The winners of the round are : \00304[join $nicks ", "]\003 with \00312$max\003 points"
	runda:castigata $chan $winner($max)
		}
		set scrabble(is:played:$chan) 1
	}
	puthelp "PRIVMSG $chan :The alternative answer was: \00312$scrabble(current_word:$chan)\003"
}

###
proc runda:castigata {chan arg} {
	global scrabble	
	set file [open $scrabble(userfile) "r"]
	set data [read -nonewline $file]
	close $file
	set words [split $data "\n"]
foreach item $arg {
	set host [lindex $item 1]
	set nick [lindex $item 0]
foreach line $words {
	set channel [lindex [split $line] 1]
	set get_host [lindex [split $line] 2]
if {[string match -nocase $chan $channel] && [string match -nocase $get_host $host]} {
	lappend current_hosts [list $nick $get_host]
			}
		}
	}
	runda:noua $chan $current_hosts
}

###
proc runda:noua {chan items} {
	global scrabble
foreach item $items {
if {$item != ""} {
	set host [lindex $item 1]
	set the_nick [lindex $item 0]
	set file [open $scrabble(userfile) "r"]
	set data [read -nonewline $file]
	close $file
	set words [split $data "\n"]
	set i [lsearch -nocase -glob $words "* $chan $host *"]
if {$i > -1} {
	set line [lindex $words $i]
	set total_general [lindex [split $line] 3]
	set runda_curenta [lindex [split $line] 4]
	set delete [lreplace $words $i $i]
	set file [open $scrabble(userfile) "w"] 
	puts $file [join $delete "\n"]
	close $file

	set file [open $scrabble(userfile) a]
	puts $file "$the_nick $chan $host $total_general [expr [join $runda_curenta] + 1]"
	close $file
			}
		}	
	}
}

###
proc reset:for:new {chan} {
	global scrabble
if {[info exists scrabble($chan:round_players)]} {	
foreach m $scrabble($chan:round_players) {
	set m [lindex $m 1]
if {[info exists scrabble($m:current_points)]} {
	unset scrabble($m:current_points)
		}
	}	
}
	
if {[info exists scrabble(current_word:$chan)]} {
		unset scrabble(current_word:$chan)		
}

if {[info exists scrabble(word:$chan)]} {
		unset scrabble(word:$chan)		
}

if {[info exists scrabble($chan:the_time)]} {
		unset scrabble($chan:the_time)		
}

if {[info exists scrabble($chan:round_words)]} {
		unset scrabble($chan:round_words)		
}

if {[info exists scrabble($chan:round_players)]} {
		unset scrabble($chan:round_players)
}
if {[info exists scrabble($chan:timer_seconds)]} {
	unset scrabble($chan:timer_seconds)
}
if {![info exists scrabble(is:played:$chan)]} {

if {![info exists scrabble(no:playing:$chan)]} {
	set scrabble(no:playing:$chan) 0
}
	set scrabble(no:playing:$chan) [expr $scrabble(no:playing:$chan) + 1]
} else {

if {[info exists scrabble(no:playing:$chan)]} {

	unset scrabble(no:playing:$chan)
		}
	}
	
if {[info exists scrabble(no:playing:$chan)]} {
	if {$scrabble(no:playing:$chan) >= $scrabble(end_rounds)} {
	puthelp "PRIVMSG $chan :\00312Scrabble\003 it stopped automatically. To play again type \00304!scrabble\003 . Tnx"
	unset scrabble(no:playing:$chan)
if {[info exists scrabble(is:played:$chan)]} {
	unset scrabble(is:played:$chan)
}
	set scrabble(stop:it:$chan) 1
	scrabble:stop $chan
		}	
	}
	if {[info exists scrabble(is:played:$chan)]} {
	unset scrabble(is:played:$chan)	
	}	
}	

###
proc scrabble:process {word} {
	global scrabble
	
	set split_word [split $word ""]
	set correct_word 0
	
while {$split_word != ""} {
	set char_position [rand [llength $split_word]]
	set char [lindex $split_word $char_position]
	lappend rand_chars [join $char]
	set split_word [lreplace $split_word $char_position $char_position]
}
	return $rand_chars
}

###
proc preia:cuvant {nick host hand chan arg} {
	global scrabble
if {![channel get $chan scrabble]} {
	return 0
}	
	set cuvant_dat [lindex [split $arg] 0]
	set correct_word 0
	set the_word 0
	set show_letters 0
	set mask [scrabble:host_return $scrabble(userhost) $nick $host]
if {![info exists scrabble($chan:run)] && ![info exists scrabble(word:$chan)]} {
	return 0
}

if {[string length $cuvant_dat]	> 2} {
if {[info exists scrabble($chan:round_words)]} {
if {[lsearch -exact [string tolower $scrabble($chan:round_words)] [string tolower $cuvant_dat]] > -1} {
	puthelp "NOTICE $nick :\00301The word\003 \00312$cuvant_dat\003 \00301it has been said once before..\003"
	return 0
	}
}
	set split_word [string toupper [split $cuvant_dat ""]]
	set split_word_one $split_word
	set split_current [split $scrabble(current_word:$chan) ""]
foreach char $split_current {
	if {[lsearch -nocase $split_word $char] > -1} {
	set position [lsearch -exact $split_word $char] 
	set correct_word [expr $correct_word + 1]
	set split_word [lreplace $split_word $position $position]
	}
}

foreach char $split_word_one {
	if {[lsearch -nocase $split_current $char] > -1} {
	set position [lsearch -exact $split_current $char] 
	set the_word [expr $the_word + 1]
	set split_current [lreplace $split_current $position $position]
	}
}
if {$correct_word > 2} {
	set correct 0
	set file [open $scrabble(file) "r"]
while {[gets $file line] != -1} {
if {[string equal -nocase $line $cuvant_dat]} {
	set correct 1
	break
	}
}
	close $file
if {($correct == 1) && ([string length $cuvant_dat] == $correct_word)} {
if {![info exists scrabble($chan:nr_correct_word)]} {
	set scrabble($chan:nr_correct_word) 1
} else {
if {$scrabble($chan:nr_correct_word) == $scrabble(correct_answers_show)} {
	set show_letters 1
	unset scrabble($chan:nr_correct_word)
		} else {
	incr scrabble($chan:nr_correct_word) 	
	}
}
	lappend scrabble($chan:round_words) $cuvant_dat
if {[info exists scrabble($chan:round_players)]} {
if {[lsearch -nocase $scrabble($chan:round_players) $mask] < 0} {
	lappend scrabble($chan:round_players) [list $nick $mask]
	}
} else {
	lappend scrabble($chan:round_players) [list $nick $mask]	
}
if {($split_current == "") && ([string length $cuvant_dat] == [string length $scrabble(current_word:$chan)])} {
	set punctaj 500
if {[info exists scrabble(double_round_now)]} {
	set punctaj [expr $punctaj * 2]
}
	scrabble:punctaj $nick $chan $mask $punctaj
	anunta:punctaj $nick $chan $mask $cuvant_dat $punctaj
	return 0
} 

switch -exact -- $correct_word {
3 {
set punctaj 15
if {[info exists scrabble(double_round_now)]} {
	set punctaj [expr $punctaj * 2]
}
scrabble:punctaj $nick $chan $mask $punctaj
anunta:punctaj $nick $chan $mask $cuvant_dat $punctaj	
}
4 {
set punctaj 30
if {[info exists scrabble(double_round_now)]} {
	set punctaj [expr $punctaj * 2]
}
scrabble:punctaj $nick $chan $mask $punctaj
anunta:punctaj $nick $chan $mask $cuvant_dat $punctaj
}
5 {
set punctaj 35
if {[info exists scrabble(double_round_now)]} {
	set punctaj [expr $punctaj * 2]
}
scrabble:punctaj $nick $chan $mask $punctaj
anunta:punctaj $nick $chan $mask $cuvant_dat $punctaj
}
6 {
set punctaj 40
if {[info exists scrabble(double_round_now)]} {
	set punctaj [expr $punctaj * 2]
}
scrabble:punctaj $nick $chan $mask $punctaj
anunta:punctaj $nick $chan $mask $cuvant_dat $punctaj
}
7 {
set punctaj 50
if {[info exists scrabble(double_round_now)]} {
	set punctaj [expr $punctaj * 2]
}
scrabble:punctaj $nick $chan $mask $punctaj
anunta:punctaj $nick $chan $mask $cuvant_dat $punctaj
}
8 {
set punctaj 60
if {[info exists scrabble(double_round_now)]} {
	set punctaj [expr $punctaj * 2]
}
scrabble:punctaj $nick $chan $mask $punctaj
anunta:punctaj $nick $chan $mask $cuvant_dat $punctaj
}

9 {
set punctaj 90
if {[info exists scrabble(double_round_now)]} {
	set punctaj [expr $punctaj * 2]
}
scrabble:punctaj $nick $chan $mask $punctaj
anunta:punctaj $nick $chan $mask $cuvant_dat $punctaj
}

default {
set punctaj 120
if {[info exists scrabble(double_round_now)]} {
	set punctaj [expr $punctaj * 2]
}
scrabble:punctaj $nick $chan $mask $punctaj
anunta:punctaj $nick $chan $mask $cuvant_dat $punctaj
 
						}
					}
if {$show_letters == 1} {
if {[info exists scrabble(double_round_now)]} {
	puthelp "PRIVMSG $chan :\[\002DOUBLE GAME\002\] Guess at least 3 letters : \00300,12$scrabble(word:$chan)\003 - \00304$scrabble($chan:timer_seconds)\003 seconds available."
} else {
	puthelp "PRIVMSG $chan :Guess at least 3 letters : \00300,12$scrabble(word:$chan)\003 - \00304$scrabble($chan:timer_seconds)\003 seconds available."
						}
					}					
				}
			}
		}
	}

###
proc scrabble:punctaj {nick chan mask punctaj} {
	global scrabble
	set counter 0
	set read_points 0
	set read_round 0
	
	set file [open $scrabble(userfile) "r"]
	set data [read -nonewline $file]
	close $file
	set words [split $data "\n"]	
foreach line $words {	
	set counter [expr $counter + 1]
	set channel [lindex [split $line] 1]
	set usermask [lindex [split $line] 2]
	
if {[string match -nocase $mask $usermask] && [string match -nocase $channel $chan]} {
	set read_points [lindex [split $line] 3]
	set read_round [lindex [split $line] 4]
if {$line != ""} {
	set counter [expr $counter - 1]
	set delete [lreplace $words $counter $counter]
	set files [open $scrabble(userfile) "w"]
	puts $files [join $delete "\n"]
	close $files
	
		}		
	}
}
	set file [open $scrabble(userfile) "r"]
	set data [read -nonewline $file]
	close $file
	
if {$data == ""} {
	set file [open $scrabble(userfile) "w"]
	close $file
}
	
	set file [open $scrabble(userfile) "a"]
	puts $file "$nick $chan $mask [expr $read_points + $punctaj] $read_round"
	close $file
	
	if {[info exists scrabble($mask:current_points)]} {
	set scrabble($mask:current_points) [expr $scrabble($mask:current_points) + $punctaj]
} else {
	set scrabble($mask:current_points) 0
 	set scrabble($mask:current_points) [expr $scrabble($mask:current_points) + $punctaj]
}
	
}

###
proc anunta:punctaj {nick chan mask cuvant_dat punctaj} {
	global scrabble
	
	set file [open $scrabble(userfile) "r"]
	set data [read -nonewline $file]
	close $file
	set words [split $data "\n"]
	
foreach line $words {
	set channel [lindex [split $line] 1]
	set usermask [lindex [split $line] 2]
	set punctaj_citit [lindex [split $line] 3]
	set round [lindex [split $line ] 4]
if {[string match -nocase $mask $usermask] && [string match -nocase $channel $chan]} {	

		set exists_user 1

	}
}

if {[info exists exists_user] && [info exists scrabble($chan:the_time)]} {

	puthelp "PRIVMSG $chan :\00312$nick\003 with \00300,12$cuvant_dat\003 scored \00304$punctaj\003 points in \00304[expr $scrabble($chan:the_time) - [get:scrabble:time $chan]]\003 seconds . Total points : \00312$punctaj_citit\003 - This round : \00312$scrabble($mask:current_points)\003 - Rounds Won : \00312$round\003 . There are \00304[get:scrabble:time $chan]\003 seconds left"

	}
}

###
proc scrabble:stop {chan} {
	global scrabble	
if {[info exists scrabble($chan:round_players)]} {	
foreach m $scrabble($chan:round_players) {
	set m [lindex $m 1]
if {[info exists scrabble($m:current_points)]} {
	unset scrabble($m:current_points)
		}
	}	
}

if {[info exists scrabble($chan:round_players)]} {
		unset scrabble($chan:round_players)
}

if {[info exists scrabble($chan:run)]} {
		unset scrabble($chan:run)		
}
if {[info exists scrabble($chan:nr_correct_word)]} {
	unset scrabble($chan:nr_correct_word)
}
if {[info exists scrabble($chan:the_time)]} {
		unset scrabble($chan:the_time)		
}

if {[info exists scrabble(current_word:$chan)]} {
		unset scrabble(current_word:$chan)		
}

if {[info exists scrabble(word:$chan)]} {
		unset scrabble(word:$chan)		
}

if {[info exists scrabble($chan:round_words)]} {
		unset scrabble($chan:round_words)		
}
if {[info exists scrabble(rand_game_counter)]} {
	unset scrabble(rand_game_counter)
}
if {[info exists scrabble(double_round)]} {
	unset scrabble(double_round)
}
if {[info exists scrabble(double_round_now)]} {
	unset scrabble(double_round_now)
}
foreach tmr [utimers] {
if {[string match "*again:scrabble*" [join [lindex $tmr 1]]]} {
killutimer [lindex $tmr 2]
		}
	}						
}

###
proc get:scrabble:time {chan} {
	global scrabble
foreach tmr [utimers] {
if {[string match "*again:scrabble $chan*" [join [lindex $tmr 1]]]} {
set time_left [lindex $tmr 0]
	}
}
	return $time_left
}
	
###
proc resetare:top {chan arguments} {
	global scrabble
foreach arg $arguments {
if {$arg != ""} {
	set file [open $scrabble(userfile) "r"]
	set data [read -nonewline $file]
	close $file
	set words [split $data "\n"]
	set i [lsearch -glob $words "* $arg *"]
if {$i > -1} {
	set line [lindex $words $i]
	set delete [lreplace $words $i $i]
	set file [open $scrabble(userfile) "w"] 
	puts $file [join $delete "\n"]
	close $file	
			}
		}		
	}
	
	set file [open $scrabble(userfile) "r"]
	set data [read -nonewline $file]
if {$data == ""} { 
	set file [open $scrabble(userfile) "w"] 
	close $file
	}	
}

###
proc scrabble:host_return {type user host} {
	global scrabble
	set ident [lindex [split $host "@"] 0]
	set uhost [lindex [split $host @] 1]
	switch $type {
1 {
	return "*!*@$uhost"
}
2 {
	return "*!$ident@$uhost"
}
3 {
	return "$user!$ident@$uhost"
}
4 {
	return "$user!*@*"
}
5 {
	return "*!$ident@*"
		}
	}
}

putlog "Black Scrabble 1.2.1 By BLaCkShaDoW Loaded"	