bind pub - .host userhost

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
