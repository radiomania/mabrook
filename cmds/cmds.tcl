# |---------------------------------------------------------------------------------|
# |                ____ ____ ____ ____ ____ ____ ____ ____ ____                     |
# |               ||E |||g |||g |||t |||c |||l |||. |||u |||s ||                    |
# |               ||__|||__|||__|||__|||__|||__|||__|||__|||__||                    |
# |               |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|                    | 
# |---------------------------------------------------------------------------------|
# |                                                                                 |
# | *** Website             @  https://www.Eggtcl.us                                |
# | *** GitHub              @  https://github.com/radiomania/mabrook	            |
# |                                                                                 |
# |---------------------------------------------------------------------------------|
# | *** IRC Support:                                                                |
# |                    #UnderX     @ UnderX.iRC.OrG                                 |
# |                                                                                 |
# | *** Contact:                                                                    |
# |                    Google Mail         : tabiligamer@gmail.com                  |
# |                                                                                 |
# |---------------------------------------------------------------------------------|
# |  INSTALLATION: 							            |
# |   ++ add "source scripts/cmds.tcl" to your eggdrop config and rehash the bot.   |
# |									            |
# |---------------------------------------------------------------------------------|
# |                               *** Commands ***                                  |
# |     +----------------+                                                          |
# |     [ ADMIN - PUBLIC ]                                                          |
# |     +----------------+                                                          |
# |      							                    |
# |		To Activate:						            |
# |     ++ .chanset #channel +cmds          	                                    |
# |		To De-activate:					                |
# |     ++ .chanset #channel -cmds                                                  |
# |                                                                                 |
# |---------------------------------------------------------------------------------|
# |                                                                                 |
# | IMPORTANT                                                                       |
# | - Basic IRC Script for FUN                                                      |
# | - To setup basic bot commands in your channel                                   |
# |                                                                                 |
# +---------------------------------------------------------------------------------|

#Main Commands
bind pub - @cmds pub_cmds
bind pub - @list pub_cmds

#Sub Commands
bind pub - @ping pub_ping
bind pub - @idle pub_idle
bind pub - @host pub_host
bind pub - @love pub_love
bind pub - @weather pub_weather
bind pub - @channel pub_channel
bind pub - @ip pub_ip
bind pub - @wiki pub_wiki
bind pub - @currency pub_currency
bind pub - @trivia pub_trivia
bind pub - @movie pub_movie


setudef flag cmds
setudef flag list

#----- Dont Edit If You Dont Know It ----#

proc pub_cmds {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel cmds]} { return 0 }
	putquick "NOTICE $channel :\00301Commands be like:\003 @ping @idle @host @love @weather @channel @ip @wiki @currency @trivia @movie"
    return 0
}


bind pub - @ping pub_ping

proc pub_ping {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel cmds]} { return 0 }
    putquick "NOTICE $channel :Usage: .ping, !ping"
    return 0
}

bind pub - @idle pub_idle

proc pub_idle {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel cmds]} { return 0 }
    putquick "NOTICE $channel :Usage: !idle, !idle <nick>, .i <nick>"
    return 0
}

bind pub - @host pub_host

proc pub_host {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel cmds]} { return 0 }
    putquick "NOTICE $channel :Usage: .h <nick>, !host <nick>"
    return 0
}

bind pub - @love pub_love

proc pub_love {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel cmds]} { return 0 }
    putquick "NOTICE $channel :Usage: .love <nick1 nick2>, !match <nick1 nick2>, !hate <nick1 nick2>"
    return 0
}

bind pub - @weather pub_weather

proc pub_weather {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel cmds]} { return 0 }
    putquick "NOTICE $channel :Usage: !w <city/location>"
    return 0
}

bind pub - @channel pub_channel

proc pub_channel {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel cmds]} { return 0 }
    putquick "NOTICE $channel :Usage: !canfix #channel (only admin), !chanage #channel (Works only for OP or VOICEd users)"
    return 0
}

bind pub - @ip pub_ip

proc pub_ip {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel cmds]} { return 0 }
    putquick "NOTICE $channel :Usage: !ip (nick|IP|host), !dns (nick|IP|host), !iping <ip> / <host> / <website>"
    return 0
}

bind pub - @wiki pub_wiki

proc pub_wiki {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel cmds]} { return 0 }
    putquick "NOTICE $channel :Usage: !wiki <keyword>"
    return 0
}

bind pub - @currency pub_currency

proc pub_currency {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel cmds]} { return 0 }  
    putquick "NOTICE $channel :Usage: !conv php usd"
    return 0
}


bind pub - @trivia pub_trivia
proc pub_trivia {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel cmds]} { return 0 }  
    putquick "NOTICE $channel :Usage: !start (start trivia), !stop (stop trivia)"
    return 0
}

bind pub - @movie pub_movie
proc pub_movie {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel cmds]} { return 0 }  
    putquick "NOTICE $channel :Usage: !imdb <movie name>, !tv search <title>"
    return 0
}

putlog "++ \[ - \00304PUBLIC\003 - \00306loaded\003 * \00303CMDS.TCL\003 modified * BY MABROOK \] ++"
