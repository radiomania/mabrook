#This Script Is Written By BaDBoY^_^ 
#Please Report Any Bugs To Me At badboy@mymail.com.my If You Find One

#Just Replace yourbotpasswd With Your Bot Nick Password

set nickpass "yourbotpasswd"

#Don't Edit Anything Below

bind join - * ident_nickserv
proc ident_nickserv { nick uhost hand args } {
    putlog "Starting To Identify"
    putserv "PRIVMSG nickserv@services.underx.org :identify $nickpass"
    putlog "Identify Progress Done"
  }

#Copyrighted By BaDBoY's TecHnoLoGieS & CoMPanYã 2001
