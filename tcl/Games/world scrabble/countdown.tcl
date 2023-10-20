# TODO
#
# 1. Add option for sequential games rather than choosing a random type.
# 2. Add support for streaks (monthly stat?)
# 3. Web interface to edit config file options + dictionary
# 4. Add automatic detection of new month - set channel topic + add autovoice
# 5. Add !rank <username>
# 6. Config file validation
# 7. Solver for numbers game that prints answer if no one gets it
# 8. Allow use of "x" as well as "*" in number games.
# 9. Write scores to html
# 10. Instructions/help page or command
# 11. More time for numbers games

# Idea: hourly winner notification (but don't store)

namespace eval ::games::countdown {
	variable game_channel "#alain"
	variable command_char "!"
	variable use_notice 1
	variable round_time 30
	variable warning_time 20
	variable delay_time 20
	variable letters_count 9
	variable letters_distribution "AAAAAAAAABBCCDDDDEEEEEEEEEEEEFFGGGHHIIIIIIIIIJKLLLLMMNNNNNNOOOOOOOOPPQRRRRRRSSSSTTTTTTUUUUVVWWXYYZ"
	variable numbers_distribution "LLSSSS"
	variable numbers_count 6
	variable numbers_points1 40
	variable numbers_points2 20
	variable numbers_points3 10
	variable numbers_points4 5
	variable letters_bonus 10
	variable conundrum_points 30
	variable conundrum_length 9
	variable game_distribution "LLLLNNC"
	variable scores_entries 10
	variable auto_start 0
	variable colours "1,15"
	variable debug 0
	
    variable script_name "World Scrabble Script"
    variable script_version "1.5.8"
    variable script_author "World Scrabble Script"
	variable script_email "kasikas.ako@gmail.com"
	
	variable data_dir "scripts/countdown"
	variable dictionary_file "$data_dir/dictionary"
	variable scores_file "$data_dir/scores"
	variable config_file "$data_dir/config"
	variable game_status 1
	variable game_timer1 0
	variable game_timer2 0
	variable game_letters
	variable game_wordss
	variable game_longestwords
	variable game_bestanswer
	variable game_type
	variable game_scrambled
	variable game_start_time
	variable game_numbers
	variable game_numbers_target
	variable game_numbers_solution
	variable countdown_dict
	variable countdown_scores
	
	array set countdown_dict { }
	array set countdown_scores { }
	
	bind pubm - * [namespace current]::public_trigger
	bind evnt - prerehash [namespace current]::abort_game
	bind evnt - disconnect-server [namespace current]::abort_game
	bind evnt - sigterm [namespace current]::save_scores_evnt
	bind evnt - sigquit [namespace current]::save_scores_evnt
	bind evnt - prerestart [namespace current]::save_scores_evnt
	bind join - * [namespace current]::handle_join
	bind time - "?0 * * * *" [namespace current]::save_scores
	bind time - "?5 * * * *" [namespace current]::save_scores
	
	proc init { } {
		variable countdown_dict
		variable countdown_scores
		
		load_config
		
		if { [array size countdown_scores] == 0 } {
			load_scores
		}
		
		if { [array size countdown_dict] == 0 } {
			set st [unixtime]
			putlog "\[Countdown\] Loaded [load_dictionary] words from dictionary file in [duration [expr [unixtime] - $st]]."
		}
		
		return 0
	}
	
	proc abort_game { type } {
		global ::botnick
		variable game_channel
	
		stop_game $botnick $game_channel
		return 0
	}
	
	proc save_scores_evnt { type } {
		save_scores 0 0 0 0 0
		return 0
	}
	
	proc handle_join { nickname userhost handle channel } {
		variable auto_start
		variable game_channel
	
		if { [isbotnick $nickname] && [string compare -nocase $channel $game_channel] == 0 && $auto_start == 1 } {
			start_game $nickname $channel
		} elseif { [string compare -nocase $channel $game_channel] == 0 } {
			show_ranks $nickname
		}
		
		return 0
	}
	
	proc load_config { } {
		variable game_channel
		variable command_char
		variable use_notice
		variable round_time
		variable warning_time
		variable delay_time
		variable letters_count
		variable letters_distribution
		variable numbers_distribution
		variable numbers_count
		variable letters_bonus
		variable conundrum_points
		variable conundrum_length
		variable game_distribution
		variable scores_entries
		variable auto_start
		variable colours
		variable config_file
		variable debug
		variable numbers_points1
		variable numbers_points2
		variable numbers_points3
		variable numbers_points4
			
		if [catch { open $config_file r } fd] {
			putlog "Failed to open config file '$config_file'."
			return -1
		} else {
			gets $fd data
			
			set data [string trim $data]
		 
			while { $data != "" } {
				if {[string index $data 0] != "#"} {
					set cvar [split $data "="]
					set var [lindex $cvar 0]
					set val [lindex $cvar 1]
					
					if { $var != "" } {
						set $var $val
					}				
				}
				
				gets $fd data
			}		
			
			close $fd
		}	
		
		return 0
	}
	
	proc load_dictionary { } {
		variable countdown_dict
		variable dictionary_file
		variable conundrum_length
		
		set countdown_dict(*CONUNDRUMS*) { }
		
		putlog "\[Countdown\] Loading dictionary file (this may take several minutes)"
		
		if [catch { open $dictionary_file r } fd] {
			putlog "Failed to open dictionary file '$dictionary_file'."
			return -1
		} else {
			fconfigure $fd -buffering line
			gets $fd data
			set wcount 0
		 
			while { $data != "" } {
				set lf [letter_frequency $data]
				set countdown_dict([string toupper $data]) $lf
				
				if {[string length $data] == $conundrum_length} {
					lappend countdown_dict(*CONUNDRUMS*) [string toupper $data]
				}
				
				incr wcount 1
				gets $fd data
			}
			
			close $fd
		}
		
		return $wcount
	}
	
