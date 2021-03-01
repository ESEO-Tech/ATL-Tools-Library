#!/bin/sh

sed -rne '
	/with/{
		h
		:a
			n
			H
			/^	}$/{
				g
				s/with \{(.*)	\}/\1/
				s/(.*)/,constraints : Constraints!ConstraintGroup (\
	constraints <- Sequence {\1	}\
)/
				s/^/		/Mg
				
				p
				b
			}
		ba
	}
	p
' "$1"

