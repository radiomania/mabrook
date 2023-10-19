####################################################################### Script to create an AI bot for a chat room.
# Uses https://www.pandorabots.com/botmaster/en/home for the AI brain
# Written by heartbroken
# version 2.4.3
# More info about the script: http://forum.egghelp.org/viewtopic.php?t=19887&start=45
# 12-26-2107, 4/27/2018 edited/repaired by Branson
# If you need help or have questions,
# go to #koachsworkshop on chat.koach.com and ask for koach
#####################################################################

# Bot's Nickname to Respond to: ex. Fovea, what's 1+1?
set pandoraNick "BORUTO"

#Your Pandora Bot ID. (Feel free to use the existing one if you want,
# but the bot will think it is fovea.

# pandorabots.com will give you a link like this with the botid
# https://www.pandorabots.com/pandora/talk?botid=fba0b9735e362e4d
set botid "fba0b9735e362e4d" 

# enable chat in bot pm : 1 ,disable : 0 or ""
set botpm 1

# user must wait X seconds between messages sent to bot.
set chatstop 1

# .chanset #channel +talk - Turn tells bot to chat in #channel
setudef flag talk

bind pubm - "*" talkto_pub
bind msgm - "*" talkto_pvt

#STOP EDITING HERE

package require http 2.5
if {[catch {package require tls 1.6}]} {
   putcmdlog "https links requires tcltls : https://core.tcl.tk/tcltls/wiki/Download"
   set enabletls 0
} else {
   set enabletls 1
   tls::init -ssl3 0 -ssl2 0 -tls1 1
   http::register https 443 [list ::tls::socket -require 0 -request 1]
}

proc talkto_pub {nick uhost hand chan text} {
   if {![channel get $chan talk] || ([expr {[lsearch -nocase [fix_chars $text] $::pandoraNick*]}] == "-1")} { return 0 }
   talkto $nick $uhost $hand $chan $text
}

proc talkto_pvt {nick uhost hand text} {
   if {[expr {[lsearch -nocase [fix_chars $text] $::pandoraNick*]}] == "-1"} { return 0 }
   if {[string length $::botpm] && $::botpm >= "1"} {
      talkto $nick $uhost $hand $nick $text
   }
   return 0
}

proc talkto {nick uhost hand chan text} {
   global botid
   if {[info exists ::flooder($nick)] && [expr {$::flooder($nick) + $::chatstop}] > [clock seconds]} { return 0 }
 
   regsub -all -nocase $::pandoraNick [fix_chars $text] {} TxT
   set TxTx [string map { " " "+" "?" "+" "]" "+" "[" "+" "{" "+" "}" "+" } $TxT];
   puthelp "privmsg $chan :$nick: [fetch_pandora  https://pandorabots.com/pandora/talk-xml?botid=$botid&custid=0&input=$TxTx]"
  set ::flooder($nick) [clock seconds]
   return 0
}

proc fetch_pandora {pandurl} {

   set pandata [exec curl -sSL $pandurl]
   if {[info exists pandata] && [llength $pandata]} {
      if {![regexp {<that>(.*?)</that>} $pandata -> responce]} {
         return -code error "This regex sucks!!! Source codes changed or what?!?"
      } else {
         return [fix_talk $responce]
      }
   }
}

proc fix_chars {txt} {
   return  [string trim $txt "?"]
}

proc fix_talk {str} {
   return [string map {"&nbsp;" " " "&amp;" {\&} "&quot;" "\'" "&copy;" "(c)" "&#" "#" "&lt;" "<" "&gt;" ">" "%20" " "} $str]
}

putlog "Loaded  pandora.2.4.4.tcl"