# Bind the !flames command to the flames proc
bind pub -|- !flames flames

# Define the flames proc
proc flames {nick host hand channel arg} {
    # Convert the nicknames to lowercase
    set nick1 [string tolower [lindex [split $arg] 0]]
    set nick2 [string tolower [lindex [split $arg] 1]]
if {$nick1 == "" || $nick2 == ""} {
    putserv "NOTICE $nick :Use !flames nick1 nick2"
    return
}
    # Initialize a counter to zero
    set count 0

    # Iterate through the letters in the first nickname
    for {set i 0} {$i < [string length $nick1]} {incr i} {
        # Get the current letter
        set c1 [string index $nick1 $i]
        # Check if the letter is not present in the second nickname
        if {[string first $c1 $nick2] == -1} {
            # If the letter is not present, increment the counter
            incr count
        }
    }

    # Iterate through the letters in the second nickname
    for {set i 0} {$i < [string length $nick2]} {incr i} {
        # Get the current letter
        set c2 [string index $nick2 $i]
        # Check if the letter is not present in the first nickname
        if {[string first $c2 $nick1] == -1} {
            # If the letter is not present, increment the counter
            incr count
        }
    }

    # Determine the result based on the value of count
    if {$count == 0 || $count == 1} {
putserv "PRIVMSG $channel :$nick1 and $nick2 = Friends."
} elseif {$count >= 2 && $count <= 3} {
putserv "PRIVMSG $channel :5 $nick1 1and6 $nick2 1= 4Lovers."
} elseif {$count >= 4 && $count <= 5} {
putserv "PRIVMSG $channel :5 $nick1 1and6 $nick2 1= 4Affectionate."
} elseif {$count >= 6 && $count <= 7} {
putserv "PRIVMSG $channel :5 $nick1 1and6 $nick2 1= 4Marriage."
} elseif {$count >= 8 && $count <= 9} {
putserv "PRIVMSG $channel :5 $nick1 1and6 $nick2 1= 4Enemies."
} else {
putserv "PRIVMSG $channel :5 $nick1 1and6 $nick2 1= 4Sister/Brother."
}
}