	proc find_words { letters } {
		variable countdown_dict
		
		set lf [letter_frequency [join $letters ""]]
		set result [list]
		
		foreach word [array names countdown_dict] {
			if {[is_anagram_lf $countdown_dict($word) $lf]} {
				lappend result $word
			}
		}
		
		return $result
	}
	
	# takes a list of words as input and returns a list of the longest words
	proc longest_words { words } {
		set x 0
		set result [list]
		
		foreach word $words {
			if {[string length $word] > $x} {
				set x [string length $word]
				set result [list $word]
			} elseif {[string length $word] == $x} {
				lappend result $word
			}
		}
		
		return $result
	}
	
	proc is_word { word } {
		variable countdown_dict
		
		return [info exists countdown_dict([string toupper $word])]
	}
	
	proc is_anagram { letters letters2 } {
		set lf [letter_frequency [join $letters ""]]
		set lf2 [letter_frequency [join $letters2 ""]]
		return [is_anagram_lf $lf $lf2]
	}
	
	proc is_anagram_lf { lf lf2 } {
		if {[llength $lf] != 26 || [llength $lf2] != 26} {
			return 0
		}
		
		for { set i 0 } { $i < 26 } { incr i } {
			set v [lindex $lf $i]
			set v2 [lindex $lf2 $i]
			
			if {![string is integer $v] || ![string is integer $v2] || $v > $v2} {
				return 0
			}
		}
		
		return 1
	}
	
	proc letter_frequency { word } {
		set freq_data [lrepeat 26 0]
		
		for { set i [expr [strlen $word] - 1] } { $i >= 0  } { incr i -1 } {
			set c [string toupper [string index $word $i]]
			
			if {[string is alpha $c]} {
				set ccode [scan $c %c]
				set j [expr $ccode - 65]
				set count [lindex $freq_data $j]
				set freq_data [lreplace $freq_data $j $j [expr $count + 1]]
			}
		}
		
		return $freq_data
	}
	
	proc choose_letters { } {
		variable letters_distribution
		variable letters_count
	
		for { set i 0 } { $i < $letters_count } { incr i } {
			set rand [expr int(rand() * [string length $letters_distribution])]
			set l [string index $letters_distribution $rand]
			
			lappend letters $l
		}
	
		return $letters
	}
	
	proc choose_numbers { } {
		variable numbers_distribution
		variable numbers_count

		set large_count 0
		for { set i 0 } { $i < $numbers_count } { incr i } {
			set r [rand [string length $numbers_distribution]]
			set ntype [string index $numbers_distribution $r]

			if { $ntype == "L" && $large_count < 4 } {
				set large_numbers [list 25 50 75 100]
				set r [rand [llength $large_numbers]]
				lappend numbers [lindex $large_numbers $r]
				incr large_count
			} else { 
				lappend numbers [expr [rand 10] + 1]
			}
		}
	
		return $numbers
	}
	
	proc eval_expression { expression nlist } {
		# strip any whitespace from expression
		regsub -all {[ ]+} $expression "" expression
		
		# check for valid content: num + - * / ( ) x
		if { ![regexp {^[0-9*+-/()]*$} $expression] } {
			error "invalid input expression for numbers game."
		}
		
		# check brackets match
		set ob 0
		for { set i 0 } { $i < [string length $expression] } { incr i } {
			if { [string index $expression $i] == "(" } {
				incr ob
			} elseif { [string index $expression $i] == ")" } {
				incr ob -1
				if { $ob < 0 } { error "unmatched parentheses in input expression" }
			}
		}
		if { $ob > 0 } { error "unmatched parentheses in input expression" }
		
		# find the numbers in the string
		regsub -all {[^0-9]} $expression " " numbers
		regsub -all {[ ]+} $numbers " " numbers
		set numbers [split [string trimleft [string trimright $numbers]]]
		
		# check numbers are a valid subset of nlist, disallowing reuse
		set tmp $nlist
		foreach n $numbers {
			set i [lsearch -integer $tmp $n] 
			if { $i == -1 && [lsearch -integer $nlist $n] == -1 } {
				error "invalid numbers used"
			} elseif { $i == -1 } {
				error "one or more numbers were reused"
			} else {
				set tmp [lreplace $tmp $i $i]
			}
		}
		
		# try to evaluate the expression
		set expression [expr::ExprConv $expression]
		set expression [string map { + add - sub * mul / div } $expression]

		if { [catch { eval set result $expression } err] } {
			if { [string match "*results of*" $err] } {
				error $err
			} else {
				error "invalid input expression for numbers game"
			}
		} else {
			return $result
		}
	}
	
	proc add { a b } {
		if { $a < 1 || $b < 1 } {
			error "inputs must be positive integers"
		}
		
		incr a $b
	}
	
	proc sub { a b } {
		if { $a < 1 || $b < 1 } {
			error "inputs must be positive integers"
		} 
		
		set r [expr $a - $b]
	
		if { $r < 1 } {
			error "results of subtraction must be positive integers"
		}
		
		return $r
	}

	proc mul { a b } {
		if { $a < 1 || $b < 1 } {
			error "inputs must be positive integers"
		}
		
		expr $a * $b
	}
	
	proc div { a b } {
		if { $a < 1 || $b < 1 } {
			error "inputs must be positive integers"
		} elseif { [expr $a % $b] } {
			error "results of division must be positive integers"
		}
		
		expr $a / $b
	}	

