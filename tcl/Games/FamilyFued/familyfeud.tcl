#
# Marky's FAMILYFEUD v0.91
# Copyright (C) 2004 Mark A. Day (techwhiz@earthlink.net)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

# Default Settings
set FAMILYFEUDChannel 	"#cebu"
set FAMILYFEUDPointsName 	"FAMILY FEUD"
set FAMILYFEUDPointsPerAnswer 100
set FAMILYFEUDQuestionTime 	70
set FAMILYFEUDMarker 		"*"
set FAMILYFEUDScoreFile 	"FAMILYFEUD.scores"
set FAMILYFEUDAskedFile		"FAMILYFEUD.asked"
set FAMILYFEUDQuestionFile	"scripts/FAMILYFEUD.db"
set FAMILYFEUDCFGFile		"scripts/FAMILYFEUD.cfg"

# Channel Triggers
bind pub - !famtop FAMILYFEUDTop10
bind pub - !famtoplast FAMILYFEUDLastMonthTop3
bind pub - !famwon FAMILYFEUDPlayerScore
bind pub - !famrepeat FAMILYFEUD_Repeat
bind pub - !famcmds FAMILYFEUDCmds
bind pub - !asked FAMILYFEUD_ShowAsked
bind pub - !familyfeud FAMILYFEUD_Start
bind pub - !famstop FAMILYFEUD_Stop

# DCC Commands
bind dcc - FAMILYFEUDrehash dcc_FAMILYFEUDrehash
bind dcc - FAMILYFEUDanswer dcc_FAMILYFEUDanswer
bind dcc - FAMILYFEUDreset dcc_FAMILYFEUDresetasked
bind dcc - FAMILYFEUDasked dcc_FAMILYFEUDshowasked
bind dcc - FAMILYFEUDforce dcc_FAMILYFEUDforce

# Cron Bind For Monthly Score Reset
bind time - "00 00 01 * *" FAMILYFEUD_NewMonth

# Global Variables
set FAMILYFEUDRunning 0
set FAMILYFEUDAllAnswered 0
set FAMILYFEUDRoundOver 0
set FAMILYFEUDQNumber 0
set FAMILYFEUDQuestion ""
set FAMILYFEUDQuestions(0) ""
set FAMILYFEUDAsked ""
set FAMILYFEUDMonthFileName ""
set FAMILYFEUDQCount 0
set FAMILYFEUDAnswerCount 0
set FAMILYFEUDDisplayNum 0
set FAMILYFEUDNumAnswered 0
set FAMILYFEUDForced 0
set FAMILYFEUDForcedQuestion ""
set FAMILYFEUDAutoStart 0

# Scores And Ads
set FAMILYFEUDAdNumber 0
set FAMILYFEUDAd(0) "$botnick"
set FAMILYFEUDAd(1) "$botnick"
set FAMILYFEUDAd(2) "$botnick"
set FAMILYFEUDLastMonthScores(0) "Nobody 0"
set FAMILYFEUDLastMonthScores(1) "Nobody 0"
set FAMILYFEUDLastMonthScores(2) "Nobody 0"

# Timers
set FAMILYFEUDAdTimer ""
set FAMILYFEUDQuestionTimer ""

# Version
set KDebug 0
set FAMILYFEUDVersion "1.0"

#
# Start FAMILYFEUD
#
proc FAMILYFEUD_Start {nick uhost hand chan args} {
 global FAMILYFEUDChannel FAMILYFEUDRunning FAMILYFEUDQCount FAMILYFEUDQNumber FAMILYFEUDQuestionFile FAMILYFEUDAdNumber FAMILYFEUDVersion KDebug

 if {($chan != $FAMILYFEUDChannel)||($FAMILYFEUDRunning != 0)} {return}

 set FAMILYFEUDQCount 0
 set FAMILYFEUDAdNumber 0

 FAMILYFEUD_ReadCFG

 if {![file exist $FAMILYFEUDQuestionFile]} {
   putcmdlog "\[FAMILYFEUD\] Question File: $FAMILYFEUDQuestionFile Unreadable Or Does Not Exist"
   return 0
 }

 set FAMILYFEUDQCount [FAMILYFEUD_ReadQuestionFile]

 if {$FAMILYFEUDQCount < 2} {
   putcmdlog "\[FAMILYFEUD\] Not Enough Questions in Question File $FAMILYFEUDQuestionFile"
   return 0
 }

 set FAMILYFEUDAskedFileLen [FAMILYFEUD_ReadAskedFile]

 if {$FAMILYFEUDAskedFileLen >= $FAMILYFEUDQCount} {
   FAMILYFEUDmsg "[FAMILYFEUD] [kcr] All Questions Asked: Resetting \003"
   FAMILYFEUD_ResetAsked
   return 0
 }

 set FAMILYFEUDRunning 1

 FAMILYFEUDmsg "Welcome to \00304Family FEUD\003 IRC Game, player can get the highest score will be the winner of the game."

 bind pubm - "*" FAMILYFEUDCheckGuess

 FAMILYFEUDAskQuestion

 return 1
}

