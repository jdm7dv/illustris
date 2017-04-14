;$Id: //depot/idl/IDL_70/idldir/external/call_external/C/astructure__define.pro#2 $
;
; Copyright (c) 1998-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;

;+
; NAME:
;	ASTRUCTURE__DEFINE
;
; PURPOSE:
;	Define the ASTRUCTURE structure definition, which is used by
;	INCR_STRUCT to demonstrate passing structures to external code.
;
; CATEGORY:
;	Dynamic Linking Examples
;
; CALLING SEQUENCE
;	ASTRUCTURE__DEFINE
;
; INPUTS:
;	None
;
; OUTPUTS:
;	None
;
; KEYWORDS:
;	None
;
; SIDE EFFECTS
;	Named structure ASTRUCTURE exists within the IDL session.
;
; RESTRICTIONS
;	None.
;
; PROCEDURE:
;	Implicitly called by IDL when it attempts to create the first
;	ASTRUCTURE strucuture.
;
; Modification History:
;	BMH, 19 October 1998
;	AB, 11 April 2002, Updated for MAKE_DLL and general cleanup
;-

PRO astructure__define
  ; This must be an exact match for the C structure definition.

  s =  { ASTRUCTURE, zero:0B, one:0L, two:0.0, three:0.0D, four:[0,0] }
END
