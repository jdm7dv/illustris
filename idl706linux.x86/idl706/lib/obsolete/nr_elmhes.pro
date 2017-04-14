; $Id: //depot/idl/IDL_70/idldir/lib/obsolete/nr_elmhes.pro#2 $
;
; Copyright (c) 1994-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;+
; NAME:
;	NR_ELMHES
;
; PURPOSE:
;
;	NR_ELMHES now executes ELMHES, the updated version of this routine. 
;       ELMHES has been modified to accept row vectors as the default input 
;	and column vectors with use of the COLUMN keyword.  This routine
;	preserves the input of column vectors.
;
; MODIFICATION HISTORY:
; 	Written by: 	BMH Nov, 1994	
;
;-
FUNCTION NR_ELMHES, a, DOUBLE=double, NO_BALANCE=no_balance

  IF NOT KEYWORD_SET(double) THEN double = 0 
  IF NOT KEYWORD_SET(no_balance) THEN no_balance = 0 

  result = ELMHES(a, DOUBLE=double, NO_BALANCE=no_balance, /COLUMN)
  RETURN, result

END
