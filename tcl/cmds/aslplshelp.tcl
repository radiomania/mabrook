############################################################################################################################################################################################################
# Support By : http://www.egghelp.org       #
# Support By : Htpp://www.bhasirc.com       #
# Author Script : Indra^Pratama & Novita    #
# Thanks To : Owner Website www.egghelp.org #
# Script modified by: asL_pLs
#---------------- Menu TCL -----------------#
# Added Code By : asL_pLs			        #
# Support By : CrazyCat					    #
# Last Update: August 2021	    			#
# Thanks To : Owner Website www.egghelp.org #
#---------------- CMDS TCL -----------------#
# +        *** Commands ***                 |
# |     +---------------+                   |
# |     [ ADMIN - PUBLIC]                   |
# |     +---------------+                   |
# |      							        |
# |		To Activate:						|
# |     ++ .chanset #channel +menu         	| 
# |		To De-activate:					    |
# |     ++ .chanset #channel -menu          | 
# |                                         |
# +-----------------------------------------+


setudef flag menu


#----- Dont Edit If You Dont Know It ----#

bind pub - !cmds pub_cmds

proc pub_cmds {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel menu]} { return 0 }
	putserv "NOTICE $channel :Commands: @weather @search @games @vote @xmas @quote @virus @news @top @horoscope @seen @yt @shows"
    return 0
}

bind pub - @weather pub_weather

proc pub_weather {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel menu]} { return 0 }
	putserv "NOTICE $nick :!w <city>"
    return 0
}

bind pub - @search pub_search

proc pub_search {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel menu]} { return 0 }
	putserv "NOTICE $nick :!wiki <keyword>; !dict <keyword>; !define <keyword>; .define <keyword>; !jdict <en-keyword> (en-japenese); !jdict <jp-keyword> (japenese-en)"
    return 0
}

bind pub - @games pub_games

proc pub_games {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel menu]} { return 0 }
    putserv "NOTICE $nick :!trivia (enabled); !scrabble(disabled); !textwist(disabled); !farkle(disabled); !lotto(disabled); !bcoin(disabled); !kaos(disabled); !uno(disabled)"
    return 0
}

bind pub - @vote pub_vote

proc pub_vote {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel menu]} { return 0 }
    putserv "NOTICE $nick : Type /msg kakashi vhelp"
    return 0
}

bind pub - @xmas pub_xmas

proc pub_xmas {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel menu]} { return 0 }
    putserv "NOTICE $nick :!xmas"
    return 0
}

bind pub - @quote pub_quote

proc pub_quote {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel menu]} { return 0 }
    putserv "NOTICE $nick :!bq (example. !bq psycho, !bq rich young )"
    return 0
}

bind pub - @virus pub_virus

proc pub_virus {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel menu]} { return 0 }
    putserv "NOTICE $nick :!covid <country>"
    return 0
}

bind pub - @news pub_news


proc pub_news {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel menu]} { return 0 }
    putserv "NOTICE $nick :!bnews <keyword> (example. !bnews google)"
    return 0
}

bind pub - @top pub_top

proc pub_top {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel menu]} { return 0 }
    putserv "NOTICE $nick :!words, !words <month>"
    return 0
}

bind pub - @horoscope pub_horoscope

proc pub_horoscope {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel menu]} { return 0 }
    putserv "NOTICE $nick :.horo <zodiac>; !horo <zodiac>; !horoscope <zodiac>"
    return 0
}

bind pub - @seen pub_seen

proc pub_seen {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel menu]} { return 0 }
    putserv "NOTICE $nick :!seen <nick>; !seen top; !seen stats"
    return 0
}

bind pub - @yt pub_yt

proc pub_yt {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel menu]} { return 0 }
    putserv "NOTICE $nick :!yt; !yt info <num>; (warning: flood)"
    return 0
}

bind pub - @shows pub_shows

proc pub_shows {nick uhost hand channel arg} {
  global botnick
  if {![channel get $channel menu]} { return 0 }
    putserv "NOTICE $nick :!tv <search> [name]; !tv [id]"
    return 0
}


###############################################################################
#---- putlog "Last update August 2021 by asL_pLs and support by CrazyCat" --- #
#---- putlog "Die Menu By Indra^Pratama & Novita Staff BhasIRC Network"  ---- #
#---- putlog "Menu.tcl On Eggdrop or Windrop Only By Indra^Prtama & Novita ---#
#---- putlog "Menu.tcl Success loaded Have A nice Day ------------------------#
###############################################################################