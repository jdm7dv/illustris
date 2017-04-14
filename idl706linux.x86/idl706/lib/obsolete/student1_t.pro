; $Id: //depot/idl/IDL_70/idldir/lib/obsolete/student1_t.pro#2 $
;
;  Copyright (c) 1991-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.


function student1_t ,X, DF
;+
; NAME:
;	STUDENT1_T
;
; PURPOSE: 
;	STUDENT1_T returns the probability that an observed value from the
;	Student's t distribution with DF degrees of freedom is less than |X|.
;
; CATEGORY:
;	Statistics.
;
; CALLING SEQUENCE:
;	Result = STUDENT1_T(X, DF)
;
; INPUTS:
;	X:	Cutoff.
;
;	DF:	Degrees of freedom.
;
; OUTPUT:
;       The probability of |X| or something smaller.
;
;-


    if DF lt 0 THEN BEGIN
       print,'student1_t - degrees of freedom'
       print, ' must be larger than 0.'
       return,-1
    ENDIF
    return, 1 - .5*betai (DF/(DF + X^2), DF/2.0, .5) 
    end 

