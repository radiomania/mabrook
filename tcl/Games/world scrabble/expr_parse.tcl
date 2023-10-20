# Expression parser in Tcl.
# Copyright (C) 2005 Salvatore Sanfilippo

# This list represents the operators.
# is composed of groups of three elements:
# The operator name, precedente, arity.
#
# Adapted for eggdrop usage

namespace eval ::games::countdown::expr {
	variable ExprOperators {
		"!" 300 1
		"~" 300 1
		"unary_minus" 300 1
		"unary_plus" 300 1
		"*" 200 2
		"/" 200 2
		"-" 100 2
		"+" 100 2
		"&&" 10 2
		"||" 10 2
	}

	proc ExprOperatorPrecedence op {
		variable ExprOperators
		
		foreach { name prec arity } $ExprOperators {
			if { $name eq $op } { return $prec }
		}
		
		return -1
	}

	proc ExprOperatorArity op {
		variable ExprOperators
		
		foreach { name prec arity } $ExprOperators {
			if { $name eq $op } { return $arity }
		}
		
		return -1
	}

	proc ExprIsOperator op {
		expr {[ExprOperatorPrecedence $op] != -1}
	}

	proc ExprGetToken exprVar {
		upvar 1 $exprVar expression
		set expression [string trim $expression]
	
		if { [regexp {(^[0-9]+)(.*)} $expression -> tok exprRest] } {
			set res [list operand $tok]
			set expression $exprRest
     	} elseif { [ExprIsOperator [string range $expression 0 1]] } {
			set res [list operator [string range $expression 0 1]]
			set expression [string range $expression 2 end]
     	} elseif { [ExprIsOperator [string index $expression 0]] } {
			set res [list operator [string index $expression 0]]
			set expression [string range $expression 1 end]
     	} elseif { [string index $expression 0] eq "(" } {
			set res [list substart {}]
			set expression [string range $expression 1 end]
		} elseif { [string index $expression 0] eq ")" } {
			set res [list subend {}]
			set expression [string range $expression 1 end]
		} else {
			return -code error \
				"default reached in ExprGetToken. String: '$expression'"
		}
     
		return $res
	}

	proc ExprTokenize expression {
		set tokens {}

		while {[string length [string trim $expression]]} {
			lappend tokens [ExprGetToken expression]
		}

		# Post-processing stage. Turns "-" into "unary_minus"
		# when - is used as unary minus. The same with unary +.
		for { set i 0 } { $i < [llength $tokens] } { incr i } {
			if {[lindex $tokens $i 0] eq {operator} && \
					([lindex $tokens $i 1] eq {-} || \
					[lindex $tokens $i 1] eq {+}) && \
					([lindex $tokens [expr $i-1] 0] eq {operator} || $i == 0)} \
			{
				switch -- [lindex $tokens $i 1] {
					- {lset tokens $i 1 "unary_minus"}
					+ {lset tokens $i 1 "unary_plus"}
				}
			}
		}
     
		return $tokens
	}

	proc ExprPop listVar {
		upvar 1 $listVar list
		set ele [lindex $list end]
		set list [lindex [list [lrange $list 0 end-1] [set list {}]] 0]
		return $ele
	}

	proc ExprPush {listVar element} {
		upvar 1 $listVar list
		lappend list $element
	}

	proc ExprPeek listVar {
		upvar 1 $listVar list
		lindex $list end
	}

	proc ExprTokensToRPN tokens {
		set rpn {}
		set stack {}
		
		foreach t $tokens {
			foreach { type token } $t {}
			
			if { $type eq {operand} } {
				ExprPush rpn $token
			} elseif { $type eq {operator} } {
				while { [llength $stack] && \
					[ExprOperatorArity $token] != 1 &&
					[ExprOperatorPrecedence [ExprPeek stack]] >= \
					[ExprOperatorPrecedence $token] } \
				{
					ExprPush rpn [ExprPop stack]
				}
				
				ExprPush stack $token
			} elseif { $type eq {substart} } {
				ExprPush stack "("
			} elseif { $type eq {subend} } {
				while 1 {
					set op [ExprPop stack]
					
					if { $op eq "(" } break
					ExprPush rpn $op
				}
			}
		}

	 	while {[llength $stack]} {
		 	ExprPush rpn [ExprPop stack]
     	}
		
	 	return $rpn
	}

	proc ExprToRpn expression {
		set tokens [ExprTokenize $expression]
		ExprTokensToRPN $tokens
	}

	proc ExprRpnToTcl rpn {
		set stack {}
		
		foreach item $rpn {
			if { [ExprIsOperator $item] } {
				set arity [ExprOperatorArity $item]
				set operators [lrange $stack end-[expr {$arity-1}] end]
				set stack [lrange $stack 0 end-$arity]
	    		while { $arity } { ExprPop rpn; incr arity -1 }
				set item "$item "
				foreach operator $operators {
					append item "$operator "
				}
				set item [string range $item 0 end-1]
				ExprPush stack "\[$item\]"
			} else {
				ExprPush stack $item
			}
		}
     
		return [lindex $stack 0]
	}
 
	proc ExprConv { e } {
		 return [ExprRpnToTcl [ExprToRpn $e]]
	}

	proc ExprTest {} {
		set expressions {
			{1+2*3}
			{1*2+3}
			{((1*(2+3)*4)+5)*2}
			{-1+5}
			{4-+5}
			{2*0-1+5}
			{1+2*3+4*5+6}
			{(1+2 || 3+4) && 10}
			{!!!3+4}
		}
	
		foreach e $expressions {
			set rpn [ExprToRpn $e]
			set tcl [ExprRpnToTcl $rpn]
			putlog "Exp: $e"
			putlog "Rpn: $rpn"
			putlog "Tcl: $tcl"
			putlog {}
		}
	}
}
