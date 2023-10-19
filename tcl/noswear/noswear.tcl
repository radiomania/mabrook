# $Id: noswear.tcl,v1 15/07/2012 10:18:58pm GMT +12 (NZST) IRCSpeed Exp $

# Commands:
# ---------
# PUBLIC: !noswear on
# PUBLIC: !noswear off
# MSG: /msg yourbot noswear #channelname on
# MSG: /msg yourbot noswear #channelname off

#NOTE: Available to Global OP (o) and above, Channel Master (m) and above. 

# Set global trigger here
set sweartrig "!"

# Set global access flags (default: o)
set swearglobflags o

# Set channel access flags (default: m)
set swearchanflags m

# Set your swearword pattern below
set swearwords {
	"fuck"
	"cunt"
	"shit"
	"dumb"
	"bollocks"
	"turd"
	"crap"
	"arsehole"
	"wanker"
	"bastard"
	"spastic"
	"arse"
	"dick"
	"arse"
	"arsehead"
	"arsehole"
	"ass"
	"asshole"
	"bastard"
	"bitch"
	"bloody"
	"bollocks"
	"bugger"
	"bullshit"
	"cock"
	"cocksucker"
	"crap"
	"cunt"
	"damn"
	"damn it"
	"dick"
	"dickhead"
	"dyke"
	"frigger"
	"fuck"
	"holyshit"
	"horseshit"
	"shit"
	"nigga"
	"nigra"
	"piss"
	"prick"
	"pussy"
	"shit ass"
	"shite"
	"slut"
	"spastic"
	"twat"


}

# -----DONT EDIT BELOW-----
bind pub - ${sweartrig}noswear noswear:pub
bind msg - noswear noswear:msg
bind pubm - * noswear:text
bind ctcp - ACTION noswear:act

setudef flag noswear

proc swearTrigger {} {
  global sweartrig
  return $sweartrig
}

proc noswear:pub {nick uhost hand chan arg} {
  global swearglobflags swearchanflags
  if {![matchattr [nick2hand $nick] $swearglobflags|$swearchanflags $chan]} {return}
  if {[lindex [split $arg] 0] == ""} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [swearTrigger]noswear on|off"; return}

  if {[lindex [split $arg] 0] == "on"} {
    if {[channel get $chan noswear]} {putquick "PRIVMSG $chan :\037ERROR\037: This setting is already enabled."; return}
    channel set $chan +noswear
    puthelp "PRIVMSG $chan :Enabled Swearing Protection for $chan"
  }

  if {[lindex [split $arg] 0] == "off"} {
    if {![channel get $chan noswear]} {putquick "PRIVMSG $chan :\037ERROR\037: This setting is already disabled."; return}
    channel set $chan -noswear
    puthelp "PRIVMSG $chan :Disabled Swearing Protection for $chan"
  }
}

proc noswear:msg {nick uhost hand arg} {
  global botnick swearglobflags swearchanflags
  set chan [strlwr [lindex $arg 0]]
  if {![matchattr [nick2hand $nick] $swearglobflags|$swearchanflags $chan]} {return}
  if {![string match "*#*" $arg]} {return}
  if {[lindex [split $arg] 0] == ""} {putquick "NOTICE $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: /msg $botnick noswear #channel on|off"; return}
  if {[lindex [split $arg] 1] == ""} {putquick "NOTICE $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: /msg $botnick noswear $chan on|off"; return}

  if {[lindex [split $arg] 1] == "on"} {
    if {[channel get $chan noswear]} {putquick "NOTICE $nick :\037ERROR\037: This setting is already enabled."; return}
    channel set $chan +noswear
    putquick "NOTICE $nick :Enabled Swearing Protection for $chan"
  }

  if {[lindex [split $arg] 1] == "off"} {
    if {![channel get $chan noswear]} {putquick "NOTICE $nick :\037ERROR\037: This setting is already disabled."; return}
    channel set $chan -noswear
    putquick "NOTICE $nick :Disabled Swearing Protection for $chan"
  }
}

proc noswear:text {nick uhost hand chan arg} {
  global swearwords
  if {[channel get $chan noswear]} {
    foreach pattern $swearwords {
      if {[string match -nocase $pattern $arg]} {
        if {![validuser [nick2hand $nick]] && ![isop $nick $chan] && ![isvoice $nick $chan]} {
          putquick "MODE $chan +b *!*@[lindex [split $uhost @] 1]"
          putquick "KICK $chan $nick :\002\037S\037\002wear-\002\037W\037\002ord \002\037D\037\002etected. Please cease use of profanity while in $chan - Thank you."
        }
      }
    }
  }
}

proc noswear:act {nick uhost hand dest key text} {
  global swearwords
  if {![string match "*#*" $dest]} {return}
  set chan $dest
  if {[channel get $chan noswear]} {
    foreach pattern $swearwords {
      if {[string match -nocase $pattern $text]} {
        if {[botisop $chan] && ![isbotnick $nick]} {
          if {[onchan $nick $chan] && ![validuser $hand] && ![isop $nick $chan] && ![isvoice $nick $chan]} {
            putquick "MODE $chan +b *!*@[lindex [split $uhost @] 1]"
            putquick "KICK $chan $nick :\002\037S\037\002wear-\002\037W\037\002ord \002\037D\037\002etected. Please cease use of profanity while in $chan - Thank you."
          }
        }
      }
    }
  }
}

putlog "Loaded: NoSwear Module. - istok @ IRCSpeed"