#
# Stop FAMILYFEUD
#
proc FAMILYFEUD_Stop {nick uhost hand chan args} {
 global FAMILYFEUDChannel FAMILYFEUDRunning FAMILYFEUDQuestionTimer FAMILYFEUDAdTimer

 if {($chan != $FAMILYFEUDChannel)||($FAMILYFEUDRunning != 1)} {return}

 set FAMILYFEUDRunning 0

 catch {killutimer $FAMILYFEUDQuestionTimer}
 catch {killutimer $FAMILYFEUDAdTimer}

 catch {unbind pubm - "*" FAMILYFEUDCheckGuess}

 FAMILYFEUDmsg "\00306FAMILY FEUD Game\003 stopped by \00304\[\00312$nick\00304\]"
 return 1
}

#
# Pick Question
#
proc FAMILYFEUDPickQuestion {} {
 global FAMILYFEUDAsked FAMILYFEUDQCount KDebug
 set FAMILYFEUDUnasked [expr ($FAMILYFEUDQCount - [llength $FAMILYFEUDAsked])]
 if {$FAMILYFEUDUnasked < 1} {
   FAMILYFEUDmsg "[FAMILYFEUD] [kcr] All Questions Asked: Resetting \003"
   FAMILYFEUD_ResetAsked
 }
 set pickdone 0
 while {$pickdone == 0} {
  set kidx 0
  set foundinasked 0
  set pick [rand $FAMILYFEUDQCount]
  while {[lindex $FAMILYFEUDAsked $kidx] != ""} {
    if {[lindex $FAMILYFEUDAsked $kidx] == $pick} {
     set foundinasked 1
     # FAMILYFEUDlog "FAMILYFEUD" "Found Pick:$pick in Asked"
     break
    }
    incr kidx
  }
  if {$foundinasked == 0} {incr pickdone}
 }
 # FAMILYFEUDlog "FAMILYFEUD" "Picked Question:$pick"
 FAMILYFEUD_AddAsked $pick
 return $pick
}

#
# Parse Question
#
proc FAMILYFEUDParseQuestion {QNum} {
 global FAMILYFEUDMarker FAMILYFEUDQuestions FAMILYFEUDQuestion FAMILYFEUDAnswers FAMILYFEUDAnswerCount FAMILYFEUDForcedQuestion KDebug

  set KAnswersLeft ""

  if {$QNum < 0} {
   set FAMILYFEUDFileQuestion $FAMILYFEUDForcedQuestion
  } {
   set FAMILYFEUDFileQuestion $FAMILYFEUDQuestions($QNum)
  }

  if {$KDebug > 1} {FAMILYFEUDlog "FAMILYFEUD" "Picked:$QNum Question:$FAMILYFEUDFileQuestion"}

  if [info exists FAMILYFEUDAnswers] {unset FAMILYFEUDAnswers}

  # Position of first "*"

  set FAMILYFEUDMarkerIDX [string first $FAMILYFEUDMarker $FAMILYFEUDFileQuestion]

  if {$FAMILYFEUDMarkerIDX < 1} {
   FAMILYFEUDlog "FAMILYFEUD" "Malformed Question #$QNum"
  }

  set FAMILYFEUDQuestionEndIDX [expr $FAMILYFEUDMarkerIDX - 1]

  set FAMILYFEUDQuestion [string range $FAMILYFEUDFileQuestion 0 $FAMILYFEUDQuestionEndIDX]

  # Move to first character in answers
  incr FAMILYFEUDMarkerIDX
  set KAnswersLeft [string range $FAMILYFEUDFileQuestion $FAMILYFEUDMarkerIDX end]

  set KDoneParsing 0
  set FAMILYFEUDAnswerCount 0

  # Parse all answers

  while {$KDoneParsing != 1 } {
   set KAnswerEnd [string first $FAMILYFEUDMarker $KAnswersLeft]

   if {$KAnswerEnd < 1} {
    set KDoneParsing 1
    set KAnswerEnd [string length $KAnswersLeft]
   }

   set KAnswer [string range $KAnswersLeft 0 [expr $KAnswerEnd -1]]

   set FAMILYFEUDAnswers($FAMILYFEUDAnswerCount) "# $KAnswer"

   set FAMILYFEUDMarkerIDX [expr $KAnswerEnd +1]

   set KAnswersLeft [string range $KAnswersLeft $FAMILYFEUDMarkerIDX end]
   incr FAMILYFEUDAnswerCount
  }
}

