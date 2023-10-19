#####################################################
# BanChan 3.4 TCL
#
#  This script is based on ChanBan, but it is not really a new version of it.  After having used ChanBan2.2b.tcl for a few
#  months, it started to really piss me off.  It had a weird timing bug that would start banning/kicking the wrong users.
#  I finally set out to squish the bug, and stared in wide-eye'd amazment at the mess of code.  I started trying to patch
#  it, but it was hopeless.  I started from stratch, and what we have here is a nice clean script.
#####################################################
# v3.0 - Clown-Man, fresh script
# v3.1 - Fixed bug where people with "{" or "}" in their nicks threw off the list functions!
# v3.2 - Fixed a bug where ANY chan the bot joined it would scan nicks!
# v3.3 - Fixed the multiple timer bug (after .rehash)
# v3.4 - Added a different banmask (*!*@host)
# Comments, Suggestions, Bug reports? ClownMan@cgocable.net
#####################################################
# Script by Clown-Man ClownMan@cgocable.net EFnet ( #Cracks #FreeISO #WarezCREW #Faith2000 )
#
# Big thanks goes out to H3llSp4wn for being such an awesome scripter who is willing to let me bug him all day for help :-P
######################################################
# TODO:
#  1) Maybe make a way to warn ppl b4 they get banned like in the old versions (this caused timeing errors b4 ....)
#  2) Add checking for all chans
#  3) A kick b4 the ban so chan ppl can see what's happening
#####################################################
# Options:

# Set the channels you want to check users on
# include the "#" and seperate them by a space.  EG set checkchans "#chan1 #chan3 #otherchan"
set checkchans "#warezcrew #sex #porn"

# Words of channels that will be banned, seperated by a space.  If you put set badchans "badc list"
# the channels that would # be banned are #badchan #chanbadc #listchan #chanthatlists etc ......
set badchans "list warez-world warez_sitez warez&scripts cablewarez98 hyperwarez leechftp 100%warez protonwarez LEETwarez sex porn"

# Minutes between each full check of a channel.  NOTE - do not set this low if you have a lot of people!
# This is a huge load on the server/bot so don't be an idiot and check every 1 min on a chan with 100 people.
# The bot will lag out (or get k-lined)
set intervalcheck 10

# Length of ban for being on the wrong chan (in minutes)
set idiotbantime 3

# The reason listed on the banlist.  This is also used when the bot msgs them saying how long they were banned for and why.
set banmsg "You are not allowed to be in any unwanwated list channels while in #cebu"

#####################################################
# END OF OPTIONS
# Do not edit anything below here unless you are making a version change!
#####################################################

bind JOIN - * banchan:join
bind RAW - 319 banchan:response
bind RAW - 353 banchan:names

if {[string match "*banchan:scan*" [timers]] == 0} {
  timer $intervalcheck banchan:scan
}

proc banchan:names {from keyword nicklist} {
  global checkchans
  set nicklist [banchan:charfilter $nicklist]
  set nicklist [lrange $nicklist 3 end]
  set chanfrom ""
  append chanfrom "*" [lindex $nicklist 2] "*"
  set chanfrom [string tolower $chanfrom]
  if {[string match $chanfrom $checkchans]} {
    return 1
  }
  set currnicknum 0
  set currentnick "b4"
  while {$currentnick != ""} {
    set currentnick [lindex $nicklist $currnicknum]
    if {[string range $currentnick 0 0] == "@" || [string range $currentnick 0 0] == "+" || [string range $currentnick 0 0] == ":"} {
      set currentnick [string range $currentnick 1 end]
    }
    if {[string range $currentnick 0 0] == "@" || [string range $currentnick 0 0] == "+" || [string range $currentnick 0 0] == ":"} {
      set currentnick [string range $currentnick 1 end]
    }
    putserv "WHOIS $currentnick"
    incr currnicknum
  }
}

proc banchan:scan { } {
  global checkchans intervalcheck
  set tocheck [string tolower $checkchans]
  set ccnum 0
  set total [llength $tocheck]
  while {$ccnum < $total} {
    putlog "BanChan: Scanning [lindex $tocheck $ccnum]"
    putserv "NAMES [lindex $tocheck $ccnum]"
    incr ccnum
  }
  if {[string match "*banchan:scan*" [timers]] == 0} {
    timer $intervalcheck banchan:scan
  }
}

proc banchan:join {nick uhost handle channel} {
  global checkchans
  set checkchans [string tolower $checkchans]
  set channel [string tolower $channel]
  set matchpattern "*$channel*"
  if {[string match $matchpattern $checkchans] == 1} {
    putserv "WHOIS $nick"
    return 0
  } else {
    return 0
  }
}

proc banchan:response {from keyword arg} {
  global badchans banmsg idiotbantime checkchans
  set badchans [string tolower $badchans]
  set badchans [concat $badchans]
  set arg [banchan:charfilter $arg]
  set currentchannel "empty"
  set chanlistnum 2
  set nick [lindex $arg 1]
  set matchpattern ""
  while {$currentchannel != ""} {
    set currentchannel [lindex $arg $chanlistnum]
    set currentchannel [string tolower $currentchannel]
    if {$currentchannel == ""} {
      break
    }
    if {$chanlistnum == 2} {
      set currentchannel [string range $currentchannel 1 end]
    }
    if {[string range $currentchannel 0 0] == "@" || [string range $currentchannel 0 0] == "+"} {
      set currentchannel [string range $currentchannel 1 end]
    }
    set currentbannum 0
    while {[llength $badchans] > $currentbannum} {
      set matchpattern "*[lindex $badchans $currentbannum]*"
      if {[string match $matchpattern $currentchannel]} {
        set uhost [getchanhost $nick]
        if {$uhost == ""} {
           return 0
        }
        set tempi [expr [string first @ $uhost] + 1]
        set uhost "*!*@[string range $uhost $tempi end]"
        set chantomsglist [string tolower $checkchans]
        set chantomsgnum 0
        while {$chantomsgnum < [llength $chantomsglist]} {
          set currentchantomsg [lindex $chantomsglist $chantomsgnum]
          if {[onchan $nick $currentchantomsg] == 1} {
            putserv "PRIVMSG $currentchantomsg :$nick is being banned for being on $currentchannel"
          }
          incr chantomsgnum
        }
        utimer 5 [banchan:delayedban $uhost]
        putserv "PRIVMSG $nick :You have been banned for $idiotbantime minutes, because you were in a forbiddon channel ($currentchannel). Please part that channel and return when your ban time is up!"
        return 0
      }
      incr currentbannum
    }
    incr chanlistnum
  }
  return 0
}

proc banchan:delayedban { banhost } {
  global banmsg idiotbantime
  newban $banhost "BanChan3.2" "$banmsg" $idiotbantime
}

proc banchan:charfilter {x {y ""}} {
 for {set i 0} {$i < [string length $x]} {incr i} {
  switch -- [string index $x $i] {
  "\"" {append y "\\\""}
  "\\" {append y "\\\\"}
  "\[" {append y "\\\["}
  "\]" {append y "\\\]"}
  "\{" {append y "\\\{"}
  "\}" {append y "\\\}"}
  default {append y [string index $x $i]}
  }
 }
 return $y
}

putlog "BanChan 3.4 By Clown-Man Loaded"