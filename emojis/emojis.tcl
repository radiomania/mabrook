# |---------------------------------------------------------------------------------|
# |                ____ ____ ____ ____ ____ ____ ____ ____ ____                     |
# |               ||E |||g |||g |||t |||c |||l |||. |||u |||s ||                    |
# |               ||__|||__|||__|||__|||__|||__|||__|||__|||__||                    |
# |               |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|                    | 
# |---------------------------------------------------------------------------------|
# |                                                                                 |
# | *** Website             @  https://www.Eggtcl.us                                |
# | *** GitHub              @  https://github.com/radiomania/mabrook	               |
# |                                                                                 |
# |---------------------------------------------------------------------------------|
# | *** IRC Support:                                                                |
# |                    #UnderX     @ UnderX.iRC.OrG                                 |
# |                                                                                 |
# | *** Contact:                                                                    |
# |                    Google Mail         : tabiligamer@gmail.com                  |
# |                                                                                 |
# |---------------------------------------------------------------------------------|
# |  INSTALLATION: 							                                             |
# |  ++ add "source scripts/emojis.tcl" to your eggdrop config and rehash the bot.  |
# |  ++ add "source scripts/utf.tcl" to your eggdrop config and rehash the bot.     |
# |									                                                      |
# |---------------------------------------------------------------------------------|
# |                                                                                 |
# | IMPORTANT                                                                       |
# | - Basic IRC Script for FUN                                                      |
# | - To setup basic bot commands in your channel                                   |
# |                                                                                 |
# +---------------------------------------------------------------------------------|


# Choose your trigger for the bot to use ... use example set cmds "!" or "."# 
set emojis "!"


bind pub - ${emojis}list pub_list
bind pub - ${emojis}rose pub_rose
bind pub - ${emojis}arrow pub_arrow
bind pub - ${emojis}spider pub_spider 
bind pub - ${emojis}fishbone pub_fishbone
bind pub - ${emojis}alien pub_alien
bind pub - ${emojis}love pub_love
bind pub - ${emojis}yolo pub_yolo
bind pub - ${emojis}kiss pub_kiss
bind pub - ${emojis}kissmark pub_kissmark
bind pub - ${emojis}kiss1 pub_kiss1
bind pub - ${emojis}kiss2 pub_kiss2
bind pub - ${emojis}life pub_life

##############################################################################
#    DO NOT EDIT BELOW #
##############################################################################
package require Tcl 8.5
encoding system utf-8
# Ok, here is a problem:
# We need all eggdrop commands.
# The good thing is that all the eggdrop commands are in the global namespace.
# The difficulty is to disingush between eggdrop commands
# And Tcl commands.
# To find out if it is a tcl command I just create an other interp, look at the commands there
# and skip them
# To make sure that this works, source this script as first script.
# Otherwise there might be extra commands in the global namespace that we don't know.
proc initUtf8 {} {
   rename initUtf8 {}
   set i [interp create]
   set tcmds [interp eval $i {info commands}]
   interp delete $i
   set procs [info procs]
   foreach cmd [info commands] {
      if {   $cmd ni $tcmds && $cmd ni $procs
         && "${cmd}_orig" ni [info commands]
         && ![string match *_orig $cmd]
      } {
         # Eggdrop command.
         rename $cmd ${cmd}_orig
         interp alias {} $cmd {} fixutf8 ${cmd}_orig
      }
   }
}
initUtf8
proc fixutf8 args {
   set cmd {}
   foreach arg $args {
      lappend cmd [encoding convertto utf-8 $arg]
   }
   catch {{*}$cmd} res opt
   dict incr opt -level
   return -opt $opt $res
}

##############################################################################
#    YOU CAN EDIT BELOW #
##############################################################################
 
proc pub_list {nick uhost hand channel rest} {
  global botnick emojis
    putquick "NOTICE $nick :!spider !rose !arrow !fishbone !alien !yolo !love !kiss !kiss1 !kiss2 !kissmark !life"
    return 0
}
 
proc pub_spider {nick uhost hand channel arg} {
  global botnick emojis
  set theNick $nick
  if { [llength $arg] == 1 } {
    set theNick [lindex [split $arg] 0]
  }
putquick "PRIVMSG $channel : ...sharing a bigger spider\00304 //\(oo)/\\ \003to \[\00305 $theNick \003\], please feed it with a\00307 _/\__/\__0>\003 (worm)." 
    return 0
}
 
proc pub_rose {nick uhost hand channel arg} {
  global botnick emojis
  set theNick $nick
  if { [llength $arg] == 1 } {
    set theNick [lindex [split $arg] 0]
  }  
putquick "PRIVMSG $channel : ..giving a red rose \00305--------\00303(\00305---\00303(\00304@\003 to \[\00305 $theNick \003\].. " 
    return 0
}
 
