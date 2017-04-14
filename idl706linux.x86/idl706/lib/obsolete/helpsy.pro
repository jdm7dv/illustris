; $Id: //depot/idl/IDL_70/idldir/lib/obsolete/helpsy.pro#2 $
;
; Copyright (c) 1990-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.

pro HELPSY
;+
; NAME:
;	HELPSY
;
; PURPOSE:
;	HELPSY prints the values of all of the system variables.
;	This procedure was built-in under version 1 VMS
;	IDL, and is provided in this form to help users of that version
;	adapt to version 2.
;
; CALLING SEQUENCE:
;	HELPSY
;
; INPUT:
;	None.
;
; OUTPUT:
;	The the values of all of the system variables are printed.
;
; RESTRICTIONS:
;	None.
;
; REVISION HISTORY:
;	10 January 1990
;-
on_error,2                        ;Return to caller if an error occurs
HELP, /SYSTEM_VARIABLES
end
