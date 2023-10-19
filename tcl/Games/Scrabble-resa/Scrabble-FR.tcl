####################################################################
#
#	Black Scrabble 1.1 TCL
#
#The game offers letters and the users have to make words
#with the letters offered. Minimum 4 letters may be used to
#make words.
#
#Comment :
#
#!scrabble <on> / <off> - activate / disable Scrabble
#!scrabble - start the game
#!scrabble stop - stop the game
#!scrabble reset - reset scores
#!top <general> / <runde> - view tops.
#!won <user> - view user statistics.
#!lettre - show the current letters .
#
#INSTALARE :
#Lang Romain
#Put Scrabble.db in the main directory of the eggdrop ( eggdrop usual )
#and the tcl BlackScrabble.tcl in scripts
#Add in config 	source scripts/BlackScrabble.tcl
#
#								have Fun
#
#					BLackShaDoW ProductionS
#					   WwW.TclScripts.Net
#####################################################################

# #################### modif dilettante
# traduction dico français
# modif pour couleur
# les scores sont par défaut basés sur le host - modif pour cumul des scores pour pseudo résa quel que soit l'host
# modif remplacement des putquick par putserv pour cause de Excess Flood
# ####################


#Set here the flags to activate/disable/reset Scrabble

set scrabble(flags) "mn|mM"

#Set here the limit rounds for the eggdrop to run without someone playing
#After that the game will stop.

set scrabble(end_rounds) "4"

set monchan "#scrabble"

#####################################################################
#
#							The End is Near :)
#
#####################################################################

bind pub - !scrabble start:scrabble
bind pubm - * preia:cuvant
bind pub - !top top:scrabble
bind pub - !won won:scrabble
bind pub - !lettre arata:litere
bind join - * top:3:join

set scrabble(file) "Scrabble.db"
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

proc arata:litere {nick host hand chan arg} {
	global scrabble
	
if {![channel get $chan scrabble]} {
	putserv "NOTICE $nick :Le \00312 Scrabble\003 n'est pas activé, voir un IRCop."
	return 0
}
if {![info exists scrabble($chan:run)]  && [channel get $chan scrabble]} {
  putserv "PRIVMSG $chan :\00312Tapez !scrabble pour démarrer le jeu"
  return 0
}
if {[info exists scrabble(word:$chan)]} {
	putserv "PRIVMSG $chan :\00304Les lettres actuelles sont \00309:\003 \00300,12 $scrabble(word:$chan) \003"
}	
}

proc won:scrabble {nick host hand chan arg} {
	global scrabble
	set lexten "*|*"
	set user [lindex [split $arg] 0]
if {![channel get $chan scrabble]} {
	putserv "NOTICE $nick : Le \00312 Scrabble\003 n'est pas activé."
	return 0
}
if {[string match $lexten $nick]} {
    regsub {\|.*$} $nick {} nick
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
	putserv "PRIVMSG $chan :\00312$user\003 \00304a\003 \00304$points\003 \00304points and\003 \00304$rounds\003 \00304manches gagnées.\003"
} else {
	putserv "NOTICE $nick :\00304Aucune information touvée\003"
	}
}	

proc top:scrabble {nick host hand chan arg} {
	global scrabble	
	set option [lindex [split $arg] 0]	
if {![channel get $chan scrabble]} {
	putserv "NOTICE $nick :Le \00312 Scrabble \003 n'est pas activé."
	return 0
}
	
if {$option == ""} {
	putserv "NOTICE $nick :\00304Use\003 \00312!top <general> / <runde>\003"
	return 0
}

switch -exact -- $option {
general {
	putserv "PRIVMSG $chan :\00314Top du \00300,2 Scrabble \003 General :"
	afiseaza:topscrabble $chan "general"
}
runde {
	putserv "PRIVMSG $chan :\00314Top du \00300,2 Scrabble \003 Tours :"
	afiseaza:topscrabble $chan "runde"
	}
default {
	putserv "NOTICE $nick :\00304Use\003 \00312!top <general> / <runde>\003"
	}
	
	}	
}

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
        lappend the_line \00303- $counter -\00309 : \003\00314[join $topscr($t_scr) ,] \00304$t_scr\ Points\003
}
}

