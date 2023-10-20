Instructions

1.Put countdown.tcl & expr_parse.tcl file inside eggdrop/scripts Directory 
put the countdown folder inside your eggdrop/scripts directory also

2.Edit countdown.tcl file adding your #channelname & Your email address (only used for ppl to email you about the games)

3.Open up the countdown folder and edit config file adding your #channelname

4.Add these two lines too your eggdrop.conf

source scripts/countdown.tcl 
source scripts/expr_parse.tcl

Once all thats done start your eggdrop with the usual ./eggdrop eggdrop.conf or whatever you have named your eggdrop.conf
file Once eggdrop has connected to IRC log into your bots partyline then type .+chan #yourchannelname
Eggdrop will autostart game as soon as it enters the room

Commands
!scores - shows the monthly high scores
!allscores - shows the full list of high scores
!rank - shows your score rankings
!repeat - shows the letters for the current round
!version - shows the script version information
!start - starts the bot if it is stopped
!stop - stops the game if it is running
!enable - enables the game if it is disabled
!disable - disables the game 

Enjoy