	proc scramble { letters } {
		set letters [join $letters ""]
		set wordlen [string length $letters]
		set result [list]
		
		for { set i 0 } { $i < $wordlen } { incr i } {
			set rand [expr int(rand() * [string length $letters])]
			set letter [string index $letters $rand]
			set letters [string replace $letters $rand $rand ""]
			lappend result $letter
		}
	
		return $result
	}
	
	proc new_game { } {
		variable game_letters
		variable game_words
		variable game_longestwords
		variable game_channel
		variable warning_time
		variable round_time
		variable game_timer1
		variable game_timer2
		variable game_bestanswer
		variable game_distribution
		variable game_type
		variable game_status
		variable game_scrambled
		variable game_start_time
		variable game_numbers
		variable game_numbers_target
		variable countdown_dict
			
		kill_timers
		
		set game_type [string index $game_distribution [expr int(rand() * [string length $game_distribution])]]
	
		if { $game_type == "C" } {
			set game_letters [lindex $countdown_dict(*CONUNDRUMS*) [expr int(rand() * [llength $countdown_dict(*CONUNDRUMS*)])]]
			set game_scrambled [join [scramble $game_letters]]
			send_msg $game_channel "[bold]\[CONUNDRUM\][bold] -4 $game_scrambled 1- (unscramble these letters to make a word using all the letters)"
			send_debug $game_channel "Solution: $game_letters"
		} elseif { $game_type == "N" } {
			set game_numbers [lsort -integer -decreasing [choose_numbers]]
			set game_numbers_target [expr [rand 899] + 100]
			set game_numbers_solution "TBC"
			set game_bestanswer [list]

			send_msg $game_channel "[bold]\[NUMBERS\][bold] -4 [join $game_numbers]1 - (use these numbers to make a number closest to the target, e.g. [lindex $game_numbers 0]+([lindex $game_numbers 1]*[lindex $game_numbers 2])-([lindex $game_numbers 3]/[lindex $game_numbers 4])+[lindex $game_numbers 5]))"
			send_msg $game_channel "The target number is:[bold] $game_numbers_target[bold]"
		} else {
			set game_type "L"
			set game_letters [choose_letters]
			set game_words [list]
			set game_bestanswer [list]
			
			while { [llength $game_words] == 0 } {
				set game_letters [choose_letters]
				set game_words [find_words $game_letters]
			}
			
			set game_longestwords [longest_words $game_words]
			send_msg $game_channel "[bold]\[LETTERS\][bold] - 4[join $game_letters]1 - (find the longest word with these letters)"
			send_msg $game_channel "I've found [bold]4[llength $game_words][bold] possible words1, including [llength $game_longestwords] with [string length [lindex $game_longestwords 0]] letters!"
			send_debug $game_channel "Solution: $game_longestwords"		
		}
	
		set game_status 3
		set game_timer1 [utimer $round_time [namespace current]::end_game]
		set wtime [expr $round_time - $warning_time]
		set game_start_time [unixtime]
	  
		if { $wtime > 0 } {
			set game_timer2 [utimer $wtime [namespace current]::send_warning]
		}
		
		return 0
	}
	
	proc send_warning { } {
		variable game_channel
		variable warning_time
		
		send_msg $game_channel "4Warning1, $warning_time seconds remaining!"
		return 0
	}
	
