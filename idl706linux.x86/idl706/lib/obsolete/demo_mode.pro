; $Id: //depot/idl/IDL_70/idldir/lib/obsolete/demo_mode.pro#2 $
;
; Copyright (c) 1991-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;
; NOTE:  This routine has been made obsolete because it has been replaced
;        by LMGR(/DEMO).
;
; NAME:
;	DEMO_MODE
;
; PURPOSE:
;	Returns true if IDL is in Demo Mode.
;
; CALLING SEQUENCE:
;	Result = DEMO_MODE()
;
; OUTPUTS:
;	Returns 1 if IDL is in Demo Mode and 0 otherwise.
;
; SIDE EFFECTS:
;	Does a FLUSH, -1.
;
; PROCEDURE:
;	Do a FLUSH, -1 and trap the error message.
;
; MODIFICATION HISTORY:
;	Written by SMR, Feb. 1991
;	KDB Oct,1993: The error string had an extra ' ' in it and
;		      the function would always return 0.
;-

FUNCTION DEMO_MODE

!err=0
FLUSH, -1
return, ((!err ne 0) and $
    (!ERR_STRING EQ 'FLUSH: Feature disabled for demo mode.'))

END
