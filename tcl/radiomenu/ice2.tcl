#Name of Radio Station
set streamname "RadioMania.Rocks"

#IP of the Icecast server.
set streamip "107.152.32.10"

#Port that Icecast is using, default is 8000.
set streamport "8000"

#Main channel for the radio bot.
set radiochan "#RadioMania"

#Other channel that the bot can advertise to. Bot must be in this channel for this to work. Ice2.tcl only
# sends stream advertisements to this channel and does not send song info.
set otherchan "#RadioMania"

#URL/Link to the stream for listening. This is what listeners need to click to tune in.
set streamurl "6https://radiomania.rocks"

#How often the bot checks the stream when it knows it is down in minutes. Recommend 1 minute.
set offlinetimer "1"

#How often the bot checks the stream when it knows it is online in seconds. Recommend 15 seconds.
set onlinetimer "15"

#Default interval for how often the bot advertises (in minutes). You want to set it to something that isn't
# pure spammage.
set adtimer "15"

#Enables advertising set to the above frequency. 1 for ON and 0 for OFF. This reminds people that the stream
# is online.
set enableadvertise "1"

#Enables Special Announcement, 1 for ON and 0 for OFF. Special announcements are displayed every 720 minutes.
# This feature of the script is very undeveloped and I don't recommend using it.
set specialannounce "1"

#Special Announcement Message
set announcemsg "6RADIOMANIA.ROCKS 1| 7https;//radiomania.rocks 4RadioMania T-Shirts Available Now."

################################################################
#  Don't edit past this stuff unless you're Tido or Henkes :P  #
################################################################


# Binds

bind pub - "!love" love
# If u like the song alot!

bind pub - "!cheese" cheese
# if u hate the song

bind pub - "!coffee" coffee
# if u want a cup of coffee

bind pub - "!song" song
# Show current song playing

bind pub - "!commands" showcommands
#Shows a list of all commands

bind pub - "!help" showcommands
#Same as !commands

bind pub - "!status" status
#Displays the status of the stream

bind pub D "!djon" dj_on
#If the user has the D flag, this sets them as the DJ

bind pub D "!djoff" dj_off
#Removes the user as the DJ

bind pub - "!listeners" listenercheck
#Reports how many listeners there are

bind pub D "!advertise" toggle_advertise
#Turns on/off advertising

bind pub D "!forceadvertise" forceadvertise
#Forces an advertising message to be sent

bind msg D "djforceoff" dj_force_off
#Force-remove a DJ with !djforceoff <nick>, must have D flag

bind pub - "!dj" dj
#Reports the current DJ

bind pub - "!djtime" djtime
#Reports the current DJ Time Slot

bind pub - "!request" request
#Sends a request to the current DJ. !request <artist/song>

bind msg - "request" msg_request
#/msg version of request

bind pub - "!version" iceversion
#Displays the Ice2.tcl version

bind pub m "!newdj" newdj
#Creates a new DJ by adding the D flag

# Varible Resets
set ice2version "1.0RC1 - modified by #Buangons"
set streamstatus "0"
set djnickname ""
if {![info exists dj]} {  set dj ""  }
set oldsong ""
set newsong ""
set newlistener ""
set oldlistener "0"
set forceadsent "0"
set sessionpeak "0"

# Check to make sure StatusCheck timer isn't running when bot rehashes.
if {![info exists statuscheck_running]} {
  timer $offlinetimer [list statuscheck]
  set statuscheck_running 1
}

# Check to make sure Special Announce timer isn't running when bot rehashes.
if {![info exists specialannounce_running]} {
  if {$specialannounce == "1"} {
    timer 720 [list specialmessage]
    set specialannounce_running 1
  }
}


# Check to make sure Advertise timer isn't running when bot rehashes.
if {![info exists adtimer_running]} {
  if {$enableadvertise == "1"} {
    timer $adtimer [list advertise]
    set adtimer_running 1
  }
}