if {[info exists the_line]} {
	putserv "PRIVMSG $chan :[join $the_line]"
} else {
	putserv "PRIVMSG $chan :\00314Aucun joueur inscrit dans le top10\003" 
	}
}

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
	putserv "NOTICE $nick :\00304Reseting du top10..\003"	
	return 0
}
if {[string equal -nocase "on" $option]} {
	channel set $chan +scrabble
	putserv "PRIVMSG $chan :Le \00304 Scrabble\003 est activé. Pour commencer à jouer tapez \00304!scrabble\003"
	return 0
}

if {[string equal -nocase "off" $option]} {
	channel set $chan -scrabble
	scrabble:stop $chan
	putserv "PRIVMSG $chan :Le \00312 Scrabble\003 est désactivé."
	return 0
	}
}
	
if {![channel get $chan scrabble]} {
	putserv "NOTICE $nick :Le \00312 Scrabble\003 n'est pas activé."
	return 0
}
	
if {[string equal -nocase "version" $option]} {
	putserv "PRIVMSG $chan :Version \00300,2 Black Scrabble 1.1 modifiée par dilettante V1.2\003 ."
	return 0
}

if {[string equal -nocase "stop" $option]} {
   if { [matchattr [nick2hand $nick] "o" $chan]} {
	putserv "PRIVMSG $chan :\00304Le Scrabble\003 a été stoppé par $nick."
	scrabble:stop $chan
   } else {
     putserv "NOTICE $nick :Vous n'avez pas l'autorisation pour arrêter le Scrabble"
   }
	return 0
}
if {[info exists scrabble($chan:run)]} {
			putserv "NOTICE $nick :\00304Le Scrabble est déjà  en cours d'éxécution.\003"
			return 0
}          
	putserv "PRIVMSG $chan :\00300,2 ¤ Scrabble ¤ \003"
        putserv "PRIVMSG $chan :\00304Trouver le maximum de mots\00302 français\00304 dans le temps imparti. Pour connaitre les lettres actuelles tapez\00302 !lettre \00302."
	afiseaza:scrabble $chan
	set scrabble($chan:run) 1
}

proc afiseaza:scrabble {chan} {
	global scrabble	
if {[info exists scrabble(stop:it:$chan)]} {
	unset scrabble(stop:it:$chan)
	return 0
}	
	set file [open $scrabble(file) "r"]
	set data [read -nonewline $file]
	close $file
	set words [split $data "\n"]
	set scrabble(current_word:$chan) [lindex $words [rand [llength $words]]]
	set scrabble(word:$chan) [scrabble:process $scrabble(current_word:$chan)]
	set length_word [string length $scrabble(current_word:$chan)]	
	switch -exact -- $length_word {
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
		putserv "PRIVMSG $chan :There are no words in my database. \00312Scrabble\003 stopped."
		scrabble:stop $chan
		return 0		
} 
	putserv "PRIVMSG $chan :\00308,4 ATTENTION \003 \0031 mots\00304 Minimum\00314 de\00304 4\00314 lettres\00309 : \00300,2 $scrabble(word:$chan) \003\00309 - \00314Vous avez \00304$timer_seconds secondes \00314pour trouver un \00304Maximum \00314de mots."
	utimer $timer_seconds [list again:scrabble $chan]
	set scrabble($chan:the_time) $timer_seconds
}

proc again:scrabble {chan} {
	global scrabble
	alege:castigator $chan
	verifica:top:3 $chan
	reset:for:new $chan
	afiseaza:scrabble $chan
}

