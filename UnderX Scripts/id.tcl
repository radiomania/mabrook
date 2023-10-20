# ratbox-services-ident.tcl

# toya script prawi bota po-lesno da se identwa w NS
namespace eval auth {
  variable version  1.0

  
  # ID informacia
  variable name     "username"
  variable pass     "password"
  
  # /mode bota +i? 
  variable usex     1
  
  # hosta na NS
  variable service  "NickServ@Services.UnderX.Org"
    
  bind EVNT  -|-   init-server   [namespace current]::connect
}

proc auth::connect {event} {
#  putquick "PRIVMSG Q@CServe.quakenet.org :AUTH Eustace 123asd"
  putquick "PRIVMSG NickServ@Services.UnderX.Org :AUTH username password"
  if {$auth::usex} {
    putquick "MODE $::botnick +i"
  }
}

putlog "Loaded:ident.tcl"