################################################################
# UnderX Login v1.0
#
# Author: UnderX
#
# Info:
# Script will auth your bot to UnderX ChanServ
# 
##################################################################
# General settings
##################################################################
#
#
set uxuser "myuser"
# Please put here your Registered Username
#
set uxpass "mypass"
# Please put here your Password
#
###################################################################
#                       Code starts here                          
################################################################### 

bind evnt - init-server my:uxlogin
proc my:uxlogint init-server {
  putlog "Starting To Identify"
  putquick "PRIVMSG NickServ@Services.UnderX.Org :AUTH $::uxuser $::uxpass"
  putquick "Identify Progress Done"
}



putlog "UnderX Login v1.0 by UnderX (https://docs.underx.org) loaded"