	proc end_game { } {
		variable game_channel
		variable delay_time
		variable game_longestwords
		variable game_bestanswer
		variable game_type
		variable game_letters
		variable game_status
		variable game_numbers_solution
		variable game_numbers_target
		variable numbers_points2
		variable numbers_points3
		variable numbers_points4
	
		set game_status 2
		
		if { $game_type == "L" } {
			send_msg $game_channel "Time is up! The longest word(s) were: [bold][join $game_longestwords][bold]."
		
			if { [llength $game_bestanswer] > 0 } {
				set old_ranks [lindex [get_ranks [lindex $game_bestanswer 0] 1] 0]
				add_score [lindex $game_bestanswer 0] [lindex $game_bestanswer 1]
				set new_ranks [lindex [get_ranks [lindex $game_bestanswer 0] 1] 0]
				send_msg $game_channel "[bold][lindex $game_bestanswer 0] scores [lindex $game_bestanswer 1] points![bold] (this month: [get_score [lindex $game_bestanswer 0] MONTH] points, ranked [lindex $new_ranks 0][get_rank_suffix [lindex $new_ranks 0]])[bold]"
				
				set rank_up [list 0 0 0]
				if { [lindex $old_ranks 0] > [lindex $new_ranks 0] } { lset rank_up 0 1 }
				if { [lindex $old_ranks 1] > [lindex $new_ranks 1] } { lset rank_up 1 1 }
				if { [lindex $old_ranks 2] > [lindex $new_ranks 2] } { lset rank_up 2 1 }
				
				if { [lindex $rank_up 0] == 1 || [lindex $rank_up 1] == 1 || [lindex $rank_up 2] == 1 } {
					set rtext "[bold][lindex $game_bestanswer 0] has moved up in rank![bold]"
					
					if { [lindex $rank_up 0] == 1 } { set rtext "$rtext This month: [lindex $new_ranks 0][get_rank_suffix [lindex $new_ranks 0]] (up [expr [lindex $old_ranks 0] - [lindex $new_ranks 0]])" }
					if { [lindex $rank_up 1] == 1 } { set rtext "$rtext This year: [lindex $new_ranks 1][get_rank_suffix [lindex $new_ranks 1]] (up [expr [lindex $old_ranks 1] - [lindex $new_ranks 1]])" }
					if { [lindex $rank_up 2] == 1 } { set rtext "$rtext Overall: [lindex $new_ranks 2][get_rank_suffix [lindex $new_ranks 2]] (up [expr [lindex $old_ranks 2] - [lindex $new_ranks 2]])" }
					
					send_msg $game_channel $rtext
				}				
			}
		} elseif { $game_type == "C" } {
			send_msg $game_channel "Time is up and nobody solved the conundrum! The answer was:[bold] $game_letters.[bold]"
		} elseif { $game_type == "N" } {
			send_msg $game_channel "3Time is up!1"
			
			if { [llength $game_bestanswer] > 0 } {
				set distance [expr abs($game_numbers_target - [lindex $game_bestanswer 1])]
				
				if { $distance <= 5 } { 
					set points $numbers_points2
				} elseif { $distance <= 10 } { 
					set points $numbers_points3 
				} else { 
					set points $numbers_points4
				} 
				
				set old_ranks [lindex [get_ranks [lindex $game_bestanswer 0] 1] 0]
				add_score [lindex $game_bestanswer 0] $points
				set new_ranks [lindex [get_ranks [lindex $game_bestanswer 0] 1] 0]
				send_msg $game_channel "[bold][lindex $game_bestanswer 0] got within $distance of the target and scores $points points![bold] (this month: [get_score [lindex $game_bestanswer 0] MONTH] points, ranked [lindex $new_ranks 0][get_rank_suffix [lindex $new_ranks 0]])[bold]"
				
				set rank_up [list 0 0 0]
				if { [lindex $old_ranks 0] > [lindex $new_ranks 0] } { lset rank_up 0 1 }
				if { [lindex $old_ranks 1] > [lindex $new_ranks 1] } { lset rank_up 1 1 }
				if { [lindex $old_ranks 2] > [lindex $new_ranks 2] } { lset rank_up 2 1 }
				
				if { [lindex $rank_up 0] == 1 || [lindex $rank_up 1] == 1 || [lindex $rank_up 2] == 1 } {
					set rtext "[bold][lindex $game_bestanswer 0] has moved up in rank![bold]"
					
					if { [lindex $rank_up 0] == 1 } { set rtext "$rtext This month: [lindex $new_ranks 0][get_rank_suffix [lindex $new_ranks 0]] (up [expr [lindex $old_ranks 0] - [lindex $new_ranks 0]])" }
					if { [lindex $rank_up 1] == 1 } { set rtext "$rtext This year: [lindex $new_ranks 1][get_rank_suffix [lindex $new_ranks 1]] (up [expr [lindex $old_ranks 1] - [lindex $new_ranks 1]])" }
					if { [lindex $rank_up 2] == 1 } { set rtext "$rtext Overall: [lindex $new_ranks 2][get_rank_suffix [lindex $new_ranks 2]] (up [expr [lindex $old_ranks 2] - [lindex $new_ranks 2]])" }
					
					send_msg $game_channel $rtext
				}				
			}			
		}
		
		kill_timers
		set game_timer1 [utimer $delay_time [namespace current]::new_game]
		return 0
	}
	
