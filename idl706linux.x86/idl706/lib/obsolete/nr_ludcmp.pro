; $Id: //depot/idl/IDL_70/idldir/lib/obsolete/nr_ludcmp.pro#2 $
;
; Copyright (c) 1994-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;+
; NAME:
;	NR_LUDCMP
;
; PURPOSE:
;
;	NR_LUDCMP now executes LUDC, the updated version of this routine. 
;       LUDC has been modified to accept row vectors as the default input 
;	and column vectors with use of the COLUMN keyword.  This routine
;	preserves the input of column vectors.
;
; MODIFICATION HISTORY:
; 	Written by: 	BMH Nov, 1994	
;
;-
PRO NR_LUDCMP, a, index, DOUBLE=double, INTERCHANGES=interchanges

  IF NOT KEYWORD_SET(double) THEN  double = 0
  IF NOT KEYWORD_SET(interchanges) THEN interchanges = 0

  LUDC, a, index, DOUBLE=double, INTERCHANGES=interchanges, /COLUMN

END