# Output for !help or !showcommands
proc showcommands {nick uhost hand chan arg} {
  global ice2version streamname botnick
  putserv "notice $nick :>>> $botnick Commands - $ice2version<<<"
  putserv "notice $nick :!status >>> Displays the stream's status. If online it shows the song, # of listeners, and the current DJ."
  putserv "notice $nick :!dj >>> Shows current DJ."
  putserv "notice $nick :!listeners >>> Shows the current number of listeners tuned into $streamname."
  putserv "notice $nick :!request (artist+track) >>> Sends a request to the DJ's queue. Example: !request Oasis - Wonderwall"
  putserv "notice $nick :/msg $botnick request (artist+track) >>> Another way to send a request that isn't visable to everyone in the channel."
}

# Turns on and off Advertising. Also lets you set the interval: !advertise X
proc toggle_advertise {nick uhost hand chan arg} {
  global radiochan enableadvertise adtimer
  if {$enableadvertise == "1"} {
    set enableadvertise "0"
    set timerinfo [gettimerid]
    killtimer $timerinfo
    putserv "PRIVMSG $chan :Advertising OFF"
  } else {
    set enableadvertise "1"
    if {$arg == ""} {
      putserv "PRIVMSG $chan :Advertising ON. Frequency set to $adtimer minutes."
    } else {
      set adtimer $arg
      putserv "privmsg $chan :Advertising ON. Frequency changed to $adtimer minutes."
      timer $adtimer [list advertise]
    }
  }
}

# Function that finds out the ID of the advertising timer.
proc gettimerid {} {
    set adtimerinfo [timers]
    set loc1 [string first "advertise" $adtimerinfo]
    set loc1 [expr $loc1 + 10]
    set str1 [string range $adtimerinfo $loc1 999]
    set endloc [string first "\}" $str1]
    set endloc [expr $endloc -1]
    set timerinfo [string range $str1 0 $endloc]
    return $timerinfo
}

# Messages that are displayed when Advertising is enabled.
proc advertise {} {
  global radiochan streamstatus otherchan enableadvertise adtimer forceadsent streamurl streamname
  if {$streamstatus != "0" && $enableadvertise == "1"} {
    putserv "PRIVMSG $radiochan :$streamname is currently broadcasting 4Live! 1Listen in @ $streamurl"
    putserv "PRIVMSG $otherchan :$streamname is currently broadcasting 4Live! 1Listen in @ $streamurl"
    if {$forceadsent == "0"} {timer $adtimer [list advertise]} else {set forceadsent "0"}
    return 1
  }
  return 0
}

# Forces the advertising messages to appear
proc forceadvertise {nick uhost hand chan arg} {
  global streamstatus enableadvertise forceadsent
  if {$streamstatus == "0"} {
    putserv "notice $nick :The stream isn't on-air. Unable to advertise."
    return 0
  } else {
    if {$enableadvertise == "0"} {
      putserv "notice $nick :Advertising isn't enabled."
      return 0
    } else {
      set forceadsent "1"
      set forceadvertised [advertise]
      if {$forceadvertised == "1"} {
        putserv "notice $nick :Done!"
      } else {
        putserv "notice $nick :Advertising message was not sent!"
      }
    }
  }
}

# Special Announcement Message.
proc specialmessage {} {
  global radiochan specialannounce announcemsg
  putserv "PRIVMSG $radiochan : $announcemsg"
  timer 720 [list specialmessage]
  return 0
}