	proc process_answer { nickname channel answer } {
		variable game_words
		variable game_longestwords
		variable delay_time
		variable letters_bonus
		variable game_bestanswer
		variable game_letters
		variable conundrum_points
		variable game_type
		variable game_status
		variable game_numbers
		variable game_numbers_target
		variable numbers_points1
	
		set answer [string toupper [join $answer]]
		
		if { $game_type == "L" } {
			if { [lsearch -exact $game_words $answer] != -1 } {
				if { [string length $answer] == [string length [lindex $game_longestwords 0]] } {
					set game_status 2
					set old_ranks [lindex [get_ranks $nickname 1] 0]
					add_score $nickname [expr [string length $answer] + $letters_bonus]
					set new_ranks [lindex [get_ranks $nickname 1] 0]
					send_msg $channel "[bold]Well done![bold] Your word \"$answer\" is one of the longest words! $nickname scores [string length $answer] points + $letters_bonus bonus! (this month: [get_score $nickname MONTH] points, ranked [lindex $new_ranks 0][get_rank_suffix [lindex $new_ranks 0]])"
					
					set rank_up [list 0 0 0]
					if { [lindex $old_ranks 0] > [lindex $new_ranks 0] } { lset rank_up 0 1 }
					if { [lindex $old_ranks 1] > [lindex $new_ranks 1] } { lset rank_up 1 1 }
					if { [lindex $old_ranks 2] > [lindex $new_ranks 2] } { lset rank_up 2 1 }
					
					if { [lindex $rank_up 0] == 1 || [lindex $rank_up 1] == 1 || [lindex $rank_up 2] == 1 } {
						set rtext "[bold]$nickname has moved up in rank![bold]"
						
						if { [lindex $rank_up 0] == 1 } { set rtext "$rtext This month: [lindex $new_ranks 0][get_rank_suffix [lindex $new_ranks 0]] (up [expr [lindex $old_ranks 0] - [lindex $new_ranks 0]])" }
						if { [lindex $rank_up 1] == 1 } { set rtext "$rtext This year: [lindex $new_ranks 1][get_rank_suffix [lindex $new_ranks 1]] (up [expr [lindex $old_ranks 1] - [lindex $new_ranks 1]])" }
						if { [lindex $rank_up 2] == 1 } { set rtext "$rtext Overall: [lindex $new_ranks 2][get_rank_suffix [lindex $new_ranks 2]] (up [expr [lindex $old_ranks 2] - [lindex $new_ranks 2]])" }
						
						send_msg $channel $rtext
					}
					
					kill_timers
					set game_timer1 [utimer $delay_time [namespace current]::new_game]
				} elseif { [llength $game_bestanswer] == 0 || [string length $answer] > [lindex $game_bestanswer 1] } {
					set game_bestanswer [list $nickname [string length $answer]]
					send_msg $channel "[bold]Well done![bold] Your word \"$answer\" has been accepted! Who can find a word longer than $nickname? (more than [string length $answer] letters)"
				}
			}
		} elseif { $game_type == "C" } {
			if { $game_letters == $answer || ([string length $game_letters] == [string length $answer] && [is_anagram $game_letters $answer] && [is_word $answer]) } {
				set game_status 2
				set old_ranks [lindex [get_ranks $nickname 1] 0]
				add_score $nickname $conundrum_points
				set new_ranks [lindex [get_ranks $nickname 1] 0]
				send_msg $channel "[bold]Well done[bold] $nickname, you have solved the conundrum and score $conundrum_points points! (this month: [get_score $nickname MONTH] points, ranked [lindex $new_ranks 0][get_rank_suffix [lindex $new_ranks 0]])"
								
				set rank_up [list 0 0 0]
				if { [lindex $old_ranks 0] > [lindex $new_ranks 0] } { lset rank_up 0 1 }
				if { [lindex $old_ranks 1] > [lindex $new_ranks 1] } { lset rank_up 1 1 }
				if { [lindex $old_ranks 2] > [lindex $new_ranks 2] } { lset rank_up 2 1 }
				
				if { [lindex $rank_up 0] == 1 || [lindex $rank_up 1] == 1 || [lindex $rank_up 2] == 1 } {
					set rtext "[bold]$nickname has moved up in rank![bold]"
					
					if { [lindex $rank_up 0] == 1 } { set rtext "$rtext This month: [lindex $new_ranks 0][get_rank_suffix [lindex $new_ranks 0]] (up [expr [lindex $old_ranks 0] - [lindex $new_ranks 0]])" }
					if { [lindex $rank_up 1] == 1 } { set rtext "$rtext This year: [lindex $new_ranks 1][get_rank_suffix [lindex $new_ranks 1]] (up [expr [lindex $old_ranks 1] - [lindex $new_ranks 1]])" }
					if { [lindex $rank_up 2] == 1 } { set rtext "$rtext Overall: [lindex $new_ranks 2][get_rank_suffix [lindex $new_ranks 2]] (up [expr [lindex $old_ranks 2] - [lindex $new_ranks 2]])" }
					
					send_msg $channel $rtext
				}				
				
				kill_timers
				set game_timer1 [utimer $delay_time [namespace current]::new_game]
			}
		} elseif { $game_type == "N" } {
			if { ![catch { set result [eval_expression $answer $game_numbers] } err] } {
				if { $result == $game_numbers_target } {
					set game_status 2
					set old_ranks [lindex [get_ranks $nickname 1] 0]
					add_score $nickname $numbers_points1
					set new_ranks [lindex [get_ranks $nickname 1] 0]
					send_msg $channel "[bold]Well done[bold] $nickname, you have solved the numbers game and score $numbers_points1 points! (this month: [get_score $nickname MONTH] points, ranked [lindex $new_ranks 0][get_rank_suffix [lindex $new_ranks 0]])"
					
					set rank_up [list 0 0 0]
					if { [lindex $old_ranks 0] > [lindex $new_ranks 0] } { lset rank_up 0 1 }
					if { [lindex $old_ranks 1] > [lindex $new_ranks 1] } { lset rank_up 1 1 }
					if { [lindex $old_ranks 2] > [lindex $new_ranks 2] } { lset rank_up 2 1 }
					
					if { [lindex $rank_up 0] == 1 || [lindex $rank_up 1] == 1 || [lindex $rank_up 2] == 1 } {
						set rtext "[bold]$nickname has moved up in rank![bold]"
						
						if { [lindex $rank_up 0] == 1 } { set rtext "$rtext This month: [lindex $new_ranks 0][get_rank_suffix [lindex $new_ranks 0]] (up [expr [lindex $old_ranks 0] - [lindex $new_ranks 0]])" }
						if { [lindex $rank_up 1] == 1 } { set rtext "$rtext This year: [lindex $new_ranks 1][get_rank_suffix [lindex $new_ranks 1]] (up [expr [lindex $old_ranks 1] - [lindex $new_ranks 1]])" }
						if { [lindex $rank_up 2] == 1 } { set rtext "$rtext Overall: [lindex $new_ranks 2][get_rank_suffix [lindex $new_ranks 2]] (up [expr [lindex $old_ranks 2] - [lindex $new_ranks 2]])" }
						
						send_msg $channel $rtext
					}
					
					kill_timers
					set game_timer1 [utimer $delay_time [namespace current]::new_game]
				} elseif { [llength $game_bestanswer] == 0 || [expr abs($game_numbers_target - $result)] < [expr abs($game_numbers_target - [lindex $game_bestanswer 1])] } {
					set game_bestanswer [list $nickname $result]
					send_msg $channel "[bold]Well done![bold] Your answer \"$answer\" evaluated to $result and has been accepted! Who can get closer to $game_numbers_target[bold] than $nickname?"
				} else {
					send_msg $nickname "Your expression [bold]\"$answer\=$result\"[bold] does not beat the best so far ([lindex $game_bestanswer 1] by [lindex $game_bestanswer 0])"
				}
			} else {
				send_msg $nickname "Error: [bold]$err[bold]"
			}
		}
		
		return 0
	}
	
