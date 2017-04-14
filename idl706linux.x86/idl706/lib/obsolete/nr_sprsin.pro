; $Id: //depot/idl/IDL_70/idldir/lib/obsolete/nr_sprsin.pro#2 $
;
; Copyright (c) 1994-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;+
; NAME:
;	NR_SPRSIN
;
; PURPOSE:
;
;	NR_SPRSIN now executes SPRSIN, the updated version of this routine. 
;       SPRSIN has been modified to accept row vectors as the default input 
;	and column vectors with use of the COLUMN keyword.  This routine
;	preserves the input of column vectors.
;
; MODIFICATION HISTORY:
; 	Written by: 	BMH Nov, 1994	
;
;-
FUNCTION NR_SPRSIN, a, DOUBLE=double, THRESH=thresh

  IF NOT KEYWORD_SET(double) THEN  double = 0 
  IF NOT KEYWORD_SET(thresh) THEN  thresh = 0 

  result = SPRSIN(a, DOUBLE=double, THRESH=thresh, /COLUMN)

  RETURN, result

END