# StatusCheck
# Function that takes the information from Icecast_Online and creates the proper responses.
proc statuscheck {} {
  global radiochan streamstatus newsong oldsong newlistener oldlistener sessionpeak dj enableadvertise otherchan onlinetimer offlinetimer streamurl streamname

  if {$streamstatus == "0"} {
    set oldstatus "0"
  } else {
    set oldstatus "1"
  }
  set newstatus "[icecast_online]"
  if {$newstatus =="0" && $oldstatus == "0"} {
    timer $offlinetimer [list statuscheck]
  }
  if {$newstatus == "1" && $oldstatus == "0"} {
    putserv "NOTICE $radiochan :$streamname is now ON-AIR!! Click to listen: $streamurl"
    putlog "(RADIO) On-Air detected."
    utimer $onlinetimer [list statuscheck]
    if {$enableadvertise == "1"} {
      putserv "PRIVMSG $otherchan :$streamname is now ON-AIR!! Click to listen: $streamurl"

    }
  }
  if {$newstatus == "0" && $oldstatus == "1"} {
    putserv "PRIVMSG $radiochan :$streamname is now off-air."
    set oldlistener "0"
    set sessionpeak "0"
    if {$enableadvertise == "1"} {
      putserv "PRIVMSG $otherchan :$streamname is now off-air."
    }
    putlog "(RADIO) Off-Air detected."
    timer $offlinetimer [list statuscheck]
  }
  if {$newstatus == "1" && $oldstatus == "1"} {
    utimer $onlinetimer [list statuscheck]
    if {$newlistener != $oldlistener} {
      putserv "notice $dj :$newlistener listeners."
      if {$newlistener > $sessionpeak} {
         putserv "NOTICE $radiochan :$streamname currently has $newlistener listeners!"
         set sessionpeak $newlistener
      }
      set oldlistener "$newlistener"
    }
    if {$newsong != $oldsong} {
      putserv "PRIVMSG $radiochan :0,3 ♪♫♪ 0,1 Dj $dj 0,4 0♥♥♥ 4,0 $newsong "
	  set oldsong "$newsong"
    }
  }
}
 
# Icecast_Online
# This is the HTTP Parser that gathers the various data from the status.xsl file.
proc icecast_online { } {
  global streamip streamport streamstatus newsong newlistener
  set pagedata ""
  if {[catch {set sock [socket $streamip $streamport] } sockerror]} {
    putlog "error: $sockerror"
    return 0
  } else {
    puts $sock "GET /status.xsl HTTP/1.1"
    puts $sock "User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.9)"
    puts $sock "Host: $streamip"
    puts $sock "Connection: close"
    puts $sock ""
    flush $sock
    while {![eof $sock]} { append pagedata "[read $sock]" }
  }
  if {[string match *streamdata* $pagedata] == 1} {
    set streamstatus "1"
    set songlocation [string first "Current Song:" $pagedata]
    set songdata1 [string range $pagedata $songlocation 99999]
    set location2 [string first "</tr>" $songdata1]
    set songdata2 [string range $songdata1 0 $location2]
    set songdata3 [string range $songdata2 41 9999]
    set location3 [string first "</td>" $songdata3]
    set location3 [expr $location3 - 1]
    set newsong [string range $songdata3 0 $location3]

    set llocation [string first "Listeners:" $pagedata]
    set countdata1 [string range $pagedata $llocation 99999]
    set llocation2 [string first "</tr>" $countdata1]
    set countdata2 [string range $countdata1 0 $llocation2]
    set countdata3 [string range $countdata2 38 9999]
    set llocation3 [string first "</td>" $countdata3]
    set llocation3 [expr $llocation3 - 1]
    set newlistener [string range $countdata3 0 $llocation3]
    close $sock
    return 1
   
  } else {
    set streamstatus "0"
    close $sock
    return 0
  }
}

# !status function. Diplays the current status of the stream.
proc status {nick uhost hand chan arg} {
  global dj radiochan newsong newlistener streamstatus streamurl streamname
  if {$streamstatus == 1} {
    putserv "PRIVMSG $chan :$streamname is currently broadcasting live @ $streamurl"
    if {$newsong != ""} {putserv "PRIVMSG $chan :5The current song is $newsong with 4 $newlistener  listeners."}
    if {$dj != ""} {putserv "PRIVMSG $chan :The DJ is $dj"}
  } else {
    putserv "PRIVMSG $chan :$streamname is currently offline."
  }
}

# !request X: sends requests to the DJ.
proc request {nick uhost hand chan arg} {
if {[too_many $nick $uhost $hand $arg]} {  return 0  }
  global dj radiochan
  if {$dj == ""} {
    putserv "PRIVMSG $chan :Sorry, there isn't a LIVE 4DJ1 logged in at the moment to take requests."
  } else {
    if {$arg == ""} {
      putserv "notice $nick :You didn't request anything!"
    } else {
      putserv "privmsg $dj :REQUEST($nick)=> $arg"
      putserv "PRIVMSG $chan : Thanks for the request 「 3 $nick 1 」, will be played soon. "
    }
  }
}

