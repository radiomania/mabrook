# SYNTAX (on PartyLine/DCC/CTCP/TELnet): .chanset #channel -/+checkisauth
# ----------
# PUBCMD:
# !checkisreg on|off
# ----------
# MSGCMD:
# /msg botnick checkisreg #channel on|off

namespace eval RegVoice {
    variable verifieduser "*has identified for*"
    setudef flag checkisauth

    bind join - * [namespace current]::joinCheck
    bind raw - 307 [namespace current]::isReg
    bind pub o|o !checkisreg [namespace current]::public
    bind msg o|o checkisreg [namespace current]::message
     
    bind time - * [namespace current]::cleanUp

    proc cleanUp {minute hour day month year} {
       global checkAuth
       if {[info exists checkAuth]} {
          foreach nick $checkAuth {
             if {![onchan $nick]} {
                set pos [lsearch -nocase $nick $checkAuth]
                set checkAuth [lreplace $checkAuth $pos $pos]
             }
          }
       }
    }
     
    proc joinCheck {nick uhost hand chan} {
       global checkAuth
       if {[isbotnick $nick]} return
       if {![channel get $chan checkisauth] || [validuser $hand]} return
       if {[info exists checkAuth]} {
          if {[lsearch -nocase $nick $checkAuth] != -1} return
       }
       lappend checkAuth $nick
       puthelp "WHOIS $nick"
    }

    proc isReg {from keyword text} {
       global checkAuth
       variable verifieduser

       set nick [lindex [split $text] 1]
       if {[info exists checkAuth]} {
          set pos [lsearch -nocase $nick $checkAuth]
          if {$pos != -1} {
             set checkAuth [lreplace $checkAuth $pos $pos]
          }
       }
       if {![string match "*has identified for*" $text]} return
       if {[validuser [nick2hand $nick]]} return
       foreach chan [channels] {
				if {![channel get $chan checkisauth] || ![onchan $nick $chan] || [isop $nick $chan] || [isvoice $nick $chan]} continue
          if {![botisop $chan]} continue
          pushmode $chan +v $nick
       }
    }
     
    proc public {nick uhost hand chan text} {
       if {[scan $text {%s} mode] != 1} {
         puthelp "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: !checkisreg on|off"
         return
       }
       doAction $mode $chan $chan
    }

    proc message {nick uhost hand chan text} {
       if {[scan $text {%s%s} mode channel] != 2} {
          puthelp "PRIVMSG $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: checkisreg #channel on|off"
          return
       }
       if {[string first # $channel] != 0} {
          puthelp "PRIVMSG $nick :\037ERROR\037: Provided channel doesn't seem to correct. \037SYNTAX\037: checkisreg #channel on|off"
          return
       }
       doAction $mode $channel $nick
    }

    proc doAction {mode chan dest} {
       if {![validchan $channel] || ![botonchan $channel]} {
          puthelp "PRIVMSG $dest ::\037ERROR\037: Channel $chan doesn't exist in my database or I'm not on it."
          return
       }
       set status [channel get $chan checkisauth]
       switch -- [string tolower $mode] {
          "on" {
             if {$status} {
                puthelp "PRIVMSG $dest :\037ERROR\037: This setting is already enabled."
             } else {
                channel set $chan +checkisauth
                puthelp "PRIVMSG $dest :Enabled Automatic Register Checking for $chan"
             }
          }
          "off" {
             if {!$status} {
                puthelp "PRIVMSG $dest :\037ERROR\037: This setting is already disabled."
             } else {
                channel set $chan -checkisauth
                puthelp "PRIVMSG $dest :Disabled Automatic Register Checking for $chan"
             }
          }
          default {
             if {![string first # $dest]} {
                puthelp "PRIVMSG $dest :\037ERROR\037: $mode is not an accepted parameter. \037SYNTAX\037: !checkisreg on|off"
             } else {
                puthelp "PRIVMSG $dest :\037ERROR\037: $mode is not an accepted parameter. \037SYNTAX\037: checkisreg #channel on|off"
             }
          }
       }
    }
 }
 
 
putlog "registerednick.tcl by Pororo loaded"