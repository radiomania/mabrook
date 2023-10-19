# uhelp.tcl v1.1 by Gemster 2011
#
# Help tcl script with almost all help info for unrealircd with anope services.
# This script will allow all users to simple find a command they want without
# having to navigate through /nickserv help, /chanserv help, /memoserv help
# or by asking nertwork staff. Also adds an extra help system for all users.
#
# To use first unzip uhelp.zip and upload uhelp.tcl to your bots script dir,
# open your eggdrop.conf and add this line to the bottom
# source scripts/uhelp.tcl
# then .rehash or .restart your bot.
#
# Commands are: 
# .help or what ever command you enter in the set hcommand ".htest" section below.
#
# Any errors please email me at admin@gemhosting.info


###########################
# CHANGE THESE 2 SETTINGS #
###########################

#set the command for the bot to respond to in the channel. ie: .help
set hcommand ".help"

#Set your help #channel here. ie: #help
set hchannel "#underx"


#############################################################
# DON'T EDIT BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING. #
#############################################################

bind pub - "$hcommand" pub:help
proc pub:help {nick host hand chan text} { 
  global hchannel
if {"$chan" != "$hchannel"} { 
        return 
        }
    switch -- [string tolower [lindex [split $text] 0]] { 
      "1" { 
        putquick "NOTICE $nick : ...\00312NickServ\003..."
        putquick "NOTICE $nick : \0034 11)\003 Change Nick \0034 12)\003 Register \0034 13)\003 Group Nicks \0034 14)\003 Identify \0034 15)\003 Drop \0034 16)\003 Recover \0034 17)\003 Release \0034 18)\003 Ghost \0034 19)\003 Change Password \0034 20)\003 Set Kill"
      }
      "2" { 
        putquick "NOTICE $nick : ...\00312Chanserv\003..."
        putquick "NOTICE $nick : \0034 21)\003 Register \0034 22)\003 Identify \0034 23)\003 Drop \0034 24)\003 Set \0034 25)\003 AOP \0034 26)\003 SOP \0034 27)\003 VOP \0034 28)\003 Access \0034 29)\003 Akick \0034 30)\003 Levels \0034 31)\003 Clear"
      }
      "3" { 
        putquick "NOTICE $nick : ...\00312Memoserv\003..."
        putquick "NOTICE $nick : \0034 72)\003 Send \0034 73)\003 Read \0034 74)\003 Limit \0034 75)\003 Cancel \0034 76)\003 Delete"
      }
      "4" { 
        putquick "NOTICE $nick : ...\00312Bans\003..."
        putquick "NOTICE $nick : \0034 77)\003 Ban Nick \0034 78)\003 Ident Ban \0034 79)\003 Host Ban"
      }
      "11" { 
        putquick "NOTICE $nick : \0033To Change Your Nick Type:\003 /nick NewNick"
      }
      "12" { 
        putquick "NOTICE $nick : \0033To register your nick Type:\003 /msg NickServ@services.underx.org register password validemail@host.com"
      }
      "13" { 
        putquick "NOTICE $nick : \0033To Your Current Nick To A Target Nick Type:\003 /msg NickServ@services.underx.org GROUP targetnick targetpassword"
      }
      "14" { 
        putquick "NOTICE $nick : \0033To identify to your nick Type:\003 /msg NickServ@services.underx.org identify password"
      }
      "15" { 
        putquick "NOTICE $nick : \0033To drop your nick you must be identified and Type:\003 /msg NickServ@services.underx.org drop"
      }
      "16" { 
        putquick "NOTICE $nick : \0033If someone else is using your nick Type:\003 /msg NickServ@services.underx.org recover nick password"
      }
      "17" { 
        putquick "NOTICE $nick : \0033To release your nickname from NickServ's 'hold' after too many incorrect passwords, or if it took you too long to identify or if you just used the recover command Type:\003 /msg NickServ@services.underx.org release nick password"
      }
      "18" { 
        putquick "NOTICE $nick : \0033To ghost your nick that is still on the server after a ping timeout or some other type of disconnection Type:\003 /msg NickServ@services.underx.org ghost nick password"
      }
      "19" { 
        putquick "NOTICE $nick : \0033To change the password on your nick Type:\003 /msg NickServ@services.underx.org set password NewPassword"
      }
      "20" { 
        putquick "NOTICE $nick : \0033To set a kill timer on your nick to give an alotted amount of time to identify to your nick to prevent imposters using your nick Type:\003 /msg NickServ@services.underx.org set kill on/quick/off"
      }
      "21" { 
        putquick "NOTICE $nick : \0033To register a channel, you must have ops in the channel and it cannot already be registered. Type:\003 /msg ChanServ@services.underx.org register #channel password description"
      }
      "22" { 
        putquick "NOTICE $nick : \0033To identify yourself as the channel founder Type:\003 /msg ChanServ@services.underx.org identify #channel password"
      }
      "23" { 
        putquick "NOTICE $nick : \0033To drop your channel first you must identify as channel founder then Type:\003 /msg ChanServ@services.underx.org drop #channel"
      }
      "24" { 
        putquick "NOTICE $nick : ...\00312Chanserv Set\003..."
        putquick "NOTICE $nick : \0034 32)\003 Set Founder \0034 33)\003 Set Successor \0034 34)\003 Set Password \0034 35)\003 Set Description \0034 36)\003 Set URL \0034 37)\003 Set Email \0034 38)\003 Set EntryMsg \0034 39)\003 Set KeepTopic \0034 40)\003 Set TopicLock \0034 41)\003 Set MLock \0034 42)\003 Set Restricted \0034 43)\003 Set Secure \0034 44)\003 Set SecureOps \0034 45)\003 Set SecureFounder \0034 46)\003 Set OpNotice \0034 47)\003 Set XOP"
      }
      "25" { 
        putquick "NOTICE $nick : ...\00312Chanserv AOP\003..."
        putquick "NOTICE $nick : \0034 48)\003 AOP Add \0034 49)\003 AOP Delete \0034 50)\003 Aop List"

      }
      "26" { 
        putquick "NOTICE $nick : ...\00312Chanserv SOP\003..."
        putquick "NOTICE $nick : \0034 51)\003 SOP Add \0034 52)\003 SOP Delete \0034 53)\003 Sop List"

      }
      "27" { 
        putquick "NOTICE $nick : ...\00312Chanserv VOP\003..."
        putquick "NOTICE $nick : \0034 54)\003 VOP Add \0034 55)\003 VOP Delete \0034 56)\003 Vop List"

      }
      "28" { 
        putquick "NOTICE $nick : ...\00312Chanserv Access\003..."
        putquick "NOTICE $nick : \0034 57)\003 Access Add \0034 58)\003 Access Delete \0034 59)\003 Access List"

      }
      "29" { 
        putquick "NOTICE $nick : ...\00312Chanserv Akick\003..."
        putquick "NOTICE $nick : \0034 60)\003 Akick Add \0034 61)\003 Akick Delete \0034 62)\003 Akick List"

      }
      "30" { 
        putquick "NOTICE $nick : ...\00312Chanserv Levels\003..."
        putquick "NOTICE $nick : \0034 63)\003 Levels Set \0034 64)\003 Levels Disable \0034 65)\003 Levels List \0034 66)\003 Levels Reset"

      }
      "31" { 
        putquick "NOTICE $nick : ...\00312Chanserv Clear\003..."
        putquick "NOTICE $nick : \0034 67)\003 Clear Ops \0034 68)\003 Clear Users \0034 69)\003 Clear Bans \0034 70)\003 Clear Modes \0034 71)\003 Clear Voices"

      }
      "32" { 
        putquick "NOTICE $nick : \0033To change the founder of a channel Type:\003 /msg ChanServ@services.underx.org set #channel founder nick"
      }
      "33" { 
        putquick "NOTICE $nick : \0033To set a successor which becomes the founder if the founder's nick expires or is dropped Type:\003 /msg ChanServ@services.underx.org set #channel successor nick"
      }
      "34" { 
        putquick "NOTICE $nick : \0033To change the password for a channel Type:\003 /msg ChanServ@services.underx.org set #channel password NewPassword"
      }
      "35" { 
        putquick "NOTICE $nick : \0033To change the channel description Type:\003 /msg ChanServ@services.underx.org set #channel desc Description"
      }
      "36" { 
        putquick "NOTICE $nick : \0033To set a URL to be associated with a channel Type:\003 /msg ChanServ@services.underx.org set #channel URL http://url.here.com"
      }
      "37" { 
        putquick "NOTICE $nick : \0033To set an email to be associated with a channel Type:\003 /msg ChanServ@services.underx.org set #channel email email@here.com"
      }
      "38" { 
        putquick "NOTICE $nick : \0033To set an entry message that users will see when joining the channel Type:\003 /msg ChanServ@services.underx.org set #channel entrymsg message"
      }
      "39" { 
        putquick "NOTICE $nick : \0033To set the Keep Topic option which keeps the topic for the channel even if its empty Type:\003 /msg ChanServ@services.underx.org set #channel keeptopic on"
      }
      "40" { 
        putquick "NOTICE $nick : \0033To lock the topic so it cannot be changed using the /topic command Type:\003 /msg ChanServ@services.underx.org set #chanserv topiclock on/off (the /msg ChanServ@services.underx.org set #channel topic NewTopic command may still be used if TopicLock is on)"
      }
      "41" { 
        putquick "NOTICE $nick : \0033To lock certain modes on or off Type:\003 /msg ChanServ@services.underx.org set #channel mlock +modes-modes"
      }
      "42" { 
        putquick "NOTICE $nick : \0033To restrict the use of the channel from all users except the founder Type:\003 /msg ChanServ@services.underx.org set #channel restricted on/off"
      }
      "43" { 
        putquick "NOTICE $nick : \0033To activate ChanServ's security features which ensure a user must me registered and identified to gain access to the channel as their level on the access list allows Type:\003 /msg ChanServ@services.underx.org set #channel secure on/off"
      }
      "44" { 
        putquick "NOTICE $nick : \0033To activate secure ops which prevents random op'ing in a channel Type:\003 /msg ChanServ@services.underx.org set #channel secureops on/off"
      }
      "45" { 
        putquick "NOTICE $nick : \0033To ensure only the true channel founder can drop the channel, change the password, the founder or the successor and not just anyone who is identified to the channel through ChanServ Type:\003 /msg ChanServ@services.underx.org set #channel securefounder on/off"
      }
      "46" { 
        putquick "NOTICE $nick : \0033To send a notice when the ChanServ op/deop command is used Type:\003 /msg ChanServ@services.underx.org set #channel opnotice on/off"
      }
      "47" { 
        putquick "NOTICE $nick : \0033To activate the AOP, SOP, and VOP lists Type:\003 /msg ChanServ@services.underx.org set #channel XOP on"
      }
      "48" { 
        putquick "NOTICE $nick : \0033To add a user to your channel Auto-Op list, the Chanserv XOp mode must be on. Type:\003 /msg ChanServ@services.underx.org AOP #channel add user"
      }
      "49" { 
        putquick "NOTICE $nick : \0033To delete a user from your channel Auto-Op list, the Chanserv XOp mode must be on. Type:\003 /msg ChanServ@services.underx.org AOP #channel del user"
      }
      "50" { 
        putquick "NOTICE $nick : \0033To list all users on the Auto-Op list, the Chanserv XOp mode must be on. Type:\003 /msg ChanServ@services.underx.org AOP #channel list"
      }
      "51" { 
        putquick "NOTICE $nick : \0033To add a user to your channel Super-Op lis, the Chanserv XOp mode must be on. Type:\003 /msg ChanServ@services.underx.org SOP #channel add user"
      }
      "52" { 
        putquick "NOTICE $nick : \0033To delete a user from your channel Super-Op list, the Chanserv XOp mode must be on. Type:\003 /msg ChanServ@services.underx.org SOP #channel del user"
      }
      "53" { 
        putquick "NOTICE $nick : \0033To list all users on the Super-Op list, the Chanserv XOp mode must be on. Type:\003 /msg ChanServ@services.underx.org SOP #channel list"
      }
      "54" { 
        putquick "NOTICE $nick : \0033To add a user to your channel Voice-Op list, the Chanserv XOp mode must be on. Type:\003 /msg ChanServ@services.underx.org VOP #channel add user"
      }
      "55" { 
        putquick "NOTICE $nick : \0033To delete a user from your channel Voice-Op list, the Chanserv XOp mode must be on. Type:\003 /msg ChanServ@services.underx.org VOP #channel del user"
      }
      "56" { 
        putquick "NOTICE $nick : \0033To list all users on the Voice-Op list, the Chanserv XOp mode must be on. Type:\003 /msg ChanServ@services.underx.org VOP #channel list"
      }
      "57" { 
        putquick "NOTICE $nick : \0033To add a user to your channel access list Type:\003 /msg ChanServ@services.underx.org access #channel add user level (the default levels settings vary from can be from -2 to 10, but can be changed using the ChanServ levels command)"
      }
      "58" { 
        putquick "NOTICE $nick : \0033To delete a user from your channel access Type:\003 /msg ChanServ@services.underx.org access #channel del user"
      }
      "59" { 
        putquick "NOTICE $nick : \0033To list all users on the access list and their levels Type:\003 /msg ChanServ@services.underx.org access #channel list"
      }
      "60" { 
        putquick "NOTICE $nick : \0033To set an akick Type:\003 /msg ChanServ@services.underx.org akick #channel add user/ident/host reason"
      }
      "61" {
        putquick "NOTICE $nick : \0033To remove a user from the channel akick list Type:\003 /msg ChanServ@services.underx.org akick #channel del nick/ident/host -OR- /msg ChanServ@services.underx.org akick #channel del EntryNumber"
      }
      "62" {
        putquick "NOTICE $nick : \0033To list all akick's for a channel Type:\003 /msg ChanServ@services.underx.org akick #channel list"
      }
      "63" {
        putquick "NOTICE $nick : \0033To change the levels setting for your channel Type:\003 /msg ChanServ@services.underx.org levels #channel set type level"
      }
      "64" {
        putquick "NOTICE $nick : \0033To disable a function to all users except the founder Type:\003 /msg ChanServ@services.underx.org levels #channel disable type"
      }
      "65" {
        putquick "NOTICE $nick : \0033To list your channel's current levels settings Type:\003 /msg ChanServ@services.underx.org levels #channel list"
      }
      "66" {
        putquick "NOTICE $nick : \0033To reset your channel's levels to the default level settings Type:\003 /msg ChanServ@services.underx.org levels #channel reset"
      }
      "67" {
        putquick "NOTICE $nick : \0033To remove +o from all users on your channel with operator status Type:\003 /msg ChanServ@services.underx.org clear #channel ops"
      }
      "68" {
        putquick "NOTICE $nick : \0033To remove all users from your channel Type:\003 /msg ChanServ@services.underx.org clear #channel users"
      }
      "69" {
        putquick "NOTICE $nick : \0033To remove all bans from your channel Type:\003 /msg ChanServ@services.underx.org clear #channel bans"
      }
      "70" {
        putquick "NOTICE $nick : \0033To remove all modes from your channel Type:\003 /msg ChanServ@services.underx.org clear #channel modes"
      }
      "71" {
        putquick "NOTICE $nick : \0033To remove +v from all users on your channel with voice-op status Type:\003 /msg ChanServ@services.underx.org clear #channel voices"
      }
      "72" {
        putquick "NOTICE $nick : \0033To send a memo your nick must be registered, Type:\003 /msg memoserv send nick/channel Message"
      }
      "73" {
        putquick "NOTICE $nick : \0033To read a memo Type:\003 /msg memoserv read 1-5"
      }
      "74" {
        putquick "NOTICE $nick : \0033To set a limit to the amount of memos you can have at once Type:\003 /msg memoserv set limit number"
      }
      "75" {
        putquick "NOTICE $nick : \0033To cancel the last memo you sent Type:\003 /msg memoserv cancle nick/channel"
      }
      "76" {
        putquick "NOTICE $nick : \0033To delete a memo Type:\003 /msg memoserv del 1-5"
      }
      "77" {
        putquick "NOTICE $nick : \0033To do a nick ban Type:\003 /mode #channel +b nick (effective at only keeping a certain nick out of a channel, easiest to evade)"
      }
      "78" {
        putquick "NOTICE $nick : \0033To do an ident ban Type:\003 /mode #channel +b *!*ident@*.host.com (this is the most commonly used ban, will only ban the single user)"
      }
      "79" {
        putquick "NOTICE $nick : \0033To do a host ban Type:\003 /mode #channel +b *!*@*.host.com (this is the most effective ban, but it will ban all users with the same host)"
      }
      default {
        putquick "NOTICE $nick : \00312Please refer to this list of help files befor you ask a question in this channel.\0033Use .help <number> for the relavent question.\0037 ie: .help 3\003"
        putquick "NOTICE $nick : \0034 1)\003 Nickserv \0034 2)\003 Chanserv \0034 3)\003 Memoserv \0034 4)\003 Bans"
        putquick "NOTICE $nick : \00312 Please Use .help <number> \0037ie: For memoserv questions type .help 3\003"
      }
    }
    }
putlog "LOADED: uhelp.tcl v1.1 by Gemster admin@gemhosting.info"
