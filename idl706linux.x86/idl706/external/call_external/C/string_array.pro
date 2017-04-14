;$Id: //depot/idl/IDL_70/idldir/external/call_external/C/string_array.pro#2 $
;
; Copyright (c) 1998-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;

;+
; NAME:
;	STRING_ARRAY
;
; PURPOSE:
; 	This IDL procedure calls a CALL_EXTERNAL routine which demonstrates
;       how to pass strings into external code. This code:
;       1) implements a simple interface to the external code.
;       2) check the type of arguments that will be passed to the external code
;
; CATEGORY:
;	Dynamic Linking Examples
;
; CALLING SEQUENCE
;	STRING_ARRAY
;       STRING_ARRAY, 'hello'
;       STRING_ARRAY, ['one', 'two', 'three']
;
; INPUTS:
;	STRARR
;	A scalar string  or array of strings. If the input is not
;;      of type string, a conversion will be attempted.
;	S_ARR
;	An array of structures of type "ASTRUCTURE". The structure
;       defintion must match the one given in astructure__define.pro
;
; OUTPUTS:
;	Returns a string value from the external C function.
;
; KEYWORDS:
;	AUTO_GLUE
;	Use the AUTO_GLUE keyword to CALL_EXTERNAL to call a version of
;	the external C function that has a natural C interface rather
;	than the IDL portable calling convension (argc, argv).
;
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
;	Sharable library of example code is built.
;
; RESTRICTIONS
;	None.
;
; PROCEDURE:
;	Use GET_CALLEXT_EXLIB to build the sharable library of example
;	code, and use CALL_EXTERNAL to call string_array().
;
; Modification History:
;	Written May, 1998 JJG
;	AB, 11 April 2002, Updated for MAKE_DLL and general cleanup
;-

PRO string_array, strarr, AUTO_GLUE=auto_glue, DEBUG=debug, VERBOSE=verbose

   IF NOT(KEYWORD_SET(debug)) THEN ON_ERROR,2

   strarr_l = (SIZE(/TNAME,strarr) EQ 'UNDEFINED') ? $
	['a','bb','ccc','d'] : STRING(strarr)

   PRINT,'Calling string_array with:'
   HELP, strarr_l
   PRINT, format='(a)', strarr_l

   func = keyword_set(auto_glue) ? 'string_array_natural' : 'string_array'
   result = CALL_EXTERNAL(GET_CALLEXT_EXLIB(VERBOSE=verbose), func, $
                          strarr_l, N_ELEMENTS(strarr_l), $
			  VALUE=[0,1], /S_VALUE, /CDECL, AUTO_GLUE=auto_glue, $
			  VERBOSE=verbose, SHOW_ALL_OUTPUT=verbose)

   PRINT,'Result from string_array is:'
   HELP, result
end