proc verifica:top:3 {chan} {
	global scrabble
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
set lexten "*|*"
foreach read_host $top_3 {
foreach user [chanlist $chan] {
    if {[string match $lexten $user]} {
        regsub {\|.*$} $user {} user
    }
  if {[string match -nocase "*guest@*" [getchanhost $user $chan]]} {
	 set get_host *!*@[lindex [split [getchanhost $user $chan] "@"] 1]
  } else {
	 set get_host "ip$user"
  }
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
#	puthelp "PRIVMSG $chan :\00304[join $now_voice ", "]\003 \00314reÃ§ois un \00304VOICE (+)\003 \00314because there are in \00304Top 3 Scrabble\003 ."
#} else {
#	puthelp "PRIVMSG $chan :\00304$now_voice\003 \00314reÃ§ois un \00304VOICE (+)\003 \00314because he is in \00304Top 3 Scrabble\003."
			}
		}
	}
}

proc top:3:join {nick host hand chan} {
	global scrabble
	set lexten "*|*"
if {![channel get $chan scrabble]} {
	return 0
}
    if {[string match $lexten $nick]} {
        regsub {\|.*$} $nick {} nick
    }

    if {[string match -nocase "*guest@*" $host]} {
	   set get_host "*!*@[lindex [split $host @] 1]"
	} else {
	   set get_host "ip$nick"
	}
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
#	utimer 3 [list puthelp "PRIVMSG $chan :\00304$nick\003 \00314reÃ§ois un \00304VOICE (+)\003 \00314because he is in \00304Top 3 Scrabble\003 ."]
		}
	}	
}

proc alege:castigator {chan} {
	global scrabble counter
	array set winner [list]
	set nicks ""
if {[info exists scrabble($chan:round_players)]} {
foreach m $scrabble($chan:round_players) {
if {[info exists scrabble($m:current_points)]} {	
	lappend winner($scrabble($m:current_points)) $m
}
}

foreach eq [lsort -integer -increasing [array names winner]] {
set max "$eq"
}

if {[info exists max]} {
  set lexten "*|*"
foreach nick [chanlist $chan] {
if {![isbotnick $nick]} {
  if {[string match $lexten $nick]} {
    regsub {\|.*$} $nick {} nick
  }
   if {[string match -nocase "*guest@*" [getchanhost $nick $chan]]} {
	   set get_host *!*@[lindex [split [getchanhost $nick $chan] "@"] 1]
	} else {
	   set get_host "ip$nick"
	}
foreach hosts $winner($max) {
if {[string match -nocase $get_host $hosts]} {
	lappend nicks $nick
		}
	}
}
}

putserv "PRIVMSG $chan :\00314La réponse alternative était\00309 : \00304$scrabble(current_word:$chan)\003 \00309- \00314 Préparez vous prochain mot dans quelque secondes"
putserv "PRIVMSG $chan :\00304Gagnants rondes\00314 : \00304[join $nicks ", "]\003 \00314avec \00304$max Points\003"
	       runda:castigata $chan $winner($max)		
		}
		set scrabble(is:played:$chan) 1
	}
        putserv "PRIVMSG $chan : "
        putserv "PRIVMSG $chan :\00314Top10 du\00304 Scrabble\00309:\003"  
               afiseaza:topscrabble $chan "general"   
        putserv "PRIVMSG $chan : "
        putserv "PRIVMSG $chan :\00300,2 ¤ Scrabble ¤ \003"
        putserv "PRIVMSG $chan :\00304Trouver des mots\00302 français.\00304 Pour connaitre les lettres actuelles tapez\00302 !lettre."
}

proc runda:castigata {chan args} {
	global scrabble	
	set file [open $scrabble(userfile) "r"]
	set data [read -nonewline $file]
	close $file
	set words [split $data "\n"]
foreach host $args {
foreach line $words {
	set channel [lindex [split $line] 1]
	set get_host [lindex [split $line] 2]
if {[string match -nocase $chan $channel] && [string match -nocase $get_host $host]} {
	lappend current_hosts [join $get_host]
			}
		}
	}
	if {[info exists current_hosts]} {
	  runda:noua $chan $current_hosts
	}
}
		