# /msg $botnick request X: sends the request to the DJ privately.
  proc msg_request {nick uhost hand arg} {
  if {[too_many $nick $uhost $hand $arg]} {  return 0  }
  global dj radiochan
  if {$dj == ""} {
    putserv "notice $nick :7There isn't a DJ logged in at the moment to take requests."
  } else {
    if {$arg == ""} {
      putserv "notice $nick :You didn't request anything!"
    } else {
      putserv "privmsg $dj :REQUEST($nick)=> $arg"
      putserv "notice $nick :Request sent to $dj :)"
    }
  }
}

# !djon (name): enables DJ status for someone with the D tag
proc dj_on {nick uhost hand chan arg} {
  global dj radiochan djnickname streamurl streamname
  if {$dj != "" && $dj != "$nick" && [onchan $djnickname $radiochan] != "0"} {
    putserv "notice $nick :7There is already a DJ active!"
    return 0
  }
  if {$arg == "" } { set djnickname $nick} else {set djnickname $arg}
  pushmode $radiochan +o $nick
  putserv "TOPIC $radiochan :6!request artist-song 1| Click here to Listen:6 $streamurl 1| Current DJ:5 $djnickname"
  putserv "PRIVMSG $radiochan : You are now listening to 6Dj 4$djnickname, 1Enjoy."
  set dj "$nick"
  putlog "(RADIO) DJ-ON: [nick2hand $nick $chan]"
}

# !djoff: Disables DJ status.
proc dj_off {nick uhost hand chan arg} {
  global dj radiochan djnickname streamurl streamname
  if {$dj != $nick} {
    putserv "notice $nick :You are not the current DJ or you changed your nickname since becoming one."
  } else {
    set dj ""
    set djnickname ""
    pushmode $radiochan -o $nick
    putserv "TOPIC $radiochan :4 $streamname 1| 7$streamurl 1| Current DJ:5 Auto Dj"
    putserv "PRIVMSG $radiochan : Thank you 6Dj 4$nick, 1'till next time..."
        putlog "(RADIO) DJ-OFF: [nick2hand $nick $chan]"
  }
}

# /msg $botnick djforceoff [nick]: Forces off a DJ from having DJ status.
proc dj_force_off {nick uhost hand arg} {
  global djnickname dj radiochan streamurl streamname
  if {$dj == ""} {
    putserv "notice $nick :No DJ currently set to boot off."
    return 0
  } else {
    if {$arg == ""} {
      putserv "notice $nick :You didn't specify a DJ to boot off."
      return 0
    } else {
      set dj ""
      set djnickname ""
      pushmode $radiochan -o $arg
      putserv "TOPIC $radiochan :4 $streamname 1| Click here to Listen:7 $streamurl 1| Current DJ:5 Auto Dj"
      putserv "notice $nick :DJ status removed for $arg."
      putserv "notice $arg :Your DJ'ness was removed by $nick."
      putlog "(RADIO) DJ-FORCEOFF: $arg booted by [nick2hand $nick $chan]"
    }
  }
}

# !dj: displays who the current DJ is.
proc dj {nick uhost hand chan arg} {
  global djnickname radiochan streamname
  if {$djnickname == ""} {
    putserv "PRIVMSG $chan :There currently are no 4DJs1 logged in at the moment."
  } else {
    putserv "PRIVMSG $chan :Dj 4$djnickname 1is the current 「 6$streamname DJ!1」"
  }
}

# !djtime: displays who the current DJ is.
proc djtime {nick uhost hand chan arg} {
  global djnickname radiochan streamname
  if {$djnickname == ""} {
    putserv "PRIVMSG $chan : 6Please see here: 7https://thebuangons.org"
  } 
}