	#################
	# USER COMMANDS #
	#################
	
	proc enable_game { nickname handle channel enabled } {
		variable game_status
		variable command_char
		
		set enabled [join $enabled]
		if { ![isop $nickname $channel] && ![isbotnick $nickname] && ![matchattr [nick2hand $nickname] "Gmn|Go" $channel] } {
			send_msg $nickname "This command is restricted to channel operators."
		} elseif { $enabled == 1 && $game_status != 0 } {
			send_msg $nickname "The game is already enabled."
		} elseif { $enabled == 0 && $game_status == 0 } {
			send_msg $nickname "The game is already disabled."
		} elseif { $enabled == 1 } {
			send_msg $channel "The game is now [bold]enabled[bold]. Type [bold]${command_char}start[bold] to start the game."
			set game_status $enabled
		} else {
			send_msg $channel "The game has been [bold]disabled[bold]. Type [bold]${command_char}enable[bold] to re-enable the game."
			set game_status $enabled
		}
		
		return 0
	}
	
	proc start_game { nickname channel } {
		variable game_status
		variable command_char
		variable game_timer1
		variable delay_time
		
		if { ![isop $nickname $channel] && ![isbotnick $nickname] && ![matchattr [nick2hand $nickname] "Gmn|Go" $channel] } {
			send_msg $nickname "This command is restricted to channel operators."
		} elseif { $game_status > 1 } {
			send_msg $nickname "The game is already running."
		} elseif { $game_status == 0 && ![isbotnick $nickname]} {
			send_msg $nickname "The game cannot be started at this time because it is disabled. Type [bold]${command_char}enable[bold] to re-enable the game."
		} else {
			set game_status 2
			new_game
		}
		
		return 0
	}
	
	proc stop_game { nickname channel } {
		variable game_status
		variable command_char
		variable game_timer1
		variable game_timer2
		
		if { ![isop $nickname $channel] && ![isbotnick $nickname] && ![matchattr [nick2hand $nickname] "Gmn|Go" $channel] } {
			send_msg $nickname "This command is restricted to channel operators."
		} elseif { $game_status < 2 && ![isbotnick $nickname] } {
			send_msg $nickname "The game is not currently running. Please type [bold]${command_char}[bold]start to start the game."
		} else {
			if { $game_status > 1 } {
				send_msg $channel "The game has been stopped. Type[bold] ${command_char}start[bold] to start a new game."
				set game_status 1
			}
			
			kill_timers
		}
		
		return 0
	}
	
	proc show_help { nickname channel } {
		set clist { "SCORES" "ALLSCORES" "RANK" "REPEAT" "VERSION" }
	
		if {[isop $nickname $channel]} {
			lappend clist "START" "STOP" "ENABLE" "DISABLE"
		}
	
		if { [matchattr [nick2hand $nickname] "Gmn|Go" $channel] } {
			lappend clist "RELOAD" "RESTART" "RESETSCORES"
		}
		
		foreach command $clist {
			switch -- $command {
				"START"			{ send_msg $nickname "!start - starts the bot if it is stopped" }
				"SCORES"		{ send_msg $nickname "!scores - shows the monthly high scores" }
				"ALLSCORES"		{ send_msg $nickname "!allscores - shows the full list of high scores" }
				"RANK"			{ send_msg $nickname "!rank - shows your score rankings" }
				"REPEAT"		{ send_msg $nickname "!repeat - shows the letters for the current round" }
				"VERSION"		{ send_msg $nickname "!version - shows the script version information" }
				"STOP"			{ send_msg $nickname "!stop - stops the game if it is running" }
				"ENABLE"		{ send_msg $nickname "!enable - enables the game if it is disabled" }
				"DISABLE"		{ send_msg $nickname "!disable - disables the game" }
				"RELOAD"		{ send_msg $nickname "!reload - reloads the configuration file from disk" }
				"RESTART"		{ send_msg $nickname "!restart - restarts the bot" }
				"RESETSCORES"	{ send_msg $nickname "!resetscores - resets all scores to zero" }
			}
		}
	
		return 0
	}
	
	proc show_scores { nickname full } {
		variable scores_entries
		
		lappend rscores [get_scores MONTH $scores_entries]
		lappend rscores [get_scores YEAR $scores_entries]
		lappend rscores [get_scores TOTAL $scores_entries]
		
		for { set i 0 } { $i < [llength $rscores] } { incr i } {
			set scores [lindex $rscores $i]
			set score_text { }
			
			for { set j 0 } { $j < [llength $scores] } { incr j } {
				set score [lindex $scores $j]
				
				if { [lindex $score 1] > 0 } {
					lappend score_text "[expr $j + 1]. [lindex $score 0] [bold]([lindex $score 1])[bold]"
				}
			}
			
			lappend result $score_text
		}
		
		for { set i 0 } { $i < [llength $rscores] && ($full == 1 || $i == 0) } { incr i } {
			set scores [lindex $result $i]
			set output { }
			
			if { $i == 0 } { 
				lappend output "This month: "
			} elseif { $i == 1 } { 
				lappend output "This year: "
			} elseif { $i == 2 } { 
				lappend output "Overall: "
			}
			
			lappend output [join [lrange $scores 0 2]]
			send_msg $nickname "[bold][join $output][bold]"
			
			for { set j 3 } { $j < [llength $scores] } { incr j 4 } {
				send_msg $nickname "[bold][join [lrange $scores $j [expr $j + 3]]][bold]"
			}
		}
		
		return 0
	}
	
