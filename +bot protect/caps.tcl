## caps.tcl

# set bot user flags to ignore text
set vCapsFlagsAllow fo

# set text length (excluding spaces) to allow without checking
set vCapsLengthAllow 4

# set maximum percentage caps allowed (calculation excludes spaces in text)
# greater than 0, less than or equal to 100
set vCapsPercentAllow 40

# set number of warnings before punishing
# integer value equal to or greater than 1
set vCapsWarnings 1

# set here the mode of punishment
# 1 == kick only (after warnings)
# 2 == kickban (after warnings)
set vCapsPunishMode 2

# time in minutes within which a warning remains valid
# even after the user is punished, passed offences remain valid for this time period
# hence a user could be punished twice for two consecutive offences
set vCapsSinTime 20

# if punishment mode 2, set here the time in minutes the ban lasts
set vCapsBanTime 60

# Set this to 1 to ignore nicks in lines
set vIgnoreNick 1

# Channel - canal o canales donde estara activa la tcl usa espacio ejemplo #micanal #beni #eggdrop
set capschans "#underx #aslpls #vhost #Bingo #trivia #help"

bind PUBM - * pCapsDetect

proc pCapsDetect {nick uhost hand chan text} {
    global vCapsBanTime vCapsFlagsAllow vCapsLengthAllow vCapsPercentAllow
    global vCapsPunishMode vCapsSinBin vCapsSinTime vCapsWarnings capschans banmask
    if {[botisop $chan]} {
	if {[matchattr $nick mo|mo $chan] || [isop $nick $chan] || [isvoice $nick $chan] || [matchattr $nick o|o $chan]} {return 0}
	if {[lsearch -exact [split [string tolower $capschans]] [string tolower $chan]] == -1} {return 0}
        if {![matchattr [nick2hand $nick] $vCapsFlagsAllow $chan]} {
         if {$::vIgnoreNick == 1} {
            set nicks [chanlist $chan]
            set text [join [ldiff [split $text] $nicks]]
         }
            set caps [regexp -all -- {[A-Z]} $text]
            set total [string length [regsub -all -- {[\s]} $text {}]]
            if {$total > $vCapsLengthAllow} {
                set percent [expr {$caps * 100.0 / $total}]
                if {$percent > $vCapsPercentAllow} {
                    set now [unixtime]
                    set max [expr {$now - ($vCapsSinTime * 60)}]
                    lappend vCapsSinBin(${nick},$chan) $now
                    foreach sin $vCapsSinBin(${nick},$chan) {
                        if {$sin >= $max} {lappend newlist $sin}
                    }
                    set vCapsSinBin(${nick},$chan) $newlist
                    if {[llength $vCapsSinBin(${nick},$chan)] > $vCapsWarnings} {
                        switch -- $vCapsPunishMode {
                            1 {}
                            2 {
                                set banmask "*!*[string range $uhost [string first "@" $uhost] end]"
								putquick "MODE $chan +b $banmask"
                                flushmode $chan
                                timer $vCapsBanTime [list pushmode $chan -b $banmask]
                            }
                            default {return 0}
                        }
                        putquick "KICK $chan $nick :Please disable Caps, thank you. - [count:kicks] -"
                    } else {
                        set output "Please disable Caps, thank you. - 1(Notice [llength $vCapsSinBin(${nick},$chan)])"
                        putquick "PRIVMSG $chan :1$nick $output"
                    }
                }
            }
        }
    }
    return 0
}


proc ldiff {list1 list2 {option -exact}} {
   if {$option ne "-nocase"} { set option -exact }
   return [lmap x $list1 {expr {[lsearch $option $list2 $x] < 0 ? $x : [continue]}}]
}

proc lintersect {list1 list2 {option -exact}} {
   if {$option ne "-nocase"} { set option -exact }
   return [lmap x $list1 {expr {[lsearch $option $list2 $x] >= 0 ? $x : [continue]}}]
}

proc count:kicks {} { 
    set increment_count "/home/mabrook/eggdrop/scripts/contadorkicks.db" 
    if { ![file exists $increment_count] } { putlog "contadorkicks.db Not exist.";return } 

    set open_text [open $increment_count "r"] 
    set KICKCOUNT [read -nonewline $open_text] 
    close $open_text 
    incr KICKCOUNT 

    set re_open_text [open $increment_count "w"] 
    puts $re_open_text $KICKCOUNT 
    close $re_open_text 

    return $KICKCOUNT 
}

putlog "Caps.tcl by arfer is loaded"