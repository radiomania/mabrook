bind mode - * thanksfor:mode

proc thanksfor:mode { nick host hand chan mode target } {
global botnick
if {$target == $botnick} {
   if {$mode == "+v"} { 
	   puthelp "PRIVMSG $chan :4♥ 7T3h5a28n13k61s1 74f61o64r 53+63v 4♥ 7$nick"
      }
	  if {$mode == "-v"} { 
	   puthelp "PRIVMSG $chan :4♥ 7T3h5a28n13k61s1 74f61o64r 53-63v 4♥ 7$nick"
      }
   if {$mode == "+o"} { 
	   puthelp "PRIVMSG $chan :4♥ 7T3h5a28n13k61s1 74f61o64r 53+63o 4♥ 7$nick"
      }
	  if {$mode == "-o"} { 
	   puthelp "PRIVMSG $chan :4♥ 7T3h5a28n13k61s1 74f61o64r 53-63o 4♥ 7$nick"
      }
	 if {$mode == "+h"} { 
	   puthelp "PRIVMSG $chan :4♥ 7T3h5a28n13k61s1 74f61o64r 53+63h 4♥ 7$nick"
   }
   if {$mode == "-h"} { 
	   puthelp "PRIVMSG $chan :4♥ 7T3h5a28n13k61s1 74f61o64r 53-63h 4♥ 7$nick"
      }
   if {$mode == "+vo"} { 
	   puthelp "PRIVMSG $chan :4♥ 7T3h5a28n13k61s1 74f61o64r 53+63v64o 4♥ 7$nick"
      }
	if {$mode == "-b"} { 
	   puthelp "PRIVMSG $chan :4♥ 7T3h5a28n13k61s1 74f61o64r 53-63b 4♥ 7$nick"
      }
}
}




putlog "thanksfor.tcl modified by mabrok Loaded"
