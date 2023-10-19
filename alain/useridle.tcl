bind pub - .idle idler

proc pub:idler {nick uhost hand chan text} {
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