# !listeners: displays how many current listeners there are.
proc listenercheck {nick uhost hand chan arg} {
  global newlistener radiochan streamstatus streamname
  if {$streamstatus == "1"} {
    if {$newlistener == "0"} {
      putserv "PRIVMSG $chan :There aren't any listeners tuned into $streamname :(."
    } elseif {$newlistener =="1"} {
      putserv "PRIVMSG $chan :There is 1 listener tuned into $streamname."
    } else {
      putserv "PRIVMSG $chan :There are $newlistener listeners tuned into $streamname."
    }
  } else {
    putserv "PRIVMSG $chan :$streamname isn't on-air."
  }
}

# !newdj [nick] [handle] [host]: Adds a new user to the bot and gives them the DJ flag (D).
proc newdj {nick host hand chan arg} {
  global radiochan streamname
  set nickname [lindex $arg 0]
  set newhand [lindex $arg 1]
  set newhost [lindex $arg 2]
  if {[validuser $nickname]} {
    putserv "privmsg $nick :There is already a user existing by that handle!"
    return 0
  }
  if {$nickname == ""} {
    putserv "privmsg $nick :You must enter their nickname handle and host!"
    return 0
  }
  if {$newhand == ""} {
    putserv "privmsg $nick :You must enter their nickname handle and host!"
    return 0
  }
  if {$newhost == ""} {
    putserv "privmsg $nick :You must enter their nickname handle and host!"
    return 0
  }
  if {([onchan $nickname $chan])} {
    adduser $newhand $newhost
    chattr $newhand +D
    putserv "privmsg $radiochan :Added $nickname ($newhand) as a $streamname DJ!"
  }
}

# !version: displays the current version of the Ice2.tcl script.
proc iceversion {nick host hand chan arg} {
   global ice2version radiochan botnick
   if {$chan == $radiochan} {
     putserv "PRIVMSG $radiochan : -= #Buangons Undernet IRC Channel =-"
   }
}

# !love function. Diplays if u like the song.
proc love {nick uhost hand chan arg} {
  global dj radiochan newsong newlistener streamstatus streamurl streamname
  if {$streamstatus == 1} {
    putserv "PRIVMSG $chan :$nick really loves 3「1 $newsong 3」1 !"
 }
}

# !song function. Diplays current playing song.
proc song {nick uhost hand chan arg} {
 global dj radiochan newsong newlistener streamstatus streamurl streamname
  if {$streamstatus == 1} {
    putserv "PRIVMSG $chan :$nick, current playing is 3「1 $newsong 3」1!"
 }
}


# !cheese function. Diplays if u hate the song.
proc cheese {nick uhost hand chan arg} {
 global dj radiochan newsong newlistener streamstatus streamurl streamname
  if {$streamstatus == 1} {
    putserv "PRIVMSG $chan :$nick thinks this song3「1 $newsong 3」1is a 7load of cheese!"
 }
}

# !coffee function. Diplays if u wave a coffee.
proc coffee {nick uhost hand chan arg} {
 global dj radiochan newsong newlistener streamstatus streamurl streamname
  if {$streamstatus == 1} {
    putserv "PRIVMSG $chan :$nick thinks this song3「1 $newsong 3」1needs 7a cup of mesmerizing coffee!"
 }
}


proc too_many {nick uhost hand arg} {
  global toomany
  set nk [string tolower $nick]
  set ut [unixtime]
  set nowls [list]

  if {[info exists toomany($nk)]} {
    foreach expire $toomany($nk) {
      if {$ut < $expire} {  lappend nowls $expire  }
    }
  }
  set toomany($nk) $nowls

  if {[llength $nowls] >= 3} {
    putserv "notice $nick : No more than 3 requests in 5 minutes!"
    return 1
  }
  lappend toomany($nk) [expr {$ut + (60 * 05)}]
  return 0
}

bind cron - {*/10 * * * *} expire_too_many

proc expire_too_many {mn hr da mo wd} {
  global toomany
  set ut [unixtime]

  foreach {aname avalue} [array get toomany] {
    set nowls [list]
    foreach expire $avalue {
      if {$ut < $expire} {  lappend nowls $expire  }
    }

    if {![llength $nowls]} {  unset toomany($aname)
    } else {  set toomany($aname) $nowls  }
  }
}

putlog "Ice2 Version $ice2version by #Buangons! :)"
