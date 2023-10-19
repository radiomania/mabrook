### Introduction
# Anti Bad-Nick Script
# SadSalman <-> salman.mehmood@gmail.com
# Version No: 0.2


### Features:
# * Sets a 2 Minute Channel ban on user who writes any of the
#   defined bad words
# * Doesn't ban users with +o OR +f flags
# * Logs ALL user/op messages containing the defined words
# * Strips Character Codes from Messages

### Set Bad Words that you want the Bot to Kick on
set badnicks { 
"sex"
"fuck"
"randi"
"s3x"
"hot"
"lund"
"horny"
"Naughty*"
"horny*"
}

### Set Your Ban Reason
set badnickreason "Bad Nick, Please change it and rejoin"

### Set Ban Time
set bnduration 24h

### Begin Script:
## (Don't change anything below here... Unless you know tcl)


## Binding all joins to our Process
bind join - * filter_bad_nicks
bind nick - * filter_bad_nicks_change

## Starting Process
proc filter_bad_nicks {nick uhost hand channel} {
 global badnicks badnickreason banmask botnick bnduration
  set handle [nick2hand $nick]
   set banmask "*$nick*!*@*" 
	foreach badnick [string tolower $badnicks] {     
	if {[string match *$badnick* [string tolower $nick]]}  {
       if {[matchattr $handle +f]} {
           putlog "-Anti Bad Nick Script- $nick ($handle) with +f joined $channel"
       } elseif {[matchattr $handle +o]} {
           putlog "-Anti Bad Nick Script- $nick ($handle) with +o flags joined $channel"
       } else {
           putlog "-Anti Bad Nick Script- KICKED $nick on $channel"
           putquick "KICK $channel $nick :$badnickreason"
           newchanban $channel $banmask $botnick $badnickreason $bnduration
       }
    }
  }
}

## Starting Process
proc filter_bad_nicks_change {nick uhost hand channel newnick} {
 global badnicks badnickreason banmask botnick
  set handle [nick2hand $newnick]
   set banmask "*$newnick*!*@*" 
   set duration 10m
	foreach badnick [string tolower $badnicks] {     
	if {[string match *$badnick* [string tolower $newnick]]}  {
       if {[matchattr $handle +f]} {
           putlog "-Anti Bad Nick Script- $nick ($handle) with +f changed nickname to $newnick on $channel"
       } elseif {[matchattr $handle +o]} {
           putlog "-Anti Bad Nick Script- $nick ($handle) with +o flags changed nickname to $newnick on $channel"
       } else {
           putlog "-Anti Bad Nick Script- KICKED $newnick on $channel"
           putquick "KICK $channel $newnick :$badnickreason"
           newchanban $channel $banmask $botnick $badnickreason 2m
       }
    }
  }
}


bind join - * filter_bad_nicks
bind nick - * filter_bad_nicks_change
putlog "SadSalman's Anti Bad Nick Script Loaded"