; $Id: //depot/idl/IDL_70/idldir/lib/obsolete/nr_lubksb.pro#2 $
;
; Copyright (c) 1994-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;+
; NAME:
;	NR_LUBKSB
;
; PURPOSE:
;
;	NR_LUBKSB now executes LUBKSB, the updated version of this routine. 
;       LUBKSB has been modified to accept row vectors as the default input 
;	and column vectors with use of the COLUMN keyword.  This routine
;	preserves the input of column vectors.
;
;-
FUNCTION NR_LUBKSB, a, index, b, DOUBLE=double

  IF NOT KEYWORD_SET(double) THEN  double = 0 

  result = LUSOL(a, index, b, DOUBLE=double, /COLUMN)

  RETURN, result

END