	proc show_ranks { nickname } {
		set ranks [get_ranks $nickname 0]
		send_msg $nickname "Your ranks - [bold]This month: [lindex $ranks 0], [bold]This year: [lindex $ranks 1], [bold]Overall: [lindex $ranks 2]"
		return 0
	}
	
	proc show_repeat { nickname } {
		variable countdown_dict
		variable game_letters
		variable game_type
		variable game_words
		variable game_bestanswer
		variable game_longestwords
		variable game_status
		variable game_scrambled
		variable game_numbers
		variable game_numbers_target
		
		if { $game_status < 3 } {
			send_msg $nickname "There is currently no game in progress."
		} elseif { $game_type == "C" } {
			send_msg $nickname "[bold]\[CONUNDRUM\][bold] -4 $game_scrambled 1- (unscramble these letters to make a word)"
			send_debug $nickname "Solution: $game_letters"
			send_msg $nickname "There are [bold][get_time_remaining] seconds[bold] remaining for this game."
		} elseif { $game_type == "N" } {
			send_msg $nickname "[bold]\[NUMBERS\] - [join $game_numbers] -[bold] (use these numbers to make a number closest to the target, e.g. 3+(6*5)-(4/2)+1))"
			send_msg $nickname "The target number is:[bold] $game_numbers_target[bold]"
			send_msg $nickname "There are [bold][get_time_remaining] seconds[bold] remaining for this game."
		} else {
			set game_type "L"
			send_msg $nickname "[bold]\[LETTERS\][bold] - 4[join $game_letters]1 - (find the longest word with these letters)"
			send_debug $nickname "Solution: $game_longestwords"
			
			if { [llength $game_bestanswer] == 2 } {
				send_msg $nickname "The longest word found so far is [bold][lindex $game_bestanswer 1] letters long[bold] (by [lindex $game_bestanswer 0])."
			}
			
			send_msg $nickname "There are [bold][get_time_remaining] seconds[bold] remaining for this game."
		}
		
		return 0
	}
	
	proc reset_scores { nickname channel } {
		variable countdown_scores
		
		if { ![matchattr [nick2hand $nickname] "Gmn|Go" $channel] } {
			send_msg $nickname "This command is restricted to authorised games staff."
		} else {
			unset countdown_scores
			array set countdown_scores { }
			save_scores 0 0 0 0 0
			send_msg $nickname "The scores have been reset to zero."
		}
		
		return 0
	}
	
	proc reload { nickname channel } {
		if { ![matchattr [nick2hand $nickname] "Gmn|Go" $channel] } {
			send_msg $nickname "This command is restricted to authorised games staff."
		} else {
			init
			send_msg $nickname "Reloaded configuration file from disk."
		}
		
		return 0
	}
	
	proc restart_bot { nickname channel } {
		if { ![matchattr [nick2hand $nickname] "Gmn|Go" $channel] } {
			send_msg $nickname "This command is restricted to authorised games staff."
		} else {
			restart
		}
		
		return 0
	}	
	
	proc public_trigger { nickname hostname handle channel arguments } {
		variable command_char
		variable game_channel
		variable game_status
		variable script_name
		variable script_version
		variable script_author
		variable script_email
	
		set arguments [stripcodes "bcruag" $arguments]
		
		if { [string compare -nocase $channel $game_channel] != 0 } {
			return 0
		} elseif { [string index $arguments 0] != $command_char } {
			if { $game_status > 2 } {
				process_answer $nickname $channel $arguments
			}
			
			return 0
		} 
		
		set command [string toupper [string range [lindex [split $arguments] 0] 1 end]]
		set arguments [lrange [split $arguments] 1 end]
		
		switch -- $command {
			"HELP"			{ show_help $nickname $channel }
			"ENABLE"		{ enable_game $nickname $handle $channel 1 }
			"DISABLE"		{ enable_game $nickname $handle $channel 0 }
			"START"			{ start_game $nickname $channel }
			"STOP"			{ stop_game $nickname $channel }
			"VERSION"		{ send_msg $nickname "[bold]$script_name v${script_version}[bold] by $script_author ($script_email)." }
			"SCORES"		{ show_scores $nickname 0 }
			"ALLSCORES"		{ show_scores $nickname 1 }
			"RESETSCORES"	{ reset_scores $nickname $channel }
			"RANK"			{ show_ranks $nickname }
			"REPEAT"		{ show_repeat $nickname }
			"R"				{ show_repeat $nickname }
			"RELOAD"		{ reload $nickname $channel }
			"RESTART"		{ restart_bot $nickname $channel }
			default    		{ return 0 }
		}	
	
		set loglist { "ENABLE" "DISABLE" "START" "STOP" "RESETSCORES" "RELOAD" "RESTART" }
		
		if { [lsearch -exact $loglist $command] != -1 } {
			putcmdlog "<<$nickname>> $command $arguments"
		}
	
		return 0	
	}
	
	#####################
	# SCORING FUNCTIONS #
	#####################
	
	proc load_scores { } {
		variable countdown_scores
		variable scores_file
		
		unset countdown_scores
		array set countdown_scores { }
		
		if { [catch { open $scores_file r } fd] } {
			putlog "Failed to open scores file '$scores_file'."
			return -1
		} else {
			gets $fd data
		 
			while { $data != "" } {
				set score [split $data "="]
				set nickname [lindex $score 0]
				
				if { $nickname != "" } {
					set countdown_scores($nickname) [split [split [lindex $score 1] ":"] ","]
				}
				
				gets $fd data
			}		
			
			close $fd
		}
		
		return 0
	}
	
