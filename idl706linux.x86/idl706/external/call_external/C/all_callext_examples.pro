;
; $Id: //depot/idl/IDL_70/idldir/external/call_external/C/all_callext_examples.pro#2 $
;
; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;

;+
; NAME:
;	ALL_CALLEXT_EXAMPLES
;
; PURPOSE:
;	Run all of the CALL_EXTERNAL examples.
;
; CATEGORY:
;	Dynamic Linking Examples
;
; CALLING SEQUENCE
;	ALL_CALLEXT_EXAMPLES
;
; INPUTS:
;	None
;
; OUTPUTS:
;	None
;
; KEYWORDS:
;       DEBUG
;	If this keyword is unset, this routine will return to the
;	caller on any error. If this keyword is set, this routine will
;	stop at the point of the error.
;
;	VERBOSE
;	If set, cause the underlying MAKE_DLL to show the commands it
;	executes to build the sharable library, and all of the output
;	produced by those commands. If not set, this routine does its
;	work silently.
;
; SIDE EFFECTS
;	ASTRUCTURE structure definition in defined.
;	Sharable library of example code is built.
;
; RESTRICTIONS
;	None.
;
; PROCEDURE:
;	Calls each of the CALL_EXTERNAL demos, relying on their default
;	cases to provide data. Each of these demos uses GET_CALLEXT_EXLIB
;	to build the sharable library of example, and uses CALL_EXTERNAL
;	to call that sharable code.
;
; Modification History:
;	AB, 11 April 2002
;-

pro ALL_CALLEXT_EXAMPLES, _ref_extra=extra

  simple_vars,  _STRICT_EXTRA=extra
  incr_struct,  _STRICT_EXTRA=extra
  string_array, _STRICT_EXTRA=extra
  sum_array,    _STRICT_EXTRA=extra
  sum_2d_array, _STRICT_EXTRA=extra
end