proc runda:noua {chan hosts} {
	global scrabble the_nick
	set lexten "*|*"
foreach host $hosts {
if {$host != ""} {
	set file [open $scrabble(userfile) "r"]
	set data [read -nonewline $file]
	close $file
	set words [split $data "\n"]
	set i [lsearch -glob $words "* $chan $host *"]
if {$i > -1} {
	set line [lindex $words $i]
	lappend total_general [lindex [split $line] 3]
	lappend runda_curenta [lindex [split $line] 4]
	set delete [lreplace $words $i $i]
	set file [open $scrabble(userfile) "w"] 
	puts $file [join $delete "\n"]
	close $file	
			}
		}		
foreach nick [chanlist $chan] {
     set orinick $nick
    if {[string match $lexten $nick]} {
        regsub {\|.*$} $nick {} nick
    }
   if {[string match -nocase "*guest@*" [getchanhost $orinick $chan]]} {
	   set get_host *!*@[lindex [split [getchanhost $orinick $chan] "@"] 1]
	} else {
	   set get_host "ip$nick"
	}	
if {[string match -nocase $get_host $host]} {
	set the_nick $nick
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

if {[info exists total_general] && [info exists runda_curenta]} {
	set file [open $scrabble(userfile) a]
	puts $file "$the_nick $chan $host [join $total_general] [expr [join $runda_curenta] + 1]"
	close $file
	}
}

proc reset:for:new {chan} {
	global scrabble
if {[info exists scrabble($chan:round_players)]} {	
foreach m $scrabble($chan:round_players) {
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
	putserv "PRIVMSG $chan :\00312Scrabble\003 arrêté. Pour jouer tapez \00304!scrabble\003 ."
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

proc scrabble:process {word} {
	global scrabble ranch_chars	
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

# modif pour couleur première lettre de couleur différente de la suite

proc xystrip {text} {
    regsub -all -- "\003(\[0-9\]\[0-9\]?(,\[0-9\]\[0-9\]?)?)?" $text "" text
    set text "[string map -nocase [list \002 "" \017 "" \026 "" \037 ""] $text]"
    return $text
}

proc preia:cuvant {nick host hand chan arg} {
	global scrabble
	set lexten "*|*"
	set orinick $nick
if {![channel get $chan scrabble]} {
	return 0
}
	set cuvant_dat [join [lindex [split $arg] 0]]
	set cuvant_dat [xystrip $cuvant_dat]
	set correct_word 0
	set the_word 0
	if {[string match $lexten $nick]} {
	   regsub {\|.*$} $nick {} nick
    }
	if {[string match -nocase "*guest@*" $host]} {
	   set mask "*!*@[lindex [split $host @] 1]"
	} else {
	   set mask "ip$nick"
	}
if {![info exists scrabble($chan:run)] && ![info exists scrabble(word:$chan)]} {
	return 0
}

if {[string length $cuvant_dat]	> 3} {
if {[info exists scrabble($chan:round_words)]} {
if {[lsearch -exact [string tolower $scrabble($chan:round_words)] [string tolower $cuvant_dat]] > -1} {
	putserv "PRIVMSG $chan :\00314Désolé \00304$orinick \00314le mot\003 \00304$cuvant_dat\003 \00314a déja été dit..\003"
	return 0
	}
}
	set split_word [string toupper [split $cuvant_dat ""]]
	set split_word_one $split_word
	set split_current [split $scrabble(current_word:$chan) ""]
	set file [open $scrabble(file) "r"]
	set data [read -nonewline $file]
	close $file
	set words [split $data "\n"]	
foreach char $split_current {
	if {[lsearch -exact $split_word $char] > -1} {
	set position [lsearch -exact $split_word $char] 
	set correct_word [expr $correct_word + 1]
	set split_word [lreplace $split_word $position $position]
	}
}

foreach char $split_word_one {
	if {[lsearch -exact $split_current $char] > -1} {
	set position [lsearch -exact $split_current $char] 
	set the_word [expr $the_word + 1]
	set split_current [lreplace $split_current $position $position]
	}
}

if {$correct_word > 3} {	
if {([lsearch -glob $words [string toupper $cuvant_dat]] > -1) && ([string length $cuvant_dat] == $correct_word)} {	
	lappend scrabble($chan:round_words) [join $cuvant_dat]
if {[info exists scrabble($chan:round_players)]} {
if {[lsearch -exact $scrabble($chan:round_players) $mask] < 0} {
	lappend scrabble($chan:round_players) [join $mask]
	}
} else {
	lappend scrabble($chan:round_players) [join $mask]	
}
	
if {($split_current == "") && ([string length $cuvant_dat] == [string length $scrabble(current_word:$chan)])} {
set punctaj 500
scrabble:punctaj $nick $chan $mask $punctaj
anunta:punctaj $nick $chan $mask $cuvant_dat $punctaj
	return 0
} 

switch -exact -- $correct_word {
4 {
set punctaj 30
scrabble:punctaj $nick $chan $mask $punctaj
anunta:punctaj $nick $chan $mask $cuvant_dat $punctaj
}
5 {
set punctaj 35
scrabble:punctaj $nick $chan $mask $punctaj
anunta:punctaj $nick $chan $mask $cuvant_dat $punctaj
}
6 {
set punctaj 40
scrabble:punctaj $nick $chan $mask $punctaj
anunta:punctaj $nick $chan $mask $cuvant_dat $punctaj
}
7 {
set punctaj 50
scrabble:punctaj $nick $chan $mask $punctaj
anunta:punctaj $nick $chan $mask $cuvant_dat $punctaj
}
8 {
set punctaj 60
scrabble:punctaj $nick $chan $mask $punctaj
anunta:punctaj $nick $chan $mask $cuvant_dat $punctaj
}
9 {
set punctaj 90
scrabble:punctaj $nick $chan $mask $punctaj
anunta:punctaj $nick $chan $mask $cuvant_dat $punctaj
}
default {
set punctaj 120
scrabble:punctaj $nick $chan $mask $punctaj
anunta:punctaj $nick $chan $mask $cuvant_dat $punctaj 
						}
					}
				}
			}
		}
	}

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
	set runde [lindex [split $line ] 4]
if {[string match -nocase $mask $usermask] && [string match -nocase $channel $chan]} {	
		set exists_user 1
	}
}

if {[info exists exists_user] && [info exists scrabble($chan:the_time)]} {
	putserv "PRIVMSG $chan :\00304$nick\003 \00314avec le mot \00300,2 $cuvant_dat \003 \00314tu obtiens \00304$punctaj points\003 \00314en \00304[expr $scrabble($chan:the_time) - [get:scrabble:time $chan]] secondes.\003 \00314Ce tour \00309: \00304$scrabble($mask:current_points) points\003 \00309- \00314Tours gagnés \00309: \00304$runde \00309- \00314Total points \00309: \00304$punctaj_citit . \00314Faites vite il vous reste \00304[get:scrabble:time $chan] secondes\003"
	}
}

proc scrabble:stop {chan} {
	global scrabble	
if {[info exists scrabble($chan:round_players)]} {	
foreach m $scrabble($chan:round_players) {
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

foreach tmr [utimers] {
if {[string match "*again:scrabble*" [join [lindex $tmr 1]]]} {
killutimer [lindex $tmr 2]
		}
	}						
}

proc get:scrabble:time {chan} {
	global scrabble time_left
foreach tmr [utimers] {
if {[string match "*again:scrabble $chan*" [join [lindex $tmr 1]]]} {
set time_left [lindex $tmr 0]
	}
}
	return $time_left
}
	
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

putlog "Black Scrabble 1.1 By BLaCkShaDoW Loaded"	