	proc save_scores { minute hour day month year } {
		variable countdown_scores
		variable scores_file
		
		if { [catch { open "${scores_file}.tmp" w } fd] } {
			putlog "Failed to open scores file '${scores_file}.tmp' for writing."
			return -1
		} else {
			foreach player [array names countdown_scores] {
				set scores [join [join $countdown_scores($player) ","] ":"]
				puts $fd "$player=$scores"
			}
			
			close $fd
			exec mv "${scores_file}.tmp" $scores_file
		}
		
		return 0
	}
	
	proc add_score { nickname points } {
		variable countdown_scores
		
		set cdate [strftime "%Y-%m"]
		set nickname [string tolower $nickname]
		set added 0
		
		if { ![info exists countdown_scores($nickname)] } {
			set countdown_scores($nickname) [list [list $cdate $points]]
		} else {
			for { set i 0 } { $i < [llength $countdown_scores($nickname)] } { incr i } {
				set score [lindex $countdown_scores($nickname) $i]
				
				if { [lindex $score 0] == $cdate } {
					lset countdown_scores($nickname) $i 1 [expr [lindex $score 1] + $points]
					set added 1
					break;
				}			
				
			}
			
			if { !$added } {
				lappend countdown_scores($nickname) [list $cdate $points]
			}
		}
		
		return 0
	}
	
	proc get_score { nickname scoretype } {
		variable countdown_scores
			
		set nickname [string tolower $nickname]
		set scoretype [string toupper $scoretype]
		set cdate [strftime "%Y-%m"]
		set result 0
		
		if { [info exists countdown_scores($nickname)] } {
			foreach score $countdown_scores($nickname) {
				if { $scoretype == "MONTH" && [lindex $score 0] == $cdate } {
					return [lindex $score 1]
				} elseif { $scoretype == "RAW" } {
					if { $result == 0 } {
						set result [list $score]
					} else {
						lappend result $score
					}
				} elseif { $scoretype == "TOTAL" || ($scoretype == "YEAR" && [string range [lindex $score 0] 0 3] == [string range $cdate 0 3]) } {				
					set result [expr $result + [lindex $score 1]]
				} 
			}
		}
		
		return $result
	}
	
	proc get_scores { scoretype limit } {
		variable countdown_scores
		
		set scoretype [string toupper $scoretype]
		set result { }
		
		foreach player [array names countdown_scores] {
			set total 0
			
			foreach score $countdown_scores($player) {
				if { $scoretype == "TOTAL" || ($scoretype == "YEAR" && [string range [lindex $score 0] 0 3] == [strftime "%Y"]) || ($scoretype == "MONTH" && [lindex $score 0] == [strftime "%Y-%m"]) } {
					set total [expr $total + [lindex $score 1]]
				} 
			}
			
			lappend result [list $player $total]
		}
		
		set result [lsort -integer -decreasing -index 1 $result]
		
		if { $limit != 0 } {
			set result [lrange $result 0 [expr $limit - 1]]
		}
		
		return $result
	}
	
	proc get_ranks { nickname raw } {
		set scores [list [get_scores "MONTH" 0] [get_scores "YEAR" 0] [get_scores "TOTAL" 0]]
		
		if { $raw == 1 } {
			set ranks [list [list 0 0 0] [list 0 0 0] [list 0 0 0]]
			set iter [llength [lindex $ranks 0]]
		} else {
			set ranks [list "Unranked[bold]" "Unranked[bold]" "Unranked[bold]"]
			set iter [llength $ranks]
		}
		
		for { set i 0 } { $i < $iter } { incr i } {
			set cscores [lindex $scores $i]
			
			for { set j 0 } { $j < [llength $cscores] } { incr j } {
				set score [lindex $cscores $j]
				
				if { [string compare -nocase [lindex $score 0] $nickname] == 0 } {
					set r [expr $j + 1]
					
					if { $raw == 1 } {
						lset ranks 0 $i $r
						lset ranks 1 $i [lindex $score 1]
					} else {
						lset ranks $i "$r[get_rank_suffix $r][bold] ([lindex $score 1])"
					}
					
					break
				}
			}
		}
		
		return $ranks
	}	
	
	####################
	# HELPER FUNCTIONS #
	####################
	
	proc send_msg { target message } {
		variable use_notice
		variable colours
		
		if { $use_notice == 1 && [string index $target 0] != "#" } {
			putquick "NOTICE $target :[colour]$colours$message[colour]"
		} else {
			putquick "PRIVMSG $target :[colour]$colours$message[colour]"
		}
		
		return 0
	}
	
	proc send_debug { target message } {
		variable debug
		
		if { $debug != 1 } { 
			return 0
		} else {
			send_msg $target $message
		}
	}
	
	proc kill_timers { } {
		variable game_timer1
		variable game_timer2
		
		foreach timer [utimers] {
			if { [lindex $timer 2] == $game_timer1 || [lindex $timer 2] == $game_timer2 } {
				killutimer [lindex $timer 2]
			}
		}
		
		return 0
	}
	
	proc get_time_remaining { } {
		variable game_start_time
		variable round_time
		return [expr $round_time - ([unixtime] - $game_start_time)]
	}
	
	proc get_rank_suffix { rank } {
		# special cases
		if { $rank >= 11 && $rank <= 13 } { return "th" }
		
		switch -regexp [string range $rank end end] {
			"[0456789]"	{ return "th" }
			"1"			{ return "st" }
			"2"			{ return "nd" }
			"3"			{ return "rd" }
			default		{ return "" }
		}
	}
	
	proc bold {} { return \002 }
	proc reverse {} { return \026 }
	proc colour {} { return \003 }
	proc underline {} { return \037 }
	
	init
}
