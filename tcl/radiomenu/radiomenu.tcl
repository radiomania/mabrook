# |-------------------------------------------------------------------------------------|
# |                ____ ____ ____ ____ ____ ____ ____ ____ ____                         |
# |               ||E |||g |||g |||t |||c |||l |||. |||u |||s ||                        |
# |               ||__|||__|||__|||__|||__|||__|||__|||__|||__||                        |
# |               |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|                        | 
# |-------------------------------------------------------------------------------------|
# |                                                                                     |
# | *** Website             @  https://www.Eggtcl.us                                    |
# | *** GitHub              @  https://github.com/cmdsmania/mabrook	                |
# |                                                                                     |
# |-------------------------------------------------------------------------------------+
# | *** IRC Support:                                                                    |
# |                    #UnderX     @ UnderX.iRC.OrG                                     |
# |                                                                                     |
# | *** Contact:                                                                        |
# |                    Google Mail         : tabiligamer@gmail.com                      |
# |                                                                                     |
# |-------------------------------------------------------------------------------------|
# |                               *** Commands ***                                      |
# |     +---------------+                                                               |
# |     [ ADMIN - PUBLIC]                                                               |
# |     +---------------+                                                               |
# |      							                                                    |
# |		To Activate:						                                            |
# |     ++ .chanset #channel +cmds          	                                        |
# |		To De-activate:					                                                |
# |     ++ .chanset #channel -cmds                                                      |
# |                                                                                     |
# |-------------------------------------------------------------------------------------|
# |                                                                                     |
# | IMPORTANT                                                                           |
# | - Basic IRC Script for FUN                                                          |
# | - To setup basic bot commands in your channel                                       |
# |                                                                                     |
# +-------------------------------------------------------------------------------------+


setudef flag cmds


#----- Dont Edit If You Dont Know It ----#

bind pub - !cmds pub_cmds

proc pub_cmds {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel cmds]} { return 0 }
	putserv "PRIVMSG $channel :!like !dislike !listeners !song !url !vote dj djnick !top like/dislike/onair !top dj broadcast/vote"
	putserv "PRIVMSG $channel :cmds Active List"
    return 0
}



putlog "++ \[ - \00304PUBLIC\003 - \00306loaded\003 * \00303CMDS.TCL\003 * BY MABROOK \] ++"