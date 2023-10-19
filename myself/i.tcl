#########################################################################
proc ccodes:filter {str} {
  regsub -all -- {\003([0-9]{1,2}(,[0-9]{1,2})?)?|\017|\037|\002|\026|\006|\007} $str "" str
  return $str
}
bind RAW - PRIVMSG msgcheck
bind RAW - NOTICE msgcheck

proc msgcheck {from key arg} {
 global botnick
 set arg [split $arg]
 set nick [lindex [split $from !] 0]
 set uhost [string range $from [expr [string first "!" $from]+1] e]
 set target [lindex $arg 0]
 if {![string match *#* $target]} { set hand "*" }
 if {[string match *#* $target]} { set hand [nick2hand $nick $target] }
 set text [string range [join [lrange $arg 1 end]] 1 end]
 if {[isbotnick $nick]} {return}
 if {[string match ** $text]} {
  set text [string range [join [lrange $arg 1 end]] 0 end]
 }
 split:pub:msg $nick $uhost $hand $target $text
}
proc split:pub:msg {nick uhost hand target text} {
# if {![string match *#* $target]} {priv:msg $nick $uhost $hand $target $text}
 if {[string match *#* $target]} {pub:msg $nick $uhost $hand $target $text}
}
proc pub:msg {nick uhost hand target text} {
 long:text $nick $uhost $hand $target $text
 caps:lock $nick $uhost $hand $target $text
 no:repeat $nick $uhost $hand $target $text
 no:badword $nick $uhost $hand $target $text
 split:cmd $nick $uhost $hand $target $text
}

proc split:pub:msg {nick uhost hand target text} {
 if {[string match *#* $target]} {pub:msg $nick $uhost $hand $target $text}
}
proc pub:msg {nick uhost hand target text} {
 split:cmd $nick $uhost $hand $target $text
}
proc split:cmd {nick uhost hand chan text} {
 global botnick
 set text [ccodes:filter $text]
 set cmd [lindex $text 0]
 set cmd [string tolower $cmd]
 set string [lrange $text 1 end]
 

 if {($cmd == ".ping") || ($cmd == "!ping")} { pub:ping $nick $uhost $hand $chan $text } 
 if {($cmd == ".i") || ($cmd == "!idle")} { pub:cekidle $nick $uhost $hand $chan $text }
 if {($cmd == ".h") || ($cmd == "!host")} { pub:userhost $nick $uhost $hand $chan $text }
}



##############ping

bind ctcr - PING pingreply
proc pub:ping {nick uhost hand chan text} {
 pingnick $nick
 return 0
}
proc pingnick {nick} {
 putquick "PRIVMSG $nick :\001PING [expr {abs([clock clicks -milliseconds])}]\001"
}
proc pingreply {nick uhost hand dest key args} {
 set pingnum [lindex $args 0]
 set pingserver [lindex [split $::server :] 0]
 if {[regexp -- {^-?[0-9]+$} $pingnum]} {
  putquick "NOTICE $nick :6Your ping reply,3 [expr {abs([expr [expr {abs([clock clicks -milliseconds])} - $pingnum] / 1000.000])}] 6seconds, from3 $pingserver "
 }
}


##############host

proc pub:userhost {nick uhost hand chan text} {
 set ::hostchan $chan
 set target [lindex $text 1]
 if {$target == "*"} { putquick "kick $chan $nick :Bwaha haha haa!!" ; return }
 bind RAW - 311 user:host
 putquick "whois $target"
}
proc user:host {from key args} {
 set chan $::hostchan
 set nick [lindex [split $args] 1]
 set ident [lindex [split $args] 2]
 set host [lindex [split $args] 3]
 putquick "PRIVMSG $chan :6Host3 $nick 14: 3\(6$ident1@6$host\3) "
 unbind RAW - 311 user:host
}


##############cekidle

proc pub:cekidle {nick uhost hand chan text} {
 set ::idlechan $chan
 set text [lindex $text 1]
 bind RAW - 317 idle:cek
 putquick "whois $text :$text"
}
proc idle:cek { from key args } {
 set nick [lindex [split $args] 1]
 set chan $::idlechan
 set idletime [lindex [split $args] 2]
 set signon [lindex [split $args] 3]
 putquick "PRIVMSG $chan :6$nick 14 Idle:3 \( [duration $idletime] 14-3 SignOn: [ctime $signon]\)"
 unbind RAW - 317 idle:cek
}


##############love matcher

bind pub - .love Matcher

proc Matcher {nick uhost hand chan args} {
regsub -nocase -all \[{}] $args "" args
set origargs $args
set args [string tolower $args]
if {[llength $args] < 2} {
 putserv "NOTICE $nick :!04LO04Vo04E! usage .love <nick1> <nick2>"
 return
}

set counter 0
set compatmarker 0
while {$counter != [string length $args]} {
 if {[string range $args $counter $counter] == "l"} {incr compatmarker 2}
 if {[string range $args $counter $counter] == "o"} {incr compatmarker 2}
 if {[string range $args $counter $counter] == "v"} {incr compatmarker 2}
 if {[string range $args $counter $counter] == "e"} {incr compatmarker 2}
 if {[string range $args $counter $counter] == "y"} {incr compatmarker 3}
 if {[string range $args $counter $counter] == "o"} {incr compatmarker 1}
 if {[string range $args $counter $counter] == "u"} {incr compatmarker 3}
 incr counter
}

set compatability 0
if {$counter > 0} {set compatability [expr 5 - ([string length $args] /2)]}
if {$counter > 2} {set compatability [expr 10 - ([string length $args] /2)]}
if {$counter > 4} {set compatability [expr 20 - ([string length $args] /2)]}
if {$counter > 6} {set compatability [expr 30 - ([string length $args] /2)]}
if {$counter > 8} {set compatability [expr 40 - ([string length $args] /2)]}
if {$counter > 10} {set compatability [expr 50 - ([string length $args] /2)]}
if {$counter > 12} {set compatability [expr 60 - ([string length $args] /2)]}
if {$counter > 14} {set compatability [expr 70 - ([string length $args] /2)]}
if {$counter > 16} {set compatability [expr 80 - ([string length $args] /2)]}
if {$counter > 18} {set compatability [expr 90 - ([string length $args] /2)]}
if {$counter > 20} {set compatability [expr 100 - ([string length $args] /2)]}
if {$counter > 22} {set compatability [expr 110 - ([string length $args] /2)]}

if {$compatability < 0} {set compatability 0}
if {$compatability > 100} {set compatability 100}
if {$compatability < 50} {
  set loves "you can believe it.. you can not.. but it is possible that you two are not married yet. I'm sorry... :)"
} elseif {$compatability < 75} {
  set loves "It takes more effort to approach both of your hearts...!!"
} elseif {$compatability < 90} {
  set loves "good start.. getting close to your soul mate.. tweet tweet.. let's be more intimate, arghh...!!"
} else {
  set loves "It's really a match... Just get married... don't forget to invite aslpls, bro...!!"
}
putserv "privmsg $chan :14Compatibility between03 $origargs 10as big as04 $compatability% ($loves)"
return
}

############## thanksforthemode

bind mode - * thanksfor:mode

proc thanksfor:mode { nick host hand chan mode target } {
global botnick
if {$target == $botnick} {
   if {$mode == "+v"} { 
	   puthelp "PRIVMSG $chan :4♥ 7T3h5a28n13k61s1 74f61o64r 53+63v 4♥ 7$nick"
      }
	  if {$mode == "-v"} { 
	   puthelp "PRIVMSG $chan :4♥ 7T3h5a28n13k61s1 74f61o64r 53-63v 4♥ 7$nick"
      }
   if {$mode == "+o"} { 
	   puthelp "PRIVMSG $chan :4♥ 7T3h5a28n13k61s1 74f61o64r 53+63o 4♥ 7$nick"
      }
	  if {$mode == "-o"} { 
	   puthelp "PRIVMSG $chan :4♥ 7T3h5a28n13k61s1 74f61o64r 53-63o 4♥ 7$nick"
      }
	 if {$mode == "+h"} { 
	   puthelp "PRIVMSG $chan :4♥ 7T3h5a28n13k61s1 74f61o64r 53+63h 4♥ 7$nick"
   }
   if {$mode == "-h"} { 
	   puthelp "PRIVMSG $chan :4♥ 7T3h5a28n13k61s1 74f61o64r 53-63h 4♥ 7$nick"
      }
   if {$mode == "+vo"} { 
	   puthelp "PRIVMSG $chan :4♥ 7T3h5a28n13k61s1 74f61o64r 53+63v64o 4♥ 7$nick"
      }
	if {$mode == "-b"} { 
	   puthelp "PRIVMSG $chan :4♥ 7T3h5a28n13k61s1 74f61o64r 53-63b 4♥ 7$nick"
      }
}
}




putlog "isfan.tcl modified by mabrook Loaded"