#
# Ask Question
#
proc FAMILYFEUDAskQuestion {} {
 global FAMILYFEUDRunning FAMILYFEUDQNumber FAMILYFEUDAllAnswered FAMILYFEUDRoundOver FAMILYFEUDQuestion
 global FAMILYFEUDPointsPerAnswer FAMILYFEUDPointsName FAMILYFEUDNumAnswered FAMILYFEUDAnswerCount
 global FAMILYFEUDQuestionTimer FAMILYFEUDQuestionTime FAMILYFEUDDisplayNum FAMILYFEUDForced FAMILYFEUDLastGuesser

 if {$FAMILYFEUDRunning != 1} {return}

 # Get The Current Scores
 read_FAMILYFEUDScore

 # Pick Next Question

 if {$FAMILYFEUDForced == 1} {
  FAMILYFEUDParseQuestion -1
  set FAMILYFEUDQNumber 0
  set FAMILYFEUDForced 0
  set FAMILYFEUDForcedQuestion ""
 } {
  set FAMILYFEUDQNumber [FAMILYFEUDPickQuestion]
  FAMILYFEUDParseQuestion $FAMILYFEUDQNumber
 }

 set FAMILYFEUDAllAnswered 0
 set FAMILYFEUDLastGuesser ""
 set FAMILYFEUDDisplayNum 0
 set FAMILYFEUDNumAnswered 0
 set FAMILYFEUDRoundOver 0

 # Choose Points Value For This Round
 set FAMILYFEUDPointsPerAnswer [rand 10]
 if {$FAMILYFEUDPointsPerAnswer < 1} {set FAMILYFEUDPointsPerAnswer 10}
 set FAMILYFEUDPointsPerAnswer [expr $FAMILYFEUDPointsPerAnswer * 10]

 set FAMILYFEUDPointTotal [expr $FAMILYFEUDPointsPerAnswer *$FAMILYFEUDAnswerCount]

 FAMILYFEUDmsg "\00303Family Feud Survey:\003 \00301$FAMILYFEUDQuestion\003 \00306\[\00310$FAMILYFEUDAnswerCount \00306Answers\]\003"
 FAMILYFEUDmsg "\00313$FAMILYFEUDPointsPerAnswer \00312Points \00301for each matching answer. \00310Total: \00313$FAMILYFEUDPointTotal Points"

 set KRemain [expr int([expr $FAMILYFEUDQuestionTime /2])]
 set FAMILYFEUDQuestionTimer [utimer $KRemain "FAMILYFEUDDisplayRemainingTime $KRemain"]
}

#
# Get Player Guess
#

