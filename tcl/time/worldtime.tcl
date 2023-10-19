#--------------------------------------------------------------------------------------------------------------------#
#                                               Wold Time Zone ScRipt By SHaNi IRC-KinG     #
#--------------------------------------------------------------------------------------------------------------------#

#Author : SHaNi - IRC-KinG
#Email : shanizchat@gmail.com
#URL : https://www.Allz4Masti.Com
#Version : 1.2
#Catch me on Irc.Allz4Masti.Com:6667 @ #Chatroom My Nick Is IRC-KinG
package require http

bind pub - .tz worldntime
bind pub - !time worldntime
bind pub - !timez worldntime

proc worldntime {nick uhost hand chan text} {
  if {![throttled2021x $chan:$chan 30]} {  

   if {![llength $text]} { puthelp "privmsg $chan :Usage: $::lastbind <location>"; return 0 }
   set token [http::geturl http://localtimes.mobi/search/?s=[join $text +]&x=0&y=0 -timeout 9000]
   set data [http::data $token]
   ::http::cleanup $token
   if {[regexp -- {Home</a>(.+?)</span>.+?<div class="timeinfo">(.+?)</div>.+?<div class="tz_container">(.+?)</li>} $data - loc t1 t2]} {
      puthelp "privmsg $chan :\00304[cleanup $loc]\003: [cleanup $t1]"
      puthelp "privmsg $chan :[cleanup $t2]"
   } else { puthelp "privmsg $chan :No Information Found For \"$text\". Please, You Can Be More Specific!"; return }
}
   return 0
}
proc cleanup str {
   regsub -all -- {(?:<label>|</label>)} $str \002 str
   regsub -all -- "<.+?>" $str " " str
   regsub -all -- {&raquo;} $str \003\u00bb\00304 str
   regsub -all -- {&nbsp;} $str { } str
   regsub -all -- {\s+} $str { } str
   return $str
}


proc throttled2021x {id time} {
   global throttled
   if {[info exists throttled($id)]} {
      return 1
   } {
      set throttled($id) [utimer $time [list unset throttled($id)]]
      return 0
   }
}