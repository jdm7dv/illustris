; $Id: //depot/idl/IDL_70/idldir/lib/cdf_exists.pro#2 $
;
;
; Copyright (c) 1992-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
; NAME:
;	CDF_EXISTS
;
; PURPOSE:
;	Test for the existence of the CDF library
;
; CATEGORY:
;	File Formats
;
; CALLING SEQUENCE:
;	Result = CDF_EXISTS()
;
; INPUTS:
;	None.
;
; KEYWORD PARAMETERS:
;	None.
;
; OUTPUTS:
;	Returns TRUE (1) if the CDF data format library is
;	supported. Returns FALSE(0) if it is not.
;
; EXAMPLE:
;	IF cdf_exists() EQ 0 THEN Fail,"CDF not supported on this machine"
;
; MODIFICATION HISTORY
;	Written by:	Joshua Goldstein,  12/8/92
;
;-

;	A fake function if libraries don't exist
FUNCTION cdf_inquire,x
	return,0
END

;
FUNCTION cdf_exists

	on_ioerror, ok
	oldquiet= !quiet
	!quiet=1

	x=cdf_inquire(0)
	!quiet=oldquiet
	return,0

   ok:
	!quiet=oldquiet
	return,1
END