proc FAMILYFEUDCheckGuess {nick uhost hand chan args} {
 global FAMILYFEUDChannel FAMILYFEUDRunning FAMILYFEUDScore FAMILYFEUDAnswerCount FAMILYFEUDAnswers FAMILYFEUDRoundOver
 global FAMILYFEUDPointsName FAMILYFEUDPointsPerAnswer FAMILYFEUDNumAnswered FAMILYFEUDAllAnswered FAMILYFEUDLastGuesser KDebug

 if {($chan != $FAMILYFEUDChannel)||($FAMILYFEUDRunning != 1)||($FAMILYFEUDRoundOver == 1)} {return}

 regsub -all \[{',.!}] $args "" args

 if {[string length args] == 0} {return}

 set FAMILYFEUDGuessOld $args
 set FAMILYFEUDGuess [string tolower $FAMILYFEUDGuessOld]

 if {$KDebug > 1} {FAMILYFEUDlog "FAMILYFEUD" "Guess: $nick $FAMILYFEUDGuess"}

 foreach z [array names FAMILYFEUDAnswers] {
  set FAMILYFEUDTry [lrange $FAMILYFEUDAnswers($z) 1 end] 
  set FAMILYFEUDTryOld $FAMILYFEUDTry

  regsub -all \[{',.!}] $FAMILYFEUDTry "" FAMILYFEUDTry

  set FAMILYFEUDTry [string tolower $FAMILYFEUDTry]
  if {$KDebug > 1} {FAMILYFEUDlog "FAMILYFEUD" "Try: $FAMILYFEUDTry"}

  if {$FAMILYFEUDTry == $FAMILYFEUDGuess} {
   if {[lindex $FAMILYFEUDAnswers($z) 0] == "#"} {
    set FAMILYFEUDAnswers($z) "$nick $FAMILYFEUDGuessOld"
    FAMILYFEUDmsg "[knikclr $nick]\00301 gets \00303$FAMILYFEUDPointsPerAnswer points \00301for the word \00310$FAMILYFEUDTryOld"
    incr FAMILYFEUDNumAnswered
    if {$FAMILYFEUDNumAnswered == $FAMILYFEUDAnswerCount} {
     set FAMILYFEUDAllAnswered 1
     set FAMILYFEUDRoundOver 1
     set FAMILYFEUDLastGuesser $nick
     FAMILYFEUDmsg "\00304You've Guessed Them All! Well Done!\003"
     FAMILYFEUD_ShowResults
     FAMILYFEUD_Recycle
    }
    return
   }
  }
 }
}

#
# Display Remaining Time And Answer Stats
#
proc FAMILYFEUDDisplayRemainingTime {remaining} {
 global FAMILYFEUDRunning FAMILYFEUDAllAnswered FAMILYFEUDNumAnswered FAMILYFEUDAnswerCount FAMILYFEUDQuestionTimer FAMILYFEUDQuestionTime FAMILYFEUDDisplayNum

 if {($FAMILYFEUDRunning != 1)||($FAMILYFEUDAllAnswered == 1)} {return}

 FAMILYFEUDmsg "\00306Matching answers: \00303$FAMILYFEUDNumAnswered \003from a possible \00304$FAMILYFEUDAnswerCount\003 answers, \00303$remaining\00301 secs remaining"

 incr FAMILYFEUDDisplayNum

 set KRemain [expr int([expr $FAMILYFEUDQuestionTime /4])]

 if {$FAMILYFEUDDisplayNum < 2} {
  set FAMILYFEUDQuestionTimer [utimer $KRemain "FAMILYFEUDDisplayRemainingTime $KRemain"]
 } {
  set FAMILYFEUDQuestionTimer [utimer $KRemain FAMILYFEUDTimesUp]
 }
}

#
# Show Results Of Round
#
proc FAMILYFEUDTimesUp {} {
 global FAMILYFEUDAnswers FAMILYFEUDAllAnswered FAMILYFEUDRoundOver FAMILYFEUDNumAnswered FAMILYFEUDAnswerCount FAMILYFEUDQuestionTimer FAMILYFEUDAdTimer

 if {$FAMILYFEUDAllAnswered == 1} { return 1}

 set FAMILYFEUDRoundOver 1

 set FAMILYFEUDmissed "\00304Time's Up!\003 "

 append KMissed "\00303FAMILY - FEUD Survery Says: \00312"

 set KAnswersRemaining [expr ($FAMILYFEUDAnswerCount - $FAMILYFEUDNumAnswered)]

 set kcount 0
 foreach z [array names FAMILYFEUDAnswers] {
  if {[lindex $FAMILYFEUDAnswers($z) 0] == "#"} {
   append KMissed "\00312[lrange $FAMILYFEUDAnswers($z) 1 end]"
   incr kcount
   if {$kcount < $KAnswersRemaining} {append KMissed " \00301| "}
  }
 }

 FAMILYFEUDmsg "$KMissed\003"

 FAMILYFEUD_ShowResults

 if {$FAMILYFEUDNumAnswered > 0} {
  FAMILYFEUDmsg "Total Number Answered Correctly: \00303$FAMILYFEUDNumAnswered\003 from a possible \00304$FAMILYFEUDAnswerCount! \003"
 } {
  FAMILYFEUDmsg "\00304Time's Up!\003 Nobody got a single Answer."
 }

 set FAMILYFEUDAdTimer [utimer 10 FAMILYFEUD_ShowAd]

 set FAMILYFEUDQuestionTimer [utimer 20 FAMILYFEUDAskQuestion]
}

#
# All Answers Gotten, Next Question
#
proc FAMILYFEUD_Recycle {} {
 global FAMILYFEUDAnswers FAMILYFEUDNumAnswered FAMILYFEUDQuestionTimer FAMILYFEUDAdTimer
 catch {killutimer $FAMILYFEUDQuestionTimer}
 if [info exists FAMILYFEUDAnswers] {unset FAMILYFEUDAnswers}
 set FAMILYFEUDAdTimer [utimer 10 FAMILYFEUD_ShowAd]
 set FAMILYFEUDQuestion ""
 set FAMILYFEUDNumAnswered 0
 set FAMILYFEUDQuestionTimer [utimer 20 FAMILYFEUDAskQuestion]
}

#
# Total Answers and Points
#
proc FAMILYFEUD_ShowResults {} {
 global FAMILYFEUDAnswers FAMILYFEUDPointsPerAnswer FAMILYFEUDPointsName FAMILYFEUDScore FAMILYFEUDAllAnswered FAMILYFEUDLastGuesser

 set NickCounter 0
 set FAMILYFEUDCounter 0

 if {$FAMILYFEUDAllAnswered == 1} {
  set FAMILYFEUDBonus [expr $FAMILYFEUDPointsPerAnswer *10]
  FAMILYFEUDmsg "[knikclr $FAMILYFEUDLastGuesser]\00306 gets \00313$FAMILYFEUDBonus \00312Bonus $FAMILYFEUDPointsName \00306For Getting The Final Answer!"
  set KNickTotals($FAMILYFEUDLastGuesser) $FAMILYFEUDBonus
  set KNickList($NickCounter) $FAMILYFEUDLastGuesser
  incr NickCounter
 }

 foreach z [array names FAMILYFEUDAnswers] {
  if {[lindex $FAMILYFEUDAnswers($z) 0] != "#"} {
   set cnick [lindex $FAMILYFEUDAnswers($z) 0]
   if {[info exists KNickTotals($cnick)]} {
    incr KNickTotals($cnick) $FAMILYFEUDPointsPerAnswer
   } {
    set KNickTotals($cnick) $FAMILYFEUDPointsPerAnswer
    set KNickList($NickCounter) $cnick
    incr NickCounter
   }
   incr FAMILYFEUDCounter
  }
 }

 if {$FAMILYFEUDCounter > 0} {
  set ncount 0
  set nicktotal "\00304$FAMILYFEUDPointsName This Round:\003"
  while {$ncount < $NickCounter} {
   set cnick $KNickList($ncount)
   if {[info exists FAMILYFEUDScore($cnick)]} {
     incr FAMILYFEUDScore($cnick) $KNickTotals($cnick)
   } {
     set FAMILYFEUDScore($cnick) $KNickTotals($cnick)
   }
   append nicktotal " \00303$cnick\003\00306 $KNickTotals($cnick)\003 "
   incr ncount
  }
  FAMILYFEUDmsg $nicktotal
  write_FAMILYFEUDScore
 }
}

#
# Read Scores
#
proc read_FAMILYFEUDScore { } {
 global FAMILYFEUDScore FAMILYFEUDScoreFile
 if [info exists FAMILYFEUDScore] { unset FAMILYFEUDScore }
 if {[file exists $FAMILYFEUDScoreFile]} {
  set f [open $FAMILYFEUDScoreFile r]
  while {[gets $f s] != -1} {
   set FAMILYFEUDScore([lindex $s 0]) [lindex $s 1]
  }
  close $f
  } {
   set f [open $FAMILYFEUDScoreFile w]
   puts $f "Nobody 0"
   close $f
  }
}

#
# Write Scores
#
proc write_FAMILYFEUDScore {} {
 global FAMILYFEUDScore FAMILYFEUDScoreFile
 set f [open $FAMILYFEUDScoreFile w]
 foreach s [lsort -decreasing -command sort_FAMILYFEUDScore [array names FAMILYFEUDScore]] {
  puts $f "$s $FAMILYFEUDScore($s)"
 }
 close $f
}

#
# Score Sorting
#
proc sort_FAMILYFEUDScore {s1 s2} {
 global FAMILYFEUDScore
 if {$FAMILYFEUDScore($s1) >  $FAMILYFEUDScore($s2)} {return 1}
 if {$FAMILYFEUDScore($s1) <  $FAMILYFEUDScore($s2)} {return -1}
 if {$FAMILYFEUDScore($s1) == $FAMILYFEUDScore($s2)} {return 0}
}

#
# Add Question Number To Asked File
#
proc FAMILYFEUD_AddAsked {KQnum} {
 global FAMILYFEUDAsked FAMILYFEUDAskedFile
 set f [open $FAMILYFEUDAskedFile a]
 puts $f $KQnum
 close $f
 lappend FAMILYFEUDAsked $KQnum
}

#
# Parse Asked Questions
#
proc FAMILYFEUD_ReadAskedFile {} {
 global FAMILYFEUDAsked FAMILYFEUDAskedFile
 set KAsked 0
 set FAMILYFEUDAsked ""
 if {![file exists $FAMILYFEUDAskedFile]} {
  set f [open $FAMILYFEUDAskedFile w]
 } {
  set f [open $FAMILYFEUDAskedFile r]
  while {[gets $f KQnum] != -1} {
   lappend FAMILYFEUDAsked "$KQnum"
   incr KAsked
  }
 }
 close $f
 return $KAsked
}

#
# Reset Asked File
#
proc FAMILYFEUD_ResetAsked {} {
 global FAMILYFEUDAskedFile FAMILYFEUDAsked
 set f [open $FAMILYFEUDAskedFile w]
 puts $f "0"
 close $f
 set FAMILYFEUDAsked ""
}

#
# Read Question File
#
proc FAMILYFEUD_ReadQuestionFile {} {
 global FAMILYFEUDQuestionFile FAMILYFEUDQuestions
 set KQuestions 0
 set f [open $FAMILYFEUDQuestionFile r]
 while {[gets $f q] != -1} {
  set FAMILYFEUDQuestions($KQuestions) $q
  incr KQuestions
 }
 close $f
 return $KQuestions
}

#
# Show Asked
#
proc FAMILYFEUD_ShowAsked {nick uhost hand chan args} {
 global FAMILYFEUDQCount FAMILYFEUDAsked FAMILYFEUDQuestions
 set FAMILYFEUDStatsAsked [llength $FAMILYFEUDAsked]
 set FAMILYFEUDStatsUnasked [expr ($FAMILYFEUDQCount - $FAMILYFEUDStatsAsked)]
 FAMILYFEUDmsg "[FAMILYFEUD][kcm] Total: [kcc] $FAMILYFEUDQCount [kcm] Asked: [kcc] $FAMILYFEUDStatsAsked [kcm] Remaining: [kcc] $FAMILYFEUDStatsUnasked \003"
}

#
# Repeat Question
#
proc FAMILYFEUD_Repeat {nick uhost hand chan args} {
 global FAMILYFEUDChannel FAMILYFEUDQuestion FAMILYFEUDRunning FAMILYFEUDQNumber FAMILYFEUDAllAnswered
 global FAMILYFEUDPointsName
 if {($chan != $FAMILYFEUDChannel)||($FAMILYFEUDRunning != 1)} {return}
 if {$FAMILYFEUDAllAnswered == 1} {return }
 FAMILYFEUDmsg "\00300,03 FAMILY FEUD - SURVEY SAYS: \00308,02 $FAMILYFEUDQuestion \003"
}

#
# Display User's Score
#
proc FAMILYFEUDPlayerScore {nick uhost hand chan args} {
 global FAMILYFEUDChannel FAMILYFEUDScoreFile FAMILYFEUDPointsName

 if {$chan != $FAMILYFEUDChannel} {return}

 regsub -all \[`,.!{}] $args "" args

 if {[string length $args] == 0} {set args $nick}

 set scorer [string tolower $args]

 set kflag 0

 set f [open $FAMILYFEUDScoreFile r]
 while {[gets $f sc] != -1} {
  set cnick [string tolower [lindex $sc 0]]
  if {$cnick == $scorer} {
   FAMILYFEUDmsg "[kcm] [lindex $sc 0] [kcc] [lindex $sc 1] $FAMILYFEUDPointsName \003"
   set kflag 1
  }
 }
 if {$kflag == 0} {FAMILYFEUDmsg "[kcm] $scorer [kcc] No Score \003"}
 close $f
}

#
# Display Top 10 Scores To A Player
#
proc FAMILYFEUDTop10 {nick uhost hand chan args} {
 global FAMILYFEUDChannel FAMILYFEUDScoreFile FAMILYFEUDPointsName
 if {$chan != $FAMILYFEUDChannel} {return}
 set KWinners "[kcr] Top10 $FAMILYFEUDPointsName \003"
 set f [open $FAMILYFEUDScoreFile r]
 for { set s 0 } { $s < 10 } { incr s } {
  gets $f FAMILYFEUDTotals
  if {[lindex $FAMILYFEUDTotals 1] > 0} {
   append KWinners " \00303#[expr $s +1] \00301[lindex $FAMILYFEUDTotals 0] [lindex $FAMILYFEUDTotals 1] "
  } {
   append KWinners " \00303#[expr $s +1] \00301Nobody 0 "
  }
 }
 FAMILYFEUDmsg "$KWinners"
 close $f
}

#
# Last Month's Top 3
#
proc FAMILYFEUDLastMonthTop3 {nick uhost hand chan args} {
 global FAMILYFEUDChannel FAMILYFEUDLastMonthScores
 if {$chan != $FAMILYFEUDChannel} {return}
 if [info exists FAMILYFEUDLastMonthScores] {
  set KWinners "[kcr] Last Month's FAMILYFEUD Top 3 \003"
  for { set s 0} { $s < 3 } { incr s} {
   append KWinners " \00303#[expr $s +1] \00301$FAMILYFEUDLastMonthScores($s) \00."
  }
  FAMILYFEUDmsg "$KWinners"
 }
}

#
# Read Config File
#
proc FAMILYFEUD_ReadCFG {} {
 global FAMILYFEUDCFGFile FAMILYFEUDChannel FAMILYFEUDAutoStart FAMILYFEUDScoreFile FAMILYFEUDAskedFile FAMILYFEUDQuestionFile FAMILYFEUDLastMonthScores FAMILYFEUDPointsName FAMILYFEUDAd
 if {[file exist $FAMILYFEUDCFGFile]} {
  set f [open $FAMILYFEUDCFGFile r]
  while {[gets $f s] != -1} {
   set kkey [string tolower [lindex [split $s "="] 0]]
   set kval [lindex [split $s "="] 1]
   switch $kkey {
    points { set FAMILYFEUDPointsName $kval }
    channel { set FAMILYFEUDChannel $kval }
    autostart { set FAMILYFEUDAutoStart $kval }
    scorefile { set FAMILYFEUDScoreFile $kval }
    askedfile { set FAMILYFEUDAskedFile $kval }
    FAMILYFEUDfile { set FAMILYFEUDQuestionFile $kval }
    ad1 { set FAMILYFEUDAd(0) $kval }
    ad2 { set FAMILYFEUDAd(1) $kval }
    ad3 { set FAMILYFEUDAd(2) $kval }
    lastmonth1 { set FAMILYFEUDLastMonthScores(0) $kval }
    lastmonth2 { set FAMILYFEUDLastMonthScores(1) $kval }
    lastmonth3 { set FAMILYFEUDLastMonthScores(2) $kval }
   }
  }
  close $f
  if {($FAMILYFEUDAutoStart < 0)||($FAMILYFEUDAutoStart > 1)} {set FAMILYFEUDAutoStart 1}
  return
 }
 FAMILYFEUDlog "FAMILYFEUD" "Config file $FAMILYFEUDCFGFile not found... using defaults"
}

#
# Write Config File
#
proc FAMILYFEUD_WriteCFG {} {
 global FAMILYFEUDCFGFile FAMILYFEUDChannel FAMILYFEUDAutoStart FAMILYFEUDScoreFile FAMILYFEUDAskedFile FAMILYFEUDQuestionFile FAMILYFEUDLastMonthScores FAMILYFEUDPointsName FAMILYFEUDAd
 set f [open $FAMILYFEUDCFGFile w]
 puts $f "# This file is automatically overwritten"
 puts $f "Points=$FAMILYFEUDPointsName"
 puts $f "Channel=$FAMILYFEUDChannel"
 puts $f "AutoStart=$FAMILYFEUDAutoStart"
 puts $f "ScoreFile=$FAMILYFEUDScoreFile"
 puts $f "AskedFile=$FAMILYFEUDAskedFile"
 puts $f "FAMILYFEUDFile=$FAMILYFEUDQuestionFile"
 puts $f "LastMonth1=$FAMILYFEUDLastMonthScores(0)"
 puts $f "LastMonth2=$FAMILYFEUDLastMonthScores(1)"
 puts $f "LastMonth3=$FAMILYFEUDLastMonthScores(2)"
 puts $f "Ad1=$FAMILYFEUDAd(0)"
 puts $f "Ad2=$FAMILYFEUDAd(1)"
 puts $f "Ad3=$FAMILYFEUDAd(2)"
 close $f
}

#
# Clear Month's Top 10
#
proc FAMILYFEUD_NewMonth {min hour day month year} {
 global FAMILYFEUDScoreFile FAMILYFEUDScore FAMILYFEUDLastMonthScores

 set cmonth [expr $month +1]
 set lmonth [FAMILYFEUDLastMonthName $cmonth]

 FAMILYFEUDmsg "\00304Clearing Monthly Scores \003"

 set FAMILYFEUDMonthFileName "$FAMILYFEUDScoreFile.$lmonth"

 set f [open $FAMILYFEUDMonthFileName w]
 set s 0
 foreach n [lsort -decreasing -command sort_FAMILYFEUDScore [array names FAMILYFEUDScore]] {
  puts $f "$n $FAMILYFEUDScore($n)"
  if {$s < 3} {
   if {$FAMILYFEUDScore($n) > 0} {
    set FAMILYFEUDLastMonthScores($s) "$n $FAMILYFEUDScore($n)"
   } {
    set FAMILYFEUDLastMonthScores($s) "Nobody 0"
   }
  }
  incr s
 }
 close $f

 FAMILYFEUD_WriteCFG

 if [info exists FAMILYFEUDScore] {unset FAMILYFEUDScore}

 set f [open $FAMILYFEUDScoreFile w]
 puts $f "Nobody 0"
 close $f

 putcmdlog "\[FAMILY FEUD\] Cleared Monthly Top10 Scores: $FAMILYFEUDMonthFileName"
}

#
# Command Help
#
proc FAMILYFEUDCmds {nick uhost hand chan args} {
 global FAMILYFEUDChannel
 if {$chan != $FAMILYFEUDChannel} {return}
 FAMILYFEUDntc $nick "FAMILY FEUD Commands: !familyfeud !famstop !famtop !famtoplast !famwon \[nick\] !famrepeat !asked"
}

#
# Color Routines
#
proc kcb {} {
 return "\0038,2"
}
proc kcg {} {
 return "\0030,3"
}
proc kcr {} {
 return "\0030,4"
}
proc kcm {} {
 return "\0030,6"
}
proc kcc {} {
 return "\0030,10"
}
proc kcs {} {
 return "\0030,12"
}
proc FAMILYFEUD {} {
 return "[kcr] FAMILY-FEUD \003"
}

# Channel Message
proc FAMILYFEUDmsg {what} {
 global FAMILYFEUDChannel
 putquick "PRIVMSG $FAMILYFEUDChannel :$what"
}

# Notice Message
proc FAMILYFEUDntc {who what} {
 putquick "NOTICE $who :$what"
}
# Command Log
proc FAMILYFEUDlog {who what} {
 putcmdlog "\[$who\] $what"
}

# Name Of Last Month
proc FAMILYFEUDLastMonthName {month} {
 switch $month {
  1 {return "Dec"}
  2 {return "Jan"}
  3 {return "Feb"}
  4 {return "Mar"}
  5 {return "Apr"}
  6 {return "May"}
  7 {return "Jun"}
  8 {return "Jul"}
  9 {return "Aug"}
  10 {return "Sep"}
  11 {return "Oct"}
  12 {return "Nov"}
  default {return "???"}
 }
}

# Assign Nickname Color
proc knikclr {nick} {
  set nicklen [strlen $nick]
  set nicktot 0
  set c 0
  while {$c < $nicklen} {
   binary scan [string range $nick $c $c] c nv
   incr nicktot [expr $nv -32]
   incr c
  }
  set nickclr [expr $nicktot %13]
  switch $nickclr {
   0 {set nickclr 10}
   1 {set nickclr 11}
   2 {set nickclr 12}
   5 {set nickclr 13}
  }
  set nik [format "%02d" $nickclr]
  return "\003$nik$nick"
}

#
# Show Ad
#
proc FAMILYFEUD_ShowAd {} {
 global FAMILYFEUDAdNumber FAMILYFEUDAd botnick FAMILYFEUDChannel
 switch $FAMILYFEUDAdNumber {
  0 { FAMILYFEUDmsg "\00305$FAMILYFEUDAd(0)\003" }
  1 { FAMILYFEUDTop10 $botnick none none $FAMILYFEUDChannel none }
  2 { FAMILYFEUDmsg "\00305$FAMILYFEUDAd(1)\003" }
  3 { FAMILYFEUDLastMonthTop3 $botnick none none $FAMILYFEUDChannel none }
  4 { FAMILYFEUDmsg "\00305$FAMILYFEUDAd(2)\003" }
 }
 incr FAMILYFEUDAdNumber
 if {$FAMILYFEUDAdNumber > 4} {set FAMILYFEUDAdNumber 0}
}

#
# Rehash FAMILYFEUD Config
#
proc dcc_FAMILYFEUDrehash {hand idx arg} {
 global FAMILYFEUDQCount

 putcmdlog "#$hand# Rehashing FAMILYFEUD config"

 FAMILYFEUD_ReadCFG

 set FAMILYFEUDQCount [FAMILYFEUD_ReadQuestionFile]

 if {$FAMILYFEUDQCount < 2} {
   FAMILYFEUDlog "FAMILYFEUD" "Not Enough Questions in Question File $FAMILYFEUDQuestionFile"
   return 0
 }

 set FAMILYFEUDAskedFileLen [FAMILYFEUD_ReadAskedFile]

 if {$FAMILYFEUDAskedFileLen >= $FAMILYFEUDQCount} {
   FAMILYFEUDlog "FAMILYFEUD" "Asked file out of sync with question database: resetting"
   FAMILYFEUD_ResetAsked
   return 0
 }
 FAMILYFEUDlog "FAMILYFEUD" "Questions:$FAMILYFEUDQCount Asked:$FAMILYFEUDAskedFileLen Remaining:[expr ($FAMILYFEUDQCount - $FAMILYFEUDAskedFileLen)]"
}

#
# Show Current Answers
#
proc dcc_FAMILYFEUDanswer {hand idx arg} {
 global FAMILYFEUDAnswers
 set ans ""
 foreach z [array names FAMILYFEUDAnswers] {
  if {[lindex $FAMILYFEUDAnswers($z) 0] == "#"} {
   append ans "[lrange $FAMILYFEUDAnswers($z) 1 end] | "
  }
 }
 FAMILYFEUDlog "FAMILYFEUD" $ans
}

#
# Reset Asked File
#
proc dcc_FAMILYFEUDresetasked {hand idx arg} {
 FAMILYFEUD_ResetAsked
 FAMILYFEUDlog "FAMILYFEUD" "#$hand# Reset Asked File"
}

#
# Show Asked
#
proc dcc_FAMILYFEUDshowasked {hand idx arg} {
 global FAMILYFEUDQCount FAMILYFEUDAsked FAMILYFEUDQuestions
 set FAMILYFEUDStatsAsked [llength $FAMILYFEUDAsked]
 set FAMILYFEUDStatsUnasked [expr ($FAMILYFEUDQCount - $FAMILYFEUDStatsAsked)]
 FAMILYFEUDlog "FAMILYFEUD" "Total:$FAMILYFEUDQCount  Asked:$FAMILYFEUDStatsAsked  Remaining:$FAMILYFEUDStatsUnasked"
}

#
# Force A Question
#
proc dcc_FAMILYFEUDforce {hand idx arg} {
 global FAMILYFEUDRunning FAMILYFEUDMarker FAMILYFEUDForced FAMILYFEUDForcedQuestion
 if {$FAMILYFEUDRunning != 1} {return}
 regsub -all \[`,.!{}] $arg "" arg
 if {$arg == ""} {return}
 set FAMILYFEUDMarkerIDX [string first $FAMILYFEUDMarker $arg]
 if {$FAMILYFEUDMarkerIDX < 2} {
  FAMILYFEUDlog "FAMILYFEUD" "Malformed question: Format: Question*Answer1*Answer2..."
  return
 }
 set FAMILYFEUDForcedQuestion $arg
 set FAMILYFEUDForced 1
 FAMILYFEUDlog "FAMILYFEUD" "Forcing A Question Next Round"
}

FAMILYFEUD_ReadCFG

putcmdlog "Loaded FAMILYFEUD $FAMILYFEUDVersion modified by MABROOK"
