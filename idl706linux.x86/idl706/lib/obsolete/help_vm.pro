; $Id: //depot/idl/IDL_70/idldir/lib/obsolete/help_vm.pro#2 $
;
; Copyright (c) 1990-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.

pro HELP_VM
;+
; NAME:
;	HELP_VM
;
; PURPOSE:
;	HELP_VM prints the amount of virtual memory currently allocated.
;	This procedure was built-in under version 1 VMS
;	IDL, and is provided in this form to help users of that version
;	adapt to version 2.
;
; CALLING SEQUENCE:
;	HELP_VM
;
; INPUT:
;	None.
;
; OUTPUT:
;	Information about current memory usage is printed.
;
; RESTRICTIONS:
;	None.
;
; REVISION HISTORY:
;	10 January 1990
;-
on_error,2                        ;Return to caller if an error occurs
HELP, /MEMORY
end