proc pub_arrow {nick uhost hand channel arg} {
  global botnick emojis
  set theNick $nick
  if { [llength $arg] == 1 } {
    set theNick [lindex [split $arg] 0]
  }
putquick "PRIVMSG $channel : ..a rebel cupid's \00306,.-~\00304*\00303´¨¯¨`\00313*·~-.¸\003\00304>>------>\003 trying to hit the \00304»-(¯`·.·´¯)-> \003of \[\00305 $theNick \003\].." 
    return 0
}
 
proc pub_fishbone {nick uhost hand channel arg} {
  global botnick emojis
  set theNick $nick
  if { [llength $arg] == 1 } {
    set theNick [lindex [split $arg] 0]
  }
  putquick "PRIVMSG $channel : ..am giving you a fishbone \00307>++('>\003 ..since, you're hungry \[\00305 $theNick \003\], hope you like it..." 
    return 0
}
 
proc pub_alien {nick uhost hand channel arg} {
  global botnick emojis
  set theNick $nick
  if { [llength $arg] == 1 } {
    set theNick [lindex [split $arg] 0]
  }
  putquick "PRIVMSG $channel :..pointing a \00304(==||::::>\003 (knife) ...telling and proving that alien \00302(<>..<>)\003 is real, \[\00305 $theNick \003\], it is REEAALLLL!!!!!" 
    return 0
}
 
proc pub_love {nick uhost hand channel arg} {
  global botnick emojis
  set theNick $nick
  if { [llength $arg] == 1 } {
    set theNick [lindex [split $arg] 0]
  }
  putquick "PRIVMSG $channel :\00307 @('_')@ \003...broadcasting the feeling to \00304»-(¯`·.·´¯)-> \[\00305 $theNick \003\]\00304<-(¯`·.·´¯)-« \003.. \00306(-(-_(-_-)_-)-)\003 (crowd cheering)" 
    return 0
}
 
proc pub_yolo {nick uhost hand channel arg} {
  global botnick emojis
  set theNick $nick
  if { [llength $arg] == 1 } {
    set theNick [lindex [split $arg] 0]
  }
  putquick "PRIVMSG $channel : \00306Y\00302ᵒᵘ\003 \00306O\00302ᶰˡʸ\003 \00306L\00302ᶤᵛᵉ\003 \00306O\00302ᶰᶜᵉ\003 , \[ \00305$theNick\003 \]" 
    return 0
}

proc pub_kiss {nick uhost hand channel arg} {
  global botnick emojis
  set theNick $nick
  if { [llength $arg] == 1 } {
    set theNick [lindex [split $arg] 0]
  }
  putquick "PRIVMSG $channel : .. giving a \00304(❀◉3◉)(ꈍεꈍ●)♡\003 niiice kiss to \[ \00305$theNick\003 \]" 
    return 0
} 
proc pub_kissmark {nick uhost hand channel arg} {
  global botnick emojis
  set theNick $nick
  if { [llength $arg] == 1 } {
    set theNick [lindex [split $arg] 0]
  }
  putquick "PRIVMSG $channel : Kissing Lips. \00304💋 \003to \[ \00305$theNick\003 \]" 
    return 0
} 
proc pub_kiss1 {nick uhost hand channel arg} {
  global botnick emojis
  set theNick $nick
  if { [llength $arg] == 1 } {
    set theNick [lindex [split $arg] 0]
  }
  putquick "PRIVMSG $channel : \00306😚\003 \[ \00305$theNick\003 \] Kissing Face With Closed Eyes." 
    return 0
} 
proc pub_kiss2 {nick uhost hand channel arg} {
  global botnick emojis
  set theNick $nick
  if { [llength $arg] == 1 } {
    set theNick [lindex [split $arg] 0]
  }
  putquick "PRIVMSG $channel : \00306😙\003 \[ \00305$theNick\003 \] Kissing Face With Smiling Eyes." 
    return 0
} 
proc pub_life {nick uhost hand channel arg} {
  global botnick emojis
  set theNick $nick
  if { [llength $arg] == 1 } {
    set theNick [lindex [split $arg] 0]
  }
  putquick "PRIVMSG $channel : \[ \00305$theNick\003 \] \00307(◍◕ᴗ◕)(•ᴗ•❤)\003 I will give you my life." 
    return 0
} 

putlog "++ \[ - \00304PUBLIC\003 - \00306loaded\003 * \00303EMOJIS.TCL\003 * BY MABROOK \] ++"
